import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property_model.dart';
import 'seed_data.dart';

class PropertyRepository {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Future<List<PropertyModel>> getProperties({
    String? branchId,
    String? type,
    String? status,
    String? searchQuery,
  }) async {
    List<PropertyModel> list = [];
    try {
      final store = _firestore;
      if (store != null) {
        Query query = store.collection('properties');
        if (branchId != null && branchId.isNotEmpty) {
          query = query.where('branchId', isEqualTo: branchId);
        }
        if (type != null && type.isNotEmpty && type != 'all') {
          query = query.where('type', isEqualTo: type);
        }
        if (status != null && status.isNotEmpty && status != 'all') {
          query = query.where('status', isEqualTo: status);
        }
        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          list = snapshot.docs
              .map((doc) => PropertyModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();
        }
      }
    } catch (_) {}

    if (list.isEmpty) {
      list = List.from(SeedData.properties);
      if (branchId != null && branchId.isNotEmpty) {
        list = list.where((p) => p.branchId == branchId).toList();
      }
      if (type != null && type.isNotEmpty && type != 'all') {
        list = list.where((p) => p.type.toLowerCase() == type.toLowerCase()).toList();
      }
      if (status != null && status.isNotEmpty && status != 'all') {
        list = list.where((p) => p.status.toLowerCase() == status.toLowerCase()).toList();
      }
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.propertyCode.toLowerCase().contains(q) ||
            p.location.toLowerCase().contains(q) ||
            p.region.toLowerCase().contains(q) ||
            p.district.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  Future<PropertyModel> createProperty(PropertyModel property) async {
    try {
      final store = _firestore;
      if (store != null) {
        final docRef = await store.collection('properties').add(property.toMap());
        final newProperty = PropertyModel.fromMap(property.toMap(), docRef.id);
        SeedData.properties.add(newProperty);
        return newProperty;
      }
    } catch (_) {}

    final newId = 'prop_${DateTime.now().millisecondsSinceEpoch}';
    final newProperty = PropertyModel.fromMap(property.toMap(), newId);
    SeedData.properties.add(newProperty);
    return newProperty;
  }

  Future<void> updatePropertyStatus(String propertyId, String newStatus) async {
    try {
      final store = _firestore;
      if (store != null) {
        await store.collection('properties').doc(propertyId).update({
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
    final idx = SeedData.properties.indexWhere((p) => p.id == propertyId);
    if (idx != -1) {
      final old = SeedData.properties[idx];
      SeedData.properties[idx] = PropertyModel(
        id: old.id,
        propertyCode: old.propertyCode,
        title: old.title,
        type: old.type,
        description: old.description,
        price: old.price,
        location: old.location,
        region: old.region,
        district: old.district,
        ward: old.ward,
        street: old.street,
        size: old.size,
        plotNumber: old.plotNumber,
        blockNumber: old.blockNumber,
        landUse: old.landUse,
        surveyStatus: old.surveyStatus,
        registrationStatus: old.registrationStatus,
        bedrooms: old.bedrooms,
        bathrooms: old.bathrooms,
        vehicleMake: old.vehicleMake,
        vehicleModel: old.vehicleModel,
        vehicleYear: old.vehicleYear,
        vehicleRegistration: old.vehicleRegistration,
        vehicleMileage: old.vehicleMileage,
        vehicleCondition: old.vehicleCondition,
        latitude: old.latitude,
        longitude: old.longitude,
        images: old.images,
        documents: old.documents,
        status: newStatus,
        branchId: old.branchId,
        assignedAgentId: old.assignedAgentId,
        assignedSurveyorId: old.assignedSurveyorId,
        createdBy: old.createdBy,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }
}
