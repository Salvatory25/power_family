class InstallmentPlanModel {
  final String id;
  final String name; // e.g. '6 Months Plan'
  final double initialPayment;
  final double installmentAmount;
  final int numberOfPayments;
  final String frequency; // WEEKLY, MONTHLY, CUSTOM
  final double totalAmount;

  InstallmentPlanModel({
    required this.id,
    required this.name,
    required this.initialPayment,
    required this.installmentAmount,
    required this.numberOfPayments,
    required this.frequency,
    required this.totalAmount,
  });

  factory InstallmentPlanModel.fromMap(Map<String, dynamic> map) {
    return InstallmentPlanModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      initialPayment: (map['initialPayment'] as num?)?.toDouble() ?? 0.0,
      installmentAmount: (map['installmentAmount'] as num?)?.toDouble() ?? 0.0,
      numberOfPayments: map['numberOfPayments'] as int? ?? 0,
      frequency: map['frequency'] ?? 'MONTHLY',
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'initialPayment': initialPayment,
      'installmentAmount': installmentAmount,
      'numberOfPayments': numberOfPayments,
      'frequency': frequency,
      'totalAmount': totalAmount,
    };
  }
}
