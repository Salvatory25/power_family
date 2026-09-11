import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sms_log_model.dart';
import 'seed_data.dart';

class SMSRepository {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Future<List<SMSLogModel>> getSMSLogs({String? branchId, String? userId}) async {
    List<SMSLogModel> list = [];
    try {
      final store = _firestore;
      if (store != null) {
        Query query = store.collection('sms_logs');
        if (branchId != null && branchId.isNotEmpty) {
          query = query.where('branchId', isEqualTo: branchId);
        }
        if (userId != null && userId.isNotEmpty) {
          query = query.where('sentBy', isEqualTo: userId);
        }
        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          list = snapshot.docs
              .map((doc) => SMSLogModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();
        }
      }
    } catch (_) {}

    if (list.isEmpty) {
      list = List.from(SeedData.smsLogs);
      if (branchId != null && branchId.isNotEmpty) {
        list = list.where((s) => s.branchId == branchId).toList();
      }
    }
    return list;
  }

  Future<SMSLogModel> logSMS(SMSLogModel log) async {
    try {
      final store = _firestore;
      if (store != null) {
        final docRef = await store.collection('sms_logs').add(log.toMap());
        final newLog = SMSLogModel.fromMap(log.toMap(), docRef.id);
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
