import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/sms_log_model.dart';
import 'sms_compose_screen.dart';

class SMSHistoryScreen extends ConsumerStatefulWidget {
  const SMSHistoryScreen({super.key});

  @override
  ConsumerState<SMSHistoryScreen> createState() => _SMSHistoryScreenState();
}

class _SMSHistoryScreenState extends ConsumerState<SMSHistoryScreen> {
  List<SMSLogModel> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    final repo = ref.read(smsRepositoryProvider);
    final list = await repo.getSMSLogs();
    setState(() {
      _logs = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS History & Logs'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _logs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final log = _logs[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.sms, color: Colors.white, size: 18),
                    ),
                    title: Text(log.phoneNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('${log.message}\nSent: ${Formatters.formatDateTime(log.createdAt)}', style: const TextStyle(fontSize: 12)),
                    trailing: Text(
                      log.status.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.statusAvailable),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
