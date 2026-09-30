import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/dynamic_kikoba_repository.dart';
import '../../models/kikoba/service_model.dart';
import '../../models/kikoba/service_column_model.dart';
import '../../models/kikoba/service_plan_model.dart';
import '../../models/kikoba/service_plan_option_model.dart';

final dynamicKikobaRepositoryProvider = Provider<DynamicKikobaRepository>((ref) {
  return DynamicKikobaRepository();
});

// Fetch all services
final kikobaServicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final repo = ref.watch(dynamicKikobaRepositoryProvider);
  return await repo.getServices();
});

// Fetch columns for a specific service
final kikobaColumnsProvider = FutureProvider.family<List<ServiceColumnModel>, String>((ref, serviceId) async {
  final repo = ref.watch(dynamicKikobaRepositoryProvider);
  return await repo.getServiceColumns(serviceId);
});

// Fetch plans for a specific service
final kikobaPlansProvider = FutureProvider.family<List<ServicePlanModel>, String>((ref, serviceId) async {
  final repo = ref.watch(dynamicKikobaRepositoryProvider);
  return await repo.getServicePlans(serviceId);
});

// Fetch options for a specific plan
final kikobaPlanOptionsProvider = FutureProvider.family<List<ServicePlanOptionModel>, String>((ref, planId) async {
  final repo = ref.watch(dynamicKikobaRepositoryProvider);
  return await repo.getPlanOptions(planId);
});
