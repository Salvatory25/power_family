import 'package:cloud_firestore/cloud_firestore.dart';

class SMSLogModel {
  final String id;
  final String recipientId;
  final String phoneNumber;
  final String message;
  final String sentBy;
  final String branchId;
  final String status; // pending, sent, failed
  final String? providerMessageId;
  final DateTime createdAt;

  SMSLogModel({
    required this.id,
    required this.recipientId,
    required this.phoneNumber,
    required this.message,
    required this.sentBy,
    required this.branchId,
    required this.status,
    this.providerMessageId,
    required this.createdAt,
  });

  factory SMSLogModel.fromMap(Map<String, dynamic> map, String id) {
    return SMSLogModel(
      id: id,
      recipientId: map['recipientId'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      message: map['message'] ?? '',
      sentBy: map['sentBy'] ?? '',
      branchId: map['branchId'] ?? '',
      status: map['status'] ?? 'pending',
      providerMessageId: map['providerMessageId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipientId': recipientId,
      'phoneNumber': phoneNumber,
      'message': message,
      'sentBy': sentBy,
      'branchId': branchId,
      'status': status,
      'providerMessageId': providerMessageId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
