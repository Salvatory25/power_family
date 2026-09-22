import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/favourites_repository.dart';
import '../../auth/auth_controller.dart';

final favouritesRepositoryProvider = Provider<FavouritesRepository>((ref) => FavouritesRepository());

class FavouritesNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  final FavouritesRepository _repository;

  FavouritesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadFavourites();
  }

  Future<void> loadFavourites() async {
    try {
      state = const AsyncValue.loading();
      final ids = await _repository.getFavouritePropertyIds();
      state = AsyncValue.data(ids.toSet());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }



  void clearFavourites() {
    state = const AsyncValue.data(<String>{});
  }

  Future<void> toggleFavourite(String propertyId) async {
    final currentState = state.valueOrNull ?? {};
    final isFavourited = currentState.contains(propertyId);
    
    // Optimistic update
    final newSet = Set<String>.from(currentState);
    if (isFavourited) {
      newSet.remove(propertyId);
    } else {
      newSet.add(propertyId);
    }
    state = AsyncValue.data(newSet);

    try {
      if (isFavourited) {
        final success = await _repository.removeFavourite(propertyId);
        if (!success) {
          // Revert on failure
          state = AsyncValue.data(currentState);
        }
      } else {
        final success = await _repository.addFavourite(propertyId);
        if (!success) {
          // Revert on failure
          state = AsyncValue.data(currentState);
        }
      }
    } catch (e) {
      // Revert on failure
      state = AsyncValue.data(currentState);
    }
  }
}

final favouritesProvider = StateNotifierProvider<FavouritesNotifier, AsyncValue<Set<String>>>((ref) {
  final authState = ref.watch(authControllerProvider);
  
  final repository = ref.watch(favouritesRepositoryProvider);
  final notifier = FavouritesNotifier(repository);
  
  // If user logs out, clear favorites
  if (authState.value == null && !authState.isLoading) {
     notifier.clearFavourites();
  }

  return notifier;
});
