import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/sale_model.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/seed_data.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/status_badge.dart';

final salesRepositoryProvider = Provider((ref) => SalesRepository());

class SalesListScreen extends ConsumerStatefulWidget {
  const SalesListScreen({super.key});

  @override
  ConsumerState<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends ConsumerState<SalesListScreen> {
  List<SaleModel> _sales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() => _isLoading = true);
    final repo = ref.read(salesRepositoryProvider);
    final list = await repo.getSales();
    setState(() {
      _sales = list;
      _isLoading = false;
    });
  }

  void _showRecordSaleModal() {
    String selectedProperty = SeedData.properties[0].id;
    String selectedCustomer = SeedData.customers[0].id;
    String selectedAgent = SeedData.users.firstWhere((u) => u.role == 'sales_agent', orElse: () => SeedData.users[0]).uid;
    final amountCtrl = TextEditingController(text: SeedData.properties[0].price.toStringAsFixed(0));
    String selectedPaymentStatus = AppConstants.paymentPaid;
    String selectedSaleStatus = AppConstants.saleCompleted;
    final notesCtrl = TextEditingController(text: 'Full payment received. Title transfer in progress.');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Record Completed / Installment Sale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              const Text('Select Sold Property:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedProperty,
                decoration: const InputDecoration(filled: true),
                items: SeedData.properties.map((p) {
                  return DropdownMenuItem(value: p.id, child: Text('${p.propertyCode} - ${p.title}'));
                }).toList(),
                onChanged: (val) => selectedProperty = val!,
              ),
              const SizedBox(height: 12),

              const Text('Select Buyer (Customer):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedCustomer,
                decoration: const InputDecoration(filled: true),
                items: SeedData.customers.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.fullName));
                }).toList(),
                onChanged: (val) => selectedCustomer = val!,
              ),
              const SizedBox(height: 12),

              AppTextField(label: 'Sale Amount (TZS)', controller: amountCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 12),

              const Text('Payment Status:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedPaymentStatus,
                decoration: const InputDecoration(filled: true),
                items: const [
                  DropdownMenuItem(value: AppConstants.paymentPaid, child: Text('Paid in Full')),
                  DropdownMenuItem(value: AppConstants.paymentPartial, child: Text('Partial / Installments')),
                  DropdownMenuItem(value: AppConstants.paymentPending, child: Text('Payment Pending')),
                ],
                onChanged: (val) => selectedPaymentStatus = val!,
              ),
              const SizedBox(height: 12),

              AppTextField(label: 'Sales Notes', controller: notesCtrl, maxLines: 2),
              const SizedBox(height: 20),

              AppButton(
                text: 'Record Sale Transaction',
                onPressed: () async {
                  final newSale = SaleModel(
                    id: 'sale_${DateTime.now().millisecondsSinceEpoch}',
                    propertyId: selectedProperty,
                    customerId: selectedCustomer,
                    agentId: selectedAgent,
                    branchId: SeedData.branches[0].id,
                    amount: double.tryParse(amountCtrl.text) ?? 0,
                    paymentStatus: selectedPaymentStatus,
                    saleStatus: selectedSaleStatus,
                    notes: notesCtrl.text.trim(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  final repo = ref.read(salesRepositoryProvider);
                  await repo.recordSale(newSale);
                  Navigator.pop(ctx);
                  _loadSales();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sale recorded! Property status updated to SOLD.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double grandTotalRevenue = _sales.fold(0, (sum, s) => sum + s.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: _showRecordSaleModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Revenue Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: AppColors.primary,
                  child: Column(
                    children: [
                      const Text('Total Revenue Closed', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatCurrency(grandTotalRevenue),
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text('${_sales.length} Verified Sales Transactions', style: const TextStyle(color: AppColors.accent, fontSize: 12)),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sales.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final sale = _sales[index];
                      final cust = SeedData.customers.firstWhere((c) => c.id == sale.customerId, orElse: () => SeedData.customers[0]);
                      final prop = SeedData.properties.firstWhere((p) => p.id == sale.propertyId, orElse: () => SeedData.properties[0]);

                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.statusAvailable,
                            child: Icon(Icons.check, color: Colors.white),
                          ),
                          title: Text(Formatters.formatCurrency(sale.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text('Buyer: ${cust.fullName}\nProperty: ${prop.propertyCode} - ${prop.title}', style: const TextStyle(fontSize: 12)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              StatusBadge(status: sale.paymentStatus),
                              const SizedBox(height: 4),
                              Text(Formatters.formatDate(sale.createdAt), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
