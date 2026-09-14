import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'seed_data.dart';

class UserRepository {
  static final List<UserModel> _localCache = [];

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<UserModel>> getUsers({String? branchId}) async {
    List<UserModel> list = [];
    try {
      final supabase = _supabase;
      if (supabase != null) {
        var query = supabase.from('profiles').select();
        if (branchId != null && branchId.isNotEmpty && branchId.length == 36) {
          query = query.eq('branch_id', branchId);
        }
        final response = await query;
        if (response != null && (response as List).isNotEmpty) {
          final List<UserModel> mappedList = [];
          for (final rawItem in (response as List)) {
            final map = rawItem as Map<String, dynamic>;
            final fn = map['first_name'] ?? '';
            final ln = map['last_name'] ?? '';
            final fullName = (map['full_name'] ?? '$fn $ln').toString().trim();
            mappedList.add(UserModel(
              uid: (map['id'] ?? '').toString(),
              fullName: fullName.isNotEmpty ? fullName : 'Staff Member',
              email: (map['email'] ?? '').toString(),
              phone: (map['phone'] ?? map['phone_number'] ?? '').toString(),
              role: (map['primary_role'] ?? map['user_role'] ?? 'SALES_AGENT').toString().toLowerCase(),
              branchId: (map['branch_id'] ?? map['assigned_branch_id'] ?? '').toString(),
              status: (map['status'] ?? 'active').toString().toLowerCase(),
              createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
              updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
            ));
          }
          list = mappedList;
        }
      }
    } catch (e) {
      print('Error loading users from Supabase: $e');
    }

    // Merge with SeedData users and local cache so demo accounts and newly added accounts are visible
    final allFallback = [..._localCache, ...SeedData.users];
    for (final fallback in allFallback) {
      if (!list.any((u) => u.uid == fallback.uid || u.email.toLowerCase() == fallback.email.toLowerCase())) {
        list.add(fallback);
      }
    }

    if (branchId != null && branchId.isNotEmpty) {
      list = list.where((u) => u.branchId == branchId).toList();
    }

    return list;
  }

  Future<UserModel> createUser(UserModel user) async {
    UserModel created = user;
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final nameParts = user.fullName.trim().split(' ');
        final firstName = nameParts.first.isNotEmpty ? nameParts.first : 'Staff';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Member';

        String? branchUuid = user.branchId;
        if (branchUuid == null || branchUuid.isEmpty || branchUuid.length != 36) {
          final branchRes = await supabase.from('branches').select('id').limit(1);
          if (branchRes != null && (branchRes as List).isNotEmpty) {
            branchUuid = branchRes.first['id'].toString();
          } else {
            branchUuid = null;
          }
        }

        final inserted = await supabase.from('profiles').insert({
          'first_name': firstName,
          'last_name': lastName,
          'email': user.email,
          'phone': user.phone.isNotEmpty ? user.phone : null,
          'primary_role': user.role.toUpperCase(),
          'branch_id': branchUuid,
          'status': user.status.toUpperCase(),
        }).select().single();

        created = UserModel(
          uid: inserted['id'].toString(),
          fullName: user.fullName,
          email: user.email,
          phone: user.phone,
          role: user.role.toLowerCase(),
          branchId: branchUuid ?? user.branchId,
          status: user.status.toLowerCase(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error creating user in Supabase profiles: $e');
    }

    _localCache.removeWhere((u) => u.uid == created.uid || u.email.toLowerCase() == created.email.toLowerCase());
    _localCache.insert(0, created);
    SeedData.users.removeWhere((u) => u.uid == created.uid || u.email.toLowerCase() == created.email.toLowerCase());
    SeedData.users.insert(0, created);

    return created;
  }

  Future<void> updateUser(UserModel updatedUser) async {
    try {
      final supabase = _supabase;
      if (supabase != null && updatedUser.uid.length == 36) {
        final nameParts = updatedUser.fullName.trim().split(' ');
        final firstName = nameParts.first.isNotEmpty ? nameParts.first : 'Staff';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Member';

        await supabase.from('profiles').update({
          'first_name': firstName,
          'last_name': lastName,
          'email': updatedUser.email,
          'phone': updatedUser.phone,
          'primary_role': updatedUser.role.toUpperCase(),
          'branch_id': (updatedUser.branchId != null && updatedUser.branchId!.length == 36) ? updatedUser.branchId : null,
          'status': updatedUser.status.toUpperCase(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', updatedUser.uid);
      }
    } catch (e) {
      print('Error updating user: $e');
    }

    _updateLocalLists(updatedUser);
  }

  Future<void> updateUserStatus(String userId, String newStatus) async {
    try {
      final supabase = _supabase;
      if (supabase != null && userId.length == 36) {
        await supabase.from('profiles').update({
          'status': newStatus.toUpperCase(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
      }
    } catch (e) {
      print('Error updating user status: $e');
    }

    _updateLocalStatus(userId, newStatus);
  }

  Future<void> updateUserRoleAndBranch(String userId, String role, String? branchId) async {
    try {
      final supabase = _supabase;
      if (supabase != null && userId.length == 36) {
        final payload = <String, dynamic>{
          'primary_role': role.toUpperCase(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        if (branchId != null && branchId.length == 36) {
          payload['branch_id'] = branchId;
        }
        await supabase.from('profiles').update(payload).eq('id', userId);
      }
    } catch (e) {
      print('Error updating user role and branch: $e');
    }

    _updateLocalRoleAndBranch(userId, role, branchId);
  }

  Future<void> deleteUser(String userId) async {
    try {
      final supabase = _supabase;
      if (supabase != null && userId.length == 36) {
        await supabase.from('profiles').delete().eq('id', userId);
      }
    } catch (e) {
      print('Error deleting user: $e');
    }

    _localCache.removeWhere((u) => u.uid == userId);
    SeedData.users.removeWhere((u) => u.uid == userId);
  }

  void _updateLocalLists(UserModel updated) {
    int idx = _localCache.indexWhere((u) => u.uid == updated.uid);
    if (idx != -1) _localCache[idx] = updated;
    int seedIdx = SeedData.users.indexWhere((u) => u.uid == updated.uid);
    if (seedIdx != -1) SeedData.users[seedIdx] = updated;
  }

  void _updateLocalStatus(String uid, String status) {
    int idx = _localCache.indexWhere((u) => u.uid == uid);
    if (idx != -1) _localCache[idx] = _localCache[idx].copyWith(status: status.toLowerCase());
    int seedIdx = SeedData.users.indexWhere((u) => u.uid == uid);
    if (seedIdx != -1) SeedData.users[seedIdx] = SeedData.users[seedIdx].copyWith(status: status.toLowerCase());
  }

  void _updateLocalRoleAndBranch(String uid, String role, String? branchId) {
    int idx = _localCache.indexWhere((u) => u.uid == uid);
    if (idx != -1) _localCache[idx] = _localCache[idx].copyWith(role: role.toLowerCase(), branchId: branchId ?? _localCache[idx].branchId);
    int seedIdx = SeedData.users.indexWhere((u) => u.uid == uid);
    if (seedIdx != -1) SeedData.users[seedIdx] = SeedData.users[seedIdx].copyWith(role: role.toLowerCase(), branchId: branchId ?? SeedData.users[seedIdx].branchId);
  }
}
