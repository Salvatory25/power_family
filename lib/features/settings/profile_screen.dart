import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/branch_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_badge.dart';
import '../auth/auth_controller.dart';
import '../dashboard/dashboard_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final branches = ref.watch(branchesProvider).value ?? [];
    final branch = branches.firstWhere(
      (b) => b.id == user?.branchId,
      orElse: () => BranchModel(
        id: '',
        name: user?.branchId ?? 'Main HQ',
        code: 'HQ',
        location: '',
        phone: '',
        email: '',
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Header Avatar
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primary,
              child: Text(
                user?.fullName.isEmpty ?? true ? 'U' : user!.fullName.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 14),

            Text(
              user?.fullName ?? 'Staff Member',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),

            Text(
              user?.email ?? 'staff@powerfamily.co.tz',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),

            StatusBadge(status: user?.status ?? 'active', fontSize: 13),
            const SizedBox(height: 24),

            // Information Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _profileRow('Assigned Role', AppConstants.getRoleLabel(user?.role ?? '')),
                    _profileRow('Assigned Branch', '${branch.name} (${branch.code})'),
                    _profileRow('Phone Number', user?.phone ?? 'N/A'),
                    _profileRow('User ID', user?.uid ?? 'N/A'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            AppButton(
              text: 'Change Password',
              isOutlined: true,
              icon: Icons.lock_reset,
              onPressed: () => context.push('/forgot-password'),
            ),
            const SizedBox(height: 12),

            AppButton(
              text: 'Logout of Account',
              backgroundColor: AppColors.statusSold,
              icon: Icons.logout,
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
