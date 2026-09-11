import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/customer_model.dart';
import '../../repositories/seed_data.dart';
import '../../widgets/header_background.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../auth/auth_controller.dart';

class SalesAgentDashboard extends ConsumerWidget {
  const SalesAgentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final agentId = user?.uid ?? 'user_agent_1';

    final assignedProps = SeedData.properties.where((p) => p.assignedAgentId == agentId).toList();
    final assignedCustomers = SeedData.customers.where((c) => c.assignedAgentId == agentId).toList();
    final assignedLeads = SeedData.leads.where((l) => l.assignedAgentId == agentId).toList();
    final mySales = SeedData.sales.where((s) => s.agentId == agentId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Card
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: HeaderBackground(
              height: 95,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.accent,
                    child: Text(
                      user?.fullName.substring(0, 1).toUpperCase() ?? 'A',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${user?.fullName ?? "Sales Agent"}',
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${assignedLeads.length} Active Leads • ${assignedCustomers.length} Assigned Customers',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Sales Performance & Tasks',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.3,
            children: [
              StatCard(
                title: 'Assigned Leads',
                value: assignedLeads.length.toString(),
                icon: Icons.trending_up,
                color: AppColors.accent,
                onTap: () => context.push('/leads'),
              ),
              StatCard(
                title: 'My Customers',
                value: assignedCustomers.length.toString(),
                icon: Icons.people_alt_outlined,
                color: AppColors.primary,
                onTap: () => context.push('/customers'),
              ),
              StatCard(
                title: 'Assigned Properties',
                value: assignedProps.length.toString(),
                icon: Icons.holiday_village_outlined,
                color: AppColors.statusUnderProcess,
                onTap: () => context.push('/properties'),
              ),
              StatCard(
                title: 'My Deals Closed',
                value: mySales.length.toString(),
                icon: Icons.check_circle_outline,
                color: AppColors.statusAvailable,
                onTap: () => context.push('/sales'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Active Leads Follow-up Queue
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Customer Follow-ups Needed',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              TextButton(
                onPressed: () => context.push('/leads'),
                child: const Text('Manage Leads'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assignedLeads.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final lead = assignedLeads[index];
              final cust = SeedData.customers.firstWhere(
                (c) => c.id == lead.customerId,
                orElse: () => CustomerModel(
                  id: '',
                  fullName: 'Customer',
                  phone: '',
                  email: '',
                  address: '',
                  notes: '',
                  interestedPropertyTypes: [],
                  budget: 0,
                  status: 'new',
                  branchId: '',
                  createdBy: '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceVariant,
                    child: Icon(Icons.phone_callback_outlined, color: AppColors.accent, size: 20),
                  ),
                  title: Text(cust.fullName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Notes: ${lead.notes}\nFollow-up: ${Formatters.formatDate(lead.nextFollowUp)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: StatusBadge(status: lead.status),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
