import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../repositories/seed_data.dart';
import '../../widgets/header_background.dart';
import '../../widgets/stat_card.dart';
import '../auth/auth_controller.dart';

class SuperAdminDashboard extends ConsumerWidget {
  const SuperAdminDashboard({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final properties = SeedData.properties;
    final branches = SeedData.branches;
    final users = SeedData.users;
    final customers = SeedData.customers;
    final leads = SeedData.leads;
    final sales = SeedData.sales;
    final activities = SeedData.activities;

    final availableProps = properties.where((p) => p.status == AppConstants.propertyAvailable).length;
    final soldProps = properties.where((p) => p.status == AppConstants.propertySold).length;

    final totalRevenue = sales.fold<double>(0, (sum, s) => sum + s.amount);
    final pendingUsers = users.where((u) => u.status == AppConstants.statusPending).length;

    return Stack(
      children: [
        // Top Deep Header Banner Background
        HeaderBackground(
          height: 250,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Premium Profile Row
                  Row(
                    children: [
                      // Avatar with Golden Ring & Online Status
                      InkWell(
                        onTap: () => context.push('/profile'),
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [AppColors.accent, Colors.white70],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 23,
                                  backgroundColor: AppColors.primaryLight,
                                  child: Text(
                                    (user?.fullName ?? 'A').substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.statusAvailable,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.accent.withOpacity(0.6), width: 0.8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.admin_panel_settings_rounded, size: 10, color: AppColors.accent),
                                      const SizedBox(width: 3),
                                      Text(
                                        AppConstants.getRoleLabel(user?.role ?? AppConstants.roleSuperAdmin).toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.fullName ?? 'System Administrator',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Header Actions
                      Row(
                        children: [
                          InkWell(
                            onTap: () => context.push('/profile'),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.18)),
                              ),
                              child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                                ),
                                child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Quick Summary Floating Pills Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildHeaderPill(Icons.payments_outlined, Formatters.formatCurrency(totalRevenue), AppColors.accent),
                        const SizedBox(width: 8),
                        _buildHeaderPill(Icons.store_mall_directory_outlined, '${branches.length} Branches', Colors.white),
                        const SizedBox(width: 8),
                        _buildHeaderPill(Icons.people_outline, '${users.length} Users', Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main Body Floating Curved Container Sheet
        Padding(
          padding: const EdgeInsets.only(top: 175.0),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pending Approvals Banner Alert (if any)
                  if (pendingUsers > 0) ...[
                    InkWell(
                      onTap: () => context.push('/users'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.statusPending.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.statusPending.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.statusPending,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.priority_high_rounded, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$pendingUsers Pending User Registrations',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Tap to review, assign roles, and activate staff accounts.',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.statusPending),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Administrator Quick Actions Section
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0C4E5B).withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Administrator Management Controls',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Manage organization structure, add company branches, and register staff across roles.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () => context.push('/branches'),
                                icon: const Icon(Icons.add_business_rounded, size: 18),
                                label: const Text('Add Branch', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                onPressed: () => context.push('/users'),
                                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                                label: const Text('Add Staff', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Key System Performance Stats Grid
                  const Text(
                    'Executive Performance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                    children: [
                      StatCard(
                        title: 'Total Revenue',
                        value: Formatters.formatCurrency(totalRevenue),
                        icon: Icons.payments_outlined,
                        color: AppColors.statusAvailable,
                        subtitle: '${sales.length} Completed Sales',
                        onTap: () => context.push('/sales'),
                      ),
                      StatCard(
                        title: 'Total Properties',
                        value: properties.length.toString(),
                        icon: Icons.holiday_village_outlined,
                        color: AppColors.primary,
                        subtitle: '$availableProps Available | $soldProps Sold',
                        onTap: () => context.push('/properties'),
                      ),
                      StatCard(
                        title: 'Company Branches',
                        value: branches.length.toString(),
                        icon: Icons.store_mall_directory_outlined,
                        color: AppColors.accent,
                        subtitle: '${branches.where((b) => b.status == 'active').length} Active Branches',
                        onTap: () => context.push('/branches'),
                      ),
                      StatCard(
                        title: 'System Users',
                        value: users.length.toString(),
                        icon: Icons.people_outline,
                        color: AppColors.statusUnderProcess,
                        subtitle: '$pendingUsers Pending Approval',
                        onTap: () => context.push('/users'),
                      ),
                      StatCard(
                        title: 'Customers',
                        value: customers.length.toString(),
                        icon: Icons.person_search_outlined,
                        color: AppColors.statusSurveying,
                        onTap: () => context.push('/customers'),
                      ),
                      StatCard(
                        title: 'Active Leads',
                        value: leads.length.toString(),
                        icon: Icons.trending_up,
                        color: AppColors.statusReserved,
                        onTap: () => context.push('/leads'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Property Breakdown Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Property Portfolio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push('/properties'),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('View All', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _propertyTypeChip(context, 'Viwanja (Land)', properties.where((p) => p.type == 'kiwanja').length, Icons.landscape),
                        const SizedBox(width: 12),
                        _propertyTypeChip(context, 'Nyumba (Houses)', properties.where((p) => p.type == 'nyumba').length, Icons.home_work),
                        const SizedBox(width: 12),
                        _propertyTypeChip(context, 'Magari (Vehicles)', properties.where((p) => p.type == 'gari').length, Icons.directions_car),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Recent Activity Audit Log
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent System Activities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.history_rounded, size: 16, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activities.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final act = activities[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.article_outlined, color: AppColors.primary, size: 20),
                          ),
                          title: Text(
                            act.description,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            '${act.actorName} • ${Formatters.formatDateTime(act.createdAt)}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderPill(IconData icon, String text, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accentColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _propertyTypeChip(BuildContext context, String label, int count, IconData icon) {
    return InkWell(
      onTap: () => context.push('/properties'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0C4E5B).withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('$count Items', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
