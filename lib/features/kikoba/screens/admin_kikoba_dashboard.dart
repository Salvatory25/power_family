import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/kikoba_package_model.dart';
import '../../../repositories/kikoba_repository.dart';

final kikobaPackagesProvider = FutureProvider<List<KikobaPackageModel>>((ref) async {
  final repo = KikobaRepository();
  return await repo.getPackages();
});

class AdminKikobaDashboard extends ConsumerStatefulWidget {
  const AdminKikobaDashboard({super.key});

  @override
  ConsumerState<AdminKikobaDashboard> createState() => _AdminKikobaDashboardState();
}

class _AdminKikobaDashboardState extends ConsumerState<AdminKikobaDashboard> {
  @override
  Widget build(BuildContext context) {
    final packagesAsync = ref.watch(kikobaPackagesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Kikoba Packages', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: packagesAsync.when(
        data: (packages) {
          if (packages.isEmpty) {
            return const Center(child: Text('No Kikoba packages found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final pkg = packages[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Contribution: TZS ${pkg.weeklyContribution}/week\nDuration: ${pkg.durationWeeks} weeks\nTarget: TZS ${pkg.targetAmount}'),
                  isThreeLine: true,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: pkg.status == 'ACTIVE' ? Colors.green[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pkg.status,
                      style: TextStyle(
                        color: pkg.status == 'ACTIVE' ? Colors.green[800] : Colors.grey[800],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePackageModal(context, ref);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreatePackageModal(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final contribCtrl = TextEditingController();
    final durCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final limitCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Create Kikoba Package', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Package Name (e.g. Plot for 1 year)')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: contribCtrl, decoration: const InputDecoration(labelText: 'Weekly Contribution (TZS)'), keyboardType: TextInputType.number),
              TextField(controller: durCtrl, decoration: const InputDecoration(labelText: 'Duration (Weeks)'), keyboardType: TextInputType.number),
              TextField(controller: targetCtrl, decoration: const InputDecoration(labelText: 'Target Amount (TZS)'), keyboardType: TextInputType.number),
              TextField(controller: limitCtrl, decoration: const InputDecoration(labelText: 'Member Limit'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final pkg = KikobaPackageModel(
                    id: '',
                    name: nameCtrl.text,
                    description: descCtrl.text,
                    weeklyContribution: double.tryParse(contribCtrl.text) ?? 0,
                    durationWeeks: int.tryParse(durCtrl.text) ?? 0,
                    targetAmount: double.tryParse(targetCtrl.text) ?? 0,
                    memberLimit: int.tryParse(limitCtrl.text) ?? 0,
                    status: 'ACTIVE',
                    createdAt: DateTime.now(),
                    createdBy: 'admin', // Ideally fetch current user uid
                  );
                  await KikobaRepository().createPackage(pkg);
                  ref.invalidate(kikobaPackagesProvider);
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Create Package'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }
}
