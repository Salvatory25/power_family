import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';
import '../../../models/property_model.dart';
import '../../../models/order_model.dart';
import '../../../repositories/order_repository.dart';
import '../../../repositories/notification_repository.dart';
import '../../auth/auth_controller.dart';

class PaymentSubmissionScreen extends ConsumerStatefulWidget {
  final PropertyModel property;
  final String plan;

  const PaymentSubmissionScreen({super.key, required this.property, required this.plan});

  @override
  ConsumerState<PaymentSubmissionScreen> createState() => _PaymentSubmissionScreenState();
}

class _PaymentSubmissionScreenState extends ConsumerState<PaymentSubmissionScreen> {
  final _amountCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  String _selectedMethod = 'BANK';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = widget.property.price.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _referenceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    if (_referenceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a transaction reference ID')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      final user = ref.read(authControllerProvider).value;
      if (user == null) throw Exception('User not logged in');

      final now = DateTime.now();
      final datePart = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
      final randomPart = math.Random().nextInt(9999).toString().padLeft(4, '0');
      final orderNum = "ORD-$datePart-$randomPart";

      final order = OrderModel(
        id: '',
        orderNumber: orderNum,
        customerId: user.uid,
        customerName: user.fullName,
        propertyId: widget.property.id,
        branchId: widget.property.branchId,
        acquisitionPlan: widget.plan,
        totalPayable: widget.property.price,
        amountPaid: double.tryParse(_amountCtrl.text) ?? widget.property.price,
        status: 'PENDING',
        paymentStatus: 'PENDING',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = OrderRepository();
      await repo.createOrder(order);

      // Notify admins and branch manager
      try {
        final notifRepo = NotificationRepository();
        
        final String detailedMessage = '''
New Payment Submitted

CUSTOMER DETAILS:
Name: ${user.fullName}
Phone: ${user.phone}
Email: ${user.email}

PROPERTY DETAILS:
Code: ${widget.property.propertyCode}
Type: ${widget.property.type}
Location: ${widget.property.location}, ${widget.property.region}
Price: ${widget.property.price} TZS
Size: ${widget.property.size ?? 'N/A'}

ORDER DETAILS:
Plan: ${widget.plan}
Amount Paid: ${_amountCtrl.text} TZS
Reference: ${_referenceCtrl.text}

Please confirm this payment by contacting the customer directly.''';

        await notifRepo.notifyAdminsAndManager(
          branchId: widget.property.branchId,
          title: 'New Property Payment (${widget.property.propertyCode})',
          message: detailedMessage,
          type: 'PAYMENT',
        );
      } catch (e) {
        debugPrint('Failed to send notifications: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order submitted successfully! Waiting for verification.')),
        );
        context.go('/my-orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting order: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Submit Payment', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Instructions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bank Name: CRDB Bank', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Account Name: Power Family Investment Ltd'),
                  Text('Account Number: 015049382910'),
                  SizedBox(height: 8),
                  Text('Or via Mobile Money (Lipa Namba):'),
                  Text('M-Pesa: 5893022', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text('Payment Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              decoration: const InputDecoration(labelText: 'Payment Method', filled: true),
              items: const [
                DropdownMenuItem(value: 'BANK', child: Text('Bank Transfer')),
                DropdownMenuItem(value: 'MOBILE_MONEY', child: Text('Mobile Money')),
                DropdownMenuItem(value: 'CASH', child: Text('Cash at Branch')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedMethod = val);
              },
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Amount Paid (TZS)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _referenceCtrl,
              decoration: const InputDecoration(
                labelText: 'Transaction Reference ID',
                hintText: 'e.g. 5A9F8E7D or Receipt Number',
              ),
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSubmitting ? null : _submitPayment,
                child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
