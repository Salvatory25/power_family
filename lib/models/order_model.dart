
class OrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String propertyId;
  final String branchId;
  final String acquisitionPlan; // 'FULL_PAYMENT', 'INSTALLMENT'
  final double totalPayable;
  final double amountPaid;
  final String status; // PENDING, ACTIVE, PARTIALLY_PAID, FULLY_PAID, COMPLETED, CANCELLED
  final String paymentStatus; // PENDING, VERIFIED
  
  // New Kikoba fields
  final String? serviceId;
  final String? servicePlanId;
  final String? optionId;
  final Map<String, dynamic>? snapshot;

  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.propertyId,
    required this.branchId,
    required this.acquisitionPlan,
    required this.totalPayable,
    required this.amountPaid,
    required this.status,
    required this.paymentStatus,
    this.serviceId,
    this.servicePlanId,
    this.optionId,
    this.snapshot,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      orderNumber: map['order_number'] ?? map['orderNumber'] ?? '',
      customerId: map['customer_id'] ?? map['customerId'] ?? '',
      customerName: map['customer_name'] ?? map['customerName'] ?? 'Unknown Customer',
      propertyId: map['property_id'] ?? map['propertyId'] ?? '',
      branchId: map['branch_id'] ?? map['branchId'] ?? '',
      acquisitionPlan: map['acquisition_plan'] ?? map['acquisitionPlan'] ?? 'FULL_PAYMENT',
      totalPayable: (map['total_payable'] as num?)?.toDouble() ?? (map['totalPayable'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (map['amount_paid'] as num?)?.toDouble() ?? (map['amountPaid'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'PENDING',
      paymentStatus: map['payment_status'] ?? map['paymentStatus'] ?? 'PENDING',
      serviceId: map['service_id'] ?? map['serviceId'],
      servicePlanId: map['service_plan_id'] ?? map['servicePlanId'],
      optionId: map['option_id'] ?? map['optionId'],
      snapshot: map['snapshot'],
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order_number': orderNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'property_id': propertyId.isEmpty ? null : propertyId,
      'branch_id': branchId.isEmpty ? null : branchId,
      'acquisition_plan': acquisitionPlan,
      'total_payable': totalPayable,
      'amount_paid': amountPaid,
      'status': status,
      // 'payment_status': paymentStatus, // Not in Supabase schema
      if (serviceId != null) 'service_id': serviceId,
      if (servicePlanId != null) 'service_plan_id': servicePlanId,
      if (optionId != null) 'option_id': optionId,
      if (snapshot != null) 'snapshot': snapshot,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? propertyId,
    String? branchId,
    String? acquisitionPlan,
    double? totalPayable,
    double? amountPaid,
    String? status,
    String? paymentStatus,
    String? serviceId,
    String? servicePlanId,
    String? optionId,
    Map<String, dynamic>? snapshot,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      propertyId: propertyId ?? this.propertyId,
      branchId: branchId ?? this.branchId,
      acquisitionPlan: acquisitionPlan ?? this.acquisitionPlan,
      totalPayable: totalPayable ?? this.totalPayable,
      amountPaid: amountPaid ?? this.amountPaid,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      serviceId: serviceId ?? this.serviceId,
      servicePlanId: servicePlanId ?? this.servicePlanId,
      optionId: optionId ?? this.optionId,
      snapshot: snapshot ?? this.snapshot,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
