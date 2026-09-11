import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../repositories/seed_data.dart';

import '../../widgets/app_logo.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final properties = SeedData.properties;
    final sales = SeedData.sales;
    final branches = SeedData.branches;

    final totalSalesVal = sales.fold<double>(0, (sum, s) => sum + s.amount);
    final kiwanjaCount = properties.where((p) => p.type == 'kiwanja').length;
    final nyumbaCount = properties.where((p) => p.type == 'nyumba').length;
    final gariCount = properties.where((p) => p.type == 'gari').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Header Card with Official Logo
            Card(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Center(
                      child: AppLogo(size: 52, isDarkBackground: true, showText: true),
                    ),
                    const Divider(height: 24, color: Colors.white24),
                    const Text('Total Realized Revenue', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatCurrency(totalSalesVal),
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text('${sales.length} Deals Closed Across ${branches.length} Branches', style: const TextStyle(color: AppColors.accent, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Portfolio Distribution Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _barReportItem('Viwanja (Land Plots)', kiwanjaCount, properties.length, AppColors.accent),
                    const SizedBox(height: 12),
                    _barReportItem('Nyumba (Residential Houses)', nyumbaCount, properties.length, AppColors.primary),
                    const SizedBox(height: 12),
                    _barReportItem('Magari (Vehicles)', gariCount, properties.length, AppColors.statusUnderProcess),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text('Branch Sales Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: branches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final b = branches[index];
                final bSales = sales.where((s) => s.branchId == b.id).toList();
                final bRevenue = bSales.fold<double>(0, (sum, s) => sum + s.amount);

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.surfaceVariant,
                      child: Icon(Icons.storefront, color: AppColors.primary),
                    ),
                    title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('${bSales.length} Sales Closed', style: const TextStyle(fontSize: 12)),
                    trailing: Text(
                      Formatters.formatCurrency(bRevenue),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.statusAvailable, fontSize: 13),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _barReportItem(String label, int count, int total, Color color) {
    final double percent = total > 0 ? count / total : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            Text('$count Items (${(percent * 100).toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percent,
          minHeight: 8,
          backgroundColor: AppColors.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}
