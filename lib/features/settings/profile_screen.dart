import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/branch_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_badge.dart';
import '../auth/auth_controller.dart';
import '../dashboard/dashboard_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        final bytes = await pickedFile.readAsBytes();
        final extension = pickedFile.name.split('.').last;
        final success = await ref.read(authControllerProvider.notifier).updateProfilePicture(bytes, extension);
        
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated!')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update profile picture.')));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(user == null ? 'Wasifu' : 'Wasifu Wangu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Header Avatar
            Stack(
              children: [
                GestureDetector(
                  onTap: _isUploading ? null : _pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.background,
                      backgroundImage: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: _isUploading
                          ? const CircularProgressIndicator(color: AppColors.accent)
                          : (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                              ? Text(
                                  (user?.fullName ?? 'U').substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                              : null,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _isUploading ? null : _pickAndUploadImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.camera_alt, size: 18, color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Text(
              user?.fullName ?? 'Mgeni (Guest)',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),

            Text(
              user?.email ?? 'Tafadhali ingia katika akaunti yako',
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (user != null) ...[
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
            ] else ...[
              AppButton(
                text: 'Ingia (Login)',
                icon: Icons.login,
                onPressed: () => context.push('/login'),
              ),
            ],
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
