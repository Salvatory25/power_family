
class ActivityModel {
  final String id;
  final String actorId;
  final String actorName;
  final String action;
  final String entityType;
  final String entityId;
  final String description;
  final String branchId;
  final DateTime createdAt;

  ActivityModel({
    required this.id,
    required this.actorId,
    required this.actorName,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.description,
    required this.branchId,
    required this.createdAt,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map, String id) {
    return ActivityModel(
      id: id,
      actorId: map['actorId'] ?? '',
      actorName: map['actorName'] ?? 'System',
      action: map['action'] ?? '',
      entityType: map['entityType'] ?? '',
      entityId: map['entityId'] ?? '',
      description: map['description'] ?? '',
      branchId: map['branchId'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'actorId': actorId,
      'actorName': actorName,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'description': description,
      'branchId': branchId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
