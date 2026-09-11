import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Company Identity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.business, color: AppColors.primary),
                  title: const Text(AppConstants.companyName, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Real Estate, Land Surveying, Plots & Vehicles'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.apps, color: AppColors.accent),
                  title: const Text('Application Name'),
                  subtitle: const Text(AppConstants.appName),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text('System Integration Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_done, color: AppColors.statusAvailable),
                  title: const Text('Firebase Authentication & Firestore'),
                  subtitle: const Text('Configured & Active'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.sms, color: AppColors.statusUnderProcess),
                  title: const Text('SMS API Gateway'),
                  subtitle: const Text('Backend Endpoint Integrated'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_active, color: AppColors.accent),
                  title: const Text('Firebase Cloud Messaging (FCM)'),
                  subtitle: const Text('In-App & Push Notifications Enabled'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
