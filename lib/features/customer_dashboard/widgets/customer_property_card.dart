import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/property_model.dart';
import '../../../core/utils/formatters.dart';
import '../providers/favourites_provider.dart';

class CustomerPropertyCard extends ConsumerStatefulWidget {
  final PropertyModel property;
  final bool isFeatured;

  const CustomerPropertyCard({
    super.key,
    required this.property,
    this.isFeatured = false,
  });

  @override
  ConsumerState<CustomerPropertyCard> createState() => _CustomerPropertyCardState();
}

class _CustomerPropertyCardState extends ConsumerState<CustomerPropertyCard> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favState = ref.watch(favouritesProvider);
    final isFavourited = favState.valueOrNull?.contains(widget.property.id) ?? false;

    return GestureDetector(
      onTap: () {
        context.push('/customer-properties/details', extra: widget.property);
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
                    child: widget.property.images.isNotEmpty
                        ? Stack(
                            children: [
                              PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() => _currentImageIndex = index);
                                },
                                itemCount: widget.property.images.length,
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    widget.property.images[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                                  );
                                },
                              ),
                              if (widget.property.images.length > 1)
                                Positioned(
                                  bottom: 12,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      widget.property.images.length,
                                      (index) => Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        width: _currentImageIndex == index ? 8 : 6,
                                        height: _currentImageIndex == index ? 8 : 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _currentImageIndex == index 
                                              ? Colors.white 
                                              : Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
                      ref.read(favouritesProvider.notifier).toggleFavourite(widget.property.id);
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
                          widget.property.title,
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
                        Formatters.formatCurrency(widget.property.price).replaceAll('TZS ', 'Tsh '),
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
                          '${widget.property.district}, ${widget.property.region}',
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

    switch (widget.property.type.toUpperCase()) {
      case 'NYUMBA':
        final beds = widget.property.bedrooms ?? 0;
        final baths = widget.property.bathrooms ?? 0;
        final size = widget.property.size ?? 'N/A';
        if (beds > 0) children.add(_buildFeatureItem(Icons.bed_rounded, '$beds Beds'));
        if (baths > 0) children.add(_buildFeatureItem(Icons.bathtub_rounded, '$baths Baths'));
        children.add(_buildFeatureItem(Icons.square_foot_rounded, size));
        break;
      case 'GARI':
        final year = widget.property.vehicleYear?.toString() ?? 'N/A';
        final make = widget.property.vehicleMake ?? 'Vehicle';
        children.add(_buildFeatureItem(Icons.calendar_month_rounded, year));
        children.add(_buildFeatureItem(Icons.directions_car_rounded, make));
        break;
      case 'KIWANJA':
      default:
        final size = widget.property.size ?? 'N/A';
        children.add(_buildFeatureItem(Icons.landscape_rounded, widget.property.landUse ?? 'Makazi'));
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
          widget.property.type,
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
