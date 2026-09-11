import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lead_model.dart';
import 'seed_data.dart';

class LeadRepository {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Future<List<LeadModel>> getLeads({String? branchId, String? agentId}) async {
    List<LeadModel> list = [];
    try {
      final store = _firestore;
      if (store != null) {
        Query query = store.collection('leads');
        if (branchId != null && branchId.isNotEmpty) {
          query = query.where('branchId', isEqualTo: branchId);
        }
        if (agentId != null && agentId.isNotEmpty) {
          query = query.where('assignedAgentId', isEqualTo: agentId);
        }
        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          list = snapshot.docs
              .map((doc) => LeadModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();
        }
      }
    } catch (_) {}

    if (list.isEmpty) {
      list = List.from(SeedData.leads);
      if (branchId != null && branchId.isNotEmpty) {
        list = list.where((l) => l.branchId == branchId).toList();
      }
      if (agentId != null && agentId.isNotEmpty) {
        list = list.where((l) => l.assignedAgentId == agentId).toList();
      }
    }
    return list;
  }

  Future<LeadModel> createLead(LeadModel lead) async {
    try {
      final store = _firestore;
      if (store != null) {
        final docRef = await store.collection('leads').add(lead.toMap());
        final newLead = LeadModel.fromMap(lead.toMap(), docRef.id);
        SeedData.leads.add(newLead);
        return newLead;
      }
    } catch (_) {}

    final newId = 'lead_${DateTime.now().millisecondsSinceEpoch}';
    final newLead = LeadModel.fromMap(lead.toMap(), newId);
    SeedData.leads.add(newLead);
    return newLead;
  }

  Future<void> updateLeadStatus(String leadId, String newStatus) async {
    try {
      final store = _firestore;
      if (store != null) {
        await store.collection('leads').doc(leadId).update({
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
    final idx = SeedData.leads.indexWhere((l) => l.id == leadId);
    if (idx != -1) {
      final old = SeedData.leads[idx];
      SeedData.leads[idx] = LeadModel(
        id: old.id,
        customerId: old.customerId,
        propertyId: old.propertyId,
        assignedAgentId: old.assignedAgentId,
        branchId: old.branchId,
        source: old.source,
        status: newStatus,
        notes: old.notes,
        nextFollowUp: old.nextFollowUp,
        createdBy: old.createdBy,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }
}
