import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import 'dynamic_kikoba_providers.dart';

// Provider to fetch only PENDING Kikoba applications
final pendingKikobaApplicationsProvider = FutureProvider<List<OrderModel>>((ref) async {
  final repo = ref.watch(dynamicKikobaRepositoryProvider);
  return await repo.getPendingApplications();
});

class KikobaAdminReviewScreen extends ConsumerStatefulWidget {
  const KikobaAdminReviewScreen({super.key});

  @override
  ConsumerState<KikobaAdminReviewScreen> createState() => _KikobaAdminReviewScreenState();
}

class _KikobaAdminReviewScreenState extends ConsumerState<KikobaAdminReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingKikobaApplicationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Review Applications', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: pendingAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox_outlined, size: 64, color: AppColors.border),
                  const SizedBox(height: 16),
                  const Text('No Pending Applications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('All caught up!', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              final snapshot = app.snapshot ?? {};
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(app.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                          const Chip(
                            label: Text('PENDING', style: TextStyle(fontSize: 10, color: AppColors.statusPending)),
                            backgroundColor: Color(0xFFFFF3CD),
                          ),
                        ],
                      ),
                      const Divider(),
                      Text('Customer: ${app.customerName}', style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 8),
                      Text('Service: ${snapshot['service_name'] ?? 'Unknown'}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Plan: ${snapshot['plan_name'] ?? 'Unknown'}'),
                      Text('Total Target: TSH ${NumberFormat('#,###').format(app.totalPayable)}'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                              onPressed: () => _rejectApplication(app),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusAvailable),
                              onPressed: () => _approveApplication(app),
                              child: const Text('Approve', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _approveApplication(OrderModel app) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Approval'),
        content: Text('Are you sure you want to approve ${app.orderNumber} for ${app.customerName}? This will instantly create an active Kikoba Account for them.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusAvailable),
            onPressed: () async {
              Navigator.pop(ctx);
              _processApproval(app);
            },
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );
  }

  Future<void> _processApproval(OrderModel app) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repo = ref.read(dynamicKikobaRepositoryProvider);
      
      // Generate a new Kikoba Account Number
      final kikobaAccNumber = 'ACC-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      
      await repo.approveApplication(app, kikobaAccNumber);

      if (mounted) {
        Navigator.pop(context); // pop loading
        ref.invalidate(pendingKikobaApplicationsProvider);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application Approved & Kikoba Account Created!')));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // pop loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _rejectApplication(OrderModel app) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Rejection', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to reject ${app.orderNumber} for ${app.customerName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              _processRejection(app);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    );
  }

  Future<void> _processRejection(OrderModel app) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repo = ref.read(dynamicKikobaRepositoryProvider);
      
      await repo.rejectApplication(app);

      if (mounted) {
        Navigator.pop(context); // pop loading
        ref.invalidate(pendingKikobaApplicationsProvider);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application Rejected.')));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // pop loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
