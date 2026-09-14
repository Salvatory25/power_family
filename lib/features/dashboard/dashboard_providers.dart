import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final propertiesProvider = FutureProvider<List<PropertyModel>>((ref) async {
  return ref.read(propertyRepoProvider).getProperties();
});

final customersProvider = FutureProvider<List<CustomerModel>>((ref) async {
  return ref.read(customerRepoProvider).getCustomers();
});

final salesProvider = FutureProvider<List<SaleModel>>((ref) async {
  return ref.read(salesRepoProvider).getSales();
});

final usersProvider = FutureProvider<List<UserModel>>((ref) async {
  return ref.read(userRepoProvider).getUsers();
});

final leadsProvider = FutureProvider<List<LeadModel>>((ref) async {
  return ref.read(leadRepoProvider).getLeads();
});

final surveysProvider = FutureProvider<List<SurveyTaskModel>>((ref) async {
  return ref.read(surveyRepoProvider).getSurveyTasks();
});

final activitiesProvider = FutureProvider<List<ActivityModel>>((ref) async {
  return ref.read(activityRepoProvider).getActivities();
});

final branchesProvider = FutureProvider<List<BranchModel>>((ref) async {
  return ref.read(branchRepoProvider).getBranches();
});
