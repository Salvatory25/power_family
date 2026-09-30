import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/kikoba/kikoba_account_model.dart';
import '../dynamic_kikoba_providers.dart';
import '../../auth/auth_controller.dart';
import '../customer_payment_screen.dart';

// Fetch the current user's active kikoba accounts
final myKikobaAccountsProvider = FutureProvider<List<KikobaAccountModel>>((ref) async {
  final user = ref.read(authControllerProvider).value;
  if (user == null) return [];
  final repo = ref.read(dynamicKikobaRepositoryProvider);
  return await repo.getCustomerKikobaAccounts(user.uid);
});

class MyKikobaScreen extends ConsumerWidget {
  const MyKikobaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(myKikobaAccountsProvider);
    final currencyFormat = NumberFormat.currency(symbol: 'TSH ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Kikoba Accounts', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.savings_outlined, size: 80, color: AppColors.border),
                  const SizedBox(height: 16),
                  const Text('No Active Kikoba', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Apply for a Kikoba to start saving today!', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final acc = accounts[index];
              final progress = acc.totalAmount > 0 ? (acc.paidAmount / acc.totalAmount) : 0.0;

              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                shadowColor: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(acc.accountNumber, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary)),
                          Chip(
                            label: Text(acc.status, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                            backgroundColor: acc.status == 'APPROVED' || acc.status == 'ACTIVE' 
                              ? AppColors.statusAvailable 
                              : Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(progress * 100).toStringAsFixed(1)}% Paid', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
                          Text(currencyFormat.format(acc.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        ],
                      ),
                      const Divider(height: 32),
                      
                      // Financial Details
                      _buildDetailRow('Paid Amount', currencyFormat.format(acc.paidAmount), isHighlighted: true),
                      const SizedBox(height: 8),
                      _buildDetailRow('Remaining Balance', currencyFormat.format(acc.balance)),
                      const SizedBox(height: 8),
                      _buildDetailRow('Frequency', acc.frequency.toUpperCase()),
                      const SizedBox(height: 8),
                      _buildDetailRow('Start Date', acc.createdAt.toString().substring(0, 10)),
                      
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CustomerPaymentScreen(account: acc)),
                            );
                          },
                          child: const Text('Make a Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isHighlighted ? AppColors.statusAvailable : AppColors.textPrimary)),
      ],
    );
  }
}
