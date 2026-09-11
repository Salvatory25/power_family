import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String address;
  final String notes;
  final List<String> interestedPropertyTypes;
  final double budget;
  final String status; // new, contacted, interested, negotiating, converted, lost
  final String? assignedAgentId;
  final String branchId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.address,
    required this.notes,
    required this.interestedPropertyTypes,
    required this.budget,
    required this.status,
    this.assignedAgentId,
    required this.branchId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map, String id) {
    return CustomerModel(
      id: id,
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      notes: map['notes'] ?? '',
      interestedPropertyTypes: List<String>.from(map['interestedPropertyTypes'] ?? []),
      budget: (map['budget'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'new',
      assignedAgentId: map['assignedAgentId'],
      branchId: map['branchId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
      'interestedPropertyTypes': interestedPropertyTypes,
      'budget': budget,
      'status': status,
      'assignedAgentId': assignedAgentId,
      'branchId': branchId,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
