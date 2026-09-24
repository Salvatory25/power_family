import 'package:cloud_firestore/cloud_firestore.dart';

class KikobaPackageModel {
  final String id;
  final String name;
  final String description;
  final double weeklyContribution;
  final int durationWeeks;
  final double targetAmount;
  final int memberLimit;
  final String status; // ACTIVE, INACTIVE
  final DateTime createdAt;
  final String createdBy;

  KikobaPackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.weeklyContribution,
    required this.durationWeeks,
    required this.targetAmount,
    required this.memberLimit,
    required this.status,
    required this.createdAt,
    required this.createdBy,
  });

  factory KikobaPackageModel.fromMap(Map<String, dynamic> map, String id) {
    return KikobaPackageModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      weeklyContribution: (map['weeklyContribution'] as num?)?.toDouble() ?? 0.0,
      durationWeeks: map['durationWeeks'] as int? ?? 0,
      targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 0.0,
      memberLimit: map['memberLimit'] as int? ?? 0,
      status: map['status'] ?? 'INACTIVE',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'weeklyContribution': weeklyContribution,
      'durationWeeks': durationWeeks,
      'targetAmount': targetAmount,
      'memberLimit': memberLimit,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  KikobaPackageModel copyWith({
    String? name,
    String? description,
    double? weeklyContribution,
    int? durationWeeks,
    double? targetAmount,
    int? memberLimit,
    String? status,
  }) {
    return KikobaPackageModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      weeklyContribution: weeklyContribution ?? this.weeklyContribution,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      targetAmount: targetAmount ?? this.targetAmount,
      memberLimit: memberLimit ?? this.memberLimit,
      status: status ?? this.status,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}
