import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../repositories/seed_data.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class FinanceHubScreen extends ConsumerStatefulWidget {
  const FinanceHubScreen({super.key});

  @override
  ConsumerState<FinanceHubScreen> createState() => _FinanceHubScreenState();
}

class _FinanceHubScreenState extends ConsumerState<FinanceHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showReceiptDialog(BuildContext context, String receiptNo, String customer, double amount, String date) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: AppColors.accent),
            const SizedBox(width: 8),
            Text('Official Receipt $receiptNo', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _receiptRow('Receipt ID', receiptNo),
                  _receiptRow('Customer', customer),
                  _receiptRow('Amount Paid', Formatters.formatCurrency(amount)),
                  _receiptRow('Date Issued', date),
                  _receiptRow('Payment Method', 'Control Number / ClickPesa'),
                  _receiptRow('Status', 'CONFIRMED'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Audit Note: Financial record locked. Modification prohibited under Phase 4 RLS rules.',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading PDF Receipt $receiptNo...')),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
            label: const Text('Print / Download PDF'),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sales = SeedData.sales;
    final totalRevenue = sales.fold<double>(0, (sum, s) => sum + (s.amount * 0.4));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Finance & Receipts Hub', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.description_outlined), text: 'Invoices'),
            Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Receipts'),
            Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Installments'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Financial Summary Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Revenue',
                    value: Formatters.formatCurrency(totalRevenue),
                    icon: Icons.payments_rounded,
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Control Numbers',
                    value: '14 Issued',
                    icon: Icons.qr_code_2_rounded,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Invoices List Tab
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 4,
                  itemBuilder: (context, idx) {
                    final invNo = 'INV-2026-00000${idx + 1}';
                    final amount = 15000000.0 * (idx + 1);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.background,
                          child: Icon(Icons.article_outlined, color: AppColors.primary),
                        ),
                        title: Text(invNo, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Due: 30 Sep 2026 • Control No: 994028471$idx'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(Formatters.formatCurrency(amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            const StatusBadge(status: 'UNPAID'),
                          ],
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Viewing Invoice details for $invNo')),
                          );
                        },
                      ),
                    );
                  },
                ),

                // Receipts Tab (REC-2026-000001)
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sales.length,
                  itemBuilder: (context, idx) {
                    final sale = sales[idx];
                    final customer = SeedData.customers.firstWhere(
                      (c) => c.id == sale.customerId,
                      orElse: () => SeedData.customers.first,
                    );
                    final property = SeedData.properties.firstWhere(
                      (p) => p.id == sale.propertyId,
                      orElse: () => SeedData.properties.first,
                    );
                    final depositPaid = sale.amount * 0.4;
                    final recNo = 'REC-2026-00000${idx + 1}';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFECFDF5),
                          child: Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
                        ),
                        title: Text(recNo, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Customer: ${customer.fullName} • Property: ${property.title}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(Formatters.formatCurrency(depositPaid), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                            const SizedBox(height: 4),
                            const StatusBadge(status: 'CONFIRMED'),
                          ],
                        ),
                        onTap: () {
                          _showReceiptDialog(context, recNo, customer.fullName, depositPaid, '14 Sep 2026');
                        },
                      ),
                    );
                  },
                ),

                // Installments Tab
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sales.length,
                  itemBuilder: (context, idx) {
                    final sale = sales[idx];
                    final customer = SeedData.customers.firstWhere(
                      (c) => c.id == sale.customerId,
                      orElse: () => SeedData.customers.first,
                    );
                    final property = SeedData.properties.firstWhere(
                      (p) => p.id == sale.propertyId,
                      orElse: () => SeedData.properties.first,
                    );
                    final depositPaid = sale.amount * 0.4;
                    final salePrice = sale.amount;
                    final balance = salePrice - depositPaid;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const StatusBadge(status: 'INSTALLMENT'),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Property: ${property.title}'),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: (depositPaid / salePrice).clamp(0.0, 1.0),
                              backgroundColor: AppColors.border,
                              color: AppColors.accent,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Paid: ${Formatters.formatCurrency(depositPaid)}', style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                                Text('Balance: ${Formatters.formatCurrency(balance)}', style: const TextStyle(fontSize: 12, color: Color(0xFFF43F5E), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
