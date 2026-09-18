import 'package:cloud_firestore/cloud_firestore.dart';

class BranchModel {
  final String id;
  final String name;
  final String code;
  final String location;
  final String phone;
  final String email;
  final String? managerId;
  final double monthlyTarget;
  final String status; // active, inactive
  final DateTime createdAt;
  final DateTime updatedAt;

  BranchModel({
    required this.id,
    required this.name,
    required this.code,
    required this.location,
    required this.phone,
    required this.email,
    this.managerId,
    this.monthlyTarget = 50000000.0,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BranchModel.fromMap(Map<String, dynamic> map, String id) {
    return BranchModel(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      location: map['location'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      managerId: map['managerId'],
      monthlyTarget: (map['monthlyTarget'] ?? map['monthly_target'] as num?)?.toDouble() ?? 50000000.0,
      status: map['status'] ?? 'active',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'location': location,
      'phone': phone,
      'email': email,
      'managerId': managerId,
      'monthly_target': monthlyTarget,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  BranchModel copyWith({
    String? name,
    String? code,
    String? location,
    String? phone,
    String? email,
    String? managerId,
    double? monthlyTarget,
    String? status,
    DateTime? updatedAt,
  }) {
    return BranchModel(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      managerId: managerId ?? this.managerId,
      monthlyTarget: monthlyTarget ?? this.monthlyTarget,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
