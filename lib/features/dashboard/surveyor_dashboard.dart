import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';

import '../../widgets/header_background.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../auth/auth_controller.dart';
import 'dashboard_providers.dart';

class SurveyorDashboard extends ConsumerWidget {
  const SurveyorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final surveyorId = user?.uid ?? 'user_surveyor_1';

    final allTasks = ref.watch(surveysProvider).value ?? [];
    final allProps = ref.watch(propertiesProvider).value ?? [];

    final tasks = allTasks.where((st) => st.surveyorId == surveyorId || surveyorId == 'user_surveyor_1').toList();
    final inProgress = tasks.where((t) => t.status == AppConstants.surveyInProgress).length;
    final completed = tasks.where((t) => t.status == AppConstants.surveyCompleted).length;

    final landProps = allProps.where((p) => p.type == AppConstants.typeKiwanja).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: HeaderBackground(
              height: 95,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  const Icon(Icons.architecture_outlined, size: 36, color: AppColors.accent),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Surveyor Dashboard (${user?.fullName})',
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tasks.length} Assigned Survey Tasks • $inProgress In Progress',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

          const Text(
            'Survey Operations Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),

          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final double ratio = width > 400 ? 1.3 : (width > 340 ? 1.15 : 1.05);
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: ratio,
                children: [
                  StatCard(
                    title: 'Active Survey Tasks',
                    value: tasks.length.toString(),
                    icon: Icons.map_outlined,
                    color: AppColors.accent,
                    onTap: () => context.push('/surveys'),
                  ),
                  StatCard(
                    title: 'In Progress',
                    value: inProgress.toString(),
                    icon: Icons.pending_actions_outlined,
                    color: AppColors.statusSurveying,
                    onTap: () => context.push('/surveys'),
                  ),
                  StatCard(
                    title: 'Completed Surveys',
                    value: completed.toString(),
                    icon: Icons.task_alt,
                    color: AppColors.statusAvailable,
                    onTap: () => context.push('/surveys'),
                  ),
                  StatCard(
                    title: 'Land Plots',
                    value: landProps.length.toString(),
                    icon: Icons.landscape_outlined,
                    color: AppColors.primary,
                    onTap: () => context.push('/properties'),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Map Placeholder
          const Text(
            'Live GPS Tracking',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map, size: 48, color: AppColors.textMuted),
                      SizedBox(height: 8),
                      Text('Map Integration Placeholder', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'map_btn',
                    onPressed: () {},
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Assigned Tasks List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Survey Assignments',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              TextButton(
                onPressed: () => context.push('/surveys'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final task = tasks[index];
              final propList = allProps.where((p) => p.id == task.propertyId).toList();

              final propTitle = propList.isNotEmpty ? propList.first.title : 'Property Task';
              final plotNo = propList.isNotEmpty ? propList.first.plotNumber ?? "N/A" : "N/A";
              final plotSize = propList.isNotEmpty ? propList.first.size ?? "N/A" : "N/A";

              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.surfaceVariant,
                      child: Icon(Icons.explore_outlined, color: AppColors.statusSurveying),
                    ),
                    title: Text(propTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Plot: $plotNo ($plotSize)\nNotes: ${task.notes}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StatusBadge(status: task.status),
                        if (task.status == AppConstants.surveyInProgress) ...[
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Marking $propTitle as completed...')),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.statusAvailable.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.statusAvailable),
                              ),
                              child: const Text(
                                'Mark Completed',
                                style: TextStyle(fontSize: 10, color: AppColors.statusAvailable, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              );

            },
          ),
        ],
      ),
    );
  }
}
