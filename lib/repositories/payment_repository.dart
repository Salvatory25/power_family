import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<PaymentModel>> getPayments({String? referenceId, String? branchId}) async {
    final supabase = _supabase;
    if (supabase == null) return [];
    
    var query = supabase.from('payments').select();
    
    if (referenceId != null && referenceId.isNotEmpty) {
      query = query.eq('reference_id', referenceId);
    }
    if (branchId != null && branchId.isNotEmpty) {
      query = query.eq('branch_id', branchId);
    }
    
    final response = await query.order('created_at', ascending: false);
    if (response != null && (response as List).isNotEmpty) {
      return (response).map((map) => PaymentModel(
        id: map['id'].toString(),
        referenceId: map['reference_id'] ?? '',
        customerId: map['customer_id'] ?? '',
        branchId: map['branch_id'] ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        method: map['method'] ?? 'CASH',
        transactionRef: map['transaction_ref'] ?? '',
        status: map['status'] ?? 'PENDING',
        verifiedBy: map['verified_by'],
        createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      )).toList();
    }
    return [];
  }

  Future<PaymentModel> createPayment(PaymentModel payment) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception("Supabase client not available");
    
    final response = await supabase.from('payments').insert({
      'reference_id': payment.referenceId,
      'customer_id': payment.customerId,
      'branch_id': payment.branchId,
      'amount': payment.amount,
      'method': payment.method,
      'transaction_ref': payment.transactionRef,
      'status': payment.status,
    }).select().single();
    
    return PaymentModel(
      id: response['id'].toString(),
      referenceId: response['reference_id'] ?? '',
      customerId: response['customer_id'] ?? '',
      branchId: response['branch_id'] ?? '',
      amount: (response['amount'] as num?)?.toDouble() ?? 0.0,
      method: response['method'] ?? 'CASH',
      transactionRef: response['transaction_ref'] ?? '',
      status: response['status'] ?? 'PENDING',
      verifiedBy: response['verified_by'],
      createdAt: DateTime.tryParse(response['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Future<void> updatePaymentStatus(String id, String status, String verifiedBy) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception("Supabase client not available");
    
    await supabase.from('payments').update({
      'status': status,
      'verified_by': verifiedBy,
    }).eq('id', id);
  }
}
