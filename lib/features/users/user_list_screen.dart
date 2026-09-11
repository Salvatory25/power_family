import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/seed_data.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/status_badge.dart';

final userRepositoryProvider = Provider((ref) => UserRepository());

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserModel> _allUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final repo = ref.read(userRepositoryProvider);
    final list = await repo.getUsers();
    setState(() {
      _allUsers = list;
      _isLoading = false;
    });
  }

  void _showAddStaffModal() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String selectedRole = AppConstants.roleSalesAgent;
    String selectedBranch = SeedData.branches.isNotEmpty ? SeedData.branches[0].id : 'b1';
    String selectedStatus = AppConstants.statusActive;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
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
                  const Text(
                    'Add New Staff Member',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Administrator registration for new employees and role assignment.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Full Name', hint: 'e.g. John Mgaya', controller: nameCtrl),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Email Address', hint: 'e.g. john@powerfamily.co.tz', controller: emailCtrl, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Phone Number', hint: '+255 7XX XXX XXX', controller: phoneCtrl, keyboardType: TextInputType.phone),
                  const SizedBox(height: 14),

                  const Text('Assign System Role:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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

                  const Text('Assign Primary Branch:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedBranch,
                    decoration: const InputDecoration(filled: true),
                    items: SeedData.branches.map((b) {
                      return DropdownMenuItem(value: b.id, child: Text('${b.name} (${b.code})'));
                    }).toList(),
                    onChanged: (val) => setModalState(() => selectedBranch = val!),
                  ),
                  const SizedBox(height: 14),

                  const Text('Account Status:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(filled: true),
                    items: const [
                      DropdownMenuItem(value: AppConstants.statusActive, child: Text('Active (Approved)')),
                      DropdownMenuItem(value: AppConstants.statusPending, child: Text('Pending Approval')),
                    ],
                    onChanged: (val) => setModalState(() => selectedStatus = val!),
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    text: 'Create Staff Account',
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in Full Name and Email.')),
                        );
                        return;
                      }

                      final newStaff = UserModel(
                        uid: 'u_${DateTime.now().millisecondsSinceEpoch}',
                        fullName: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        role: selectedRole,
                        branchId: selectedBranch,
                        status: selectedStatus,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );

                      final repo = ref.read(userRepositoryProvider);
                      await repo.createUser(newStaff);

                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Staff account created for ${newStaff.fullName}')),
                        );
                      }
                      _loadUsers();
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

  void _showRoleAssignmentModal(UserModel user) {
    String selectedRole = user.role;
    String? selectedBranch = user.branchId ?? SeedData.branches[0].id;
    String selectedStatus = user.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage User: ${user.fullName}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Email: ${user.email} • Phone: ${user.phone}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 16),

                const Text('Account Status:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(filled: true),
                  items: const [
                    DropdownMenuItem(value: AppConstants.statusActive, child: Text('Active (Approved)')),
                    DropdownMenuItem(value: AppConstants.statusPending, child: Text('Pending Approval')),
                    DropdownMenuItem(value: AppConstants.statusSuspended, child: Text('Suspended')),
                    DropdownMenuItem(value: AppConstants.statusDisabled, child: Text('Disabled')),
                  ],
                  onChanged: (val) => setModalState(() => selectedStatus = val!),
                ),
                const SizedBox(height: 14),

                const Text('Assign System Role:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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

                const Text('Assign Primary Branch:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedBranch,
                  decoration: const InputDecoration(filled: true),
                  items: SeedData.branches.map((b) {
                    return DropdownMenuItem(value: b.id, child: Text('${b.name} (${b.code})'));
                  }).toList(),
                  onChanged: (val) => setModalState(() => selectedBranch = val),
                ),
                const SizedBox(height: 24),

                AppButton(
                  text: 'Save Permissions & Status',
                  onPressed: () async {
                    final repo = ref.read(userRepositoryProvider);
                    await repo.updateUserStatus(user.uid, selectedStatus);
                    await repo.updateUserRoleAndBranch(user.uid, selectedRole, selectedBranch);
                    Navigator.pop(ctx);
                    _loadUsers();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingUsers = _allUsers.where((u) => u.status == AppConstants.statusPending).toList();
    final activeUsers = _allUsers.where((u) => u.status != AppConstants.statusPending).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User & Role Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Staff Member',
            onPressed: _showAddStaffModal,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textMuted,
          tabs: [
            Tab(text: 'Pending (${pendingUsers.length})'),
            Tab(text: 'All Staff (${activeUsers.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStaffModal,
        icon: const Icon(Icons.add),
        label: const Text('Add Staff'),
        backgroundColor: AppColors.primary,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(pendingUsers, isPendingTab: true),
                _buildUserList(activeUsers, isPendingTab: false),
              ],
            ),
    );
  }

  Widget _buildUserList(List<UserModel> users, {required bool isPendingTab}) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          isPendingTab ? 'No pending user registration requests.' : 'No staff accounts found.',
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
        final branch = SeedData.branches.firstWhere((b) => b.id == u.branchId, orElse: () => SeedData.branches[0]);

        return Card(
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
              'Role: ${AppConstants.getRoleLabel(u.role)}\nBranch: ${branch.name} • ${u.phone}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(status: u.status),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _showRoleAssignmentModal(u),
                  child: const Text('Manage', style: TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
