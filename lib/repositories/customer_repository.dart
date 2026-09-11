import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import 'seed_data.dart';

class CustomerRepository {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Future<List<CustomerModel>> getCustomers({String? branchId, String? agentId}) async {
    List<CustomerModel> list = [];
    try {
      final store = _firestore;
      if (store != null) {
        Query query = store.collection('customers');
        if (branchId != null && branchId.isNotEmpty) {
          query = query.where('branchId', isEqualTo: branchId);
        }
        if (agentId != null && agentId.isNotEmpty) {
          query = query.where('assignedAgentId', isEqualTo: agentId);
        }
        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          list = snapshot.docs
              .map((doc) => CustomerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();
        }
      }
    } catch (_) {}

    if (list.isEmpty) {
      list = List.from(SeedData.customers);
      if (branchId != null && branchId.isNotEmpty) {
        list = list.where((c) => c.branchId == branchId).toList();
      }
      if (agentId != null && agentId.isNotEmpty) {
        list = list.where((c) => c.assignedAgentId == agentId).toList();
      }
    }
    return list;
  }

  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    try {
      final store = _firestore;
      if (store != null) {
        final docRef = await store.collection('customers').add(customer.toMap());
        final newCustomer = CustomerModel.fromMap(customer.toMap(), docRef.id);
        SeedData.customers.add(newCustomer);
        return newCustomer;
      }
    } catch (_) {}

    final newId = 'cust_${DateTime.now().millisecondsSinceEpoch}';
    final newCustomer = CustomerModel.fromMap(customer.toMap(), newId);
    SeedData.customers.add(newCustomer);
    return newCustomer;
  }

  Future<void> updateCustomerStatus(String customerId, String newStatus) async {
    try {
      final store = _firestore;
      if (store != null) {
        await store.collection('customers').doc(customerId).update({
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
    final idx = SeedData.customers.indexWhere((c) => c.id == customerId);
    if (idx != -1) {
      final old = SeedData.customers[idx];
      SeedData.customers[idx] = CustomerModel(
        id: old.id,
        fullName: old.fullName,
        phone: old.phone,
        email: old.email,
        address: old.address,
        notes: old.notes,
        interestedPropertyTypes: old.interestedPropertyTypes,
        budget: old.budget,
        status: newStatus,
        assignedAgentId: old.assignedAgentId,
        branchId: old.branchId,
        createdBy: old.createdBy,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }
}
