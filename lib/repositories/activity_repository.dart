import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity_model.dart';

class ActivityRepository {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<ActivityModel>> getActivities({String? branchId, int limit = 20}) async {
    List<ActivityModel> list = [];
    try {
      final supabase = _supabase;
      if (supabase != null) {
        var query = supabase.from('audit_logs').select();
        if (branchId != null && branchId.isNotEmpty) {
          query = query.eq('branch_id', branchId);
        }
        final response = await query.order('created_at', ascending: false).limit(limit);
        if (response != null && (response as List).isNotEmpty) {
          final List<ActivityModel> mappedList = [];
          for (final rawItem in (response as List)) {
            final map = rawItem as Map<String, dynamic>;
            mappedList.add(ActivityModel(
              id: (map['id'] ?? '').toString(),
              actorId: (map['actor_id'] ?? '').toString(),
              actorName: (map['actor_name'] ?? 'System User').toString(),
              action: (map['action_type'] ?? 'ACTIVITY').toString(),
              entityType: (map['target_entity_type'] ?? 'Entity').toString(),
              entityId: (map['target_entity_id'] ?? '').toString(),
              description: (map['description'] ?? '').toString(),
              branchId: (map['branch_id'] ?? 'branch_dar').toString(),
              createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
            ));
          }
          list = mappedList;
        }
      }
    } catch (_) {}


    return list;
  }

  Stream<List<ActivityModel>> getActivitiesStream({String? branchId, int limit = 100}) {
    final supabase = _supabase;
    if (supabase == null) return Stream.value([]);

    var stream = supabase.from('audit_logs').stream(primaryKey: ['id']).order('created_at', ascending: false).limit(limit);

    return stream.map((event) {
      var filtered = event;
      if (branchId != null && branchId.isNotEmpty) {
        filtered = event.where((map) => map['branch_id'] == branchId).toList();
      }
      return filtered.map((map) {
        return ActivityModel(
          id: (map['id'] ?? '').toString(),
          actorId: (map['actor_id'] ?? '').toString(),
          actorName: (map['actor_name'] ?? 'System User').toString(),
          action: (map['action_type'] ?? 'ACTIVITY').toString(),
          entityType: (map['target_entity_type'] ?? 'Entity').toString(),
          entityId: (map['target_entity_id'] ?? '').toString(),
          description: (map['description'] ?? '').toString(),
          branchId: (map['branch_id'] ?? 'branch_dar').toString(),
          createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
        );
      }).toList();
    });
  }

  Future<void> logActivity(ActivityModel activity) async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        await supabase.from('audit_logs').insert({
          'actor_id': activity.actorId,
          'actor_name': activity.actorName,
          'action_type': activity.action,
          'target_entity_type': activity.entityType,
          'target_entity_id': activity.entityId,
          'description': activity.description,
          'branch_id': activity.branchId.isNotEmpty ? activity.branchId : 'branch_dar',
        });
      }
    } catch (_) {}
  }
}
