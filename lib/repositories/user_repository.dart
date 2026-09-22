import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class UserRepository {
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
            mappedList.add(
              UserModel(
                uid: (map['id'] ?? '').toString(),
                fullName: fullName.isNotEmpty ? fullName : 'Staff Member',
                email: (map['email'] ?? '').toString(),
                phone: (map['phone'] ?? map['phone_number'] ?? '').toString(),
                role: (map['primary_role'] ?? map['user_role'] ?? 'SALES_AGENT')
                    .toString()
                    .toLowerCase(),
                branchId: (map['branch_id'] ?? map['assigned_branch_id'] ?? '')
                    .toString(),
                status: (map['status'] ?? 'active').toString().toLowerCase(),
                createdAt: map['created_at'] != null
                    ? DateTime.tryParse(map['created_at'].toString()) ??
                          DateTime.now()
                    : DateTime.now(),
                updatedAt: map['updated_at'] != null
                    ? DateTime.tryParse(map['updated_at'].toString()) ??
                          DateTime.now()
                    : DateTime.now(),
              ),
            );
          }
          list = mappedList;
        }
      }
    } catch (e) {
      print('Error loading users from Supabase: $e');
    }


    if (branchId != null && branchId.isNotEmpty) {
      list = list.where((u) => u.branchId == branchId).toList();
    }

    return list;
  }

  Future<UserModel> createUser(UserModel user, {String? password}) async {
    UserModel created = user;
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final nameParts = user.fullName.trim().split(' ');
        final firstName = nameParts.first.isNotEmpty
            ? nameParts.first
            : 'Staff';
        final lastName = nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : 'Member';

        String? branchUuid = user.branchId;
        if (branchUuid == null ||
            branchUuid.isEmpty ||
            branchUuid.length != 36) {
          final branchRes = await supabase
              .from('branches')
              .select('id')
              .limit(1);
          if (branchRes != null && (branchRes as List).isNotEmpty) {
            branchUuid = branchRes.first['id'].toString();
          } else {
            branchUuid = null;
          }
        }

        String targetUid = user.uid;
        if (password != null && password.trim().isNotEmpty) {
          try {
            final authRes = await supabase.auth.signUp(
              email: user.email.trim(),
              password: password.trim(),
            );
            if (authRes.user != null) {
              targetUid = authRes.user!.id;
            }
          } catch (e) {
            print('Notice during Supabase auth signUp: $e');
          }
        }

        final profilePayload = <String, dynamic>{
          'first_name': firstName,
          'last_name': lastName,
          'email': user.email.trim(),
          'phone': user.phone.isNotEmpty ? user.phone.trim() : null,
          'primary_role': user.role.toUpperCase(),
          'branch_id': branchUuid,
          'status': user.status.toUpperCase(),
        };

        if (targetUid.length == 36 && !targetUid.startsWith('u_')) {
          profilePayload['id'] = targetUid;
        }

        final inserted = await supabase
            .from('profiles')
            .insert(profilePayload)
            .select()
            .single();

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

        final currentUser = supabase.auth.currentUser;
        final actorId = currentUser?.id ?? created.uid;
        final actorName = currentUser != null ? 'Staff/Admin' : created.fullName;
        
        await supabase.from('audit_logs').insert({
          'actor_id': actorId,
          'actor_name': actorName,
          'action_type': 'USER_CREATED',
          'target_entity_type': 'User',
          'target_entity_id': created.uid,
          'description': 'User \${created.fullName} signed up/created with role \${created.role}',
          'branch_id': (created.branchId ?? '').isNotEmpty ? created.branchId : 'branch_dar',
        });
      }
    } catch (e) {
      print('Error creating user in Supabase profiles: $e');
    }


    return created;
  }

  Future<void> updateUser(UserModel updatedUser) async {
    try {
      final supabase = _supabase;
      if (supabase != null && updatedUser.uid.length == 36) {
        final nameParts = updatedUser.fullName.trim().split(' ');
        final firstName = nameParts.first.isNotEmpty
            ? nameParts.first
            : 'Staff';
        final lastName = nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : 'Member';

        await supabase
            .from('profiles')
            .update({
              'first_name': firstName,
              'last_name': lastName,
              'email': updatedUser.email,
              'phone': updatedUser.phone,
              'primary_role': updatedUser.role.toUpperCase(),
              'branch_id':
                  (updatedUser.branchId != null &&
                      updatedUser.branchId!.length == 36)
                  ? updatedUser.branchId
                  : null,
              'status': updatedUser.status.toUpperCase(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', updatedUser.uid);
      }
    } catch (e) {
      print('Error updating user: $e');
    }

  }

  Future<void> updateUserStatus(String userId, String newStatus) async {
    try {
      final supabase = _supabase;
      if (supabase != null && userId.length == 36) {
        await supabase
            .from('profiles')
            .update({
              'status': newStatus.toUpperCase(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
            
        final currentUser = supabase.auth.currentUser;
        await supabase.from('audit_logs').insert({
          'actor_id': currentUser?.id ?? 'system',
          'actor_name': currentUser != null ? 'Admin' : 'System',
          'action_type': 'USER_STATUS_UPDATED',
          'target_entity_type': 'User',
          'target_entity_id': userId,
          'description': 'User status updated to \$newStatus',
          'branch_id': 'branch_dar', 
        });
      }
    } catch (e) {
      print('Error updating user status: $e');
    }

  }

  Future<void> updateUserRoleAndBranch(
    String userId,
    String role,
    String? branchId,
  ) async {
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

  }


}
