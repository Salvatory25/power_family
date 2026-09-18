import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_badge.dart';
import 'auth_controller.dart';



class AccountStatusScreen extends ConsumerWidget {
  const AccountStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    final status = user?.status ?? AppConstants.statusPending;

    IconData icon = Icons.pending_actions_rounded;
    Color color = AppColors.statusPending;
    String title = 'Account Pending Approval';
    String message =
        'Your staff account has been created successfully. A Super Admin must review and approve your account before you can access Power Family features.';

    if (status == AppConstants.statusSuspended) {
      icon = Icons.pause_circle_outline;
      color = AppColors.statusSold;
      title = 'Account Suspended';
      message = 'Your account has been temporarily suspended. Please contact your Super Admin or Branch Manager for assistance.';
    } else if (status == AppConstants.statusDisabled) {
      icon = Icons.block;
      color = AppColors.statusSold;
      title = 'Account Disabled';
      message = 'Your staff access has been disabled. You cannot perform operations in this system.';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 64, color: color),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                if (user != null) StatusBadge(status: status, fontSize: 13),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),



                // Check Status Button
                AppButton(
                  text: 'Check Account Status Again',
                  isOutlined: true,
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).init();
                    final updatedUser = ref.read(authControllerProvider).value;
                    if (updatedUser != null && updatedUser.status == AppConstants.statusActive) {
                      if (context.mounted) context.go('/dashboard');
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account status is still pending approval.')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),

                TextButton.icon(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout, size: 18, color: AppColors.statusSold),
                  label: const Text(
                    'Logout to Login Screen',
                    style: TextStyle(color: AppColors.statusSold, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
