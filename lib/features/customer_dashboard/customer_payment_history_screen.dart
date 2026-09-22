import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomerPaymentHistoryScreen extends StatelessWidget {
  const CustomerPaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Payment History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You have no transaction records yet. Once you make a payment for a property, your receipts will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
