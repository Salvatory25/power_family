import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kikoba/service_model.dart';
import '../models/kikoba/service_column_model.dart';
import '../models/kikoba/service_plan_model.dart';
import '../models/kikoba/service_plan_option_model.dart';
import '../models/order_model.dart';
import '../models/kikoba/kikoba_account_model.dart';
import '../models/kikoba/kikoba_installment_model.dart';

class DynamicKikobaRepository {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // === Services ===

  Future<List<ServiceModel>> getServices() async {
    final supabase = _supabase;
    if (supabase == null) return [];

    final response = await supabase
        .from('services')
        .select()
        .order('created_at', ascending: false);
    return response.map((e) => ServiceModel.fromMap(e)).toList();
  }

  Future<ServiceModel> createService(ServiceModel service) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception("Supabase client not available");

    final response = await supabase
        .from('services')
        .insert(service.toMap())
        .select()
        .single();
    return ServiceModel.fromMap(response);
  }

  // === Service Columns ===

  Future<List<ServiceColumnModel>> getServiceColumns(String serviceId) async {
    final supabase = _supabase;
    if (supabase == null) return [];

    final response = await supabase
        .from('service_columns')
        .select()
        .eq('service_id', serviceId)
        .order('position', ascending: true);
    return response.map((e) => ServiceColumnModel.fromMap(e)).toList();
  }

  Future<ServiceColumnModel> createColumn(ServiceColumnModel column) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception("Supabase client not available");

    final response = await supabase
        .from('service_columns')
        .insert(column.toMap())
        .select()
        .single();
    return ServiceColumnModel.fromMap(response);
  }

  // === Service Plans ===

  Future<List<ServicePlanModel>> getServicePlans(String serviceId) async {
    final supabase = _supabase;
    if (supabase == null) return [];

    final response = await supabase
        .from('service_plans')
        .select()
        .eq('service_id', serviceId)
        .order('position', ascending: true);
    return response.map((e) => ServicePlanModel.fromMap(e)).toList();
  }

  Future<ServicePlanModel> createPlan(ServicePlanModel plan) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception("Supabase client not available");

    final response = await supabase
        .from('service_plans')
        .insert(plan.toMap())
        .select()
        .single();
    return ServicePlanModel.fromMap(response);
  }

  // === Service Plan Options ===

  Future<List<ServicePlanOptionModel>> getPlanOptions(String planId) async {
    final supabase = _supabase;
    if (supabase == null) return [];

    final response = await supabase
        .from('service_plan_options')
        .select()
        .eq('service_plan_id', planId)
        .order('position', ascending: true);
    return response.map((e) => ServicePlanOptionModel.fromMap(e)).toList();
  }

  Future<ServicePlanOptionModel> createPlanOption(ServicePlanOptionModel option) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception("Supabase client not available");

    final response = await supabase
        .from('service_plan_options')
        .insert(option.toMap())
        .select()
        .single();
    return ServicePlanOptionModel.fromMap(response);
  }

  // === Customer Applications (Orders) ===

  Future<OrderModel> submitApplication(OrderModel order) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception("Supabase client not available");

    final response = await supabase
        .from('orders')
        .insert(order.toMap())
        .select()
        .single();
    return OrderModel.fromMap(response, response['id']);
  }

  Future<List<OrderModel>> getPendingApplications() async {
    final supabase = _supabase;
    if (supabase == null) return [];

    final response = await supabase
        .from('orders')
        .select()
        .eq('status', 'PENDING')
        .order('created_at', ascending: false);
        
    final allOrders = response.map((e) => OrderModel.fromMap(e, e['id'])).toList();
    // Filter for Kikoba apps in memory
    return allOrders.where((o) => o.serviceId != null && o.serviceId!.isNotEmpty).toList();
  }

  // === Admin Approval ===

  Future<KikobaAccountModel> approveApplication(OrderModel order, String accountNumber) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception("Supabase client not available");

    // 1. Update order status
    await supabase
        .from('orders')
        .update({'status': 'APPROVED'})
        .eq('id', order.id);

    // 2. Create Kikoba Account
    final account = KikobaAccountModel(
      id: '',
      accountNumber: accountNumber,
      customerId: order.customerId,
      orderId: order.id,
      serviceId: order.serviceId,
      planId: order.servicePlanId,
      optionId: order.optionId,
      totalAmount: order.totalPayable,
      paidAmount: order.amountPaid,
      balance: order.totalPayable - order.amountPaid,
      frequency: 'weekly', // Could extract from plan
      status: 'APPROVED',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final response = await supabase
        .from('kikoba_accounts')
        .insert(account.toMap())
        .select()
        .single();

    return KikobaAccountModel.fromMap(response);
  }

  Future<void> rejectApplication(OrderModel order) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception("Supabase client not available");

    await supabase
        .from('orders')
        .update({'status': 'REJECTED'})
        .eq('id', order.id);
  }

  // === Customer & Admin Kikoba Accounts ===

  Future<List<KikobaAccountModel>> getCustomerKikobaAccounts(String customerId) async {
    final supabase = _supabase;
    if (supabase == null) return [];

    final response = await supabase
        .from('kikoba_accounts')
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    return response.map((e) => KikobaAccountModel.fromMap(e)).toList();
  }

  Future<List<KikobaAccountModel>> getAllAccounts() async {
    final supabase = _supabase;
    if (supabase == null) return [];

    final response = await supabase
        .from('kikoba_accounts')
        .select()
        .order('created_at', ascending: false);

    return response.map((e) => KikobaAccountModel.fromMap(e)).toList();
  }


  // === Installments & Payments ===

  Future<List<KikobaInstallmentModel>> getInstallments(String accountId) async {
    final supabase = _supabase;
    if (supabase == null) return [];

    final response = await supabase
        .from('kikoba_installments')
        .select()
        .eq('kikoba_account_id', accountId)
        .order('created_at', ascending: false);

    return response.map((e) => KikobaInstallmentModel.fromMap(e)).toList();
  }

  Future<KikobaInstallmentModel> recordPayment(KikobaInstallmentModel payment, double currentPaid, double currentBalance) async {
    final supabase = _supabase;
    if (supabase == null) throw Exception("Supabase client not available");

    // 1. Insert Payment
    final paymentResponse = await supabase
        .from('kikoba_installments')
        .insert(payment.toMap())
        .select()
        .single();
        
    final newPayment = KikobaInstallmentModel.fromMap(paymentResponse);

    // 2. Update Account Balance
    final newPaid = currentPaid + payment.amountPaid;
    final newBalance = currentBalance - payment.amountPaid;
    final status = newBalance <= 0 ? 'COMPLETED' : 'ACTIVE';

    await supabase.from('kikoba_accounts').update({
      'paid_amount': newPaid,
      'balance': newBalance,
      'status': status,
    }).eq('id', payment.kikobaAccountId);

    return newPayment;
  }
}

