import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/branch_model.dart';

class BranchRepository {
  static final List<BranchModel> _localCache = [];

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<BranchModel>> getBranches() async {
    List<BranchModel> list = [];
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final response = await supabase.from('branches').select();
        if (response != null && (response as List).isNotEmpty) {
          final List<BranchModel> mappedList = [];
          for (final rawItem in (response as List)) {
            final map = rawItem as Map<String, dynamic>;
            mappedList.add(BranchModel(
              id: (map['id'] ?? '').toString(),
              name: (map['name'] ?? map['branch_name'] ?? 'Branch').toString(),
              code: (map['code'] ?? map['branch_code'] ?? 'PF-BR').toString(),
              location: (map['location'] ?? '${map['district'] ?? ''}, ${map['region'] ?? ''}').toString(),
              phone: (map['phone'] ?? '+255 700 000 000').toString(),
              email: (map['email'] ?? 'branch@powerfamily.co.tz').toString(),
              status: (map['status'] ?? 'ACTIVE').toString().toLowerCase(),
              createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
              updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
            ));
          }
          list = mappedList;
        }
      }
    } catch (e) {
      print('Error loading branches: $e');
    }

    // Merge locally created branches that may not yet be in remote database
    for (final localB in _localCache) {
      if (!list.any((b) => b.id == localB.id || b.code == localB.code)) {
        list.add(localB);
      }
    }

    return list;
  }

  Future<BranchModel> createBranch(BranchModel branch) async {
    BranchModel created = branch;
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final inserted = await supabase.from('branches').insert({
          'name': branch.name,
          'code': branch.code,
          'region': branch.location.isNotEmpty ? branch.location : 'Dar es Salaam',
          'location': branch.location,
          'phone': branch.phone.isNotEmpty ? branch.phone : '+255 700 000 000',
          'email': branch.email.isNotEmpty ? branch.email : 'branch@powerfamily.co.tz',
        }).select().single();

        created = BranchModel(
          id: inserted['id'].toString(),
          name: (inserted['name'] ?? branch.name).toString(),
          code: (inserted['code'] ?? branch.code).toString(),
          location: (inserted['location'] ?? branch.location).toString(),
          phone: (inserted['phone'] ?? branch.phone).toString(),
          email: (inserted['email'] ?? branch.email).toString(),
          status: (inserted['status'] ?? 'active').toString().toLowerCase(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error creating branch in Supabase: $e');
    }

    // Store in local cache so it appears immediately on UI
    _localCache.removeWhere((b) => b.id == created.id || b.code == created.code);
    _localCache.insert(0, created);

    return created;
  }

  Future<void> updateBranch(BranchModel branch) async {
    try {
      final supabase = _supabase;
      if (supabase != null && branch.id.length == 36) {
        await supabase.from('branches').update({
          'name': branch.name,
          'code': branch.code,
          'location': branch.location,
          'phone': branch.phone,
          'email': branch.email,
          'status': branch.status.toUpperCase(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', branch.id);
      }
    } catch (e) {
      print('Error updating branch: $e');
    }

    final idx = _localCache.indexWhere((b) => b.id == branch.id);
    if (idx != -1) {
      _localCache[idx] = branch;
    } else {
      _localCache.add(branch);
    }
  }
}
