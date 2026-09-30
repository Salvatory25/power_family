class ServiceColumnModel {
  final String id;
  final String serviceId;
  final String key;
  final String label;
  final String type; // currency, number, text, boolean
  final int position;
  final bool isRequired;
  final DateTime createdAt;

  ServiceColumnModel({
    required this.id,
    required this.serviceId,
    required this.key,
    required this.label,
    required this.type,
    required this.position,
    required this.isRequired,
    required this.createdAt,
  });

  factory ServiceColumnModel.fromMap(Map<String, dynamic> map) {
    return ServiceColumnModel(
      id: map['id'] ?? '',
      serviceId: map['service_id'] ?? '',
      key: map['key'] ?? '',
      label: map['label'] ?? '',
      type: map['type'] ?? 'text',
      position: map['position'] ?? 0,
      isRequired: map['is_required'] ?? true,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'service_id': serviceId,
      'key': key,
      'label': label,
      'type': type,
      'position': position,
      'is_required': isRequired,
    };
  }
}
