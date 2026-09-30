
class LeadModel {
  final String id;
  final String customerId;
  final String propertyId;
  final String assignedAgentId;
  final String branchId;
  final String source;
  final String status; // new, contacted, interested, negotiating, converted, lost
  final String notes;
  final DateTime? nextFollowUp;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeadModel({
    required this.id,
    required this.customerId,
    required this.propertyId,
    required this.assignedAgentId,
    required this.branchId,
    required this.source,
    required this.status,
    required this.notes,
    this.nextFollowUp,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeadModel.fromMap(Map<String, dynamic> map, String id) {
    return LeadModel(
      id: id,
      customerId: map['customerId'] ?? '',
      propertyId: map['propertyId'] ?? '',
      assignedAgentId: map['assignedAgentId'] ?? '',
      branchId: map['branchId'] ?? '',
      source: map['source'] ?? 'Direct Inquiry',
      status: map['status'] ?? 'new',
      notes: map['notes'] ?? '',
      nextFollowUp: DateTime.tryParse(map['nextFollowUp']?.toString() ?? ''),
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'propertyId': propertyId,
      'assignedAgentId': assignedAgentId,
      'branchId': branchId,
      'source': source,
      'status': status,
      'notes': notes,
      'nextFollowUp': nextFollowUp != null ? nextFollowUp!.toIso8601String() : null,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
