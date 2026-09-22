import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

import '../../models/branch_model.dart';
import '../../widgets/header_background.dart';
import '../../widgets/stat_card.dart';
import '../auth/auth_controller.dart';
import 'dashboard_providers.dart';

class BranchManagerDashboard extends ConsumerWidget {
  const BranchManagerDashboard({super.key});

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
    final branchId = user?.branchId ?? 'branch_dar';

    final allProps = ref.watch(propertiesProvider).value ?? [];
    final allStaff = ref.watch(usersProvider).value ?? [];
    final allLeads = ref.watch(leadsProvider).value ?? [];
    final allSales = ref.watch(salesProvider).value ?? [];
    final allSurveys = ref.watch(surveysProvider).value ?? [];
    final branches = ref.watch(branchesProvider).value ?? [];

    final branchProps = allProps.where((p) => p.branchId == branchId || branchId == 'branch_dar').toList();
    final branchStaff = allStaff.where((u) => u.branchId == branchId || branchId == 'branch_dar').toList();
    final branchLeads = allLeads.where((l) => l.branchId == branchId || branchId == 'branch_dar').toList();
    final branchSales = allSales.where((s) => s.branchId == branchId || branchId == 'branch_dar').toList();
    final branchSurveys = allSurveys.where((st) => st.branchId == branchId || branchId == 'branch_dar').toList();

    final allActivities = ref.watch(activitiesProvider).value ?? [];
    final branchActivities = allActivities.where((a) => a.branchId == branchId || branchId == 'branch_dar').toList();
    branchActivities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final currentBranch = branches.firstWhere((b) => b.id == branchId, orElse: () => BranchModel(id: '', name: '', code: '', location: '', phone: '', email: '', status: 'active', createdAt: DateTime.now(), updatedAt: DateTime.now()));
    final double branchTarget = currentBranch.monthlyTarget;
    final double totalRevenue = branchSales.where((s) => s.saleStatus == 'completed' || s.saleStatus == AppConstants.saleCompleted).fold(0.0, (sum, item) => sum + item.amount);
    final double targetProgress = branchTarget > 0 ? (totalRevenue / branchTarget).clamp(0.0, 1.0) : 0.0;

