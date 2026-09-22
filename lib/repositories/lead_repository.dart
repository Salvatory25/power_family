import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lead_model.dart';

class LeadRepository {
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

  Future<List<LeadModel>> getLeads({String? branchId, String? agentId}) async {
    List<LeadModel> list = [];
    try {
      final supabase = _supabase;
      if (supabase != null) {
        var query = supabase.from('leads').select();
        if (branchId != null && branchId.isNotEmpty && branchId.length == 36) {
          query = query.eq('branch_id', branchId);
        }
        final response = await query;
        if (response != null && (response as List).isNotEmpty) {
          final List<LeadModel> mappedList = [];
          for (final rawItem in (response as List)) {
            final map = rawItem as Map<String, dynamic>;
            mappedList.add(LeadModel(
              id: (map['id'] ?? map['lead_id'] ?? '').toString(),
              customerId: (map['converted_customer_id'] ?? map['customer_id'] ?? '').toString(),
              propertyId: (map['interested_plot_type'] ?? '').toString(),
              assignedAgentId: (map['assigned_agent_id'] ?? '').toString(),
              branchId: (map['branch_id'] ?? '').toString(),
              source: (map['source'] ?? 'Direct Call').toString(),
              status: (map['status'] ?? 'INTERESTED').toString(),
              notes: (map['notes'] ?? '').toString(),
              nextFollowUp: map['next_follow_up'] != null ? DateTime.tryParse(map['next_follow_up'].toString()) : null,
              createdBy: (map['created_by'] ?? 'system').toString(),
              createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
              updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
            ));
          }
          list = mappedList;
        }
      }
    } catch (e) {
      print('Error loading leads: $e');
    }


    return list;
  }

  Future<LeadModel> createLead(LeadModel lead) async {
    LeadModel created = lead;
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final branchUuid = await _resolveBranchUuid(supabase, lead.branchId);
        if (branchUuid == null) throw Exception('Branch resolution failed');

        final leadCode = 'PFI-LED-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        final inserted = await supabase.from('leads').insert({
          'lead_id': leadCode,
          'branch_id': branchUuid,
          'full_name': 'Prospect Lead',
          'phone': '+255 700 000 000',
          'source': lead.source.isNotEmpty ? lead.source : 'Direct Call',
          'status': lead.status.toUpperCase(),
          'notes': lead.notes,
        }).select().single();

        created = LeadModel(
          id: inserted['id'].toString(),
          customerId: lead.customerId,
          propertyId: lead.propertyId,
          assignedAgentId: lead.assignedAgentId,
          branchId: branchUuid,
          source: lead.source,
          status: lead.status,
          notes: lead.notes,
          nextFollowUp: lead.nextFollowUp,
          createdBy: lead.createdBy,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final currentUser = supabase.auth.currentUser;
        await supabase.from('audit_logs').insert({
          'actor_id': currentUser?.id ?? created.createdBy,
          'actor_name': currentUser != null ? 'Staff' : 'System',
          'action_type': 'LEAD_CREATED',
          'target_entity_type': 'Lead',
          'target_entity_id': created.id,
          'description': 'Added new lead from \${created.source}',
          'branch_id': branchUuid,
        });
      }
    } catch (e) {
      print('Error creating lead in Supabase: $e');
    }


    return created;
  }

  Future<void> updateLeadStatus(String leadId, String newStatus) async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        await supabase.from('leads').update({
          'status': newStatus.toUpperCase(),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', leadId);
        
        final currentUser = supabase.auth.currentUser;
        await supabase.from('audit_logs').insert({
          'actor_id': currentUser?.id ?? 'system',
          'actor_name': currentUser != null ? 'Staff' : 'System',
          'action_type': 'LEAD_STATUS_UPDATED',
          'target_entity_type': 'Lead',
          'target_entity_id': leadId,
          'description': 'Lead status updated to \$newStatus',
          'branch_id': 'branch_dar',
        });
      }
    } catch (e) {
      print('Error updating lead status: $e');
    }


  }
}
