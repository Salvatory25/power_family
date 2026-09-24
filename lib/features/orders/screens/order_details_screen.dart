import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../../models/order_model.dart';
import '../../../models/payment_model.dart';
import '../../../repositories/payment_repository.dart';
import '../../../repositories/order_repository.dart';

final orderPaymentsProvider = FutureProvider.family<List<PaymentModel>, String>((ref, orderId) async {
  final repo = PaymentRepository();
  final all = await repo.getPayments();
  return all.where((p) => p.referenceId == orderId).toList();
});

class OrderDetailsScreen extends ConsumerWidget {
  final OrderModel order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(orderPaymentsProvider(order.id));
    final balance = order.totalPayable - order.amountPaid;
    final progress = (order.amountPaid / order.totalPayable).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Order #${order.orderNumber}', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Delete Order',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Order'),
                  content: const Text('Are you sure you want to delete this order? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  final repo = OrderRepository();
                  await repo.deleteOrder(order.id);
                  // Ignore context rules for simple pop here since we checked mounted if it was stateful,
                  // but in a stateless widget we can just pop.
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order deleted successfully.')),
                    );
                    context.pop(); // Go back to My Orders
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete order: $e')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paid: TZS ${order.amountPaid}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                Text('Balance: TZS $balance', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 32),

            const Text('Order Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInfoRow('Status', order.status),
            _buildInfoRow('Acquisition Plan', order.acquisitionPlan),
            _buildInfoRow('Total Payable', 'TZS ${order.totalPayable}'),
            _buildInfoRow('Order Date', order.createdAt.toString().substring(0, 10)),
            const SizedBox(height: 32),

            const Text('Payment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            paymentsAsync.when(
              data: (payments) {
                if (payments.isEmpty) return const Text('No payments recorded yet.');
                return Column(
                  children: payments.map((p) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(backgroundColor: AppColors.primaryLight, child: Icon(Icons.payment, color: Colors.white)),
                    title: Text('TZS ${p.amount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${p.method} - ${p.transactionRef}'),
                    trailing: Text(p.createdAt.toString().substring(0, 10)),
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading payments: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
