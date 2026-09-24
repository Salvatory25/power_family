import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/property_model.dart';
import '../../repositories/property_repository.dart';
import '../dashboard/dashboard_providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/confirm_dialog.dart';
import 'property_list_screen.dart';
import '../auth/auth_controller.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  ConsumerState<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  PropertyModel? _property;
  bool _isLoading = true;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  Future<void> _loadProperty() async {
    final props = await ref.read(propertyRepositoryProvider).getProperties();
    final match = props.where((p) => p.id == widget.propertyId).toList();
    if (mounted) {
      setState(() {
        _property = match.isNotEmpty ? match.first : (props.isNotEmpty ? props.first : null);
        _isLoading = false;
      });
    }
  }

  void _showStatusUpdateModal() {
    if (_property == null) return;
    String selectedStatus = _property!.status;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Change Property Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(filled: true),
                  items: const [
                    DropdownMenuItem(value: AppConstants.propertyAvailable, child: Text('Available')),
                    DropdownMenuItem(value: AppConstants.propertyReserved, child: Text('Reserved')),
                    DropdownMenuItem(value: AppConstants.propertySold, child: Text('Sold')),
                    DropdownMenuItem(value: AppConstants.propertyUnderProcess, child: Text('Under Process')),
                    DropdownMenuItem(value: AppConstants.propertySurveying, child: Text('Surveying')),
                    DropdownMenuItem(value: AppConstants.propertyInactive, child: Text('Inactive')),
                  ],
                  onChanged: (val) => setModalState(() => selectedStatus = val!),
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: 'Update Status',
                  onPressed: () async {
                    final repo = ref.read(propertyRepositoryProvider);
                    await repo.updatePropertyStatus(_property!.id, selectedStatus);
                    Navigator.pop(ctx);
                    _loadProperty();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Property status updated to ${selectedStatus.toUpperCase()}')),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    if (_property == null) return;
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Delete Property',
      message: 'Are you sure you want to permanently delete this property? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirm == true) {
      final repo = ref.read(propertyRepositoryProvider);
      await repo.deleteProperty(_property!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property deleted successfully.')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _property == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Property Details')),
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Property not found.'),
        ),
      );
    }

    final p = _property!;
    final branches = ref.watch(branchesProvider).value ?? [];
    final users = ref.watch(usersProvider).value ?? [];
    final branchMatches = branches.where((b) => b.id == p.branchId).toList();
    final branchName = branchMatches.isNotEmpty ? branchMatches.first.name : 'Main HQ';
    final agentMatches = users.where((u) => u.uid == p.assignedAgentId).toList();
    final agentName = agentMatches.isNotEmpty ? agentMatches.first.fullName : 'Unassigned Agent';
    final user = ref.watch(authControllerProvider).value;
    final isCustomer = user?.role.toUpperCase() == AppConstants.roleCustomer;


    return Scaffold(
      appBar: AppBar(
        title: Text(p.propertyCode),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Property',
            onPressed: () {
              context.push('/properties/edit', extra: p).then((_) => _loadProperty());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            tooltip: 'Delete Property',
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Image Carousel Banner
            SizedBox(
              height: 250,
              width: double.infinity,
              child: p.images.isNotEmpty
                  ? Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: p.images.length,
                          onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                          itemBuilder: (ctx, idx) {
                            return Image.network(
                              p.images[idx],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.primaryLight,
                                child: const Icon(Icons.apartment, size: 64, color: Colors.white38),
                              ),
                            );
                          },
                        ),
                        // Web Navigation Arrows Overlay
                        if (p.images.length > 1)
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
                                        if (_currentImageIndex < p.images.length - 1) {
                                          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (p.images.length > 1)
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                p.images.length,
                                (idx) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentImageIndex == idx ? 12 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentImageIndex == idx ? Colors.white : Colors.white54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: AppColors.primaryLight,
                      child: const Center(child: Icon(Icons.apartment, size: 64, color: Colors.white38)),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadge(status: p.status, fontSize: 13),
                      Text(
                        AppConstants.getPropertyTypeLabel(p.type),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    p.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    Formatters.formatCurrency(p.price),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.accentDark),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${p.location}, ${p.district}, ${p.region}',
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  // Property Specific Details Breakdown
                  const Text('Property Specifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        if (p.type == AppConstants.typeKiwanja) ...[
                          _specRow('Plot Size', p.size ?? 'N/A'),
                          _specRow('Plot Number', p.plotNumber ?? 'N/A'),
                          _specRow('Block Number', p.blockNumber ?? 'N/A'),
                          _specRow('Land Use', p.landUse ?? 'N/A'),
                          _specRow('Survey Status', p.surveyStatus ?? 'N/A'),
                          _specRow('Registration Status', p.registrationStatus ?? 'N/A'),
                          if (p.documentation != null) _specRow('Documentation', p.documentation!),
                        ],
                        if (p.type == AppConstants.typeNyumba) ...[
                          if (p.houseType != null) _specRow('Type', p.houseType!),
                          _specRow('Bedrooms', '${p.bedrooms ?? 0} Rooms'),
                          _specRow('Bathrooms', '${p.bathrooms ?? 0} Baths'),
                          _specRow('Property Size', p.size ?? 'N/A'),
                          if (p.houseCondition != null) _specRow('Condition', p.houseCondition!),
                        ],
                        if (p.type == AppConstants.typeGari) ...[
                          _specRow('Make & Model', '${p.vehicleMake ?? ""} ${p.vehicleModel ?? ""}'),
                          _specRow('Year', '${p.vehicleYear ?? "N/A"}'),
                          _specRow('Registration Number', p.vehicleRegistration ?? 'N/A'),
                          _specRow('Mileage', p.vehicleMileage ?? 'N/A'),
                          _specRow('Condition', p.vehicleCondition ?? 'N/A'),
                          if (p.fuelType != null) _specRow('Fuel Type', p.fuelType!),
                          if (p.transmission != null) _specRow('Transmission', p.transmission!),
                          if (p.bodyType != null) _specRow('Body Type', p.bodyType!),
                          if (p.color != null) _specRow('Color', p.color!),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    p.description,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                  ),

                  const Divider(height: 30),

                  // Assignment Details
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text('Assigned Agent: $agentName'),
                      subtitle: Text('Branch: $branchName'),
                      trailing: IconButton(
                        icon: const Icon(Icons.phone, color: AppColors.statusAvailable),
                        onPressed: () {
                          // Call Agent
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (isCustomer && p.status == AppConstants.propertyAvailable)
                    AppButton(
                      text: 'Get This Property',
                      onPressed: () {
                        context.push('/orders/acquire', extra: p);
                      },
                    ),

                  if (!isCustomer)
                    AppButton(
                      text: 'Change Property Status',
                      onPressed: _showStatusUpdateModal,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
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
