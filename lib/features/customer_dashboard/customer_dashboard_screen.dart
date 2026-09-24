import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../auth/auth_controller.dart';
import '../../repositories/property_repository.dart';
import '../../models/property_model.dart';
import '../../models/user_model.dart';
import '../../widgets/header_background.dart';
import '../notifications/notification_controller.dart';
import 'customer_explore_screen.dart';
import 'customer_favourites_screen.dart';
import 'customer_profile_screen.dart';
import 'widgets/customer_property_card.dart';

final customerPropertyRepositoryProvider = Provider<PropertyRepository>((ref) => PropertyRepository());

final availablePropertiesProvider = FutureProvider<List<PropertyModel>>((ref) async {
  final repository = ref.read(customerPropertyRepositoryProvider);
  final properties = await repository.getProperties();
  return properties.where((p) => p.status == AppConstants.propertyAvailable).toList();
});

class CustomerDashboardScreen extends ConsumerStatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  ConsumerState<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends ConsumerState<CustomerDashboardScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'All'; // 'All', 'KIWANJA', 'NYUMBA', 'GARI'

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authControllerProvider);
    final user = userState.value;
    
    Widget body;
    switch (_currentIndex) {
      case 1:
        body = const CustomerExploreScreen();
        break;
      case 2:
        body = const CustomerFavouritesScreen();
        break;
      case 3:
        body = Center(child: Text('Connecting to WhatsApp...', style: TextStyle(color: AppColors.textPrimary)));
        break;
      case 4:
        body = const CustomerProfileScreen();
        break;
      case 0:
      default:
        body = _buildHome(user);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Expanded(child: body),
              _buildBottomNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _buildNavItem(1, Icons.explore_rounded, Icons.explore_outlined, 'dashboard.explore'.tr()),
              _buildNavItem(2, Icons.favorite_rounded, Icons.favorite_outline_rounded, 'dashboard.favourites'.tr()),
              _buildNavItem(3, Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded, 'Chat'),
              _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'dashboard.profile'.tr()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () async {
        if (index == 3) {
          context.push('/chat');
          return;
        }
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : inactiveIcon,
            color: isActive ? AppColors.accent : AppColors.textSecondary,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? AppColors.accent : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final isSw = context.locale.languageCode == 'sw';
    if (hour < 12) {
      return isSw ? 'HABARI ZA ASUBUHI' : 'GOOD MORNING';
    } else if (hour < 17) {
      return isSw ? 'HABARI ZA MCHANA' : 'GOOD AFTERNOON';
    } else {
      return isSw ? 'HABARI ZA JIONI' : 'GOOD EVENING';
    }
  }

  Widget _buildHome(UserModel? user) {
    final propertiesState = ref.watch(availablePropertiesProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Stack(
      children: [
        // Top Deep Header Banner Background
        HeaderBackground(
          height: 290,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Profile Picture and Name
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _currentIndex = 4), // Go to profile
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primaryLight,
                                backgroundImage: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                                    ? NetworkImage(user.photoUrl!)
                                    : null,
                                child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                                    ? Text(
                                        (user?.fullName ?? 'C').substring(0, 1).toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.fullName?.split(" ").first ?? 'Customer',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Customer',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Notification Bell
                      GestureDetector(
                        onTap: () => context.push('/notifications'),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: AppColors.statusAvailable,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.primary, width: 1.5),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Personalized Greeting
                  Text(
                    '${_getGreeting(context)}, ${user?.fullName?.split(" ").first ?? "Customer"}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tafuta mali inayokufaa leo.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Compact Search Bar
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 1), // Go to explore tab
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Tafuta nyumba, viwanja au magari...',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main Body Floating Curved Container Sheet
        Padding(
          padding: const EdgeInsets.only(top: 260.0),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Actions
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                                label: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () => context.push('/my-orders'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.savings_outlined, size: 18),
                                label: const Text('My Kikoba', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () => context.push('/my-kikoba'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Compact Category Shortcuts
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildCategoryShortcut('All', 'Yote'),
                              const SizedBox(width: 12),
                              _buildCategoryShortcut('NYUMBA', 'Nyumba'),
                              const SizedBox(width: 12),
                              _buildCategoryShortcut('KIWANJA', 'Viwanja'),
                              const SizedBox(width: 12),
                              _buildCategoryShortcut('GARI', 'Magari'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Featured Section Header
                        Text(
                          'dashboard.available_properties'.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // Properties List
                propertiesState.when(
                  data: (properties) {
                    var filtered = properties;
                    if (_selectedCategory != 'All') {
                      filtered = filtered.where((p) => p.type.toUpperCase() == _selectedCategory).toList();
                    }

                    if (filtered.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'explore.no_results'.tr(),
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 24, 
                              right: 24, 
                              bottom: 24,
                            ),
                            child: CustomerPropertyCard(
                              property: filtered[index],
                              isFeatured: true,
                            ),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
                  ),
                  error: (error, _) => SliverFillRemaining(
                    child: Center(
                      child: Text('Error: $error', style: const TextStyle(color: AppColors.statusSold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryShortcut(String value, String label) {
    final isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.accent : AppColors.border),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
