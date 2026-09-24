import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String propertyId;
  final String branchId;
  final String acquisitionPlan; // 'FULL_PAYMENT', 'INSTALLMENT'
  final double totalPayable;
  final double amountPaid;
  final String status; // PENDING, ACTIVE, PARTIALLY_PAID, FULLY_PAID, COMPLETED, CANCELLED
  final String paymentStatus; // PENDING, VERIFIED
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.propertyId,
    required this.branchId,
    required this.acquisitionPlan,
    required this.totalPayable,
    required this.amountPaid,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      orderNumber: map['orderNumber'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? 'Unknown Customer',
      propertyId: map['propertyId'] ?? '',
      branchId: map['branchId'] ?? '',
      acquisitionPlan: map['acquisitionPlan'] ?? 'FULL_PAYMENT',
      totalPayable: (map['totalPayable'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (map['amountPaid'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'PENDING',
      paymentStatus: map['paymentStatus'] ?? 'PENDING',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'propertyId': propertyId,
      'branchId': branchId,
      'acquisitionPlan': acquisitionPlan,
      'totalPayable': totalPayable,
      'amountPaid': amountPaid,
      'status': status,
      'paymentStatus': paymentStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  OrderModel copyWith({
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? propertyId,
    String? branchId,
    String? acquisitionPlan,
    double? totalPayable,
    double? amountPaid,
    String? status,
    String? paymentStatus,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      propertyId: propertyId ?? this.propertyId,
      branchId: branchId ?? this.branchId,
      acquisitionPlan: acquisitionPlan ?? this.acquisitionPlan,
      totalPayable: totalPayable ?? this.totalPayable,
      amountPaid: amountPaid ?? this.amountPaid,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
