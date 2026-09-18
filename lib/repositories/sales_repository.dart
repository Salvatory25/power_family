import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sale_model.dart';
import '../core/constants/app_constants.dart';
import 'property_repository.dart';

class SalesRepository {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  final PropertyRepository _propertyRepo = PropertyRepository();

  Future<String?> _resolveBranchUuid(SupabaseClient supabase, String? requestedId) async {
    try {
      if (requestedId != null && requestedId.length == 36 && requestedId.contains('-')) {
        return requestedId;
      }
      final res = await supabase.from('branches').select('id').limit(1);
      if (res != null && (res as List).isNotEmpty) {
        return res.first['id'].toString();
      }
      final inserted = await supabase.from('branches').insert({
        'name': 'Dar es Salaam HQ',
        'code': 'PF-DAR',
        'region': 'Dar es Salaam',
        'district': 'Kinondoni',
        'phone': '+255 712 000 111',
        'email': 'dar@powerfamily.co.tz',
      }).select().single();
      return inserted['id'].toString();
    } catch (e) {
      print('Error resolving branch UUID: $e');
      return null;
    }
  }

  Future<String?> _resolveProjectUuid(SupabaseClient supabase, String branchUuid) async {
    try {
      final res = await supabase.from('projects').select('id').limit(1);
      if (res != null && (res as List).isNotEmpty) {
        return res.first['id'].toString();
      }
      final inserted = await supabase.from('projects').insert({
        'branch_id': branchUuid,
        'project_code': 'PRJ-PF-001',
        'name': 'Power Family Main Project',
        'region': 'Dar es Salaam',
        'district': 'Kigamboni',
        'total_area_sqm': 50000.0,
      }).select().single();
      return inserted['id'].toString();
    } catch (e) {
      print('Error resolving project UUID: $e');
      return null;
    }
  }

  Future<List<SaleModel>> getSales({String? branchId, String? agentId}) async {
    List<SaleModel> list = [];
    try {
      final supabase = _supabase;
      if (supabase != null) {
        var query = supabase.from('sales').select();
        if (branchId != null && branchId.isNotEmpty && branchId.length == 36) {
          query = query.eq('branch_id', branchId);
        }
        final response = await query;
        if (response != null && (response as List).isNotEmpty) {
          final List<SaleModel> mappedList = [];
          for (final rawItem in (response as List)) {
            final map = rawItem as Map<String, dynamic>;
            mappedList.add(SaleModel(
              id: (map['id'] ?? map['sale_id'] ?? '').toString(),
              propertyId: (map['plot_id'] ?? '').toString(),
              customerId: (map['customer_id'] ?? '').toString(),
              agentId: (map['sales_agent_id'] ?? '').toString(),
              branchId: (map['branch_id'] ?? '').toString(),
              amount: (map['agreed_price'] as num?)?.toDouble() ?? 15000000.0,
              paymentStatus: (map['payment_plan_type'] ?? 'installment').toString(),
              saleStatus: (map['sale_status'] ?? 'ACTIVE').toString(),
              notes: (map['notes'] ?? '').toString(),
              createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
              updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
            ));
          }
          list = mappedList;
        }
      }
    } catch (e) {
      print('Error loading sales: $e');
    }


    return list;
  }

  Future<SaleModel> recordSale(SaleModel sale) async {
    SaleModel created = sale;
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final branchUuid = await _resolveBranchUuid(supabase, sale.branchId);
        if (branchUuid == null) throw Exception('Branch resolution failed');
        final projectUuid = await _resolveProjectUuid(supabase, branchUuid);
        if (projectUuid == null) throw Exception('Project resolution failed');

        String plotUuid = sale.propertyId;
        if (plotUuid.isEmpty || plotUuid.length != 36) {
          final plotsRes = await supabase.from('plots').select('id').limit(1);
          if (plotsRes != null && (plotsRes as List).isNotEmpty) {
            plotUuid = plotsRes.first['id'].toString();
          } else {
            final newPlot = await supabase.from('plots').insert({
              'plot_id': 'PFI-KW-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
              'plot_number': '001',
              'block_name': 'Block A',
              'project_id': projectUuid,
              'branch_id': branchUuid,
              'region': 'Dar es Salaam',
              'district': 'Kigamboni',
              'area_sqm': 500.0,
              'list_price': sale.amount,
              'availability_status': 'AVAILABLE',
            }).select().single();
            plotUuid = newPlot['id'].toString();
          }
        }

        String customerUuid = sale.customerId;
        if (customerUuid.isEmpty || customerUuid.length != 36) {
          final custRes = await supabase.from('customers').select('id').limit(1);
          if (custRes != null && (custRes as List).isNotEmpty) {
            customerUuid = custRes.first['id'].toString();
          } else {
            final newCust = await supabase.from('customers').insert({
              'customer_id': 'PFI-CUST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
              'first_name': 'Client',
              'last_name': 'Buyer',
              'phone': '+255 715 000 000',
              'phone_normalized': '255715000000',
              'branch_id': branchUuid,
              'status': 'ACTIVE',
            }).select().single();
            customerUuid = newCust['id'].toString();
          }
        }

        final saleCode = 'PFI-SLE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

        final inserted = await supabase.from('sales').insert({
          'sale_id': saleCode,
          'branch_id': branchUuid,
          'customer_id': customerUuid,
          'plot_id': plotUuid,
          'project_id': projectUuid,
          'agreed_price': sale.amount,
          'deposit_amount': sale.amount * 0.4,
          'balance_amount': sale.amount * 0.6,
          'payment_plan_type': sale.paymentStatus,
          'sale_status': sale.saleStatus.toUpperCase(),
          'notes': sale.notes,
        }).select().single();

        if (sale.saleStatus == AppConstants.saleCompleted) {
          await _propertyRepo.updatePropertyStatus(plotUuid, AppConstants.propertySold);
        }

        created = SaleModel(
          id: inserted['id'].toString(),
          propertyId: plotUuid,
          customerId: customerUuid,
          agentId: sale.agentId,
          branchId: branchUuid,
          amount: sale.amount,
          paymentStatus: sale.paymentStatus,
          saleStatus: sale.saleStatus,
          notes: sale.notes,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error recording sale in Supabase: $e');
    }


    return created;
  }
}
