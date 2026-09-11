import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_model.dart';
import 'seed_data.dart';

class ActivityRepository {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Future<List<ActivityModel>> getActivities({String? branchId, int limit = 20}) async {
    List<ActivityModel> list = [];
    try {
      final store = _firestore;
      if (store != null) {
        Query query = store.collection('activities').orderBy('createdAt', descending: true).limit(limit);
        if (branchId != null && branchId.isNotEmpty) {
          query = query.where('branchId', isEqualTo: branchId);
        }
        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          list = snapshot.docs
              .map((doc) => ActivityModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();
        }
      }
    } catch (_) {}

    if (list.isEmpty) {
      list = List.from(SeedData.activities);
      if (branchId != null && branchId.isNotEmpty) {
        list = list.where((a) => a.branchId == branchId).toList();
      }
    }
    return list;
  }

  Future<void> logActivity(ActivityModel activity) async {
    try {
      final store = _firestore;
      if (store != null) {
        await store.collection('activities').add(activity.toMap());
      }
    } catch (_) {}
    SeedData.activities.insert(0, activity);
  }
}
