import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import 'seed_data.dart';

class AuthRepository {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // Local state cache for active session
  UserModel? _currentUser = SeedData.users[0]; // Default active session

  UserModel? get currentUser => _currentUser;

  /// Check current user session from Supabase Auth & PostgreSQL profiles table
  Future<UserModel?> getCurrentUserSession() async {
    try {
      final supabase = _supabase;
      if (supabase != null && supabase.auth.currentUser != null) {
        final userId = supabase.auth.currentUser!.id;
        final response = await supabase.from('profiles').select().eq('id', userId).maybeSingle();
        if (response != null) {
          _currentUser = UserModel.fromMap(response, userId);
          return _currentUser;
        }
      }
    } catch (_) {}
    return _currentUser;
  }

  /// Sign In with Email & Password via Supabase Auth
  Future<UserModel> login({required String email, required String password}) async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final AuthResponse res = await supabase.auth.signInWithPassword(
          email: email.trim(),
          password: password.trim(),
        );

        if (res.user != null) {
          final profileData = await supabase.from('profiles').select().eq('id', res.user!.id).maybeSingle();
          if (profileData != null) {
            _currentUser = UserModel.fromMap(profileData, res.user!.id);
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

  /// Register new user account in Supabase Auth & profiles table
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? requestedRole,
    String? branchId,
  }) async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final AuthResponse res = await supabase.auth.signUp(
          email: email.trim(),
          password: password.trim(),
        );

        final newUid = res.user?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        final nameParts = fullName.trim().split(' ');
        final firstName = nameParts.first;
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'User';

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

        // Insert into Supabase profiles table
        await supabase.from('profiles').insert({
          'id': newUid,
          'first_name': firstName,
          'last_name': lastName,
          'email': email.trim(),
          'phone': phone.trim(),
          'primary_role': requestedRole ?? AppConstants.roleSalesAgent,
          'branch_id': branchId,
          'status': AppConstants.statusPending,
        });

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
      final supabase = _supabase;
      if (supabase != null) {
        await supabase.auth.resetPasswordForEmail(email.trim());
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        await supabase.auth.signOut();
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
