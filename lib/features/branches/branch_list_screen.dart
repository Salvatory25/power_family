import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/tanzania_locations.dart';
import '../../models/branch_model.dart';
import '../../repositories/branch_repository.dart';

import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/confirm_dialog.dart';
import '../dashboard/dashboard_providers.dart';
import 'package:easy_localization/easy_localization.dart';

final branchRepositoryProvider = Provider((ref) => BranchRepository());

class BranchListScreen extends ConsumerStatefulWidget {
  const BranchListScreen({super.key});

  @override
  ConsumerState<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends ConsumerState<BranchListScreen> {
  void _showBranchForm([BranchModel? branch]) {
    final nameCtrl = TextEditingController(text: branch?.name ?? '');
    final codeCtrl = TextEditingController(text: branch?.code ?? '');
    final streetCtrl = TextEditingController(
      text: branch != null ? branch.location.split('•').first.trim() : '',
    );
    final phoneCtrl = TextEditingController(text: branch?.phone ?? '');
    final emailCtrl = TextEditingController(text: branch?.email ?? '');

    String? selectedRegion = 'Dar es Salaam Region';
    String? selectedDistrict = 'Kinondoni Municipal';

    if (branch != null && branch.location.contains(',')) {
      final parts = branch.location.split(',');
      if (parts.length >= 2) {
        final regCandidate = parts.last.trim();
        final distCandidate = parts[parts.length - 2].trim();
        if (TanzaniaLocations.allRegions.contains(regCandidate)) {
          selectedRegion = regCandidate;
        }
        final districts = TanzaniaLocations.getDistricts(selectedRegion);
        if (districts.contains(distCandidate)) {
          selectedDistrict = distCandidate;
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final currentDistricts = TanzaniaLocations.getDistricts(selectedRegion);
          final validDistrict = currentDistricts.contains(selectedDistrict)
              ? selectedDistrict
              : (currentDistricts.isNotEmpty ? currentDistricts.first : null);

          return Padding(
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
                  Text(
                    branch == null ? 'branch_list.create_new'.tr() : 'branch_list.edit_details'.tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(label: 'branch_list.branch_name'.tr(), hint: 'branch_list.name_hint'.tr(), controller: nameCtrl),
                  const SizedBox(height: 12),
                  AppTextField(label: 'branch_list.branch_code'.tr(), hint: 'branch_list.code_hint'.tr(), controller: codeCtrl),
                  const SizedBox(height: 14),

                  Text('branch_list.select_region'.tr(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedRegion,
                    decoration: const InputDecoration(filled: true, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    items: TanzaniaLocations.allRegions.map((reg) {
                      return DropdownMenuItem(value: reg, child: Text(reg));
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedRegion = val;
                        final newDistricts = TanzaniaLocations.getDistricts(val);
                        selectedDistrict = newDistricts.isNotEmpty ? newDistricts.first : null;
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  Text('branch_list.select_district'.tr(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: validDistrict,
                    decoration: const InputDecoration(filled: true, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    items: currentDistricts.map((dist) {
                      return DropdownMenuItem(value: dist, child: Text(dist));
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedDistrict = val;
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    label: 'branch_list.street'.tr(),
                    hint: 'branch_list.street_hint'.tr(),
                    controller: streetCtrl,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(label: 'branch_list.phone'.tr(), hint: 'branch_list.phone_hint'.tr(), controller: phoneCtrl, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  AppTextField(label: 'branch_list.email'.tr(), hint: 'branch_list.email_hint'.tr(), controller: emailCtrl, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  AppButton(
                    text: branch == null ? 'branch_list.save_branch'.tr() : 'branch_list.update_branch'.tr(),
                    onPressed: () async {
                      if (nameCtrl.text.isEmpty || codeCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('branch_list.name_code_req'.tr())));
                        return;
                      }

                      final String fullLocation = streetCtrl.text.trim().isNotEmpty
                          ? '${streetCtrl.text.trim()}, ${validDistrict ?? ""}, ${selectedRegion ?? ""}'
                          : '${validDistrict ?? ""}, ${selectedRegion ?? ""}';

                      final repo = ref.read(branchRepositoryProvider);
                      if (branch == null) {
                        final newB = BranchModel(
                          id: 'branch_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameCtrl.text.trim(),
                          code: codeCtrl.text.trim(),
                          location: fullLocation,
                          phone: phoneCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          status: AppConstants.branchActive,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );
                        await repo.createBranch(newB);
                      } else {
                        final updated = branch.copyWith(
                          name: nameCtrl.text.trim(),
                          code: codeCtrl.text.trim(),
                          location: fullLocation,
                          phone: phoneCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                        );
                        await repo.updateBranch(updated);
                      }
                      ref.invalidate(branchesProvider);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(branch == null ? 'branch_list.created_success'.tr() : 'branch_list.updated_success'.tr())),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final branchesAsync = ref.watch(branchesProvider);
    final users = ref.watch(usersProvider).value ?? [];
    final properties = ref.watch(propertiesProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('branch_list.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showBranchForm(),
          ),
        ],
      ),
      body: branchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading branches: $err')),
        data: (branches) {
          if (branches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('branch_list.no_branches'.tr(), style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showBranchForm(),
                    icon: const Icon(Icons.add),
                    label: Text('branch_list.create_first'.tr()),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: branches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final b = branches[index];
              final staffCount = users.where((u) => u.branchId == b.id).length;
              final propCount = properties.where((p) => p.branchId == b.id).length;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            b.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: b.status == 'active' ? AppColors.statusAvailable.withOpacity(0.12) : AppColors.statusSold.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              b.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: b.status == 'active' ? AppColors.statusAvailable : AppColors.statusSold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('${'branch_list.code'.tr()}: ${b.code} • ${b.location}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text('${'branch_list.phone'.tr()}: ${b.phone} | ${'branch_list.email'.tr()}: ${b.email}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$staffCount ${'branch_list.staff_members'.tr()} • $propCount ${'branch_list.properties'.tr()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                                onPressed: () => _showBranchForm(b),
                              ),
                              IconButton(
                                icon: Icon(
                                  b.status == 'active' ? Icons.block : Icons.check_circle,
                                  size: 18,
                                  color: b.status == 'active' ? AppColors.statusSold : AppColors.statusAvailable,
                                ),
                                onPressed: () async {
                                  final confirm = await ConfirmDialog.show(
                                    context,
                                    title: b.status == 'active' ? 'branch_list.deactivate'.tr() : 'branch_list.activate'.tr(),
                                    message: '${'branch_list.confirm_status_change'.tr()} ${b.name}?',
                                    isDestructive: b.status == 'active',
                                  );
                                  if (confirm == true) {
                                    final repo = ref.read(branchRepositoryProvider);
                                    await repo.updateBranch(b.copyWith(status: b.status == 'active' ? 'inactive' : 'active'));
                                    ref.invalidate(branchesProvider);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
