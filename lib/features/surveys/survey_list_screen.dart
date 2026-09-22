import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/survey_task_model.dart';
import '../../repositories/survey_repository.dart';
import '../dashboard/dashboard_providers.dart';
import '../auth/auth_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/status_badge.dart';

final surveyRepositoryProvider = Provider((ref) => SurveyRepository());

class SurveyListScreen extends ConsumerStatefulWidget {
  const SurveyListScreen({super.key});

  @override
  ConsumerState<SurveyListScreen> createState() => _SurveyListScreenState();
}

class _SurveyListScreenState extends ConsumerState<SurveyListScreen> {
  List<SurveyTaskModel> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadTasks());
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final user = ref.read(authControllerProvider).value;
    final isAdmin = user?.role.toUpperCase() == AppConstants.roleSuperAdmin || 
                    user?.role.toUpperCase() == AppConstants.roleSystemAdmin;
    final filterBranchId = isAdmin ? null : user?.branchId;

    final repo = ref.read(surveyRepositoryProvider);
    final list = await repo.getSurveyTasks(branchId: filterBranchId);
    setState(() {
      _tasks = list;
      _isLoading = false;
    });
  }

  void _showAssignSurveyModal() {
    final properties = ref.read(propertiesProvider).value ?? [];
    final users = ref.read(usersProvider).value ?? [];
    final branches = ref.read(branchesProvider).value ?? [];

    final kiwanjaProps = properties.where((p) => p.type == 'kiwanja').toList();
    String selectedProperty = kiwanjaProps.isNotEmpty ? kiwanjaProps.first.id : (properties.isNotEmpty ? properties.first.id : '');
    final surveyors = users.where((u) => u.role.toLowerCase() == 'surveyor').toList();
    String selectedSurveyor = surveyors.isNotEmpty ? surveyors.first.uid : (users.isNotEmpty ? users.first.uid : '');
    final notesCtrl = TextEditingController(text: 'Perform boundary beacon mapping and submit ministry survey plan.');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Assign Land Surveying / Urasimishaji', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              const Text('Select Plot Property:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedProperty.isNotEmpty ? selectedProperty : null,
                decoration: const InputDecoration(filled: true, hintText: 'Select Property'),
                items: kiwanjaProps.map((p) {
                  return DropdownMenuItem(value: p.id, child: Text('${p.propertyCode} - ${p.title}'));
                }).toList(),
                onChanged: (val) { if (val != null) selectedProperty = val; },
              ),
              const SizedBox(height: 12),

              const Text('Assign Licensed Surveyor:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedSurveyor.isNotEmpty ? selectedSurveyor : null,
                decoration: const InputDecoration(filled: true, hintText: 'Select Surveyor'),
                items: users.map((u) {
                  return DropdownMenuItem(value: u.uid, child: Text('${u.fullName} (${AppConstants.getRoleLabel(u.role)})'));
                }).toList(),
                onChanged: (val) { if (val != null) selectedSurveyor = val; },
              ),
              const SizedBox(height: 12),
              AppTextField(label: 'Surveying Instructions & Notes', controller: notesCtrl, maxLines: 2),
              const SizedBox(height: 20),

              AppButton(
                text: 'Assign Survey Task',
                onPressed: () async {
                  if (selectedProperty.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add or select a property first.')));
                    return;
                  }
                  final newTask = SurveyTaskModel(
                    id: 'survey_${DateTime.now().millisecondsSinceEpoch}',
                    propertyId: selectedProperty,
                    surveyorId: selectedSurveyor,
                    branchId: branches.isNotEmpty ? branches.first.id : '',
                    status: AppConstants.surveyAssigned,
                    deadline: DateTime.now().add(const Duration(days: 14)),
                    notes: notesCtrl.text.trim(),
                    documents: ['Plot_Coordinates_Doc.pdf'],
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  final repo = ref.read(surveyRepositoryProvider);
                  await repo.createSurveyTask(newTask);
                  Navigator.pop(ctx);
                  _loadTasks();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _showUpdateSurveyStatusModal(SurveyTaskModel task) {
    String selectedStatus = task.status;
    final notesCtrl = TextEditingController(text: task.notes);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Update Survey Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(filled: true),
              items: const [
                DropdownMenuItem(value: AppConstants.surveyAssigned, child: Text('Assigned')),
                DropdownMenuItem(value: AppConstants.surveyInProgress, child: Text('In Progress (Beacons Placed)')),
                DropdownMenuItem(value: AppConstants.surveyCompleted, child: Text('Completed (Title Deed Ready)')),
                DropdownMenuItem(value: AppConstants.surveyOnHold, child: Text('On Hold')),
              ],
              onChanged: (val) => selectedStatus = val!,
            ),
            const SizedBox(height: 12),
            AppTextField(label: 'Surveyor Progress Notes', controller: notesCtrl, maxLines: 2),
            const SizedBox(height: 20),
            AppButton(
              text: 'Save Progress',
              onPressed: () async {
                final repo = ref.read(surveyRepositoryProvider);
                await repo.updateSurveyTaskStatus(task.id, selectedStatus, notesCtrl.text.trim());
                Navigator.pop(ctx);
                _loadTasks();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Land Surveying (Urasimishaji)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            onPressed: _showAssignSurveyModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final task = _tasks[index];

                final props = ref.read(propertiesProvider).value ?? [];
                final users = ref.read(usersProvider).value ?? [];
                final propMatches = props.where((p) => p.id == task.propertyId).toList();
                final propTitle = propMatches.isNotEmpty ? propMatches.first.title : 'Survey Property';
                final plotNo = propMatches.isNotEmpty ? (propMatches.first.plotNumber ?? "N/A") : "N/A";
                final plotSize = propMatches.isNotEmpty ? (propMatches.first.size ?? "N/A") : "N/A";
                final surveyorMatches = users.where((u) => u.uid == task.surveyorId).toList();
                final surveyorName = surveyorMatches.isNotEmpty ? surveyorMatches.first.fullName : 'Assigned Surveyor';
                final surveyorPhone = surveyorMatches.isNotEmpty ? surveyorMatches.first.phone : '';

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(propTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            StatusBadge(status: task.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Plot Number: $plotNo ($plotSize)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text('Surveyor: $surveyorName ($surveyorPhone)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),

                        const SizedBox(height: 6),
                        Text('Notes: ${task.notes}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Deadline: ${Formatters.formatDate(task.deadline)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ElevatedButton.icon(
                              onPressed: () => _showUpdateSurveyStatusModal(task),
                              icon: const Icon(Icons.edit, size: 14),
                              label: const Text('Update Progress', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
