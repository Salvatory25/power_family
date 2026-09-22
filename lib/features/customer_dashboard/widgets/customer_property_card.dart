import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/property_model.dart';
import '../../../core/utils/formatters.dart';
import '../providers/favourites_provider.dart';

class CustomerPropertyCard extends ConsumerWidget {
  final PropertyModel property;
  final bool isFeatured;

  const CustomerPropertyCard({
    super.key,
    required this.property,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favState = ref.watch(favouritesProvider);
    final isFavourited = favState.valueOrNull?.contains(property.id) ?? false;

    return GestureDetector(
      onTap: () {
        context.push('/customer-properties/details', extra: property);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: AspectRatio(
                    aspectRatio: 16 / 11,
                    child: property.images.isNotEmpty
                        ? Image.network(
                            property.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                
                // 360 Badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.view_in_ar_rounded, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          '360°',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Favorite Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(favouritesProvider.notifier).toggleFavourite(property.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavourited ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                        color: isFavourited ? Colors.redAccent : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Info Area
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Formatters.formatCurrency(property.price).replaceAll('TZS ', 'Tsh '),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.district}, ${property.region}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Features Area
                  _buildFeaturesRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 48, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildFeaturesRow() {
    List<Widget> children = [];

    switch (property.type.toUpperCase()) {
      case 'NYUMBA':
        final beds = property.bedrooms ?? 0;
        final baths = property.bathrooms ?? 0;
        final size = property.size ?? 'N/A';
        if (beds > 0) children.add(_buildFeatureItem(Icons.bed_rounded, '$beds Beds'));
        if (baths > 0) children.add(_buildFeatureItem(Icons.bathtub_rounded, '$baths Baths'));
        children.add(_buildFeatureItem(Icons.square_foot_rounded, size));
        break;
      case 'GARI':
        final year = property.vehicleYear?.toString() ?? 'N/A';
        final make = property.vehicleMake ?? 'Vehicle';
        children.add(_buildFeatureItem(Icons.calendar_month_rounded, year));
        children.add(_buildFeatureItem(Icons.directions_car_rounded, make));
        break;
      case 'KIWANJA':
      default:
        final size = property.size ?? 'N/A';
        children.add(_buildFeatureItem(Icons.landscape_rounded, property.landUse ?? 'Makazi'));
        children.add(_buildFeatureItem(Icons.square_foot_rounded, size));
        break;
    }

    // Add property type badge
    children.add(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          property.type,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      )
    );

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
