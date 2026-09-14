import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sms_log_model.dart';
import 'seed_data.dart';

class SMSRepository {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<SMSLogModel>> getSMSLogs({String? branchId, String? userId}) async {
    List<SMSLogModel> list = [];
    try {
      final supabase = _supabase;
      if (supabase != null) {
        var query = supabase.from('sms_logs').select();
        if (branchId != null && branchId.isNotEmpty) {
          query = query.eq('branch_id', branchId);
        }
        if (userId != null && userId.isNotEmpty) {
          query = query.eq('sent_by', userId);
        }
        final response = await query;
        if (response != null && (response as List).isNotEmpty) {
          final List<SMSLogModel> mappedList = [];
          for (final rawItem in (response as List)) {
            final map = rawItem as Map<String, dynamic>;
            mappedList.add(SMSLogModel(
              id: (map['id'] ?? '').toString(),
              recipientId: (map['recipient_phone'] ?? '').toString(),
              phoneNumber: (map['recipient_phone'] ?? '').toString(),
              message: (map['message_content'] ?? '').toString(),
              sentBy: (map['sent_by'] ?? 'system').toString(),
              branchId: (map['branch_id'] ?? 'branch_dar').toString(),
              status: (map['delivery_status'] ?? 'SENT').toString(),
              createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
            ));
          }
          list = mappedList;
        }
      }
    } catch (_) {}

    return list;
  }

  Future<SMSLogModel> logSMS(SMSLogModel log) async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final inserted = await supabase.from('sms_logs').insert({
          'recipient_phone': log.phoneNumber,
          'message_content': log.message,
          'sent_by': log.sentBy,
          'branch_id': log.branchId.isNotEmpty ? log.branchId : 'branch_dar',
          'delivery_status': log.status.toUpperCase(),
        }).select().single();

        final newLog = SMSLogModel(
          id: inserted['id'],
          recipientId: log.recipientId,
          phoneNumber: log.phoneNumber,
          message: log.message,
          sentBy: log.sentBy,
          branchId: log.branchId,
          status: log.status,
          createdAt: DateTime.now(),
        );
        SeedData.smsLogs.add(newLog);
        return newLog;
      }
    } catch (_) {}

    final newId = 'sms_${DateTime.now().millisecondsSinceEpoch}';
    final newLog = SMSLogModel.fromMap(log.toMap(), newId);
    SeedData.smsLogs.add(newLog);
    return newLog;
  }
}
