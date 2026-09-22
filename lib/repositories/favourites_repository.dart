import 'package:supabase_flutter/supabase_flutter.dart';

class FavouritesRepository {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> getFavouritePropertyIds() async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final userId = supabase.auth.currentUser?.id;
        if (userId == null) return [];

        final response = await supabase
            .from('customer_favourites')
            .select('plot_id')
            .eq('customer_id', userId);

        if (response != null && (response as List).isNotEmpty) {
          return response.map((e) => e['plot_id'].toString()).toList();
        }
      }
    } catch (e) {
      print('Error getting favourite property IDs: $e');
    }
    return [];
  }

  Future<bool> addFavourite(String propertyId) async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final userId = supabase.auth.currentUser?.id;
        if (userId == null) return false;

        await supabase.from('customer_favourites').insert({
          'customer_id': userId,
          'plot_id': propertyId,
        });
        return true;
      }
    } catch (e) {
      print('Error adding favourite: $e');
    }
    return false;
  }

  Future<bool> removeFavourite(String propertyId) async {
    try {
      final supabase = _supabase;
      if (supabase != null) {
        final userId = supabase.auth.currentUser?.id;
        if (userId == null) return false;

        await supabase
            .from('customer_favourites')
            .delete()
            .eq('customer_id', userId)
            .eq('plot_id', propertyId);
        return true;
      }
    } catch (e) {
      print('Error removing favourite: $e');
    }
    return false;
  }
}
