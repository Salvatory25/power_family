import 'package:cloud_firestore/cloud_firestore.dart';

class KikobaMembershipModel {
  final String id;
  final String packageId;
  final String customerId;
  final String customerName;
  final String propertyId;
  final String branchId;
  final double totalContributed;
  final String status; // PENDING, ACTIVE, COMPLETED, CANCELLED, DEFAULTED
  final DateTime createdAt;
  final DateTime updatedAt;

  KikobaMembershipModel({
    required this.id,
    required this.packageId,
    required this.customerId,
    required this.customerName,
    required this.propertyId,
    required this.branchId,
    required this.totalContributed,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KikobaMembershipModel.fromMap(Map<String, dynamic> map, String id) {
    return KikobaMembershipModel(
      id: id,
      packageId: map['packageId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? 'Unknown Customer',
      propertyId: map['propertyId'] ?? '',
      branchId: map['branchId'] ?? '',
      totalContributed: (map['totalContributed'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'PENDING',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'packageId': packageId,
      'customerId': customerId,
      'customerName': customerName,
      'propertyId': propertyId,
      'branchId': branchId,
      'totalContributed': totalContributed,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  KikobaMembershipModel copyWith({
    String? packageId,
    String? customerId,
    String? customerName,
    String? propertyId,
    String? branchId,
    double? totalContributed,
    String? status,
    DateTime? updatedAt,
  }) {
    return KikobaMembershipModel(
      id: id,
      packageId: packageId ?? this.packageId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      propertyId: propertyId ?? this.propertyId,
      branchId: branchId ?? this.branchId,
      totalContributed: totalContributed ?? this.totalContributed,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
