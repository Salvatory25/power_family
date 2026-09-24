import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/property_model.dart';

class AcquisitionFlowScreen extends ConsumerStatefulWidget {
  final PropertyModel property;
  const AcquisitionFlowScreen({super.key, required this.property});

  @override
  ConsumerState<AcquisitionFlowScreen> createState() => _AcquisitionFlowScreenState();
}

class _AcquisitionFlowScreenState extends ConsumerState<AcquisitionFlowScreen> {
  String? _selectedPlan;

  @override
  Widget build(BuildContext context) {
    final plans = widget.property.allowedAcquisitionPlans;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Acquire Property', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.property.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Price: TZS ${widget.property.price}', style: const TextStyle(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 32),

            const Text('Select Acquisition Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            if (plans.isEmpty)
              const Text('No acquisition plans available for this property.', style: TextStyle(color: Colors.red)),

            ...plans.map((plan) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: _selectedPlan == plan ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RadioListTile<String>(
                  title: Text(_getPlanLabel(plan), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_getPlanDescription(plan)),
                  value: plan,
                  groupValue: _selectedPlan,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _selectedPlan = val;
                    });
                  },
                ),
              );
            }).toList(),

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
                onPressed: _selectedPlan == null ? null : () {
                  context.push('/orders/payment-submission', extra: {
                    'property': widget.property,
                    'plan': _selectedPlan,
                  });
                },
                child: const Text('Proceed to Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPlanLabel(String plan) {
    switch (plan) {
      case 'FULL_PAYMENT': return 'Full Payment';
      case 'INSTALLMENT': return 'Installment Plan';
      case 'KIKOBA': return 'Kikoba Package';
      default: return plan;
    }
  }

  String _getPlanDescription(String plan) {
    switch (plan) {
      case 'FULL_PAYMENT': return 'Pay the full amount upfront.';
      case 'INSTALLMENT': return 'Pay in structured installments over time.';
      case 'KIKOBA': return 'Join a Kikoba savings group to acquire this.';
      default: return '';
    }
  }
}
