import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/account_status_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/branches/branch_list_screen.dart';
import '../../features/users/user_list_screen.dart';
import '../../features/properties/property_list_screen.dart';
import '../../features/properties/property_detail_screen.dart';
import '../../features/properties/property_form_screen.dart';
import '../../features/customers/customer_list_screen.dart';
import '../../features/customers/customer_detail_screen.dart';
import '../../features/leads/lead_list_screen.dart';
import '../../features/sales/sales_list_screen.dart';
import '../../features/surveys/survey_list_screen.dart';
import '../../features/sms/sms_compose_screen.dart';
import '../../features/sms/sms_history_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/reports/realtime_activity_report_screen.dart';
import '../../features/settings/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/properties/digital_plot_map_screen.dart';
import '../../features/finance/finance_hub_screen.dart';
import '../../features/land_processing/land_processing_hub_screen.dart';
import '../../features/marketing/ai_marketing_center_screen.dart';
import '../../features/customer_dashboard/customer_dashboard_screen.dart';
import '../../features/customer_dashboard/customer_property_details_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../models/property_model.dart';
import '../constants/app_constants.dart';
import '../../features/orders/screens/acquisition_flow_screen.dart';
import '../../features/orders/screens/payment_submission_screen.dart';
import '../../features/orders/screens/admin_order_management_screen.dart';
import '../../features/kikoba/screens/admin_kikoba_dashboard.dart';
import '../../features/orders/screens/my_orders_screen.dart';
import '../../features/orders/screens/order_details_screen.dart';
import '../../features/kikoba/screens/my_kikoba_screen.dart';
import '../../models/order_model.dart';
import '../../features/chat/screens/chat_list_screen.dart';
import '../../features/chat/screens/chat_room_screen.dart';
import '../../features/chat/screens/new_chat_screen.dart';
import '../../models/chat_model.dart';



final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/account-status',
        builder: (context, state) => const AccountStatusScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/customer-dashboard',
        builder: (context, state) => const CustomerDashboardScreen(),
      ),
      GoRoute(
        path: '/branches',
        builder: (context, state) => const BranchListScreen(),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UserListScreen(),
      ),
      GoRoute(
        path: '/properties',
        builder: (context, state) => const PropertyListScreen(),
      ),
      GoRoute(
        path: '/plot-map',
        builder: (context, state) => const DigitalPlotMapScreen(),
      ),
      GoRoute(
        path: '/finance-hub',
        builder: (context, state) => const FinanceHubScreen(),
      ),
      GoRoute(
        path: '/land-processing-hub',
        builder: (context, state) => const LandProcessingHubScreen(),
      ),
      GoRoute(
        path: '/marketing-center',
        builder: (context, state) => const AIMarketingCenterScreen(),
      ),
      GoRoute(
        path: '/properties/new',
        builder: (context, state) => const PropertyFormScreen(),
      ),
      GoRoute(
        path: '/properties/edit',
        builder: (context, state) {
          final property = state.extra as PropertyModel?;
          return PropertyFormScreen(propertyToEdit: property);
        },
      ),
      GoRoute(
        path: '/properties/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'prop_kiwanja_1';
          return PropertyDetailScreen(propertyId: id);
        },
      ),
      GoRoute(
        path: '/customer-properties/details',
        redirect: (context, state) => state.extra == null ? '/customer-dashboard' : null,
        builder: (context, state) {
          final property = state.extra as PropertyModel;
          return CustomerPropertyDetailsScreen(property: property);
        },
      ),
      GoRoute(
        path: '/customers',
        builder: (context, state) => const CustomerListScreen(),
      ),
      GoRoute(
        path: '/customers/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'cust_1';
          return CustomerDetailScreen(customerId: id);
        },
      ),
      GoRoute(
        path: '/leads',
        builder: (context, state) => const LeadListScreen(),
      ),
      GoRoute(
        path: '/sales',
        builder: (context, state) => const SalesListScreen(),
      ),
      GoRoute(
        path: '/surveys',
        builder: (context, state) => const SurveyListScreen(),
      ),
      GoRoute(
        path: '/sms',
        builder: (context, state) {
          final recipient = state.uri.queryParameters['recipient'];
          return SMSComposeScreen(initialRecipient: recipient);
        },
      ),
      GoRoute(
        path: '/sms/history',
        builder: (context, state) => const SMSHistoryScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/activity-report',
        builder: (context, state) => const RealtimeActivityReportScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/orders/acquire',
        redirect: (context, state) => state.extra == null ? '/customer-dashboard' : null,
        builder: (context, state) {
          final prop = state.extra as PropertyModel;
          return AcquisitionFlowScreen(property: prop);
        },
      ),
      GoRoute(
        path: '/orders/payment-submission',
        redirect: (context, state) => state.extra == null ? '/customer-dashboard' : null,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return PaymentSubmissionScreen(
            property: args['property'] as PropertyModel,
            plan: args['plan'] as String,
          );
        },
      ),
      GoRoute(
        path: '/my-orders',
        builder: (context, state) => const MyOrdersScreen(),
      ),
      GoRoute(
        path: '/my-kikoba',
        builder: (context, state) => const MyKikobaScreen(),
      ),
      GoRoute(
        path: '/orders/detail',
        redirect: (context, state) => state.extra == null ? '/my-orders' : null,
        builder: (context, state) {
          final order = state.extra as OrderModel;
          return OrderDetailsScreen(order: order);
        },
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => const AdminOrderManagementScreen(),
      ),
      GoRoute(
        path: '/admin/kikoba',
        builder: (context, state) => const AdminKikobaDashboard(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/new',
        builder: (context, state) => const NewChatScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final chat = state.extra as ChatModel;
          return ChatRoomScreen(chat: chat);
        },
      ),
    ],
  );
});
