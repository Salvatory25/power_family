import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String referenceId; // Order ID or Kikoba Membership ID
  final String customerId;
  final String branchId;
  final double amount;
  final String method; // BANK, MOBILE_MONEY, CASH
  final String transactionRef; // e.g. MPESA12345
  final String status; // PENDING, VERIFIED, REJECTED
  final String? verifiedBy; // Admin or Branch Manager ID
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.referenceId,
    required this.customerId,
    required this.branchId,
    required this.amount,
    required this.method,
    required this.transactionRef,
    required this.status,
    this.verifiedBy,
    required this.createdAt,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentModel(
      id: id,
      referenceId: map['referenceId'] ?? '',
      customerId: map['customerId'] ?? '',
      branchId: map['branchId'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      method: map['method'] ?? 'CASH',
      transactionRef: map['transactionRef'] ?? '',
      status: map['status'] ?? 'PENDING',
      verifiedBy: map['verifiedBy'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'referenceId': referenceId,
      'customerId': customerId,
      'branchId': branchId,
      'amount': amount,
      'method': method,
      'transactionRef': transactionRef,
      'status': status,
      'verifiedBy': verifiedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
