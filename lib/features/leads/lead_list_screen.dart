import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/lead_model.dart';
import '../../repositories/lead_repository.dart';
import '../../repositories/seed_data.dart';
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
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    setState(() => _isLoading = true);
    final repo = ref.read(leadRepositoryProvider);
    final list = await repo.getLeads();
    setState(() {
      _leads = list;
      _isLoading = false;
    });
  }

  void _showAddLeadModal() {
    String selectedCustomer = SeedData.customers[0].id;
    String selectedProperty = SeedData.properties[0].id;
    String selectedAgent = SeedData.users.firstWhere((u) => u.role == 'sales_agent', orElse: () => SeedData.users[0]).uid;
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
                value: selectedCustomer,
                decoration: const InputDecoration(filled: true),
                items: SeedData.customers.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text('${c.fullName} (${c.phone})'));
                }).toList(),
                onChanged: (val) => selectedCustomer = val!,
              ),
              const SizedBox(height: 12),

              const Text('Select Property of Interest:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedProperty,
                decoration: const InputDecoration(filled: true),
                items: SeedData.properties.map((p) {
                  return DropdownMenuItem(value: p.id, child: Text('${p.propertyCode} - ${p.title}'));
                }).toList(),
                onChanged: (val) => selectedProperty = val!,
              ),
              const SizedBox(height: 12),

              const Text('Assign Sales Agent:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedAgent,
                decoration: const InputDecoration(filled: true),
                items: SeedData.users.map((u) {
                  return DropdownMenuItem(value: u.uid, child: Text('${u.fullName} (${AppConstants.getRoleLabel(u.role)})'));
                }).toList(),
                onChanged: (val) => selectedAgent = val!,
              ),
              const SizedBox(height: 12),
              AppTextField(label: 'Lead Follow-up Notes', hint: 'Customer requested 5% discount...', controller: notesCtrl, maxLines: 2),
              const SizedBox(height: 20),

              AppButton(
                text: 'Create Lead Assignment',
                onPressed: () async {
                  final newLead = LeadModel(
                    id: 'lead_${DateTime.now().millisecondsSinceEpoch}',
                    customerId: selectedCustomer,
                    propertyId: selectedProperty,
                    assignedAgentId: selectedAgent,
                    branchId: SeedData.branches[0].id,
                    source: 'Direct Client Inquiry',
                    status: AppConstants.leadNew,
                    notes: notesCtrl.text.trim(),
                    nextFollowUp: DateTime.now().add(const Duration(days: 2)),
                    createdBy: 'user_admin',
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
                final cust = SeedData.customers.firstWhere((c) => c.id == lead.customerId, orElse: () => SeedData.customers[0]);
                final prop = SeedData.properties.firstWhere((p) => p.id == lead.propertyId, orElse: () => SeedData.properties[0]);
                final agent = SeedData.users.firstWhere((u) => u.uid == lead.assignedAgentId, orElse: () => SeedData.users[0]);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(cust.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            StatusBadge(status: lead.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Property: ${prop.propertyCode} - ${prop.title}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text('Assigned Agent: ${agent.fullName}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
