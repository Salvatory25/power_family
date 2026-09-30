class KikobaAccountModel {
  final String id;
  final String accountNumber;
  final String customerId;
  final String? orderId;
  final String? serviceId;
  final String? planId;
  final String? optionId;
  final double totalAmount;
  final double paidAmount;
  final double balance;
  final String frequency; // weekly, monthly
  final DateTime? startDate;
  final DateTime? endDate;
  final String status; // APPROVED, ACTIVE, OVERDUE, SUSPENDED, COMPLETED
  final DateTime createdAt;
  final DateTime updatedAt;

  KikobaAccountModel({
    required this.id,
    required this.accountNumber,
    required this.customerId,
    this.orderId,
    this.serviceId,
    this.planId,
    this.optionId,
    required this.totalAmount,
    this.paidAmount = 0.0,
    required this.balance,
    required this.frequency,
    this.startDate,
    this.endDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KikobaAccountModel.fromMap(Map<String, dynamic> map) {
    return KikobaAccountModel(
      id: map['id'] ?? '',
      accountNumber: map['account_number'] ?? '',
      customerId: map['customer_id'] ?? '',
      orderId: map['order_id'],
      serviceId: map['service_id'],
      planId: map['plan_id'],
      optionId: map['option_id'],
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0.0,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      frequency: map['frequency'] ?? 'weekly',
      startDate: map['start_date'] != null ? DateTime.tryParse(map['start_date']) : null,
      endDate: map['end_date'] != null ? DateTime.tryParse(map['end_date']) : null,
      status: map['status'] ?? 'APPROVED',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'account_number': accountNumber,
      'customer_id': customerId,
      if (orderId != null) 'order_id': orderId,
      if (serviceId != null) 'service_id': serviceId,
      if (planId != null) 'plan_id': planId,
      if (optionId != null) 'option_id': optionId,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'balance': balance,
      'frequency': frequency,
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      if (endDate != null) 'end_date': endDate!.toIso8601String(),
      'status': status,
    };
  }

  KikobaAccountModel copyWith({
    String? id,
    String? accountNumber,
    String? customerId,
    String? orderId,
    String? serviceId,
    String? planId,
    String? optionId,
    double? totalAmount,
    double? paidAmount,
    double? balance,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KikobaAccountModel(
      id: id ?? this.id,
      accountNumber: accountNumber ?? this.accountNumber,
      customerId: customerId ?? this.customerId,
      orderId: orderId ?? this.orderId,
      serviceId: serviceId ?? this.serviceId,
      planId: planId ?? this.planId,
      optionId: optionId ?? this.optionId,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      balance: balance ?? this.balance,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
