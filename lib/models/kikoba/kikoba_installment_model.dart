class KikobaInstallmentModel {
  final String id;
  final String kikobaAccountId;
  final double amountPaid;
  final String paymentMethod; // M-PESA, BANK, CASH
  final String? referenceNumber;
  final DateTime paidAt;
  final String status;
  final String? notes;

  KikobaInstallmentModel({
    required this.id,
    required this.kikobaAccountId,
    required this.amountPaid,
    required this.paymentMethod,
    this.referenceNumber,
    required this.paidAt,
    required this.status,
    this.notes,
  });

  factory KikobaInstallmentModel.fromMap(Map<String, dynamic> map) {
    return KikobaInstallmentModel(
      id: map['id'] ?? '',
      kikobaAccountId: map['kikoba_account_id'] ?? '',
      amountPaid: (map['amount_paid'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['payment_method'] ?? 'UNKNOWN',
      referenceNumber: map['reference_number'],
      paidAt: map['paid_at'] != null ? DateTime.parse(map['paid_at']) : DateTime.now(),
      status: map['status'] ?? 'COMPLETED',
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kikoba_account_id': kikobaAccountId,
      'amount_paid': amountPaid,
      'payment_method': paymentMethod,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      'status': status,
      if (notes != null) 'notes': notes,
    };
  }
}
