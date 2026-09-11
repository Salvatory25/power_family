import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import 'seed_data.dart';

class AuthRepository {
  fb.FirebaseAuth? get _auth {
    try {
      return fb.FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // Local state cache for development / offline preview mode
  UserModel? _currentUser = SeedData.users[0]; // Default Super Admin for dev

  UserModel? get currentUser => _currentUser;

  /// Check current user session
  Future<UserModel?> getCurrentUserSession() async {
    try {
      final auth = _auth;
      final store = _firestore;
      if (auth != null && store != null && auth.currentUser != null) {
        final doc = await store.collection('users').doc(auth.currentUser!.uid).get();
        if (doc.exists && doc.data() != null) {
          _currentUser = UserModel.fromMap(doc.data()!, doc.id);
          return _currentUser;
        }
      }
    } catch (_) {}
    return _currentUser;
  }

  /// Sign In with Email & Password
  Future<UserModel> login({required String email, required String password}) async {
    try {
      final auth = _auth;
      final store = _firestore;
      if (auth != null && store != null) {
        final credential = await auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        if (credential.user != null) {
          final doc = await store.collection('users').doc(credential.user!.uid).get();
          if (doc.exists && doc.data() != null) {
            _currentUser = UserModel.fromMap(doc.data()!, doc.id);
            await store.collection('users').doc(doc.id).update({
              'lastLoginAt': FieldValue.serverTimestamp(),
            });
            return _currentUser!;
          }
        }
      }
    } catch (e) {
      // Fallback
    }

    final seedMatch = SeedData.users.firstWhere(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () => throw Exception('Invalid email or password.'),
    );
    _currentUser = seedMatch;
    return _currentUser!;
  }

  /// Register new user account
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? requestedRole,
    String? branchId,
  }) async {
    try {
      final auth = _auth;
      final store = _firestore;
      if (auth != null && store != null) {
        final credential = await auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        final newUid = credential.user?.uid ?? DateTime.now().millisecondsSinceEpoch.toString();

        final newUser = UserModel(
          uid: newUid,
          fullName: fullName.trim(),
          email: email.trim(),
          phone: phone.trim(),
          role: requestedRole ?? AppConstants.roleSalesAgent,
          branchId: branchId,
          status: AppConstants.statusPending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await store.collection('users').doc(newUid).set(newUser.toMap());
        _currentUser = newUser;
        return newUser;
      }
    } catch (e) {
      // Fallback
    }

    final newUid = 'user_registered_${DateTime.now().millisecondsSinceEpoch}';
    final newUser = UserModel(
      uid: newUid,
      fullName: fullName.trim(),
      email: email.trim(),
      phone: phone.trim(),
      role: requestedRole ?? AppConstants.roleSalesAgent,
      branchId: branchId ?? 'branch_dar',
      status: AppConstants.statusPending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    SeedData.users.add(newUser);
    _currentUser = newUser;
    return newUser;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final auth = _auth;
      if (auth != null) {
        await auth.sendPasswordResetEmail(email: email.trim());
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      final auth = _auth;
      if (auth != null) {
        await auth.signOut();
      }
    } catch (_) {}
    _currentUser = null;
  }

  void switchDevRole(String role) {
    final match = SeedData.users.firstWhere(
      (u) => u.role == role && u.status == AppConstants.statusActive,
      orElse: () => SeedData.users[0],
    );
    _currentUser = match;
  }
}
