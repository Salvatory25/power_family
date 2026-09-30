import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/header_background.dart';
import '../../core/utils/download_helper.dart';
import '../../core/utils/pdf_report_generator.dart';
import '../dashboard/dashboard_providers.dart';
import 'package:printing/printing.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          HeaderBackground(
            height: 220,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 10, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Analytics Hub',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        IconButton(
                          onPressed: _exportCurrentTab,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.ios_share_rounded, color: Colors.white, size: 20),
                          ),
                          tooltip: 'Export & Share Report',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Comprehensive real-time reports and insights.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 110),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.primary,
                    isScrollable: true,
                    unselectedLabelColor: Colors.white.withOpacity(0.8),
                    labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13),
                    unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                    dividerColor: Colors.transparent,
                    padding: const EdgeInsets.all(4),
                    tabs: const [
                      Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Row(children: [Icon(Icons.analytics_rounded, size: 16), SizedBox(width: 6), Text('Finance')]))),
                      Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Row(children: [Icon(Icons.people_alt_rounded, size: 16), SizedBox(width: 6), Text('Users')]))),
                      Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Row(children: [Icon(Icons.holiday_village_rounded, size: 16), SizedBox(width: 6), Text('Properties')]))),
                      Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Row(children: [Icon(Icons.receipt_long_rounded, size: 16), SizedBox(width: 6), Text('Audit Log')]))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAnalyticsTab(context),
                      _buildUsersTab(context),
                      _buildPropertiesTab(context),
                      _buildAuditLogTab(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    final properties = ref.watch(propertiesProvider).value ?? [];
    final sales = ref.watch(salesProvider).value ?? [];
    final branches = ref.watch(branchesProvider).value ?? [];

    final totalSalesVal = properties
        .where((p) => p.status == 'SOLD')
        .fold<double>(0, (sum, p) => sum + p.price);
    
    final actualPayments = sales.fold<double>(0, (sum, s) => sum + s.amount);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Global Revenue Overview
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                if (!isMobile)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 36),
                  ),
                if (!isMobile) const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isMobile) ...[
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                              child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(child: Text('Total Realized Revenue (Sold)', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Formatters.formatCurrency(totalSalesVal),
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: isMobile ? 24 : 28, fontWeight: FontWeight.w900, letterSpacing: -1),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                        child: Text('Actual Payments Received: ${Formatters.formatCurrency(actualPayments)}', style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          _buildSectionHeader('Portfolio Distribution'),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 5))],
            ),
            child: isMobile 
            ? Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: _buildPieChartBody(properties),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem('Nyumba', AppColors.primary),
                      _buildLegendItem('Kiwanja', AppColors.accent),
                      _buildLegendItem('Gari', AppColors.statusUnderProcess),
                    ],
                  ),
                ],
              )
            : SizedBox(
                height: 240,
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildPieChartBody(properties),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem('Nyumba', AppColors.primary),
                          const SizedBox(height: 16),
                          _buildLegendItem('Kiwanja', AppColors.accent),
                          const SizedBox(height: 16),
                          _buildLegendItem('Gari', AppColors.statusUnderProcess),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ),
          const SizedBox(height: 32),
          
          _buildSectionHeader('Branch Performance'),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: branches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final b = branches[index];
              final bProps = properties.where((p) => p.branchId == b.id && p.status == 'SOLD').toList();
              final bRevenue = bProps.fold<double>(0, (sum, p) => sum + p.price);
              final double maxRevenue = branches.fold<double>(0, (max, branch) {
                final rev = properties.where((p) => p.branchId == branch.id && p.status == 'SOLD').fold<double>(0, (sum, p) => sum + p.price);
                return rev > max ? rev : max;
              });
              final double progress = maxRevenue > 0 ? bRevenue / maxRevenue : 0;

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(b.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                        Text(Formatters.formatCurrency(bRevenue), style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppColors.statusAvailable, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPieChartBody(List<dynamic> properties) {
    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 45,
        sections: [
          PieChartSectionData(
            color: AppColors.primary,
            value: properties.where((p) => p.type.toUpperCase() == 'NYUMBA').length.toDouble(),
            title: '',
            radius: 35,
            badgeWidget: _buildPieBadge(Icons.home_work_rounded, AppColors.primary),
            badgePositionPercentageOffset: .98,
          ),
          PieChartSectionData(
            color: AppColors.accent,
            value: properties.where((p) => p.type.toUpperCase() == 'KIWANJA').length.toDouble(),
            title: '',
            radius: 35,
            badgeWidget: _buildPieBadge(Icons.landscape_rounded, AppColors.accent),
            badgePositionPercentageOffset: .98,
          ),
          PieChartSectionData(
            color: AppColors.statusUnderProcess,
            value: properties.where((p) => p.type.toUpperCase() == 'GARI').length.toDouble(),
            title: '',
            radius: 35,
            badgeWidget: _buildPieBadge(Icons.directions_car_rounded, AppColors.statusUnderProcess),
            badgePositionPercentageOffset: .98,
          ),
        ],
      ),
    );
  }

  Widget _buildPieBadge(IconData icon, Color color) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }

  Widget _buildUsersTab(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    final users = ref.watch(usersProvider).value ?? [];
    final customers = ref.watch(customersProvider).value ?? [];

    final superAdmins = users.where((u) => u.role == 'super_admin').length;
    final branchManagers = users.where((u) => u.role == 'branch_manager').length;
    final staff = users.length - superAdmins - branchManagers;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            _buildMetricCard(context, 'Total Staff', users.length.toString(), Icons.badge_rounded, AppColors.primary),
            const SizedBox(height: 12),
            _buildMetricCard(context, 'Customers', customers.length.toString(), Icons.person_search_rounded, AppColors.accent),
          ] else
            Row(
              children: [
                Expanded(child: _buildMetricCard(context, 'Total Staff', users.length.toString(), Icons.badge_rounded, AppColors.primary)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard(context, 'Customers', customers.length.toString(), Icons.person_search_rounded, AppColors.accent)),
              ],
            ),
          const SizedBox(height: 32),
          
          _buildSectionHeader('Staff Role Distribution'),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 5))],
            ),
            child: Column(
              children: [
                _buildRoleRow('Super Admins', superAdmins, users.length, Colors.redAccent),
                const SizedBox(height: 20),
                _buildRoleRow('Branch Managers', branchManagers, users.length, Colors.blue),
                const SizedBox(height: 20),
                _buildRoleRow('Sales & Field Staff', staff, users.length, Colors.green),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          _buildSectionHeader('New Registered Users'),
          Builder(
            builder: (context) {
              final sortedUsers = List.of(users)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              final recentUsers = sortedUsers.take(10).toList();
              
              if (recentUsers.isEmpty) return const Text('No recent users.');
              
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentUsers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final u = recentUsers[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(u.fullName.substring(0, 1).toUpperCase(), style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                      title: Text(u.fullName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('${u.role.replaceAll('_', ' ').toUpperCase()} • Registered: ${Formatters.formatDate(u.createdAt)}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: u.status == 'active' ? AppColors.statusAvailable.withOpacity(0.1) : AppColors.statusPending.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          u.status.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: u.status == 'active' ? AppColors.statusAvailable : AppColors.statusPending,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPropertiesTab(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    final properties = ref.watch(propertiesProvider).value ?? [];
    final branches = ref.watch(branchesProvider).value ?? [];
    final users = ref.watch(usersProvider).value ?? [];

    final sortedProps = List.of(properties)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final newProps = sortedProps.take(20).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            _buildMetricCard(context, 'Total Properties', properties.length.toString(), Icons.holiday_village_rounded, AppColors.primary),
            const SizedBox(height: 12),
            _buildMetricCard(context, 'Available', properties.where((p) => p.status == 'AVAILABLE').length.toString(), Icons.check_circle_outline, AppColors.statusAvailable),
          ] else
            Row(
              children: [
                Expanded(child: _buildMetricCard(context, 'Total Properties', properties.length.toString(), Icons.holiday_village_rounded, AppColors.primary)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard(context, 'Available', properties.where((p) => p.status == 'AVAILABLE').length.toString(), Icons.check_circle_outline, AppColors.statusAvailable)),
              ],
            ),
          const SizedBox(height: 32),
          _buildSectionHeader('Recently Added Portfolio'),
          if (newProps.isEmpty)
             Center(child: Text('No properties found.', style: GoogleFonts.inter(color: AppColors.textSecondary)))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: newProps.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = newProps[index];
                
                final creator = users.where((u) => u.uid == p.createdBy).firstOrNull;
                final creatorName = creator != null ? creator.fullName : 'Admin / Manager';

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.holiday_village_outlined, color: AppColors.primary),
                    ),
                    title: Text(
                      p.title,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text('${p.type} • ${Formatters.formatCurrency(p.price)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        const SizedBox(height: 4),
                        Text('Added by: $creatorName on ${Formatters.formatDate(p.createdAt)}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: p.status == 'AVAILABLE' ? AppColors.statusAvailable.withOpacity(0.1) : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p.status,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: p.status == 'AVAILABLE' ? AppColors.statusAvailable : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAuditLogTab(BuildContext context) {
    final activitiesAsync = ref.watch(activitiesStreamProvider);

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return Center(child: Text('No system activities found.', style: GoogleFonts.inter(color: AppColors.textSecondary)));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: activities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final act = activities[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.article_outlined, color: AppColors.primary, size: 20),
                ),
                title: Text(
                  act.description,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    '${act.actorName} • ${Formatters.formatDateTime(act.createdAt)}',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    act.action,
                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const LoadingView(message: 'Loading live logs...'),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          if (isMobile) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: color.withOpacity(0.9), letterSpacing: -1)),
                  Text(title, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ] else 
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(height: 20),
                  Text(value, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: color.withOpacity(0.9), letterSpacing: -1)),
                  Text(title, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _exportCurrentTab() async {
    final properties = ref.read(propertiesProvider).value ?? [];
    final users = ref.read(usersProvider).value ?? [];
    final branches = ref.read(branchesProvider).value ?? [];
    final sales = ref.read(salesProvider).value ?? [];

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating PDF Report...'), duration: Duration(seconds: 1)),
    );

    final pdfBytes = await PdfReportGenerator.generateReport(
      properties: properties,
      users: users,
      branches: branches,
      sales: sales,
    );

    final filename = 'Power_Family_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    
    // Automatically shares on mobile OR downloads on Web!
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text("PDF Report Ready! You can now share it.", style: GoogleFonts.inter(fontWeight: FontWeight.bold))),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildRoleRow(String label, int count, int total, Color color) {
    final double percent = total > 0 ? count / total : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
            Text('$count (${(percent * 100).toStringAsFixed(0)}%)', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 10,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
