import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/kikoba/kikoba_account_model.dart';
import 'dynamic_kikoba_providers.dart';
import 'admin_installments_screen.dart';

final allKikobaAccountsProvider = FutureProvider<List<KikobaAccountModel>>((ref) async {
  final repo = ref.read(dynamicKikobaRepositoryProvider);
  // Ideally, add an admin method getActiveKikobaAccounts() in repo.
  // For now, let's assume getCustomerKikobaAccounts works, wait no, it requires customerId.
  // I need to add getAllAccounts to repo!
  return await repo.getAllAccounts();
});

class KikobaAdminAccountsListScreen extends ConsumerWidget {
  const KikobaAdminAccountsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(allKikobaAccountsProvider);
    final currencyFormat = NumberFormat.currency(symbol: 'TSH ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Active Kikoba Accounts', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(child: Text('No active Kikoba accounts found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final acc = accounts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.account_balance_wallet, color: Colors.white),
                  ),
                  title: Text(acc.accountNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Balance: ${currencyFormat.format(acc.balance)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      Text('Total Target: ${currencyFormat.format(acc.totalAmount)}'),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminInstallmentsScreen(account: acc)),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading accounts: $err')),
      ),
    );
  }
}
