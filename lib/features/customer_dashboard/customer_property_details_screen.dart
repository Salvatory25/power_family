import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/property_model.dart';
import 'providers/favourites_provider.dart';
import 'widgets/customer_property_card.dart';
import 'customer_dashboard_screen.dart';
import '../auth/auth_controller.dart';
import '../../repositories/chat_repository.dart';
import '../../models/chat_model.dart';

class CustomerPropertyDetailsScreen extends ConsumerStatefulWidget {
  final PropertyModel property;

  const CustomerPropertyDetailsScreen({
    super.key,
    required this.property,
  });

  @override
  ConsumerState<CustomerPropertyDetailsScreen> createState() => _CustomerPropertyDetailsScreenState();
}

class _CustomerPropertyDetailsScreenState extends ConsumerState<CustomerPropertyDetailsScreen> {
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _contactPowerFamily() async {
    final phone = '+255759423626';
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _openWhatsApp() async {
    final phone = '255759423626'; // WhatsApp number without '+'
    final message = 'Hello Power Family, I am interested in the property: ${widget.property.title} (${widget.property.propertyCode}). Please provide more details.';
    final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('details.whatsapp_error'.tr())),
        );
      }
    }
  }

  bool _isStartingChat = false;

  void _startLiveChat() async {
    if (_isStartingChat) return;
    setState(() => _isStartingChat = true);
    
    try {
      final user = ref.read(authControllerProvider).value;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to start a chat')),
        );
        return;
      }

      final chatRepo = ChatRepository();
      final chat = await chatRepo.startPropertyChat(
        user.uid, 
        widget.property.id, 
        widget.property.branchId,
      );

      if (mounted) {
        context.push('/chat/${chat.id}', extra: chat);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not start chat: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isStartingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favState = ref.watch(favouritesProvider);
    final isFavourited = favState.valueOrNull?.contains(widget.property.id) ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isFavourited),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPropertySummary(),
                  const SizedBox(height: 32),
                  _buildInformationGrid(),
                  const SizedBox(height: 32),
                  _buildDescriptionSection(),
                  const SizedBox(height: 32),
                  _buildLocationSection(),
                  const SizedBox(height: 32),
                  _buildAgentSection(),
                  const SizedBox(height: 32),
                  _buildSimilarProperties(),
                  const SizedBox(height: 40), // Padding before bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildStickyBottomCTA(),
    );
  }

  Widget _buildSliverAppBar(bool isFavourited) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.45,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              ref.read(favouritesProvider.notifier).toggleFavourite(widget.property.id);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFavourited ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                color: isFavourited ? Colors.redAccent : AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            widget.property.images.isNotEmpty
                ? PageView.builder(
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
                  )
                : _buildPlaceholder(),
            
            // Web Navigation Arrows Overlay
            if (widget.property.images.length > 1)
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          onPressed: () {
                            if (_currentImageIndex > 0) {
                              _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                          onPressed: () {
                            if (_currentImageIndex < widget.property.images.length - 1) {
                              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Image Counter Overlay
            if (widget.property.images.length > 1)
              Positioned(
                bottom: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1} / ${widget.property.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

            // 360 View Badge Overlay
            // (Mocking condition here, but checking for a known 360 data field if it existed)
            if (widget.property.images.isNotEmpty && widget.property.type.toUpperCase() == 'NYUMBA') // Example condition
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.view_in_ar_rounded, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        '360° View',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image_not_supported_outlined, size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text('Property image unavailable', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPropertySummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.property.title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.property.type.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.location_on_rounded, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 6),
            Text(
              '${widget.property.district}, ${widget.property.region}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          Formatters.formatCurrency(widget.property.price).replaceAll('TZS ', 'Tsh '),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInformationGrid() {
    List<Map<String, String>> infoData = [];
    
    // Add common fields
    infoData.add({'label': 'details.status'.tr(), 'value': widget.property.status, 'icon': 'info'});
    infoData.add({'label': 'details.location'.tr(), 'value': widget.property.region, 'icon': 'location'});

    switch (widget.property.type.toUpperCase()) {
      case 'VIWANJA':
      case 'KIWANJA':
        infoData.insert(0, {'label': 'details.size'.tr(), 'value': widget.property.size ?? 'N/A', 'icon': 'size'});
        infoData.insert(1, {'label': 'details.type'.tr(), 'value': widget.property.landUse ?? 'Makazi', 'icon': 'type'});
        if (widget.property.documentation != null) infoData.add({'label': 'details.docs'.tr(), 'value': widget.property.documentation!, 'icon': 'description'});
        break;
      case 'NYUMBA':
        infoData.insert(0, {'label': 'details.bedrooms'.tr(), 'value': widget.property.bedrooms?.toString() ?? 'N/A', 'icon': 'bed'});
        infoData.insert(1, {'label': 'details.bathrooms'.tr(), 'value': widget.property.bathrooms?.toString() ?? 'N/A', 'icon': 'bath'});
        infoData.insert(2, {'label': 'details.size'.tr(), 'value': widget.property.size ?? 'N/A', 'icon': 'size'});
        if (widget.property.houseType != null) infoData.add({'label': 'details.type'.tr(), 'value': widget.property.houseType!, 'icon': 'home'});
        if (widget.property.houseCondition != null) infoData.add({'label': 'details.condition'.tr(), 'value': widget.property.houseCondition!, 'icon': 'star'});
        break;
      case 'MAGARI':
      case 'GARI':
        infoData.insert(0, {'label': 'details.make'.tr(), 'value': widget.property.vehicleMake ?? 'N/A', 'icon': 'car'});
        infoData.insert(1, {'label': 'details.model'.tr(), 'value': widget.property.vehicleModel ?? 'N/A', 'icon': 'car_repair'});
        infoData.insert(2, {'label': 'details.year'.tr(), 'value': widget.property.vehicleYear?.toString() ?? 'N/A', 'icon': 'calendar'});
        if (widget.property.fuelType != null) infoData.add({'label': 'details.fuel'.tr(), 'value': widget.property.fuelType!, 'icon': 'local_gas_station'});
        if (widget.property.transmission != null) infoData.add({'label': 'details.gear'.tr(), 'value': widget.property.transmission!, 'icon': 'settings'});
        if (widget.property.bodyType != null) infoData.add({'label': 'details.body'.tr(), 'value': widget.property.bodyType!, 'icon': 'directions_car'});
        if (widget.property.color != null && widget.property.color!.isNotEmpty) infoData.add({'label': 'details.color'.tr(), 'value': widget.property.color!, 'icon': 'palette'});
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.property_info'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: infoData.length,
          itemBuilder: (context, index) {
            final item = infoData[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['value']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['label']!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    final String description = widget.property.description.isNotEmpty 
        ? widget.property.description 
        : 'No description provided by the agent.';

    // Very simplistic length check for preview
    final bool isLong = description.length > 150;
    final String displayText = _isDescriptionExpanded || !isLong
        ? description
        : '${description.substring(0, 150)}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.about_property'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Text(
            displayText,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        if (isLong)
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _isDescriptionExpanded ? 'details.show_less'.tr() : 'details.read_more'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.location'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${widget.property.street ?? ''} ${widget.property.ward ?? ''} ${widget.property.district}, ${widget.property.region}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.listed_by'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryLight,
                child: const Text('PF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'Power Family Investment Ltd',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.verified_rounded, color: Colors.blue, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'details.verified_agent'.tr(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarProperties() {
    final propertiesState = ref.watch(availablePropertiesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.similar_properties'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        propertiesState.when(
          data: (properties) {
            // Filter by type and exclude current property
            final similar = properties.where((p) => 
                p.type.toUpperCase() == widget.property.type.toUpperCase() && 
                p.id != widget.property.id
            ).take(4).toList();

            if (similar.isEmpty) {
              return Text('details.no_similar'.tr(), style: const TextStyle(color: AppColors.textSecondary));
            }

            return SizedBox(
              height: 450, // Increased height to prevent overflow
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: similar.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8, // 80% width
                    child: CustomerPropertyCard(
                      property: similar[index],
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
          error: (error, _) => const Text('Failed to load similar properties.', style: TextStyle(color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _buildStickyBottomCTA() {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 8 : 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/orders/acquire', extra: widget.property),
              icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 20),
              label: Text(
                context.locale.languageCode == 'sw' ? 'Miliki Mali Hii' : 'Get This Property',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openWhatsApp,
                  icon: const Icon(Icons.chat_rounded, size: 16, color: Color(0xFF25D366)),
                  label: const Text('WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isStartingChat ? null : _startLiveChat,
                  icon: _isStartingChat 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.forum_rounded, size: 16, color: AppColors.primary),
                  label: const Text('Live Chat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _contactPowerFamily,
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 16, color: AppColors.accent),
                  label: const Text('Call Us', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.accent, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

