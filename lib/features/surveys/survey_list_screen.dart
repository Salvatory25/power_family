import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/survey_task_model.dart';
import '../../repositories/survey_repository.dart';
import '../../repositories/seed_data.dart';
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
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final repo = ref.read(surveyRepositoryProvider);
    final list = await repo.getSurveyTasks();
    setState(() {
      _tasks = list;
      _isLoading = false;
    });
  }

  void _showAssignSurveyModal() {
    String selectedProperty = SeedData.properties.firstWhere((p) => p.type == 'kiwanja', orElse: () => SeedData.properties[0]).id;
    String selectedSurveyor = SeedData.users.firstWhere((u) => u.role == 'surveyor', orElse: () => SeedData.users[0]).uid;
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
                value: selectedProperty,
                decoration: const InputDecoration(filled: true),
                items: SeedData.properties.where((p) => p.type == 'kiwanja').map((p) {
                  return DropdownMenuItem(value: p.id, child: Text('${p.propertyCode} - ${p.title}'));
                }).toList(),
                onChanged: (val) => selectedProperty = val!,
              ),
              const SizedBox(height: 12),

              const Text('Assign Licensed Surveyor:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedSurveyor,
                decoration: const InputDecoration(filled: true),
                items: SeedData.users.map((u) {
                  return DropdownMenuItem(value: u.uid, child: Text('${u.fullName} (${AppConstants.getRoleLabel(u.role)})'));
                }).toList(),
                onChanged: (val) => selectedSurveyor = val!,
              ),
              const SizedBox(height: 12),
              AppTextField(label: 'Surveying Instructions & Notes', controller: notesCtrl, maxLines: 2),
              const SizedBox(height: 20),

              AppButton(
                text: 'Assign Survey Task',
                onPressed: () async {
                  final newTask = SurveyTaskModel(
                    id: 'survey_${DateTime.now().millisecondsSinceEpoch}',
                    propertyId: selectedProperty,
                    surveyorId: selectedSurveyor,
                    branchId: SeedData.branches[0].id,
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
                final prop = SeedData.properties.firstWhere((p) => p.id == task.propertyId, orElse: () => SeedData.properties[0]);
                final surveyor = SeedData.users.firstWhere((u) => u.uid == task.surveyorId, orElse: () => SeedData.users[0]);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(prop.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            StatusBadge(status: task.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Plot Number: ${prop.plotNumber ?? "N/A"} (${prop.size ?? "N/A"})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text('Surveyor: ${surveyor.fullName} (${surveyor.phone})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
