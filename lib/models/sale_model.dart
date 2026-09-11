import 'package:cloud_firestore/cloud_firestore.dart';

class SaleModel {
  final String id;
  final String propertyId;
  final String customerId;
  final String agentId;
  final String branchId;
  final double amount;
  final String paymentStatus; // pending, partial, paid
  final String saleStatus; // pending, completed, cancelled
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  SaleModel({
    required this.id,
    required this.propertyId,
    required this.customerId,
    required this.agentId,
    required this.branchId,
    required this.amount,
    required this.paymentStatus,
    required this.saleStatus,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SaleModel.fromMap(Map<String, dynamic> map, String id) {
    return SaleModel(
      id: id,
      propertyId: map['propertyId'] ?? '',
      customerId: map['customerId'] ?? '',
      agentId: map['agentId'] ?? '',
      branchId: map['branchId'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: map['paymentStatus'] ?? 'pending',
      saleStatus: map['saleStatus'] ?? 'pending',
      notes: map['notes'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'customerId': customerId,
      'agentId': agentId,
      'branchId': branchId,
      'amount': amount,
      'paymentStatus': paymentStatus,
      'saleStatus': saleStatus,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
