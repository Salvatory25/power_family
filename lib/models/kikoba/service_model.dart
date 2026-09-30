class ServiceModel {
  final String id;
  final String name;
  final String slug;
  final String category;
  final String description;
  final String paymentType;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    required this.description,
    required this.paymentType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      slug: map['slug'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      paymentType: map['payment_type'] ?? 'kikoba',
      status: map['status'] ?? 'active',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'slug': slug,
      'category': category,
      'description': description,
      'payment_type': paymentType,
      'status': status,
    };
  }
}
