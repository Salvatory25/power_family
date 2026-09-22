import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/header_background.dart';
import '../auth/auth_controller.dart';
import 'customer_personal_info_screen.dart';
import 'customer_my_properties_screen.dart';
import 'customer_payment_history_screen.dart';
import 'customer_support_screen.dart';

class CustomerProfileScreen extends ConsumerStatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  ConsumerState<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends ConsumerState<CustomerProfileScreen> {
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
    final userState = ref.watch(authControllerProvider);
    final user = userState.value;

    return Stack(
      children: [
        // Premium Profile Header
        HeaderBackground(
          height: 280,
          child: SafeArea(
            bottom: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _isUploading ? null : _pickAndUploadImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.accent, Colors.white70],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                                ? NetworkImage(user.photoUrl!)
                                : null,
                            child: _isUploading
                                ? const CircularProgressIndicator(color: AppColors.accent)
                                : (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                                    ? Text(
                                        (user?.fullName ?? 'C').substring(0, 1).toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 40,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      )
                                    : null,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: GestureDetector(
                          onTap: _isUploading ? null : _pickAndUploadImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(Icons.camera_alt, size: 16, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'Customer Name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'customer@example.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),

        // Main Body Floating Curved Container Sheet
        Padding(
          padding: const EdgeInsets.only(top: 250.0),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Menu Options
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Personal Information',
                          subtitle: 'View and edit your profile',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CustomerPersonalInfoScreen()),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 64, color: AppColors.border),
                        _buildMenuTile(
                          icon: Icons.home_work_outlined,
                          title: 'My Properties',
                          subtitle: 'View properties you are buying',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CustomerMyPropertiesScreen()),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 64, color: AppColors.border),
                        _buildMenuTile(
                          icon: Icons.receipt_long_outlined,
                          title: 'Payment History',
                          subtitle: 'Receipts and transaction logs',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CustomerPaymentHistoryScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.support_agent_rounded,
                          title: 'Help & Support',
                          subtitle: 'Contact us for assistance',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CustomerSupportScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(authControllerProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/auth'); // Route to auth explicitly just in case, though auth listener usually handles it
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.redAccent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
