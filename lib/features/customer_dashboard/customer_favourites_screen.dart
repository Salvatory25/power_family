import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/app_empty_state.dart';
import 'customer_dashboard_screen.dart'; // To access availablePropertiesProvider
import 'providers/favourites_provider.dart';
import 'widgets/customer_property_card.dart';

class CustomerFavouritesScreen extends ConsumerWidget {
  const CustomerFavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favState = ref.watch(favouritesProvider);
    final propertiesState = ref.watch(availablePropertiesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Zilizohifadhiwa', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
        centerTitle: false,
      ),
      body: favState.when(
        data: (favIds) {
          if (favIds.isEmpty) {
            return const AppEmptyState(
              title: 'Huna mali kwenye Vipendwa',
              subtitle: 'Bonyeza ❤️ kwenye mali yoyote ili kuihifadhi hapa.',
              icon: Icons.favorite_border_rounded,
            );
          }

          return propertiesState.when(
            data: (properties) {
              final favProperties = properties.where((p) => favIds.contains(p.id)).toList();

              if (favProperties.isEmpty) {
                return const AppEmptyState(
                  title: 'Huna mali kwenye Vipendwa',
                  subtitle: 'Bonyeza ❤️ kwenye mali yoyote ili kuihifadhi hapa.',
                  icon: Icons.favorite_border_rounded,
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: favProperties.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return CustomerPropertyCard(
                    property: favProperties[index],
                    isFeatured: false,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (error, _) => AppEmptyState(
              title: 'Imeshindikana kupakia mali',
              subtitle: 'Angalia internet yako kisha ujaribu tena.',
              icon: Icons.wifi_off_rounded,
              actionLabel: 'Jaribu Tena',
              onAction: () => ref.refresh(availablePropertiesProvider),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, _) => AppEmptyState(
          title: 'Imeshindikana kupakia vipendwa',
          subtitle: 'Angalia internet yako kisha ujaribu tena.',
          icon: Icons.wifi_off_rounded,
          actionLabel: 'Jaribu Tena',
          onAction: () => ref.read(favouritesProvider.notifier).loadFavourites(),
        ),
      ),
    );
  }
}
