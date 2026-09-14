import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/survey_task_model.dart';
import 'seed_data.dart';

class SurveyRepository {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<SurveyTaskModel>> getSurveyTasks({String? branchId, String? surveyorId}) async {
    List<SurveyTaskModel> list = [];
    try {
      final supabase = _supabase;
      if (supabase != null) {
        var query = supabase.from('land_processing_stages').select();
        if (branchId != null && branchId.isNotEmpty) {
          query = query.eq('branch_id', branchId);
        }
        if (surveyorId != null && surveyorId.isNotEmpty) {
          query = query.eq('assigned_surveyor_id', surveyorId);
        }
        final response = await query;
        if (response != null && (response as List).isNotEmpty) {
          final List<SurveyTaskModel> mappedList = [];
          for (final rawItem in (response as List)) {
            final map = rawItem as Map<String, dynamic>;
            mappedList.add(SurveyTaskModel(
              id: (map['id'] ?? '').toString(),
              propertyId: (map['plot_id'] ?? '').toString(),
              surveyorId: (map['assigned_surveyor_id'] ?? '').toString(),
              branchId: (map['branch_id'] ?? 'branch_dar').toString(),
              status: (map['stage_status'] ?? 'IN_PROGRESS').toString(),
              deadline: map['deadline'] != null ? DateTime.tryParse(map['deadline'].toString()) ?? DateTime.now().add(const Duration(days: 14)) : DateTime.now().add(const Duration(days: 14)),
              notes: (map['notes'] ?? '').toString(),
              documents: (map['documents'] as List?)?.map((e) => e.toString()).toList() ?? const [],
              createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
              updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
            ));
          }
          list = mappedList;
        }
      }
    } catch (_) {}

    return list;
  }

  Future<SurveyTaskModel> createSurveyTask(SurveyTaskModel task) async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final inserted = await supabase.from('land_processing_stages').insert({
          'plot_id': task.propertyId,
          'assigned_surveyor_id': task.surveyorId,
          'branch_id': task.branchId.isNotEmpty ? task.branchId : 'branch_dar',
          'stage_status': task.status,
          'notes': task.notes,
        }).select().single();

        final newTask = SurveyTaskModel(
          id: inserted['id'],
          propertyId: task.propertyId,
          surveyorId: task.surveyorId,
          branchId: task.branchId,
          status: task.status,
          deadline: task.deadline,
          notes: task.notes,
          documents: task.documents,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        SeedData.surveyTasks.add(newTask);
        return newTask;
      }
    } catch (_) {}

    final newId = 'survey_${DateTime.now().millisecondsSinceEpoch}';
    final newTask = SurveyTaskModel.fromMap(task.toMap(), newId);
    SeedData.surveyTasks.add(newTask);
    return newTask;
  }

  Future<void> updateSurveyTaskStatus(String taskId, String newStatus, String notes) async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        await supabase.from('land_processing_stages').update({
          'stage_status': newStatus,
          'notes': notes,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', taskId);
      }
    } catch (_) {}
    final idx = SeedData.surveyTasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final old = SeedData.surveyTasks[idx];
      SeedData.surveyTasks[idx] = SurveyTaskModel(
        id: old.id,
        propertyId: old.propertyId,
        surveyorId: old.surveyorId,
        branchId: old.branchId,
        status: newStatus,
        deadline: old.deadline,
        notes: notes,
        documents: old.documents,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }
}
