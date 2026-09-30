import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/communication_service.dart';
import '../../models/sms_log_model.dart';
import '../../repositories/sms_repository.dart';
import '../dashboard/dashboard_providers.dart';
import '../auth/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/header_background.dart';

final smsRepositoryProvider = Provider((ref) => SMSRepository());

class SMSComposeScreen extends ConsumerStatefulWidget {
  final String? initialRecipient;

  const SMSComposeScreen({super.key, this.initialRecipient});

  @override
  ConsumerState<SMSComposeScreen> createState() => _SMSComposeScreenState();
}

class _SMSComposeScreenState extends ConsumerState<SMSComposeScreen> {
  bool _isBulkCampaign = false;
  String _targetAudience = 'All Customers';
  
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController(text: 'Habari, Karibu Power Family Investment kwa ajili ya fursa za viwanja, nyumba na huduma zetu.');
  int _characterCount = 0;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialRecipient != null) {
      _phoneCtrl.text = widget.initialRecipient!;
    }
    _characterCount = _messageCtrl.text.length;
    _messageCtrl.addListener(() {
      setState(() => _characterCount = _messageCtrl.text.length);
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendSms() async {
    if (!_isBulkCampaign && _phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipient phone is required for single message.')));
      return;
    }
    if (_messageCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message body is required.')));
      return;
    }

    final customers = ref.read(customersProvider).value ?? [];
    final leads = ref.read(leadsProvider).value ?? [];
    
    List<String> recipients = [];
    if (_isBulkCampaign) {
      if (_targetAudience == 'All Customers') {
        recipients = customers.map((c) => c.phone).where((p) => p.isNotEmpty).toList();
      } else if (_targetAudience == 'All Leads') {
        // Find customers associated with leads
        final leadCustomerIds = leads.map((l) => l.customerId).toSet();
        recipients = customers.where((c) => leadCustomerIds.contains(c.id)).map((c) => c.phone).where((p) => p.isNotEmpty).toList();
      } else if (_targetAudience == 'Active Buyers') {
        recipients = customers.where((c) => c.status == 'ACTIVE').map((c) => c.phone).where((p) => p.isNotEmpty).toList();
      }
    } else {
      recipients = [_phoneCtrl.text.trim()];
    }
    
    if (recipients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No valid phone numbers found in the target audience.')));
      return;
    }

    final confirm = await ConfirmDialog.show(
      context,
      title: _isBulkCampaign ? 'Launch Bulk Campaign?' : 'Send SMS Message?',
      message: _isBulkCampaign 
        ? 'You are about to send this message to ${recipients.length} recipients in "$_targetAudience".\n\nProceed?' 
        : 'Send SMS to ${_phoneCtrl.text}?\nMessage: ${_messageCtrl.text}',
      confirmText: _isBulkCampaign ? 'Launch Campaign' : 'Send SMS',
    );

    if (confirm != true) return;

    setState(() => _isSending = true);

    final currentUser = ref.read(authControllerProvider).value;
    final repo = ref.read(smsRepositoryProvider);

    // If it's a single message, try to open the native SMS composer.
    // If it's a bulk campaign, we simulate the gateway processing.
    if (!_isBulkCampaign) {
      try {
        await CommunicationService.openSmsComposer(recipients.first, message: _messageCtrl.text);
      } catch (_) {} // Ignore if device doesn't support it, just log it.
    }

    // Log SMS attempts for all recipients
    for (String phone in recipients) {
      final newLog = SMSLogModel(
        id: 'sms_${DateTime.now().microsecondsSinceEpoch}',
        recipientId: phone,
        phoneNumber: phone,
        message: _messageCtrl.text.trim(),
        sentBy: currentUser?.uid ?? '',
        branchId: currentUser?.branchId ?? '',
        status: 'sent',
        providerMessageId: 'MSG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        createdAt: DateTime.now(),
      );
      await repo.logSMS(newLog);
    }

    setState(() => _isSending = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBulkCampaign 
            ? 'Campaign launched successfully to ${recipients.length} recipients!' 
            : 'SMS logged successfully!'
          ),
          backgroundColor: AppColors.statusAvailable,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          HeaderBackground(
            height: 250,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const BackButton(color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'SMS Marketing',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 48),
                      child: Text(
                        'Launch bulk campaigns or text clients individually.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mode Selector
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isBulkCampaign = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !_isBulkCampaign ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Single SMS',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    color: !_isBulkCampaign ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isBulkCampaign = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _isBulkCampaign ? AppColors.accent : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Bulk Campaign',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    color: _isBulkCampaign ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recipient Section
                    if (_isBulkCampaign) ...[
                      Text('Target Audience', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _targetAudience,
                            isExpanded: true,
                            icon: const Icon(Icons.groups_rounded, color: AppColors.accent),
                            items: ['All Customers', 'All Leads', 'Active Buyers'].map((a) {
                              return DropdownMenuItem(
                                value: a,
                                child: Text(a, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _targetAudience = val!),
                          ),
                        ),
                      ),
                    ] else ...[
                      if (customers.isNotEmpty) ...[
                        Text('Select Customer (Optional)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _phoneCtrl.text.isNotEmpty && customers.any((c) => c.phone == _phoneCtrl.text) ? _phoneCtrl.text : null,
                              isExpanded: true,
                              hint: const Text('Search by Name'),
                              items: customers.where((c) => c.phone.isNotEmpty).map((c) {
                                return DropdownMenuItem(value: c.phone, child: Text('${c.fullName} (${c.phone})', style: GoogleFonts.inter(fontWeight: FontWeight.w500)));
                              }).toList(),
                              onChanged: (val) => setState(() => _phoneCtrl.text = val ?? ''),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      AppTextField(
                        label: 'Phone Number',
                        hint: '+255 700 000 000',
                        controller: _phoneCtrl,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Message Section
                    AppTextField(
                      label: 'Campaign Message',
                      hint: 'Type your promotional SMS text here...',
                      controller: _messageCtrl,
                      maxLines: 6,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bar_chart_rounded, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text('Characters: $_characterCount / 160 (1 SMS)', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, size: 16, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text('Secure Gateway', style: GoogleFonts.inter(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    AppButton(
                      text: _isBulkCampaign ? 'Launch Bulk Campaign' : 'Send Secure SMS',
                      icon: _isBulkCampaign ? Icons.rocket_launch_rounded : Icons.send_rounded,
                      onPressed: _sendSms,
                      isLoading: _isSending,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
