import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../auth/auth_controller.dart';
import 'super_admin_dashboard.dart';
import 'branch_manager_dashboard.dart';
import 'sales_agent_dashboard.dart';
import 'surveyor_dashboard.dart';
import '../marketing/ai_marketing_center_screen.dart';
import '../finance/finance_hub_screen.dart';
import '../customers/customer_list_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authControllerProvider);
    final user = userState.value;
    final role = user?.role ?? AppConstants.roleSuperAdmin;

    return Scaffold(
      body: _buildRoleDashboardBody(role),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _navigateTab(role, index);
        },
        items: _buildRoleNavItems(role),
      ),
    );
  }

  Widget _buildRoleDashboardBody(String rawRole) {
    final role = rawRole.toUpperCase();
    switch (role) {
      case AppConstants.roleSuperAdmin:
      case AppConstants.roleAdmin:
      case AppConstants.roleManagement:
        return const SuperAdminDashboard();

      case AppConstants.roleBranchManager:
      case AppConstants.roleSalesManager:
        return const BranchManagerDashboard();

      case AppConstants.roleSalesAgent:
      case AppConstants.roleSecretary:
      case AppConstants.roleFollowUpOfficer:
      case AppConstants.roleFieldOfficer:
        return const SalesAgentDashboard();

      case AppConstants.roleSurveyor:
      case AppConstants.roleSurveyAssistant:
      case AppConstants.roleDocumentOfficer:
        return const SurveyorDashboard();

      case AppConstants.roleMarketingManager:
      case AppConstants.roleSocialMediaManager:
        return const AIMarketingCenterScreen();

      case AppConstants.roleAccountant:
        return const FinanceHubScreen();

      case AppConstants.roleCustomerSupport:
        return const CustomerListScreen();

      default:
        return const SalesAgentDashboard();
    }
  }

  List<BottomNavigationBarItem> _buildRoleNavItems(String rawRole) {
    final role = rawRole.toUpperCase();
    switch (role) {
      case AppConstants.roleSuperAdmin:
      case AppConstants.roleAdmin:
      case AppConstants.roleManagement:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.holiday_village_outlined), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'More Hub'),
        ];

      case AppConstants.roleBranchManager:
      case AppConstants.roleSalesManager:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Branch HQ'),
          BottomNavigationBarItem(icon: Icon(Icons.holiday_village_outlined), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard_outlined), label: 'Leads'),
        ];

      case AppConstants.roleSalesAgent:
      case AppConstants.roleSecretary:
      case AppConstants.roleFollowUpOfficer:
      case AppConstants.roleFieldOfficer:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'My Desk'),
          BottomNavigationBarItem(icon: Icon(Icons.holiday_village_outlined), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'My Leads'),
        ];

      case AppConstants.roleSurveyor:
      case AppConstants.roleSurveyAssistant:
      case AppConstants.roleDocumentOfficer:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Survey Desk'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Survey Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.landscape_outlined), label: 'Land Plots'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ];

      case AppConstants.roleMarketingManager:
      case AppConstants.roleSocialMediaManager:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), label: 'AI Marketing'),
          BottomNavigationBarItem(icon: Icon(Icons.holiday_village_outlined), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Leads'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ];

      case AppConstants.roleAccountant:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Finance Hub'),
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Sales'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment_outlined), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ];

      case AppConstants.roleCustomerSupport:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Leads'),
          BottomNavigationBarItem(icon: Icon(Icons.sms_outlined), label: 'SMS Center'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ];

      default:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'My Desk'),
          BottomNavigationBarItem(icon: Icon(Icons.holiday_village_outlined), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ];
    }
  }

  void _navigateTab(String rawRole, int index) {
    if (index == 0) return; // Stay on primary dashboard screen

    final role = rawRole.toUpperCase();
    switch (role) {
      case AppConstants.roleSuperAdmin:
      case AppConstants.roleAdmin:
      case AppConstants.roleManagement:
        if (index == 1) context.push('/properties');
        if (index == 2) context.push('/customers');
        if (index == 3) _showSuperAdminMoreModal(context);
        break;

      case AppConstants.roleBranchManager:
      case AppConstants.roleSalesManager:
        if (index == 1) context.push('/properties');
        if (index == 2) context.push('/customers');
        if (index == 3) context.push('/leads');
        break;

      case AppConstants.roleSalesAgent:
      case AppConstants.roleSecretary:
      case AppConstants.roleFollowUpOfficer:
      case AppConstants.roleFieldOfficer:
        if (index == 1) context.push('/properties');
        if (index == 2) context.push('/customers');
        if (index == 3) context.push('/leads');
        break;

      case AppConstants.roleSurveyor:
      case AppConstants.roleSurveyAssistant:
      case AppConstants.roleDocumentOfficer:
        if (index == 1) context.push('/surveys');
        if (index == 2) context.push('/properties');
        if (index == 3) context.push('/profile');
        break;

      case AppConstants.roleMarketingManager:
      case AppConstants.roleSocialMediaManager:
        if (index == 1) context.push('/properties');
        if (index == 2) context.push('/leads');
        if (index == 3) context.push('/profile');
        break;

      case AppConstants.roleAccountant:
        if (index == 1) context.push('/sales');
        if (index == 2) context.push('/reports');
        if (index == 3) context.push('/profile');
        break;

      case AppConstants.roleCustomerSupport:
        if (index == 1) context.push('/leads');
        if (index == 2) context.push('/sms');
        if (index == 3) context.push('/profile');
        break;

      default:
        if (index == 1) context.push('/properties');
        if (index == 2) context.push('/customers');
        if (index == 3) context.push('/profile');
        break;
    }
  }

  void _showSuperAdminMoreModal(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 4 : (screenWidth > 360 ? 3 : 2);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Super Admin Management Hub',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _hubTile(context, 'Plot Map (GIS)', Icons.map_outlined, '/plot-map', const Color(0xFF10B981)),
                  _hubTile(context, 'Finance Hub', Icons.account_balance_wallet_outlined, '/finance-hub', Colors.blue),
                  _hubTile(context, 'Land & Hati', Icons.badge_outlined, '/land-processing-hub', Colors.purple),
                  _hubTile(context, 'AI Marketing', Icons.auto_awesome_outlined, '/marketing-center', AppColors.accent),
                  _hubTile(context, 'Branches', Icons.storefront, '/branches', AppColors.accent),
                  _hubTile(context, 'Users/Staff', Icons.manage_accounts, '/users', AppColors.primary),
                  _hubTile(context, 'Leads', Icons.trending_up, '/leads', AppColors.statusPending),
                  _hubTile(context, 'Sales', Icons.point_of_sale, '/sales', AppColors.statusAvailable),
                  _hubTile(context, 'Surveys', Icons.architecture, '/surveys', AppColors.statusSurveying),
                  _hubTile(context, 'SMS System', Icons.sms_outlined, '/sms', AppColors.statusUnderProcess),
                  _hubTile(context, 'Reports', Icons.assessment_outlined, '/reports', AppColors.primary),
                  _hubTile(context, 'Settings', Icons.settings_outlined, '/settings', AppColors.textSecondary),
                  _hubTile(context, 'Profile', Icons.person_outline, '/profile', AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hubTile(BuildContext context, String label, IconData icon, String route, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        context.push(route);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
