class ServicePlanOptionModel {
  final String id;
  final String servicePlanId;
  final Map<String, dynamic> values; // e.g. {"price": 3000000, "width": 15, "length": 20}
  final int position;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServicePlanOptionModel({
    required this.id,
    required this.servicePlanId,
    required this.values,
    required this.position,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServicePlanOptionModel.fromMap(Map<String, dynamic> map) {
    return ServicePlanOptionModel(
      id: map['id'] ?? '',
      servicePlanId: map['service_plan_id'] ?? '',
      values: map['values'] ?? {},
      position: map['position'] ?? 0,
      status: map['status'] ?? 'active',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'service_plan_id': servicePlanId,
      'values': values,
      'position': position,
      'status': status,
    };
  }
}
