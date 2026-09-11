import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/communication_service.dart';
import '../../models/sms_log_model.dart';
import '../../repositories/sms_repository.dart';
import '../../repositories/seed_data.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/confirm_dialog.dart';

final smsRepositoryProvider = Provider((ref) => SMSRepository());

class SMSComposeScreen extends ConsumerStatefulWidget {
  final String? initialRecipient;

  const SMSComposeScreen({super.key, this.initialRecipient});

  @override
  ConsumerState<SMSComposeScreen> createState() => _SMSComposeScreenState();
}

class _SMSComposeScreenState extends ConsumerState<SMSComposeScreen> {
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController(text: 'Habari, kuwasiliana kutoka Power Family Investment Ltd kuhusu fursa za Viwanja na Nyumba.');
  int _characterCount = 0;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialRecipient != null) {
      _phoneCtrl.text = widget.initialRecipient!;
    } else {
      _phoneCtrl.text = SeedData.customers[0].phone;
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
    if (_phoneCtrl.text.isEmpty || _messageCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipient phone and message body are required.')));
      return;
    }

    final confirm = await ConfirmDialog.show(
      context,
      title: 'Send SMS Message?',
      message: 'Send SMS to ${_phoneCtrl.text}?\nMessage: ${_messageCtrl.text}',
      confirmText: 'Send SMS',
    );

    if (confirm != true) return;

    setState(() => _isSending = true);

    // 1. Open Native SMS Application Launcher
    await CommunicationService.openSmsComposer(_phoneCtrl.text, message: _messageCtrl.text);

    // 2. Log SMS attempt to Firestore sms_logs collection securely
    final newLog = SMSLogModel(
      id: 'sms_${DateTime.now().millisecondsSinceEpoch}',
      recipientId: _phoneCtrl.text,
      phoneNumber: _phoneCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
      sentBy: 'user_admin',
      branchId: SeedData.branches[0].id,
      status: 'sent',
      providerMessageId: 'MSG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      createdAt: DateTime.now(),
    );

    final repo = ref.read(smsRepositoryProvider);
    await repo.logSMS(newLog);

    setState(() => _isSending = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SMS logged successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Hub & Composer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Send SMS Message', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Compose customer communication. Credentials are secured on backend.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 16),

                    const Text('Select Customer / Recipient:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _phoneCtrl.text,
                      decoration: const InputDecoration(filled: true),
                      items: SeedData.customers.map((c) {
                        return DropdownMenuItem(value: c.phone, child: Text('${c.fullName} (${c.phone})'));
                      }).toList(),
                      onChanged: (val) => setState(() => _phoneCtrl.text = val!),
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Message Body',
                      hint: 'Type SMS text here...',
                      controller: _messageCtrl,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Character Count: $_characterCount / 160 (1 SMS)', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        const Text('Power Family SMS Gateway', style: TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    AppButton(
                      text: 'Send SMS Message',
                      icon: Icons.send,
                      onPressed: _sendSms,
                      isLoading: _isSending,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