    final availableCount = branchProps.where((p) => p.status == AppConstants.propertyAvailable).length;
    final soldCount = branchProps.where((p) => p.status == AppConstants.propertySold).length;

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
                                  backgroundImage: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                                      ? NetworkImage(user.photoUrl!)
                                      : null,
                                  child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                                      ? Text(
                                          (user?.fullName ?? 'M').substring(0, 1).toUpperCase(),
                                          style: const TextStyle(
                                            color: AppColors.accent,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        )
                                      : null,
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
                                      const Icon(Icons.stars_rounded, size: 10, color: AppColors.accent),
                                      const SizedBox(width: 3),
                                      Text(
                                        AppConstants.getRoleLabel(user?.role ?? AppConstants.roleBranchManager).toUpperCase(),
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
                              user?.fullName ?? 'Branch Manager',
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
                        _buildHeaderPill(Icons.people_outline, '${branchStaff.length} Staff Members', AppColors.accent),
                        const SizedBox(width: 8),
                        _buildHeaderPill(Icons.home_work_outlined, '${branchProps.length} Properties', Colors.white),
                        const SizedBox(width: 8),
                        _buildHeaderPill(Icons.point_of_sale_outlined, '${branchSales.length} Completed Sales', Colors.white),
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
          padding: const EdgeInsets.only(top: 185.0),
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
                  // Quick Actions Bar
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 85,
                          child: _buildQuickActionButton(context, Icons.add_home_work_rounded, 'Properties', () => context.push('/properties'), AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 85,
                          child: _buildQuickActionButton(context, Icons.add_card_rounded, 'Sales', () => context.push('/sales'), AppColors.statusAvailable),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 85,
                          child: _buildQuickActionButton(context, Icons.person_add_alt_rounded, 'Leads', () => context.push('/leads'), AppColors.accent),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 85,
                          child: _buildQuickActionButton(context, Icons.map_rounded, 'Surveys', () => context.push('/surveys'), AppColors.statusSurveying),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Branch Targets & Goals
                  const Text(
                    'Branch Targets & Goals',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTargetProgress(totalRevenue, branchTarget, targetProgress),
                  const SizedBox(height: 24),

                  const Text(
                    'Operational Performance',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double width = constraints.maxWidth;
                      final double ratio = width > 400 ? 1.25 : (width > 340 ? 1.1 : 1.0);
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: ratio,
                        children: [
                          StatCard(
                            title: 'Branch Properties',
                            value: branchProps.length.toString(),
                            icon: Icons.home_work_outlined,
                            color: AppColors.primary,
                            subtitle: '$availableCount Available | $soldCount Sold',
                            onTap: () => context.push('/properties'),
                          ),
                          StatCard(
                            title: 'Branch Sales',
                            value: branchSales.length.toString(),
                            icon: Icons.point_of_sale,
                            color: AppColors.statusAvailable,
                            onTap: () => context.push('/sales'),
                          ),
                          StatCard(
                            title: 'Branch Leads',
                            value: branchLeads.length.toString(),
                            icon: Icons.leaderboard,
                            color: AppColors.accent,
                            onTap: () => context.push('/leads'),
                          ),
                          StatCard(
                            title: 'Land Surveys',
                            value: branchSurveys.length.toString(),
                            icon: Icons.map_outlined,
                            color: AppColors.statusSurveying,
                            onTap: () => context.push('/surveys'),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Recent Revenue Chart
                  const Text(
                    'Recent Revenue',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRevenueChart(branchSales),
                  const SizedBox(height: 28),

                  // Branch Staff Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Branch Staff Members',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push('/users'),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text(
                          'View All',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: branchStaff.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final staff = branchStaff[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.accent.withOpacity(0.15),
                            child: Text(
                              staff.fullName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.accentDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          title: Text(
                            staff.fullName,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          subtitle: Text(
                            '${AppConstants.getRoleLabel(staff.role)} • ${staff.phone}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: staff.status == 'active'
                                  ? AppColors.statusAvailable.withOpacity(0.12)
                                  : AppColors.statusPending.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              staff.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: staff.status == 'active' ? AppColors.statusAvailable : AppColors.statusPending,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Recent Activities
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Activities',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('View All', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildActivitiesList(branchActivities),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetProgress(double totalRevenue, double target, double progress) {
    final currencyFormat = NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Revenue Target',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currencyFormat.format(totalRevenue),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Text(
                currencyFormat.format(target),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(List<dynamic> sales) {
    if (sales.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text('No sales data available for chart.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    
    // Create mock points for the last 7 days based on real data
    final Map<int, double> salesByDay = {for (var i = 0; i < 7; i++) i: 0.0};
    final now = DateTime.now();
    for (var s in sales) {
      final diff = now.difference(s.createdAt).inDays;
      if (diff >= 0 && diff < 7) {
        salesByDay[6 - diff] = (salesByDay[6 - diff] ?? 0) + s.amount;
      }
    }
    
    final spots = salesByDay.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    final double maxY = salesByDay.values.isEmpty ? 1000 : (salesByDay.values.reduce((a, b) => a > b ? a : b) * 1.2);

    return Container(
      height: 220,
      padding: const EdgeInsets.only(right: 20, left: 10, top: 20, bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY / 4) > 0 ? (maxY / 4) : 1,
            getDrawingHorizontalLine: (value) => FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final daysAgo = 6 - value.toInt();
                  if (daysAgo < 0 || daysAgo > 6) return const SizedBox.shrink();
                  final date = now.subtract(Duration(days: daysAgo));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('E').format(date),
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    '${(value / 1000000).toStringAsFixed(1)}M',
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: maxY == 0 ? 1000 : maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.statusAvailable,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.statusAvailable.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesList(List<dynamic> activities) {
    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text('No recent activities.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length > 5 ? 5 : activities.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final act = activities[index];
        IconData icon = Icons.info_outline;
        Color color = AppColors.primary;
        
        if (act.action.toLowerCase().contains('sale') || act.entityType == 'sale') {
          icon = Icons.attach_money;
          color = AppColors.statusAvailable;
        } else if (act.action.toLowerCase().contains('lead') || act.entityType == 'lead') {
          icon = Icons.person_add;
          color = AppColors.accent;
        } else if (act.action.toLowerCase().contains('property') || act.entityType == 'property') {
          icon = Icons.home;
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 16, color: color),
            ),
            title: Text(
              act.action,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            subtitle: Text(
              act.description,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              DateFormat('MMM d, h:mm a').format(act.createdAt),
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap, Color iconColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
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
}
