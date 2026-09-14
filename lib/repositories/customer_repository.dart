import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _resolveBranchUuid(SupabaseClient supabase, String? requestedId) async {
    try {
      if (requestedId != null && requestedId.length == 36 && requestedId.contains('-')) {
        return requestedId;
      }
      final res = await supabase.from('branches').select('id').limit(1);
      if (res != null && (res as List).isNotEmpty) {
        return res.first['id'].toString();
      }
      final inserted = await supabase.from('branches').insert({
        'name': 'Dar es Salaam HQ',
        'code': 'PF-DAR',
        'region': 'Dar es Salaam',
        'district': 'Kinondoni',
        'phone': '+255 712 000 111',
        'email': 'dar@powerfamily.co.tz',
      }).select().single();
      return inserted['id'].toString();
    } catch (e) {
      print('Error resolving branch UUID: $e');
      return null;
    }
  }

  Future<List<CustomerModel>> getCustomers({String? branchId, String? agentId}) async {
    List<CustomerModel> list = [];
    try {
      final supabase = _supabase;
      if (supabase != null) {
        var query = supabase.from('customers').select();
        if (branchId != null && branchId.isNotEmpty && branchId.length == 36) {
          query = query.eq('branch_id', branchId);
        }
        final response = await query;
        if (response != null && (response as List).isNotEmpty) {
          final List<CustomerModel> mappedList = [];
          for (final rawItem in (response as List)) {
            final map = rawItem as Map<String, dynamic>;
            mappedList.add(CustomerModel(
              id: (map['id'] ?? map['customer_id'] ?? '').toString(),
              fullName: (map['full_name'] ?? 'Customer').toString(),
              phone: (map['phone'] ?? '').toString(),
              email: (map['email'] ?? '').toString(),
              address: (map['address'] ?? '').toString(),
              notes: (map['notes'] ?? '').toString(),
              interestedPropertyTypes: const ['KIWANJA'],
              budget: 15000000.0,
              status: (map['status'] ?? 'ACTIVE').toString(),
              assignedAgentId: map['assigned_staff_id']?.toString(),
              branchId: (map['branch_id'] ?? '').toString(),
              createdBy: (map['created_by'] ?? 'system').toString(),
              createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
              updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
            ));
          }
          list = mappedList;
        }
      }
    } catch (e) {
      print('Error loading customers: $e');
    }

    return list;
  }

  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final branchUuid = await _resolveBranchUuid(supabase, customer.branchId);
        if (branchUuid == null) {
          throw Exception('Failed to resolve valid branch UUID');
        }

        final nameParts = customer.fullName.trim().split(' ');
        final firstName = nameParts.first;
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Customer';
        final custCode = 'PFI-CUST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

        final payload = <String, dynamic>{
          'customer_id': custCode,
          'first_name': firstName,
          'last_name': lastName,
          'phone': customer.phone,
          'phone_normalized': customer.phone.replaceAll(RegExp(r'[^0-9]'), ''),
          'email': customer.email.isNotEmpty ? customer.email : null,
          'email_normalized': customer.email.isNotEmpty ? customer.email.trim().toLowerCase() : null,
          'address': customer.address,
          'notes': customer.notes,
          'branch_id': branchUuid,
          'status': 'ACTIVE',
        };

        final inserted = await supabase.from('customers').insert(payload).select().single();

        return CustomerModel(
          id: inserted['id'].toString(),
          fullName: customer.fullName,
          phone: customer.phone,
          email: customer.email,
          address: customer.address,
          notes: customer.notes,
          interestedPropertyTypes: customer.interestedPropertyTypes,
          budget: customer.budget,
          status: 'ACTIVE',
          assignedAgentId: customer.assignedAgentId,
          branchId: branchUuid,
          createdBy: customer.createdBy,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error creating customer in Supabase: $e');
    }

    return customer;
  }

  Future<void> updateCustomerStatus(String customerId, String newStatus) async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        await supabase.from('customers').update({
          'status': newStatus.toUpperCase(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', customerId);
      }
    } catch (e) {
      print('Error updating customer status: $e');
    }
  }
}
