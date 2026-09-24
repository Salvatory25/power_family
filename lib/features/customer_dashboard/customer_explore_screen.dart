import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/app_empty_state.dart';
import 'customer_dashboard_screen.dart'; // To access the availablePropertiesProvider
import 'widgets/customer_property_card.dart';
import '../../models/property_model.dart';

class CustomerExploreScreen extends ConsumerStatefulWidget {
  const CustomerExploreScreen({super.key});

  @override
  ConsumerState<CustomerExploreScreen> createState() => _CustomerExploreScreenState();
}

class _CustomerExploreScreenState extends ConsumerState<CustomerExploreScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All'; // 'All', 'KIWANJA', 'NYUMBA', 'GARI'

  @override
  Widget build(BuildContext context) {
    final propertiesState = ref.watch(availablePropertiesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('explore.title'.tr(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                // Search Bar
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          onChanged: (value) => setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: 'dashboard.search_hint'.tr(),
                            hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('All', 'explore.filter_all'.tr()),
                      const SizedBox(width: 8),
                      _buildCategoryChip('KIWANJA', 'explore.filter_plots'.tr()),
                      const SizedBox(width: 8),
                      _buildCategoryChip('NYUMBA', 'explore.filter_houses'.tr()),
                      const SizedBox(width: 8),
                      _buildCategoryChip('GARI', 'explore.filter_cars'.tr()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: propertiesState.when(
              data: (properties) {
                // Filter logic
                var filtered = properties;
                
                if (_selectedCategory != 'All') {
                  filtered = filtered.where((p) => p.type.toUpperCase() == _selectedCategory).toList();
                }

                if (_searchQuery.trim().isNotEmpty) {
                  final q = _searchQuery.trim().toLowerCase();
                  filtered = filtered.where((p) => 
                    p.title.toLowerCase().contains(q) || 
                    p.location.toLowerCase().contains(q) ||
                    p.region.toLowerCase().contains(q) ||
                    p.district.toLowerCase().contains(q)
                  ).toList();
                }

                if (filtered.isEmpty) {
                  return AppEmptyState(
                    title: 'dashboard.no_properties'.tr(),
                    subtitle: 'explore.no_results'.tr(),
                    icon: Icons.search_off_rounded,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return CustomerPropertyCard(
                      property: filtered[index],
                      isFeatured: false,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (error, _) => AppEmptyState(
                title: 'Imeshindikana kupakia mali',
                subtitle: 'Angalia internet yako kisha ujaribu tena.',
                icon: Icons.wifi_off_rounded,
                actionLabel: 'Jaribu Tena',
                onAction: () => ref.refresh(availablePropertiesProvider),
              ),
            ),
          ),
        ],
      ),
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
