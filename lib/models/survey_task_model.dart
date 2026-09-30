
class SurveyTaskModel {
  final String id;
  final String propertyId;
  final String surveyorId;
  final String branchId;
  final String status; // assigned, in_progress, completed, on_hold, cancelled
  final DateTime? deadline;
  final String notes;
  final List<String> documents;
  final DateTime createdAt;
  final DateTime updatedAt;

  SurveyTaskModel({
    required this.id,
    required this.propertyId,
    required this.surveyorId,
    required this.branchId,
    required this.status,
    this.deadline,
    required this.notes,
    required this.documents,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SurveyTaskModel.fromMap(Map<String, dynamic> map, String id) {
    return SurveyTaskModel(
      id: id,
      propertyId: map['propertyId'] ?? '',
      surveyorId: map['surveyorId'] ?? '',
      branchId: map['branchId'] ?? '',
      status: map['status'] ?? 'assigned',
      deadline: DateTime.tryParse(map['deadline']?.toString() ?? ''),
      notes: map['notes'] ?? '',
      documents: List<String>.from(map['documents'] ?? []),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'surveyorId': surveyorId,
      'branchId': branchId,
      'status': status,
      'deadline': deadline != null ? deadline!.toIso8601String() : null,
      'notes': notes,
      'documents': documents,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
