import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kikoba_package_model.dart';
import '../models/kikoba_membership_model.dart';

class KikobaRepository {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // --- Packages ---

  Future<List<KikobaPackageModel>> getPackages({String? status}) async {
    final supabase = _supabase;
    if (supabase == null) return [];
    
    var query = supabase.from('kikoba_packages').select();
    
    if (status != null && status.isNotEmpty && status != 'ALL') {
      query = query.eq('status', status);
    }
    
    final response = await query.order('created_at', ascending: false);
    if (response != null && (response as List).isNotEmpty) {
      return (response).map((map) => KikobaPackageModel(
        id: map['id'].toString(),
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        weeklyContribution: (map['weekly_contribution'] as num?)?.toDouble() ?? 0.0,
        durationWeeks: map['duration_weeks'] as int? ?? 0,
        targetAmount: (map['target_amount'] as num?)?.toDouble() ?? 0.0,
        memberLimit: map['member_limit'] as int? ?? 0,
        status: map['status'] ?? 'INACTIVE',
        createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
        createdBy: map['created_by'] ?? 'system',
      )).toList();
    }
    return [];
  }

  Future<KikobaPackageModel> createPackage(KikobaPackageModel package) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception("Supabase client not available");
    
    final response = await supabase.from('kikoba_packages').insert({
      'name': package.name,
      'description': package.description,
      'weekly_contribution': package.weeklyContribution,
      'duration_weeks': package.durationWeeks,
      'target_amount': package.targetAmount,
      'member_limit': package.memberLimit,
      'status': package.status,
      'created_by': package.createdBy,
    }).select().single();
    
    return KikobaPackageModel(
      id: response['id'].toString(),
      name: response['name'] ?? '',
      description: response['description'] ?? '',
      weeklyContribution: (response['weekly_contribution'] as num?)?.toDouble() ?? 0.0,
      durationWeeks: response['duration_weeks'] as int? ?? 0,
      targetAmount: (response['target_amount'] as num?)?.toDouble() ?? 0.0,
      memberLimit: response['member_limit'] as int? ?? 0,
      status: response['status'] ?? 'INACTIVE',
      createdAt: DateTime.tryParse(response['created_at'] ?? '') ?? DateTime.now(),
      createdBy: response['created_by'] ?? 'system',
    );
  }

  // --- Memberships ---

  Future<List<KikobaMembershipModel>> getMemberships({String? packageId, String? customerId, String? branchId}) async {
    final supabase = _supabase;
    if (supabase == null) return [];
    
    var query = supabase.from('kikoba_memberships').select();
    
    if (packageId != null && packageId.isNotEmpty) {
      query = query.eq('package_id', packageId);
    }
    if (customerId != null && customerId.isNotEmpty) {
      query = query.eq('customer_id', customerId);
    }
    if (branchId != null && branchId.isNotEmpty) {
      query = query.eq('branch_id', branchId);
    }
    
    final response = await query.order('created_at', ascending: false);
    if (response != null && (response as List).isNotEmpty) {
      return (response).map((map) => KikobaMembershipModel(
        id: map['id'].toString(),
        packageId: map['package_id'] ?? '',
        customerId: map['customer_id'] ?? '',
        customerName: map['customer_name'] ?? 'Unknown',
        propertyId: map['property_id'] ?? '',
        branchId: map['branch_id'] ?? '',
        totalContributed: (map['total_contributed'] as num?)?.toDouble() ?? 0.0,
        status: map['status'] ?? 'PENDING',
        createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
      )).toList();
    }
    return [];
  }

  Future<KikobaMembershipModel> createMembership(KikobaMembershipModel membership) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception("Supabase client not available");
    
    final response = await supabase.from('kikoba_memberships').insert({
      'package_id': membership.packageId,
      'customer_id': membership.customerId,
      'customer_name': membership.customerName,
      'property_id': membership.propertyId,
      'branch_id': membership.branchId,
      'total_contributed': membership.totalContributed,
      'status': membership.status,
    }).select().single();
    
    return KikobaMembershipModel(
      id: response['id'].toString(),
      packageId: response['package_id'] ?? '',
      customerId: response['customer_id'] ?? '',
      customerName: response['customer_name'] ?? 'Unknown',
      propertyId: response['property_id'] ?? '',
      branchId: response['branch_id'] ?? '',
      totalContributed: (response['total_contributed'] as num?)?.toDouble() ?? 0.0,
      status: response['status'] ?? 'PENDING',
      createdAt: DateTime.tryParse(response['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(response['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}
