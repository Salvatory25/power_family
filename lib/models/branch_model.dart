import 'package:cloud_firestore/cloud_firestore.dart';

class BranchModel {
  final String id;
  final String name;
  final String code;
  final String location;
  final String phone;
  final String email;
  final String? managerId;
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
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
