import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'seed_data.dart';

class UserRepository {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Future<List<UserModel>> getUsers({String? branchId}) async {
    try {
      final store = _firestore;
      if (store != null) {
        Query query = store.collection('users');
        if (branchId != null && branchId.isNotEmpty) {
          query = query.where('branchId', isEqualTo: branchId);
        }
        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();
        }
      }
    } catch (_) {}

    if (branchId != null && branchId.isNotEmpty) {
      return SeedData.users.where((u) => u.branchId == branchId).toList();
    }
    return List.from(SeedData.users);
  }

  Future<void> updateUserStatus(String userId, String newStatus) async {
    try {
      final store = _firestore;
      if (store != null) {
        await store.collection('users').doc(userId).update({
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
    final idx = SeedData.users.indexWhere((u) => u.uid == userId);
    if (idx != -1) {
      SeedData.users[idx] = SeedData.users[idx].copyWith(status: newStatus);
    }
  }

  Future<void> updateUserRoleAndBranch(String userId, String role, String? branchId) async {
    try {
      final store = _firestore;
      if (store != null) {
        await store.collection('users').doc(userId).update({
          'role': role,
          'branchId': branchId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
    final idx = SeedData.users.indexWhere((u) => u.uid == userId);
    if (idx != -1) {
      SeedData.users[idx] = SeedData.users[idx].copyWith(
        role: role,
        branchId: branchId,
      );
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      final store = _firestore;
      if (store != null) {
        await store.collection('users').doc(user.uid).set(user.toMap());
      }
    } catch (_) {}
    SeedData.users.add(user);
  }
}

