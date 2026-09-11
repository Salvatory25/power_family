import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/property_model.dart';
import '../../repositories/seed_data.dart';
import '../../repositories/property_repository.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/confirm_dialog.dart';
import 'property_list_screen.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  ConsumerState<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  late PropertyModel _property;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  void _loadProperty() {
    final match = SeedData.properties.firstWhere(
      (p) => p.id == widget.propertyId,
      orElse: () => SeedData.properties[0],
    );
    setState(() {
      _property = match;
      _isLoading = false;
    });
  }

  void _showStatusUpdateModal() {
    String selectedStatus = _property.status;

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
                    await repo.updatePropertyStatus(_property.id, selectedStatus);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final p = _property;
    final branch = SeedData.branches.firstWhere((b) => b.id == p.branchId, orElse: () => SeedData.branches[0]);
    final agent = SeedData.users.firstWhere((u) => u.uid == p.assignedAgentId, orElse: () => SeedData.users[0]);

    return Scaffold(
      appBar: AppBar(
        title: Text(p.propertyCode),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Update Status',
            onPressed: _showStatusUpdateModal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Image Carousel Banner
            Container(
              height: 220,
              width: double.infinity,
              color: AppColors.primaryLight,
              child: p.images.isNotEmpty
                  ? Image.network(p.images.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.apartment, size: 64, color: Colors.white38))
                  : const Icon(Icons.apartment, size: 64, color: Colors.white38),
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
                        ],
                        if (p.type == AppConstants.typeNyumba) ...[
                          _specRow('Bedrooms', '${p.bedrooms ?? 0} Rooms'),
                          _specRow('Bathrooms', '${p.bathrooms ?? 0} Baths'),
                          _specRow('Property Size', p.size ?? 'N/A'),
                        ],
                        if (p.type == AppConstants.typeGari) ...[
                          _specRow('Make & Model', '${p.vehicleMake ?? ""} ${p.vehicleModel ?? ""}'),
                          _specRow('Year', '${p.vehicleYear ?? "N/A"}'),
                          _specRow('Registration Number', p.vehicleRegistration ?? 'N/A'),
                          _specRow('Mileage', p.vehicleMileage ?? 'N/A'),
                          _specRow('Condition', p.vehicleCondition ?? 'N/A'),
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
                      title: Text('Assigned Agent: ${agent.fullName}'),
                      subtitle: Text('Branch: ${branch.name} (${branch.code})'),
                      trailing: IconButton(
                        icon: const Icon(Icons.phone, color: AppColors.statusAvailable),
                        onPressed: () {
                          // Call Agent
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

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
