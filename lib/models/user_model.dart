import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role; // super_admin, branch_manager, sales_agent, surveyor
  final String? branchId;
  final String? branchName;
  final String? photoUrl;
  final String status; // active, pending, suspended, disabled
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.branchId,
    this.branchName,
    this.photoUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    final fn = map['fullName'] ?? map['full_name'];
    final String fullNameCalculated;
    if (fn != null && fn.toString().isNotEmpty) {
      fullNameCalculated = fn.toString();
    } else {
      final first = map['first_name'] ?? '';
      final last = map['last_name'] ?? '';
      fullNameCalculated = '$first $last'.trim();
    }

    return UserModel(
      uid: id,
      fullName: fullNameCalculated.isNotEmpty ? fullNameCalculated : 'Staff Member',
      email: (map['email'] ?? '').toString(),
      phone: (map['phone'] ?? map['phone_number'] ?? '').toString(),
      role: (map['role'] ?? map['primary_role'] ?? 'SALES_AGENT').toString(),
      branchId: map['branchId'] ?? map['branch_id'],
      branchName: map['branchName'] ?? map['branch_name'],
      photoUrl: map['photoUrl'] ?? map['photo_url'],
      status: (map['status'] ?? 'PENDING').toString(),
      createdAt: _parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: _parseDate(map['updatedAt'] ?? map['updated_at']),
      lastLoginAt: _parseDate(map['lastLoginAt'] ?? map['last_login_at']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'branchId': branchId,
      'branchName': branchName,
      'photoUrl': photoUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? role,
    String? branchId,
    String? branchName,
    String? photoUrl,
    String? status,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
