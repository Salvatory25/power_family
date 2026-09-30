import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../../widgets/header_background.dart';
import '../../widgets/loading_view.dart';

final leadRepositoryProvider = Provider((ref) => LeadRepository());

class LeadListScreen extends ConsumerStatefulWidget {
  const LeadListScreen({super.key});

  @override
  ConsumerState<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends ConsumerState<LeadListScreen> {
  List<LeadModel> _leads = [];
  bool _isLoading = true;
  bool _isSendingSms = false;

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

  void _showLeadHistoryModal(LeadModel lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final allActivities = ref.watch(activitiesStreamProvider).value ?? [];
          final history = allActivities.where((a) => a.entityId == lead.id).toList();
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.history_rounded, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lead History Timeline', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
                          Text('Audit log for this lead', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (history.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text('No history found for this lead.', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, i) {
                        final log = history[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle, border: Border.all(color: AppColors.surface, width: 2)),
                                  ),
                                  if (i != history.length - 1)
                                    Container(
                                      width: 2,
                                      height: 60,
                                      color: AppColors.accent.withOpacity(0.3),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Formatters.formatDateTime(log.createdAt),
                                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      log.description,
                                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'By: ${log.actorName}',
                                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSmsCampaignModal() {
    final msgCtrl = TextEditingController();
    String targetAudience = 'All Leads';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.campaign_rounded, color: AppColors.accent, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SMS Marketing Campaign', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
                        Text('Blast offers and updates to your leads', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Text('Target Audience', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: targetAudience,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'All Leads', child: Text('All Registered Leads')),
                    DropdownMenuItem(value: 'New Leads', child: Text('New Leads Only')),
                    DropdownMenuItem(value: 'Interested', child: Text('Interested / Hot Leads')),
                    DropdownMenuItem(value: 'Converted', child: Text('Converted Customers')),
                  ],
                  onChanged: (val) => setStateModal(() => targetAudience = val!),
                ),
                const SizedBox(height: 20),

                Text('Campaign Message', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 8),
                TextField(
                  controller: msgCtrl,
                  maxLines: 4,
                  maxLength: 160,
                  decoration: InputDecoration(
                    hintText: 'e.g. Habari! Power Family inakuletea ofa kabambe ya viwanja...',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  onChanged: (_) => setStateModal(() {}),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      shadowColor: AppColors.primary.withOpacity(0.5),
                    ),
                    onPressed: _isSendingSms ? null : () async {
                      if (msgCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message cannot be empty!')));
                        return;
                      }
                      
                      setStateModal(() => _isSendingSms = true);
                      
                      // Simulate SMS Gateway Delay
                      await Future.delayed(const Duration(seconds: 2));
                      
                      setStateModal(() => _isSendingSms = false);
                      Navigator.pop(ctx);
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.rocket_launch_rounded, color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(child: Text("Campaign blasted successfully to $targetAudience!", style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                              ],
                            ),
                            backgroundColor: AppColors.accent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }
                    },
                    child: _isSendingSms
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Blast Campaign', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          HeaderBackground(
            height: 220,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BackButton(color: Colors.white),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _showSmsCampaignModal,
                              tooltip: 'SMS Campaigns',
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.campaign_rounded, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: _showAddLeadModal,
                              tooltip: 'Add Lead',
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.add, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lead Management',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Wateja Wanaotarajiwa | Track and convert leads',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
              ),
              child: _isLoading
                  ? const LoadingView()
                  : _leads.isEmpty
                      ? Center(
                          child: Text(
                            'No leads found.',
                            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 16),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
                          itemCount: _leads.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final lead = _leads[index];
                            final customers = ref.read(customersProvider).value ?? [];
                            final properties = ref.read(propertiesProvider).value ?? [];
                            final users = ref.read(usersProvider).value ?? [];

                            final custMatches = customers.where((c) => c.id == lead.customerId).toList();
                            final custName = custMatches.isNotEmpty ? custMatches.first.fullName : 'Client (Unassigned)';
                            final propMatches = properties.where((p) => p.id == lead.propertyId).toList();
                            final propTitle = propMatches.isNotEmpty ? '${propMatches.first.propertyCode} - ${propMatches.first.title}' : 'General Inquiry';
                            final agentMatches = users.where((u) => u.uid == lead.assignedAgentId).toList();
                            final agentName = agentMatches.isNotEmpty ? agentMatches.first.fullName : 'Unassigned';

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
                                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.person, color: AppColors.primary, size: 24),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                custName,
                                                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Agent: $agentName',
                                                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        StatusBadge(status: lead.status),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.home_work_outlined, size: 16, color: AppColors.primary),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              propTitle,
                                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (lead.notes.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        'Notes: ${lead.notes}',
                                        style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16.0),
                                      child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                                            const SizedBox(width: 6),
                                            Text(
                                              lead.nextFollowUp != null ? 'Follow-up: ${Formatters.formatDate(lead.nextFollowUp!)}' : 'No follow-up set',
                                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            TextButton(
                                              onPressed: () => _showLeadHistoryModal(lead),
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                              child: Text('History', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                                            ),
                                            TextButton(
                                              onPressed: () => _showStatusUpdateModal(lead),
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                backgroundColor: AppColors.accent.withOpacity(0.1),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              ),
                                              child: Text('Update Status', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
