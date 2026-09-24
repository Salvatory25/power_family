import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/kikoba_membership_model.dart';
import '../../../repositories/kikoba_repository.dart';
import '../../auth/auth_controller.dart';

final myKikobaMembershipsProvider = FutureProvider<List<KikobaMembershipModel>>((ref) async {
  final user = ref.read(authControllerProvider).value;
  if (user == null) return [];
  final repo = KikobaRepository();
  final all = await repo.getMemberships();
  return all.where((m) => m.customerId == user.uid).toList();
});

class MyKikobaScreen extends ConsumerWidget {
  const MyKikobaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipsAsync = ref.watch(myKikobaMembershipsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Kikoba Savings', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: membershipsAsync.when(
        data: (memberships) {
          if (memberships.isEmpty) {
            return const Center(child: Text('You have not joined any Kikoba packages.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: memberships.length,
            itemBuilder: (context, index) {
              final m = memberships[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Package: \${m.packageId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Status: \${m.status}', style: TextStyle(color: m.status == 'ACTIVE' ? Colors.green : Colors.grey)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Contributed:'),
                          Text('TZS \${m.totalContributed}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Joined Date:'),
                          Text(m.createdAt.toString().substring(0, 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
