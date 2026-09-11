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
        onTap: (index) {
          setState(() => _currentIndex = index);
          _navigateTab(role, index);
        },
        items: _buildRoleNavItems(role),
      ),
    );
  }

  Widget _buildRoleDashboardBody(String role) {
    switch (role) {
      case AppConstants.roleSuperAdmin:
        return const SuperAdminDashboard();
      case AppConstants.roleBranchManager:
        return const BranchManagerDashboard();
      case AppConstants.roleSalesAgent:
        return const SalesAgentDashboard();
      case AppConstants.roleSurveyor:
        return const SurveyorDashboard();
      default:
        return const SuperAdminDashboard();
    }
  }

  List<BottomNavigationBarItem> _buildRoleNavItems(String role) {
    switch (role) {
      case AppConstants.roleSuperAdmin:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.holiday_village_outlined), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'More Hub'),
        ];
      case AppConstants.roleBranchManager:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.holiday_village_outlined), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard_outlined), label: 'Leads'),
        ];
      case AppConstants.roleSalesAgent:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.holiday_village_outlined), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'My Leads'),
        ];
      case AppConstants.roleSurveyor:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Survey Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.landscape_outlined), label: 'Land Plots'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ];
      default:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.holiday_village_outlined), label: 'Properties'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ];
    }
  }

  void _navigateTab(String role, int index) {
    if (index == 0) return; // Stay on dashboard

    if (role == AppConstants.roleSuperAdmin) {
      if (index == 1) context.push('/properties');
      if (index == 2) context.push('/customers');
      if (index == 3) _showSuperAdminMoreModal(context);
    } else if (role == AppConstants.roleBranchManager) {
      if (index == 1) context.push('/properties');
      if (index == 2) context.push('/customers');
      if (index == 3) context.push('/leads');
    } else if (role == AppConstants.roleSalesAgent) {
      if (index == 1) context.push('/properties');
      if (index == 2) context.push('/customers');
      if (index == 3) context.push('/leads');
    } else if (role == AppConstants.roleSurveyor) {
      if (index == 1) context.push('/surveys');
      if (index == 2) context.push('/properties');
      if (index == 3) context.push('/profile');
    }
  }

  void _showSuperAdminMoreModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
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
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _hubTile(context, 'Branches', Icons.storefront, '/branches', AppColors.accent),
                  _hubTile(context, 'Users/Staff', Icons.manage_accounts, '/users', AppColors.primary),
                  _hubTile(context, 'Leads', Icons.trending_up, '/leads', AppConstants.leadNew != '' ? AppColors.statusPending : Colors.grey),
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
