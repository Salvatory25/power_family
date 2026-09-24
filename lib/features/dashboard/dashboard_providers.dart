import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../auth/auth_controller.dart';
import '../../models/property_model.dart';
import '../../models/customer_model.dart';
import '../../models/sale_model.dart';
import '../../models/user_model.dart';
import '../../models/lead_model.dart';
import '../../models/survey_task_model.dart';
import '../../models/activity_model.dart';
import '../../models/branch_model.dart';
import '../../repositories/property_repository.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/lead_repository.dart';
import '../../repositories/survey_repository.dart';
import '../../repositories/activity_repository.dart';
import '../../repositories/branch_repository.dart';

final propertyRepoProvider = Provider((ref) => PropertyRepository());
final customerRepoProvider = Provider((ref) => CustomerRepository());
final salesRepoProvider = Provider((ref) => SalesRepository());
final userRepoProvider = Provider((ref) => UserRepository());
final leadRepoProvider = Provider((ref) => LeadRepository());
final surveyRepoProvider = Provider((ref) => SurveyRepository());
final activityRepoProvider = Provider((ref) => ActivityRepository());
final branchRepoProvider = Provider((ref) => BranchRepository());

String? _getBranchFilter(Ref ref) {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return null;
  final role = user.role.toUpperCase();
  if (role == AppConstants.roleSuperAdmin || role == AppConstants.roleSystemAdmin) {
    return null; // Access to everything
  }
  return user.branchId; // Restricted to their branch
}

final propertiesProvider = FutureProvider<List<PropertyModel>>((ref) async {
  final branchId = _getBranchFilter(ref);
  return ref.read(propertyRepoProvider).getProperties(branchId: branchId);
});

final customersProvider = FutureProvider<List<CustomerModel>>((ref) async {
  final branchId = _getBranchFilter(ref);
  return ref.read(customerRepoProvider).getCustomers(branchId: branchId);
});

final salesProvider = FutureProvider<List<SaleModel>>((ref) async {
  final branchId = _getBranchFilter(ref);
  return ref.read(salesRepoProvider).getSales(branchId: branchId);
});

final usersProvider = FutureProvider<List<UserModel>>((ref) async {
  final branchId = _getBranchFilter(ref);
  return ref.read(userRepoProvider).getUsers(branchId: branchId);
});

final leadsProvider = FutureProvider<List<LeadModel>>((ref) async {
  final branchId = _getBranchFilter(ref);
  return ref.read(leadRepoProvider).getLeads(branchId: branchId);
});

final surveysProvider = FutureProvider<List<SurveyTaskModel>>((ref) async {
  final branchId = _getBranchFilter(ref);
  return ref.read(surveyRepoProvider).getSurveyTasks(branchId: branchId);
});

final activitiesProvider = FutureProvider<List<ActivityModel>>((ref) async {
  final branchId = _getBranchFilter(ref);
  return ref.read(activityRepoProvider).getActivities(branchId: branchId);
});

final activitiesStreamProvider = StreamProvider<List<ActivityModel>>((ref) {
  final branchId = _getBranchFilter(ref);
  return ref.read(activityRepoProvider).getActivitiesStream(branchId: branchId);
});

final branchesProvider = FutureProvider<List<BranchModel>>((ref) async {
  // Branches are globally visible typically, but can be filtered if needed. 
  // We'll leave branches unfiltered so branch managers see other branches exist, 
  // or they can be filtered if the user desires. 
  // For now, no branchId filter for branches themselves.
  return ref.read(branchRepoProvider).getBranches();
});
