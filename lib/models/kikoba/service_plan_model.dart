class ServicePlanModel {
  final String id;
  final String serviceId;
  final String name;
  final double minPayment;
  final double maxPayment;
  final String frequency; // weekly, monthly
  final int durationValue;
  final String durationUnit; // year, month
  final int? capacity;
  final String capacityMode; // strict, unlimited
  final int position;
  final String status;
  final int configVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServicePlanModel({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.minPayment,
    required this.maxPayment,
    required this.frequency,
    required this.durationValue,
    required this.durationUnit,
    this.capacity,
    required this.capacityMode,
    required this.position,
    required this.status,
    required this.configVersion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServicePlanModel.fromMap(Map<String, dynamic> map) {
    return ServicePlanModel(
      id: map['id'] ?? '',
      serviceId: map['service_id'] ?? '',
      name: map['name'] ?? '',
      minPayment: (map['min_payment'] ?? 0).toDouble(),
      maxPayment: (map['max_payment'] ?? 0).toDouble(),
      frequency: map['frequency'] ?? 'weekly',
      durationValue: map['duration_value'] ?? 1,
      durationUnit: map['duration_unit'] ?? 'year',
      capacity: map['capacity'],
      capacityMode: map['capacity_mode'] ?? 'unlimited',
      position: map['position'] ?? 0,
      status: map['status'] ?? 'active',
      configVersion: map['config_version'] ?? 1,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'service_id': serviceId,
      'name': name,
      'min_payment': minPayment,
      'max_payment': maxPayment,
      'frequency': frequency,
      'duration_value': durationValue,
      'duration_unit': durationUnit,
      'capacity': capacity,
      'capacity_mode': capacityMode,
      'position': position,
      'status': status,
      'config_version': configVersion,
    };
  }
}
