import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/property_model.dart';
import '../../repositories/property_repository.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';
import '../auth/auth_controller.dart';

final propertyRepositoryProvider = Provider((ref) => PropertyRepository());

class PropertyListScreen extends ConsumerStatefulWidget {
  const PropertyListScreen({super.key});

  @override
  ConsumerState<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends ConsumerState<PropertyListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<PropertyModel> _properties = [];
  bool _isLoading = true;
  String _selectedStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => _loadProperties());
    // Use Future.microtask to allow providers to be read after init
    Future.microtask(() => _loadProperties());
  }

  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);
    String typeFilter = 'all';
    if (_tabController.index == 1) typeFilter = AppConstants.typeKiwanja;
    if (_tabController.index == 2) typeFilter = AppConstants.typeNyumba;
    if (_tabController.index == 3) typeFilter = AppConstants.typeGari;

    final user = ref.read(authControllerProvider).value;
    final isAdmin = user?.role.toUpperCase() == AppConstants.roleSuperAdmin || 
                    user?.role.toUpperCase() == AppConstants.roleSystemAdmin;
    final filterBranchId = isAdmin ? null : user?.branchId;

    final repo = ref.read(propertyRepositoryProvider);
    final list = await repo.getProperties(
      type: typeFilter,
      status: _selectedStatusFilter,
      searchQuery: _searchController.text,
      branchId: filterBranchId,
    );

    setState(() {
      _properties = list;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_home_work),
            tooltip: 'Add Property',
            onPressed: () => context.push('/properties/new').then((_) => _loadProperties()),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Viwanja'),
            Tab(text: 'Nyumba'),
            Tab(text: 'Magari'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search & Status Filter Toolbar
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _loadProperties(),
                  decoration: InputDecoration(
                    hintText: 'Search properties by code, title, location...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _loadProperties();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _statusFilterChip('All Statuses', 'all'),
                      const SizedBox(width: 6),
                      _statusFilterChip('Available', AppConstants.propertyAvailable),
                      const SizedBox(width: 6),
                      _statusFilterChip('Reserved', AppConstants.propertyReserved),
                      const SizedBox(width: 6),
                      _statusFilterChip('Sold', AppConstants.propertySold),
                      const SizedBox(width: 6),
                      _statusFilterChip('Under Process', AppConstants.propertyUnderProcess),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Property Cards List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _properties.isEmpty
                    ? EmptyState(
                        title: 'No Properties Found',
                        message: 'No properties match your filter criteria.',
                        buttonText: 'Add New Property',
                        onButtonPressed: () => context.push('/properties/new').then((_) => _loadProperties()),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProperties,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _properties.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final p = _properties[index];
                            return _buildPropertyCard(context, p);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _statusFilterChip(String label, String value) {
    final isSelected = _selectedStatusFilter == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.textPrimary)),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceVariant,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedStatusFilter = value);
          _loadProperties();
        }
      },
    );
  }

  Widget _buildPropertyCard(BuildContext context, PropertyModel p) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/properties/${p.id}').then((_) => _loadProperties()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview Container with Badges
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  color: AppColors.primaryLight,
                  child: p.images.isNotEmpty
                      ? Image.network(
                          p.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.apartment, size: 48, color: Colors.white38),
                        )
                      : const Icon(Icons.apartment, size: 48, color: Colors.white38),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      p.propertyCode,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: StatusBadge(status: p.status),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      AppConstants.getPropertyTypeLabel(p.type),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            // Details Body
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          p.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Specifications Highlights
                  if (p.type == AppConstants.typeKiwanja)
                    Text('Size: ${p.size ?? "N/A"} • Plot ${p.plotNumber ?? "N/A"} • ${p.surveyStatus ?? "Not Surveyed"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  if (p.type == AppConstants.typeNyumba)
                    Text('Bedrooms: ${p.bedrooms ?? 0} • Bathrooms: ${p.bathrooms ?? 0} • ${p.size ?? ""}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  if (p.type == AppConstants.typeGari)
                    Text('Year: ${p.vehicleYear ?? "N/A"} • Reg: ${p.vehicleRegistration ?? "N/A"} • ${p.vehicleMileage ?? ""}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),

                  const Divider(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatters.formatCurrency(p.price),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.accentDark),
                      ),
                      const Icon(Icons.arrow_forward, size: 18, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
