import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../models/branch_model.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/branch_repository.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/confirm_dialog.dart';
import '../dashboard/dashboard_providers.dart';
import 'package:easy_localization/easy_localization.dart';

final userRepositoryProvider = Provider((ref) => UserRepository());
final branchRepositoryProvider = Provider((ref) => BranchRepository());

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddStaffModal(List<BranchModel> branches) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController(text: 'Password123');
    bool isPasswordObscured = true;
    String selectedRole = AppConstants.roleSalesAgent;
    String selectedBranch = branches.isNotEmpty ? branches[0].id : '';
    String selectedStatus = AppConstants.statusActive;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final validBranchValue = branches.any((b) => b.id == selectedBranch)
              ? selectedBranch
              : (branches.isNotEmpty ? branches[0].id : null);

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
                    'user_list.add_new_staff'.tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'user_list.add_staff_desc'.tr(),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(label: 'user_list.full_name'.tr(), hint: 'e.g. John Mgaya', controller: nameCtrl),
                  const SizedBox(height: 12),
                  AppTextField(label: 'user_list.email'.tr(), hint: 'e.g. john@powerfamily.co.tz', controller: emailCtrl, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  AppTextField(label: 'user_list.phone'.tr(), hint: '+255 7XX XXX XXX', controller: phoneCtrl, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),

                  // Initial Password Set By Admin
                  AppTextField(
                    label: 'user_list.password'.tr(),
                    hint: 'e.g. Password123',
                    controller: passwordCtrl,
                    obscureText: isPasswordObscured,
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () {
                        setModalState(() {
                          isPasswordObscured = !isPasswordObscured;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text('user_list.assign_role'.tr(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(filled: true),
                    items: AppConstants.allRoles.map((r) {
                      return DropdownMenuItem(value: r, child: Text(AppConstants.getRoleLabel(r)));
                    }).toList(),
                    onChanged: (val) => setModalState(() => selectedRole = val!),
                  ),
                  const SizedBox(height: 14),

                  if (selectedRole != AppConstants.roleSuperAdmin && selectedRole != AppConstants.roleSystemAdmin) ...[
                    Text('user_list.assign_branch'.tr(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: validBranchValue,
                      decoration: const InputDecoration(filled: true),
                      items: branches.map((b) {
                        return DropdownMenuItem(value: b.id, child: Text('${b.name} (${b.code})'));
                      }).toList(),
                      onChanged: (val) => setModalState(() => selectedBranch = val ?? ''),
                    ),
                    const SizedBox(height: 14),
                  ],

                  Text('user_list.account_status'.tr(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(filled: true),
                    items: [
                      DropdownMenuItem(value: AppConstants.statusActive, child: Text('user_list.active'.tr())),
                      DropdownMenuItem(value: AppConstants.statusPending, child: Text('user_list.pending'.tr())),
                    ],
                    onChanged: (val) => setModalState(() => selectedStatus = val!),
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    text: 'user_list.create_account'.tr(),
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty || passwordCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('user_list.fill_required'.tr())),
                        );
                        return;
                      }

                      final isAdmin = selectedRole == AppConstants.roleSuperAdmin || selectedRole == AppConstants.roleSystemAdmin;

                      final newStaff = UserModel(
                        uid: 'u_${DateTime.now().millisecondsSinceEpoch}',
                        fullName: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        role: selectedRole,
                        branchId: isAdmin ? '' : selectedBranch,
                        status: selectedStatus,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );

                      final repo = ref.read(userRepositoryProvider);
                      await repo.createUser(newStaff, password: passwordCtrl.text.trim());

                      ref.invalidate(usersProvider);
                      ref.invalidate(branchesProvider);

                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Staff account created for ${newStaff.fullName} (${AppConstants.getRoleLabel(selectedRole)}) with password: ${passwordCtrl.text.trim()}')),
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

  void _showEditUserModal(UserModel user, List<BranchModel> branches) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phone);
    String selectedRole = user.role;
    String selectedBranch = (user.branchId != null && user.branchId!.isNotEmpty) ? user.branchId! : (branches.isNotEmpty ? branches[0].id : '');
    String selectedStatus = user.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final validBranchValue = branches.any((b) => b.id == selectedBranch)
              ? selectedBranch
              : (branches.isNotEmpty ? branches[0].id : null);

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Staff: ${user.fullName}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppTextField(label: 'user_list.full_name'.tr(), hint: 'Full Name', controller: nameCtrl),
                  const SizedBox(height: 12),
                  AppTextField(label: 'user_list.email'.tr(), hint: 'Email', controller: emailCtrl, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  AppTextField(label: 'user_list.phone'.tr(), hint: 'Phone', controller: phoneCtrl, keyboardType: TextInputType.phone),
                  const SizedBox(height: 14),

                  Text('user_list.account_status'.tr(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(filled: true),
                    items: [
                      DropdownMenuItem(value: AppConstants.statusActive, child: Text('user_list.active'.tr())),
                      DropdownMenuItem(value: AppConstants.statusPending, child: Text('user_list.pending'.tr())),
                      DropdownMenuItem(value: AppConstants.statusSuspended, child: Text('user_list.suspended'.tr())),
                      DropdownMenuItem(value: AppConstants.statusDisabled, child: Text('user_list.disabled'.tr())),
                    ],
                    onChanged: (val) => setModalState(() => selectedStatus = val!),
                  ),
                  const SizedBox(height: 14),

                  Text('user_list.assign_role'.tr(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(filled: true),
                    items: AppConstants.allRoles.map((r) {
                      return DropdownMenuItem(value: r, child: Text(AppConstants.getRoleLabel(r)));
                    }).toList(),
                    onChanged: (val) => setModalState(() => selectedRole = val!),
                  ),
                  const SizedBox(height: 14),

                  if (selectedRole != AppConstants.roleSuperAdmin && selectedRole != AppConstants.roleSystemAdmin) ...[
                    Text('user_list.assign_branch'.tr(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: validBranchValue,
                      decoration: const InputDecoration(filled: true),
                      items: branches.map((b) {
                        return DropdownMenuItem(value: b.id, child: Text('${b.name} (${b.code})'));
                      }).toList(),
                      onChanged: (val) => setModalState(() => selectedBranch = val ?? ''),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    const SizedBox(height: 24),
                  ],

                  AppButton(
                    text: 'user_list.update_account'.tr(),
                    onPressed: () async {
                      final isAdmin = selectedRole == AppConstants.roleSuperAdmin || selectedRole == AppConstants.roleSystemAdmin;
                      
                      final updated = user.copyWith(
                        fullName: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        role: selectedRole,
                        branchId: isAdmin ? '' : selectedBranch,
                        status: selectedStatus,
                        updatedAt: DateTime.now(),
                      );
                      final repo = ref.read(userRepositoryProvider);
                      await repo.updateUser(updated);

                      ref.invalidate(usersProvider);
                      ref.invalidate(branchesProvider);

                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Updated user: ${updated.fullName}')),
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

  Future<void> _confirmDeleteUser(UserModel user) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'user_list.delete_title'.tr(),
      message: 'user_list.delete_msg'.tr(),
      isDestructive: true,
    );

    if (confirm == true) {
      final repo = ref.read(userRepositoryProvider);
      await repo.deleteUser(user.uid);
      ref.invalidate(usersProvider);
      ref.invalidate(branchesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Staff member ${user.fullName} deleted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);
    final branches = ref.watch(branchesProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('user_list.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'user_list.add_staff_tooltip'.tr(),
            onPressed: () => _showAddStaffModal(branches),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textMuted,
          tabs: [
            Tab(text: 'user_list.pending_tab'.tr()),
            Tab(text: 'user_list.all_staff_tab'.tr()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStaffModal(branches),
        icon: const Icon(Icons.add),
        label: Text('user_list.add_staff'.tr()),
        backgroundColor: AppColors.primary,
      ),

      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'user_list.search_hint'.tr(),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchCtrl.clear(),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),

          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading users: $err')),
              data: (users) {
                final filteredUsers = users.where((u) {
                  if (_searchQuery.isEmpty) return true;
                  final matchName = u.fullName.toLowerCase().contains(_searchQuery);
                  final matchEmail = u.email.toLowerCase().contains(_searchQuery);
                  final matchPhone = u.phone.toLowerCase().contains(_searchQuery);
                  final matchRole = AppConstants.getRoleLabel(u.role).toLowerCase().contains(_searchQuery);
                  return matchName || matchEmail || matchPhone || matchRole;
                }).toList();

                final pendingUsers = filteredUsers.where((u) => u.status == AppConstants.statusPending || u.status == 'pending').toList();
                final activeUsers = filteredUsers.where((u) => u.status != AppConstants.statusPending && u.status != 'pending').toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUserList(pendingUsers, branches: branches, isPendingTab: true),
                    _buildUserList(activeUsers, branches: branches, isPendingTab: false),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users, {required List<BranchModel> branches, required bool isPendingTab}) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          isPendingTab ? 'user_list.no_pending'.tr() : 'user_list.no_staff'.tr(),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final u = users[index];
        final String userBranchId = u.branchId ?? '';
        final branchMatch = branches.firstWhere(
          (b) => b.id == userBranchId,
          orElse: () => BranchModel(id: '', name: userBranchId.isEmpty ? 'Main HQ' : userBranchId, code: '', location: '', phone: '', email: '', status: 'active', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        );
        final branchName = branchMatch.name;

        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.12),
                child: Text(
                  u.fullName.isEmpty ? 'U' : u.fullName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              title: Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(
                '${'user_list.role'.tr()}: ${AppConstants.getRoleLabel(u.role)}\n${'user_list.branch'.tr()}: $branchName • ${u.email}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPendingTab)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final updated = u.copyWith(status: AppConstants.statusActive);
                        final repo = ref.read(userRepositoryProvider);
                        await repo.updateUser(updated);
                        ref.invalidate(usersProvider);
                        ref.invalidate(branchesProvider);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Account approved for ${u.fullName}!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusAvailable,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 14),
                      label: Text('user_list.approve'.tr(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    )
                  else
                    StatusBadge(status: u.status, fontSize: 10, padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2)),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
                    onSelected: (val) {
                      if (val == 'approve') {
                        final updated = u.copyWith(status: AppConstants.statusActive);
                        ref.read(userRepositoryProvider).updateUser(updated);
                        ref.invalidate(usersProvider);
                        ref.invalidate(branchesProvider);
                      }
                      if (val == 'edit') _showEditUserModal(u, branches);
                      if (val == 'delete') _confirmDeleteUser(u);
                    },
                    itemBuilder: (ctx) => [
                      if (isPendingTab)
                        PopupMenuItem(
                          value: 'approve',
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 16, color: AppColors.statusAvailable),
                              const SizedBox(width: 8),
                              Text('user_list.approve_account'.tr()),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text('user_list.edit_staff'.tr()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline, size: 16, color: AppColors.statusSold),
                            const SizedBox(width: 8),
                            Text('user_list.delete_account'.tr(), style: const TextStyle(color: AppColors.statusSold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

