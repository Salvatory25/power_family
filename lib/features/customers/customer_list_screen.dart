import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/customer_model.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/seed_data.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/status_badge.dart';

final customerRepositoryProvider = Provider((ref) => CustomerRepository());

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  List<CustomerModel> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    final repo = ref.read(customerRepositoryProvider);
    final list = await repo.getCustomers();
    setState(() {
      _customers = list;
      _isLoading = false;
    });
  }

  void _showAddCustomerModal() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final budgetCtrl = TextEditingController(text: '50000000');
    final notesCtrl = TextEditingController();

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
              const Text('Add New Customer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              AppTextField(label: 'Full Name', hint: 'e.g. Hon. Juma Rashid', controller: nameCtrl),
              const SizedBox(height: 12),
              AppTextField(label: 'Phone Number', hint: '+255 7XX XXX XXX', controller: phoneCtrl, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              AppTextField(label: 'Email', hint: 'customer@gmail.com', controller: emailCtrl, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              AppTextField(label: 'Address', hint: 'Mikocheni, Dar es Salaam', controller: addressCtrl),
              const SizedBox(height: 12),
              AppTextField(label: 'Budget (TZS)', hint: '50000000', controller: budgetCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              AppTextField(label: 'Interest Notes', hint: 'Interested in Kigamboni plot...', controller: notesCtrl, maxLines: 2),
              const SizedBox(height: 20),
              AppButton(
                text: 'Save Customer Profile',
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and Phone are required.')));
                    return;
                  }
                  final newCustomer = CustomerModel(
                    id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                    fullName: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    address: addressCtrl.text.trim(),
                    notes: notesCtrl.text.trim(),
                    interestedPropertyTypes: [AppConstants.typeKiwanja],
                    budget: double.tryParse(budgetCtrl.text) ?? 0,
                    status: AppConstants.customerNew,
                    branchId: SeedData.branches[0].id,
                    createdBy: 'user_admin',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  final repo = ref.read(customerRepositoryProvider);
                  await repo.createCustomer(newCustomer);
                  Navigator.pop(ctx);
                  _loadCustomers();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: _showAddCustomerModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _customers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final c = _customers[index];
                return Card(
                  child: ListTile(
                    onTap: () => context.push('/customers/${c.id}'),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accent.withOpacity(0.2),
                      child: Text(
                        c.fullName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentDark),
                      ),
                    ),
                    title: Text(c.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('Phone: ${c.phone}\nBudget: ${Formatters.formatCurrency(c.budget)}', style: const TextStyle(fontSize: 12)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StatusBadge(status: c.status),
                        const SizedBox(height: 4),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
