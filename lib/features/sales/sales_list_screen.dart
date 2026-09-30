import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/sale_model.dart';
import '../../repositories/sales_repository.dart';
import '../dashboard/dashboard_providers.dart';
import '../auth/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/header_background.dart';
import '../../widgets/loading_view.dart';

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
    Future.microtask(() => _loadSales());
  }

  Future<void> _loadSales() async {
    setState(() => _isLoading = true);
    final user = ref.read(authControllerProvider).value;
    final isAdmin = user?.role.toUpperCase() == AppConstants.roleSuperAdmin || 
                    user?.role.toUpperCase() == AppConstants.roleSystemAdmin;
    final filterBranchId = isAdmin ? null : user?.branchId;

    final repo = ref.read(salesRepositoryProvider);
    final list = await repo.getSales(branchId: filterBranchId);
    
    // SYNCHRONIZATION FALLBACK:
    // Some properties might be marked as 'SOLD' but the user hasn't explicitly created a sale record yet.
    // To ensure the ledger revenue exactly matches the dashboard, we construct legacy sales on the fly.
    final propertyRepo = ref.read(propertyRepoProvider);
    final properties = await propertyRepo.getProperties(branchId: filterBranchId);
    final soldProperties = properties.where((p) => p.status == AppConstants.propertySold).toList();
    
    final List<SaleModel> allSales = List.from(list);
    
    for (var prop in soldProperties) {
      if (!allSales.any((s) => s.propertyId == prop.id)) {
        allSales.add(SaleModel(
          id: 'legacy_sale_${prop.id}',
          propertyId: prop.id,
          customerId: 'legacy',
          agentId: prop.assignedAgentId ?? 'system',
          branchId: prop.branchId,
          amount: prop.price,
          paymentStatus: AppConstants.paymentPaid,
          saleStatus: AppConstants.saleCompleted,
          createdAt: prop.updatedAt,
          updatedAt: prop.updatedAt,
          notes: 'Auto-synchronized legacy sale',
        ));
      }
    }
    
    allSales.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _sales = allSales;
      _isLoading = false;
    });
  }

  void _showRecordSaleModal() {
    final properties = ref.read(propertiesProvider).value ?? [];
    final customers = ref.read(customersProvider).value ?? [];
    final users = ref.read(usersProvider).value ?? [];
    final branches = ref.read(branchesProvider).value ?? [];

    String selectedProperty = properties.isNotEmpty ? properties.first.id : '';
    String selectedCustomer = customers.isNotEmpty ? customers.first.id : '';
    final agents = users.where((u) => u.role.toLowerCase() == 'sales_agent').toList();
    String selectedAgent = agents.isNotEmpty ? agents.first.uid : (users.isNotEmpty ? users.first.uid : '');
    final amountCtrl = TextEditingController(text: properties.isNotEmpty ? properties.first.price.toStringAsFixed(0) : '0');
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
                value: selectedProperty.isNotEmpty ? selectedProperty : null,
                decoration: const InputDecoration(filled: true, hintText: 'Select Property'),
                items: properties.map((p) {
                  return DropdownMenuItem(value: p.id, child: Text('${p.propertyCode} - ${p.title}'));
                }).toList(),
                onChanged: (val) { if (val != null) selectedProperty = val; },
              ),
              const SizedBox(height: 12),

              const Text('Select Buyer (Customer):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedCustomer.isNotEmpty ? selectedCustomer : null,
                decoration: const InputDecoration(filled: true, hintText: 'Select Customer'),
                items: customers.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.fullName));
                }).toList(),
                onChanged: (val) { if (val != null) selectedCustomer = val; },
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
                  if (selectedProperty.isEmpty || selectedCustomer.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select property and customer first.')));
                    return;
                  }
                  final newSale = SaleModel(
                    id: 'sale_${DateTime.now().millisecondsSinceEpoch}',
                    propertyId: selectedProperty,
                    customerId: selectedCustomer,
                    agentId: selectedAgent,
                    branchId: branches.isNotEmpty ? branches.first.id : '',
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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          HeaderBackground(
            height: 250,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BackButton(color: Colors.white),
                        IconButton(
                          onPressed: _showRecordSaleModal,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.add_shopping_cart, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sales Ledger',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Realized Revenue',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatCurrency(grandTotalRevenue),
                      style: GoogleFonts.outfit(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.statusAvailable,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 230),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
              ),
              child: _isLoading
                  ? const LoadingView()
                  : _sales.isEmpty
                      ? Center(
                          child: Text(
                            'No sales transactions found.',
                            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 16),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
                          itemCount: _sales.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final sale = _sales[index];

                            final customers = ref.read(customersProvider).value ?? [];
                            final properties = ref.read(propertiesProvider).value ?? [];
                            final custMatches = customers.where((c) => c.id == sale.customerId).toList();
                            final custName = custMatches.isNotEmpty ? custMatches.first.fullName : 'Buyer';
                            final propMatches = properties.where((p) => p.id == sale.propertyId).toList();
                            final propTitle = propMatches.isNotEmpty ? '${propMatches.first.propertyCode} - ${propMatches.first.title}' : 'Property Transaction';

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
                                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.statusAvailable.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.check_circle_outline, color: AppColors.statusAvailable, size: 24),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                Formatters.formatCurrency(sale.amount),
                                                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Buyer: $custName',
                                                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        StatusBadge(status: sale.paymentStatus),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.maps_home_work_outlined, size: 16, color: AppColors.primary),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              propTitle,
                                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16.0),
                                      child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Recorded: ${Formatters.formatDate(sale.createdAt)}',
                                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
