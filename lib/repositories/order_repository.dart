import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';

class OrderRepository {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<OrderModel>> getOrders({String? branchId, String? customerId}) async {
    final supabase = _supabase;
    if (supabase == null) return [];
    
    var query = supabase.from('orders').select();
    
    if (branchId != null && branchId.isNotEmpty) {
      query = query.eq('branch_id', branchId);
    }
    if (customerId != null && customerId.isNotEmpty) {
      query = query.eq('customer_id', customerId);
    }
    
    final response = await query.order('created_at', ascending: false);
    if (response != null && (response as List).isNotEmpty) {
      return (response).map((map) => OrderModel(
        id: map['id'].toString(),
        orderNumber: map['order_number'] ?? '',
        customerId: map['customer_id'] ?? '',
        customerName: map['customer_name'] ?? 'Unknown',
        propertyId: map['property_id'] ?? '',
        branchId: map['branch_id'] ?? '',
        acquisitionPlan: map['acquisition_plan'] ?? 'FULL_PAYMENT',
        totalPayable: (map['total_payable'] as num?)?.toDouble() ?? 0.0,
        amountPaid: (map['amount_paid'] as num?)?.toDouble() ?? 0.0,
        status: map['status'] ?? 'PENDING',
        paymentStatus: map['payment_status'] ?? map['status'] ?? 'PENDING',
        createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
      )).toList();
    }
    return [];
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception("Supabase client not available");
    
    final response = await supabase.from('orders').insert({
      'order_number': order.orderNumber,
      'customer_id': order.customerId,
      'customer_name': order.customerName,
      'property_id': order.propertyId,
      'branch_id': order.branchId,
      'acquisition_plan': order.acquisitionPlan,
      'total_payable': order.totalPayable,
      'amount_paid': order.amountPaid,
      'status': order.status,
    }).select().single();
    
    return OrderModel(
      id: response['id'].toString(),
      orderNumber: response['order_number'] ?? '',
      customerId: response['customer_id'] ?? '',
      customerName: response['customer_name'] ?? 'Unknown',
      propertyId: response['property_id'] ?? '',
      branchId: response['branch_id'] ?? '',
      acquisitionPlan: response['acquisition_plan'] ?? 'FULL_PAYMENT',
      totalPayable: (response['total_payable'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (response['amount_paid'] as num?)?.toDouble() ?? 0.0,
      status: response['status'] ?? 'PENDING',
      paymentStatus: response['payment_status'] ?? response['status'] ?? 'PENDING',
      createdAt: DateTime.tryParse(response['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(response['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Future<void> updateOrderStatus(String id, String status) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception("Supabase client not available");
    
    await supabase.from('orders').update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> deleteOrder(String id) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception("Supabase client not available");
    
    await supabase.from('orders').delete().eq('id', id);
  }
}
