import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/kikoba/kikoba_account_model.dart';
import '../../../models/kikoba/kikoba_installment_model.dart';
import 'dynamic_kikoba_providers.dart';
import 'screens/my_kikoba_screen.dart';

class CustomerPaymentScreen extends ConsumerStatefulWidget {
  final KikobaAccountModel account;

  const CustomerPaymentScreen({super.key, required this.account});

  @override
  ConsumerState<CustomerPaymentScreen> createState() => _CustomerPaymentScreenState();
}

class _CustomerPaymentScreenState extends ConsumerState<CustomerPaymentScreen> {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String _selectedMethod = 'M-PESA';

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0 || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount and phone number')));
      return;
    }
    
    if (amount > widget.account.balance) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Amount exceeds remaining balance of TSH \${widget.account.balance}')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate Payment Gateway Delay
      await Future.delayed(const Duration(seconds: 2));

      final payment = KikobaInstallmentModel(
        id: '', // Supabase will auto-generate
        kikobaAccountId: widget.account.id,
        amountPaid: amount,
        paymentMethod: _selectedMethod,
        referenceNumber: 'TXN-\${DateTime.now().millisecondsSinceEpoch}',
        paidAt: DateTime.now(),
        status: 'COMPLETED',
        notes: 'Mobile payment via \$_selectedMethod',
      );

      final repo = ref.read(dynamicKikobaRepositoryProvider);
      await repo.recordPayment(payment, widget.account.paidAmount, widget.account.balance);
      
      // Refresh My Kikoba Accounts
      ref.invalidate(myKikobaAccountsProvider);

      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'TSH ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Make a Payment', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account: \${widget.account.accountNumber}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Remaining Balance: \${currencyFormat.format(widget.account.balance)}', style: const TextStyle(fontSize: 16, color: AppColors.accent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            
            const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: ['M-PESA', 'TIGO PESA', 'AIRTEL MONEY', 'HALOPESA'].map((m) {
                return DropdownMenuItem(value: m, child: Text(m));
              }).toList(),
              onChanged: (val) => setState(() => _selectedMethod = val!),
            ),
            
            const SizedBox(height: 24),
            const Text('Mobile Number', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'e.g. 07XXXXXXXX',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            
            const SizedBox(height: 24),
            const Text('Amount to Pay (TSH)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter amount',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _processPayment,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm Payment', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
