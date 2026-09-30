import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/kikoba/service_column_model.dart';
import '../../models/kikoba/service_plan_model.dart';
import 'dynamic_kikoba_providers.dart';

class KikobaServiceDetailScreen extends ConsumerStatefulWidget {
  final String serviceId;

  const KikobaServiceDetailScreen({super.key, required this.serviceId});

  @override
  ConsumerState<KikobaServiceDetailScreen> createState() => _KikobaServiceDetailScreenState();
}

class _KikobaServiceDetailScreenState extends ConsumerState<KikobaServiceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // We can fetch the specific service details if we need its name, 
    // but for now we focus on its Columns and Plans.
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Service Configuration', style: TextStyle(fontWeight: FontWeight.w800)),
          backgroundColor: AppColors.surface,
          elevation: 0,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Dynamic Columns'),
              Tab(text: 'Plans & Options'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildColumnsTab(),
            _buildPlansTab(),
          ],
        ),
      ),
    );
  }

  // ================= COLUMNS TAB =================

  Widget _buildColumnsTab() {
    final columnsAsync = ref.watch(kikobaColumnsProvider(widget.serviceId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: columnsAsync.when(
        data: (columns) {
          if (columns.isEmpty) {
            return _buildEmptyState('No Columns Yet', 'Add columns like "Bei", "Upana" to define what data this Kikoba requires.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: columns.length,
            itemBuilder: (context, index) {
              final col = columns[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: AppColors.accent, child: Icon(Icons.view_column, color: Colors.white)),
                  title: Text(col.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Key: ${col.key} | Type: ${col.type}'),
                  trailing: col.isRequired 
                      ? const Chip(label: Text('Required', style: TextStyle(fontSize: 10)), backgroundColor: AppColors.primaryLight)
                      : const Chip(label: Text('Optional', style: TextStyle(fontSize: 10))),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddColumnDialog(),
        heroTag: 'col_fab',
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Column', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddColumnDialog() {
    final labelCtrl = TextEditingController();
    final keyCtrl = TextEditingController();
    String selectedType = 'number';
    bool isRequired = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('New Dynamic Column'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: labelCtrl,
                    decoration: const InputDecoration(labelText: 'Label (e.g. Bei ya Kiwanja)', border: OutlineInputBorder()),
                    onChanged: (val) {
                      keyCtrl.text = val.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-z0-9_]'), '');
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: keyCtrl,
                    decoration: const InputDecoration(labelText: 'Key (JSON key)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Data Type', border: OutlineInputBorder()),
                    items: ['text', 'number', 'currency', 'boolean', 'date']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                        .toList(),
                    onChanged: (val) => setState(() => selectedType = val!),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Is Required?'),
                    value: isRequired,
                    onChanged: (val) => setState(() => isRequired = val),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (labelCtrl.text.isEmpty || keyCtrl.text.isEmpty) return;
                  
                  final newCol = ServiceColumnModel(
                    id: '',
                    serviceId: widget.serviceId,
                    key: keyCtrl.text,
                    label: labelCtrl.text,
                    type: selectedType,
                    position: 0,
                    isRequired: isRequired,
                    createdAt: DateTime.now(),
                  );

                  await ref.read(dynamicKikobaRepositoryProvider).createColumn(newCol);
                  ref.invalidate(kikobaColumnsProvider(widget.serviceId));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Save Column'),
              ),
            ],
          );
        }
      ),
    );
  }

  // ================= PLANS TAB =================

  Widget _buildPlansTab() {
    final plansAsync = ref.watch(kikobaPlansProvider(widget.serviceId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: plansAsync.when(
        data: (plans) {
          if (plans.isEmpty) {
            return _buildEmptyState('No Plans Yet', 'Create a payment plan (e.g., 20k-29k / week) for customers to choose from.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(plan.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          Chip(label: Text(plan.frequency.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: AppColors.statusAvailable),
                        ],
                      ),
                      const Divider(),
                      Text('Min Payment: TSH ${plan.minPayment}'),
                      Text('Max Payment: TSH ${plan.maxPayment}'),
                      Text('Duration: ${plan.durationValue} ${plan.durationUnit}(s)'),
                      if (plan.capacity != null)
                        Text('Capacity: ${plan.capacity} (${plan.capacityMode})'),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPlanDialog(),
        heroTag: 'plan_fab',
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddPlanDialog() {
    final nameCtrl = TextEditingController();
    final minCtrl = TextEditingController();
    final maxCtrl = TextEditingController();
    final durationValCtrl = TextEditingController(text: '1');
    String frequency = 'weekly';
    String durationUnit = 'year';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('New Payment Plan'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Plan Name (e.g. 20k-29k / week)', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: minCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Min TSH', border: OutlineInputBorder()))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: maxCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max TSH', border: OutlineInputBorder()))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: frequency,
                    decoration: const InputDecoration(labelText: 'Frequency', border: OutlineInputBorder()),
                    items: ['weekly', 'monthly'].map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                    onChanged: (val) => setState(() => frequency = val!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: durationValCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration', border: OutlineInputBorder()))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: durationUnit,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: ['week', 'month', 'year'].map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                          onChanged: (val) => setState(() => durationUnit = val!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || minCtrl.text.isEmpty || maxCtrl.text.isEmpty) return;
                  
                  final newPlan = ServicePlanModel(
                    id: '',
                    serviceId: widget.serviceId,
                    name: nameCtrl.text,
                    minPayment: double.tryParse(minCtrl.text) ?? 0,
                    maxPayment: double.tryParse(maxCtrl.text) ?? 0,
                    frequency: frequency,
                    durationValue: int.tryParse(durationValCtrl.text) ?? 1,
                    durationUnit: durationUnit,
                    capacityMode: 'unlimited',
                    position: 0,
                    status: 'active',
                    configVersion: 1,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  await ref.read(dynamicKikobaRepositoryProvider).createPlan(newPlan);
                  ref.invalidate(kikobaPlansProvider(widget.serviceId));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Save Plan'),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: AppColors.border),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
