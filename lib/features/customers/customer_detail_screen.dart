import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/communication_service.dart';
import '../../core/utils/formatters.dart';
import '../../models/customer_model.dart';
import '../dashboard/dashboard_providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_badge.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersProvider).value ?? [];
    final matches = customers.where((c) => c.id == customerId).toList();
    if (matches.isEmpty && customers.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Customer Details')),
        body: const Center(child: Text('Customer profile not found.')),
      );
    }
    final customer = matches.isNotEmpty ? matches.first : customers.first;


    return Scaffold(
      appBar: AppBar(
        title: Text(customer.fullName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        customer.fullName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customer.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(customer.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          StatusBadge(status: customer.status),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Native Action Bar (CALL, WHATSAPP, SMS)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => CommunicationService.makePhoneCall(customer.phone),
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('CALL'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusAvailable),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => CommunicationService.openWhatsApp(customer.phone, message: 'Habari ${customer.fullName}, kuwasiliana kutoka Power Family Investment Ltd.'),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('WHATSAPP'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/sms?recipient=${customer.phone}'),
                    icon: const Icon(Icons.sms, size: 18),
                    label: const Text('SMS'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Profile Information Breakdown
            const Text('Customer Profile Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _infoRow('Phone Number', customer.phone),
                  _infoRow('Email Address', customer.email),
                  _infoRow('Physical Address', customer.address),
                  _infoRow('Investment Budget', Formatters.formatCurrency(customer.budget)),
                  _infoRow('Interested In', customer.interestedPropertyTypes.join(', ').toUpperCase()),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text('Customer Notes & Inquiry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(customer.notes, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),

            const Divider(height: 30),

            // Activity History Timeline
            const Text('Interaction & Follow-up History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _timelineItem('Property Viewed', 'Customer visited Kigamboni plot PF-KW-001 with Agent', '10 Sep 2026', Icons.visibility_outlined),
                _timelineItem('WhatsApp Inquiry Received', 'Requested property price breakdown and title deed info', '08 Sep 2026', Icons.chat),
                _timelineItem('SMS Sent', 'Follow-up reminder sent regarding site visit', '05 Sep 2026', Icons.sms),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _timelineItem(String title, String subtitle, String date, IconData icon) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text('$subtitle\n$date', style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
