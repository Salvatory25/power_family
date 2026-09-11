import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/branch_model.dart';
import 'seed_data.dart';

class BranchRepository {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Future<List<BranchModel>> getBranches() async {
    try {
      final store = _firestore;
      if (store != null) {
        final snapshot = await store.collection('branches').get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => BranchModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      }
    } catch (_) {}
    return List.from(SeedData.branches);
  }

  Future<BranchModel> createBranch(BranchModel branch) async {
    try {
      final store = _firestore;
      if (store != null) {
        final docRef = await store.collection('branches').add(branch.toMap());
        final newBranch = BranchModel(
          id: docRef.id,
          name: branch.name,
          code: branch.code,
          location: branch.location,
          phone: branch.phone,
          email: branch.email,
          managerId: branch.managerId,
          status: branch.status,
          createdAt: branch.createdAt,
          updatedAt: DateTime.now(),
        );
        SeedData.branches.add(newBranch);
        return newBranch;
      }
    } catch (_) {}

    final newBranch = BranchModel(
      id: 'branch_${DateTime.now().millisecondsSinceEpoch}',
      name: branch.name,
      code: branch.code,
      location: branch.location,
      phone: branch.phone,
      email: branch.email,
      managerId: branch.managerId,
      status: branch.status,
      createdAt: branch.createdAt,
      updatedAt: DateTime.now(),
    );
    SeedData.branches.add(newBranch);
    return newBranch;
  }

  Future<void> updateBranch(BranchModel branch) async {
    try {
      final store = _firestore;
      if (store != null) {
        await store.collection('branches').doc(branch.id).update(branch.toMap());
      }
    } catch (_) {}
    final idx = SeedData.branches.indexWhere((b) => b.id == branch.id);
    if (idx != -1) {
      SeedData.branches[idx] = branch;
    }
  }
}
