import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../auth/auth_controller.dart';
import '../../repositories/property_repository.dart';
import '../../models/property_model.dart';
import '../../models/user_model.dart';
import '../../widgets/header_background.dart';
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
        body = Center(child: Text('Chat Coming Soon', style: TextStyle(color: AppColors.textPrimary)));
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
              _buildNavItem(1, Icons.explore_rounded, Icons.explore_outlined, 'Explore'),
              _buildNavItem(2, Icons.favorite_rounded, Icons.favorite_outline_rounded, 'Favorites'),
              _buildNavItem(3, Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded, 'Chat'),
              _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'GOOD MORNING';
    } else if (hour < 17) {
      return 'GOOD AFTERNOON';
    } else {
      return 'GOOD EVENING';
    }
  }

  Widget _buildHome(UserModel? user) {
    final propertiesState = ref.watch(availablePropertiesProvider);

    return Stack(
      children: [
        // Top Deep Header Banner Background
        HeaderBackground(
          height: 200,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Sleek Profile Avatar
                      GestureDetector(
                        onTap: () => setState(() => _currentIndex = 4), // Go to profile
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                                ? NetworkImage(user.photoUrl!)
                                : null,
                            child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                                ? Text(
                                    (user?.fullName ?? 'C').substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Greeting and Name
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.fullName ?? 'Valued Customer',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Header Actions (Notification)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                width: 8,
                                height: 8,
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
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main Body Floating Curved Container Sheet
        Padding(
          padding: const EdgeInsets.only(top: 110.0),
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
                        // Featured Section Header
                        const Text(
                          'Featured Properties',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Categories
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildCategoryChip('All', 'Zote'),
                              const SizedBox(width: 8),
                              _buildCategoryChip('KIWANJA', 'Viwanja'),
                              const SizedBox(width: 8),
                              _buildCategoryChip('NYUMBA', 'Nyumba'),
                              const SizedBox(width: 8),
                              _buildCategoryChip('GARI', 'Magari'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8), // Replaced the extra space with a smaller one, since list has padding
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
                      return const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No properties found in this category.',
                            style: TextStyle(color: AppColors.textSecondary),
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

  Widget _buildCategoryChip(String value, String label) {
    final isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
