import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/lead_model.dart';
import '../../repositories/lead_repository.dart';
import '../dashboard/dashboard_providers.dart';
import '../auth/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/status_badge.dart';

final leadRepositoryProvider = Provider((ref) => LeadRepository());

class LeadListScreen extends ConsumerStatefulWidget {
  const LeadListScreen({super.key});

  @override
  ConsumerState<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends ConsumerState<LeadListScreen> {
  List<LeadModel> _leads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadLeads());
  }

  Future<void> _loadLeads() async {
    setState(() => _isLoading = true);
    final user = ref.read(authControllerProvider).value;
    final isAdmin = user?.role.toUpperCase() == AppConstants.roleSuperAdmin || 
                    user?.role.toUpperCase() == AppConstants.roleSystemAdmin;
    final filterBranchId = isAdmin ? null : user?.branchId;

    final repo = ref.read(leadRepositoryProvider);
    final list = await repo.getLeads(branchId: filterBranchId);
    setState(() {
      _leads = list;
      _isLoading = false;
    });
  }

  void _showAddLeadModal() {
    final customers = ref.read(customersProvider).value ?? [];
    final properties = ref.read(propertiesProvider).value ?? [];
    final users = ref.read(usersProvider).value ?? [];
    final branches = ref.read(branchesProvider).value ?? [];

    String selectedCustomer = customers.isNotEmpty ? customers.first.id : '';
    String selectedProperty = properties.isNotEmpty ? properties.first.id : '';
    final agents = users.where((u) => u.role.toLowerCase() == 'sales_agent').toList();
    String selectedAgent = agents.isNotEmpty ? agents.first.uid : (users.isNotEmpty ? users.first.uid : '');
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create New Sales Lead', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              const Text('Select Customer:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedCustomer.isNotEmpty ? selectedCustomer : null,
                decoration: const InputDecoration(filled: true, hintText: 'Select Customer'),
                items: customers.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text('${c.fullName} (${c.phone})'));
                }).toList(),
                onChanged: (val) { if (val != null) selectedCustomer = val; },
              ),
              const SizedBox(height: 12),

              const Text('Select Property of Interest:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedProperty.isNotEmpty ? selectedProperty : null,
                decoration: const InputDecoration(filled: true, hintText: 'Select Property'),
                items: properties.map((p) {
                  return DropdownMenuItem(value: p.id, child: Text('${p.propertyCode} - ${p.title}'));
                }).toList(),
                onChanged: (val) { if (val != null) selectedProperty = val; },
              ),
              const SizedBox(height: 12),

              const Text('Assign Sales Agent:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedAgent.isNotEmpty ? selectedAgent : null,
                decoration: const InputDecoration(filled: true, hintText: 'Select Agent'),
                items: users.map((u) {
                  return DropdownMenuItem(value: u.uid, child: Text('${u.fullName} (${AppConstants.getRoleLabel(u.role)})'));
                }).toList(),
                onChanged: (val) { if (val != null) selectedAgent = val; },
              ),
              const SizedBox(height: 12),
              AppTextField(label: 'Lead Follow-up Notes', hint: 'Customer requested discount...', controller: notesCtrl, maxLines: 2),
              const SizedBox(height: 20),

              AppButton(
                text: 'Create Lead Assignment',
                onPressed: () async {
                  if (selectedCustomer.isEmpty || selectedProperty.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select customer and property first.')));
                    return;
                  }
                  final newLead = LeadModel(
                    id: 'lead_${DateTime.now().millisecondsSinceEpoch}',
                    customerId: selectedCustomer,
                    propertyId: selectedProperty,
                    assignedAgentId: selectedAgent,
                    branchId: branches.isNotEmpty ? branches.first.id : '',
                    source: 'Direct Client Inquiry',
                    status: AppConstants.leadNew,
                    notes: notesCtrl.text.trim(),
                    nextFollowUp: DateTime.now().add(const Duration(days: 2)),
                    createdBy: selectedAgent,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  final repo = ref.read(leadRepositoryProvider);
                  await repo.createLead(newLead);
                  Navigator.pop(ctx);
                  _loadLeads();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showStatusUpdateModal(LeadModel lead) {
    String selectedStatus = lead.status;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Update Lead Lifecycle Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(filled: true),
              items: const [
                DropdownMenuItem(value: AppConstants.leadNew, child: Text('New Lead')),
                DropdownMenuItem(value: AppConstants.leadContacted, child: Text('Contacted')),
                DropdownMenuItem(value: AppConstants.leadInterested, child: Text('Interested')),
                DropdownMenuItem(value: AppConstants.leadNegotiating, child: Text('Negotiating')),
                DropdownMenuItem(value: AppConstants.leadConverted, child: Text('Converted (Deal Won)')),
                DropdownMenuItem(value: AppConstants.leadLost, child: Text('Lost')),
              ],
              onChanged: (val) => selectedStatus = val!,
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'Save Lead Status',
              onPressed: () async {
                final repo = ref.read(leadRepositoryProvider);
                await repo.updateLeadStatus(lead.id, selectedStatus);
                Navigator.pop(ctx);
                _loadLeads();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: _showAddLeadModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _leads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final lead = _leads[index];

                final customers = ref.read(customersProvider).value ?? [];
                final properties = ref.read(propertiesProvider).value ?? [];
                final users = ref.read(usersProvider).value ?? [];

                final custMatches = customers.where((c) => c.id == lead.customerId).toList();
                final custName = custMatches.isNotEmpty ? custMatches.first.fullName : 'Client';
                final propMatches = properties.where((p) => p.id == lead.propertyId).toList();
                final propTitle = propMatches.isNotEmpty ? '${propMatches.first.propertyCode} - ${propMatches.first.title}' : 'Property Inquiry';
                final agentMatches = users.where((u) => u.uid == lead.assignedAgentId).toList();
                final agentName = agentMatches.isNotEmpty ? agentMatches.first.fullName : 'Assigned Agent';

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(custName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            StatusBadge(status: lead.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Interested in: $propTitle', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text('Assigned Agent: $agentName', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),

                        const SizedBox(height: 6),

                        Text('Notes: ${lead.notes}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Follow-up: ${Formatters.formatDate(lead.nextFollowUp)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            OutlinedButton(
                              onPressed: () => _showStatusUpdateModal(lead),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
                              child: const Text('Update Status', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
