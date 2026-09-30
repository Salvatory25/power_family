import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/kikoba/kikoba_account_model.dart';
import '../../../models/kikoba/kikoba_installment_model.dart';
import 'dynamic_kikoba_providers.dart';

final accountInstallmentsProvider = FutureProvider.family<List<KikobaInstallmentModel>, String>((ref, accountId) async {
  final repo = ref.read(dynamicKikobaRepositoryProvider);
  return await repo.getInstallments(accountId);
});

class AdminInstallmentsScreen extends ConsumerStatefulWidget {
  final KikobaAccountModel account;

  const AdminInstallmentsScreen({super.key, required this.account});

  @override
  ConsumerState<AdminInstallmentsScreen> createState() => _AdminInstallmentsScreenState();
}

class _AdminInstallmentsScreenState extends ConsumerState<AdminInstallmentsScreen> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedMethod = 'CASH';
  bool _isLoading = false;
  late KikobaAccountModel _currentAccount;

  @override
  void initState() {
    super.initState();
    _currentAccount = widget.account;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddPaymentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Record Manual Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount Paid (TSH)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _selectedMethod,
                  decoration: InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['CASH', 'BANK TRANSFER', 'M-PESA', 'TIGO PESA', 'AIRTEL MONEY'].map((m) {
                    return DropdownMenuItem(value: m, child: Text(m));
                  }).toList(),
                  onChanged: (val) => setModalState(() => _selectedMethod = val!),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes / Reference (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: _isLoading ? null : () => _recordPayment(context),
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }
        ),
      ),
    );
  }

  Future<void> _recordPayment(BuildContext modalContext) async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payment = KikobaInstallmentModel(
        id: '', 
        kikobaAccountId: _currentAccount.id,
        amountPaid: amount,
        paymentMethod: _selectedMethod,
        notes: _notesController.text.trim(),
        paidAt: DateTime.now(),
        status: 'COMPLETED',
      );

      final repo = ref.read(dynamicKikobaRepositoryProvider);
      await repo.recordPayment(payment, _currentAccount.paidAmount, _currentAccount.balance);
      
      // Update local state to reflect new balance without requerying the full account
      setState(() {
        _currentAccount = _currentAccount.copyWith(
          paidAmount: _currentAccount.paidAmount + amount,
          balance: _currentAccount.balance - amount,
          status: (_currentAccount.balance - amount) <= 0 ? 'COMPLETED' : 'ACTIVE',
        );
      });

      ref.invalidate(accountInstallmentsProvider(_currentAccount.id));

      if (!mounted) return;
      Navigator.pop(modalContext); // close modal
      _amountController.clear();
      _notesController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final installmentsAsync = ref.watch(accountInstallmentsProvider(_currentAccount.id));
    final currencyFormat = NumberFormat.currency(symbol: 'TSH ', decimalDigits: 0);
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Installments: ${_currentAccount.accountNumber}', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _currentAccount.balance <= 0 ? null : _showAddPaymentModal,
        backgroundColor: _currentAccount.balance <= 0 ? Colors.grey : AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Record Payment', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Summary Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Paid', style: TextStyle(color: AppColors.textSecondary)),
                    Text(currencyFormat.format(_currentAccount.paidAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.statusAvailable)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Balance', style: TextStyle(color: AppColors.textSecondary)),
                    Text(currencyFormat.format(_currentAccount.balance), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
                  ],
                )
              ],
            ),
          ),
          
          Expanded(
            child: installmentsAsync.when(
              data: (installments) {
                if (installments.isEmpty) {
                  return const Center(child: Text('No payments recorded yet.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: installments.length,
                  itemBuilder: (context, index) {
                    final inst = installments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.check_circle, color: AppColors.primary),
                        ),
                        title: Text(currencyFormat.format(inst.amountPaid), style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dateFormat.format(inst.paidAt)),
                            Text('Method: ${inst.paymentMethod}', style: const TextStyle(fontSize: 12)),
                            if (inst.notes != null && inst.notes!.isNotEmpty)
                              Text('Notes: ${inst.notes}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Chip(
                          label: Text(inst.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                          backgroundColor: Colors.green,
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
