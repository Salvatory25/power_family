import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../models/kikoba/service_model.dart';
import '../../models/kikoba/service_plan_model.dart';
import '../../models/order_model.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/notifications/notification_controller.dart';
import 'dynamic_kikoba_providers.dart';

class CustomerKikobaApplicationScreen extends ConsumerStatefulWidget {
  const CustomerKikobaApplicationScreen({super.key});

  @override
  ConsumerState<CustomerKikobaApplicationScreen> createState() => _CustomerKikobaApplicationScreenState();
}

class _CustomerKikobaApplicationScreenState extends ConsumerState<CustomerKikobaApplicationScreen> {
  ServiceModel? _selectedService;
  ServicePlanModel? _selectedPlan;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(kikobaServicesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Apply for Kikoba', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: servicesAsync.when(
        data: (services) {
          if (services.isEmpty) {
            return const Center(child: Text('No active Kikoba services available.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                
                // 1. Select Service
                const Text('1. Select Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                _buildServiceDropdown(services),
                
                // 2. Select Plan (if service selected)
                if (_selectedService != null) ...[
                  const SizedBox(height: 32),
                  const Text('2. Choose Payment Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildPlansSection(),
                ],

                // 3. Submit
                if (_selectedPlan != null) ...[
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isSubmitting ? null : _submitApplication,
                      child: _isSubmitting 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Application', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ]
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          Icon(Icons.savings_outlined, color: Colors.white, size: 48),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kikoba Application', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Secure your future, step by step.', style: TextStyle(color: Colors.white70)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildServiceDropdown(List<ServiceModel> services) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ServiceModel>(
          isExpanded: true,
          hint: const Text('Select a Kikoba Service...'),
          value: _selectedService,
          items: services.map((s) => DropdownMenuItem(
            value: s,
            child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          )).toList(),
          onChanged: (val) {
            setState(() {
              _selectedService = val;
              _selectedPlan = null; // Reset plan when service changes
            });
          },
        ),
      ),
    );
  }

  Widget _buildPlansSection() {
    final plansAsync = ref.watch(kikobaPlansProvider(_selectedService!.id));

    return plansAsync.when(
      data: (plans) {
        if (plans.isEmpty) return const Text('No plans available for this service yet.');
        
        return Column(
          children: plans.map((plan) {
            final isSelected = _selectedPlan?.id == plan.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedPlan = plan),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.surface,
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Radio<ServicePlanModel>(
                      value: plan,
                      groupValue: _selectedPlan,
                      onChanged: (val) => setState(() => _selectedPlan = val),
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Min: TSH ${plan.minPayment} - Max: TSH ${plan.maxPayment}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          Text('Duration: ${plan.durationValue} ${plan.durationUnit}s', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading plans: $e'),
    );
  }

  Future<void> _submitApplication() async {
    final user = ref.read(authControllerProvider).value;
    if (user == null || _selectedService == null || _selectedPlan == null) return;

    setState(() => _isSubmitting = true);
    
    try {
      final newOrder = OrderModel(
        id: '', // Supabase gen
        orderNumber: 'KB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}', // Temp generation
        customerId: user.uid,
        customerName: user.fullName ?? 'Customer',
        propertyId: '', // Will be null in DB
        branchId: '', // Will be null in DB
        acquisitionPlan: 'KIKOBA',
        totalPayable: _selectedPlan!.maxPayment,
        amountPaid: 0.0,
        status: 'PENDING',
        paymentStatus: 'PENDING',
        serviceId: _selectedService!.id,
        servicePlanId: _selectedPlan!.id,
        snapshot: {
          'service_name': _selectedService!.name,
          'plan_name': _selectedPlan!.name,
          'frequency': _selectedPlan!.frequency,
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(dynamicKikobaRepositoryProvider).submitApplication(newOrder);

      // Notify Admins
      try {
        await ref.read(notificationRepositoryProvider).notifyAllAdmins(
          title: 'New Kikoba Application',
          message: "\${user.fullName ?? 'A customer'} applied for \${_selectedService!.name}",
          type: 'ORDER',
        );
      } catch (e) {
        // Soft fail on notification error
        debugPrint('Failed to send notification: $e');
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Note: Notification failed: $e')));
        }
      }

      setState(() => _isSubmitting = false);
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Column(
              children: [
                Icon(Icons.check_circle, color: AppColors.statusAvailable, size: 64),
                SizedBox(height: 16),
                Text('Application Received!'),
              ],
            ),
            content: const Text(
              'Your Kikoba application has been submitted successfully. An Admin will review it shortly.',
              textAlign: TextAlign.center,
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Back to Home', style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }
}
