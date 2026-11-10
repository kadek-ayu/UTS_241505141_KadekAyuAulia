import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const int profileId = 1;

  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isFavorite(int pharmacyMedicineId) {
    return _favorites.any(
      (item) => item['pharmacy_medicine_id'] == pharmacyMedicineId,
    );
  }

  Future<void> loadFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('saved_products')
          .select('''
            id,
            profile_id,
            pharmacy_medicine_id,
            created_at,
            pharmacy_medicines (
              id,
              price,
              stock_quantity,
              availability_status,
              pharmacy_id,
              medicines (
                id,
                name,
                category,
                description,
                packaging
              ),
              pharmacies (
                id,
                name,
                address
              )
            )
          ''')
          .eq('profile_id', profileId)
          .order('created_at', ascending: false);

      _favorites = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite(int pharmacyMedicineId) async {
    try {
      if (isFavorite(pharmacyMedicineId)) {
        await _supabase
            .from('saved_products')
            .delete()
            .eq('profile_id', profileId)
            .eq('pharmacy_medicine_id', pharmacyMedicineId);
      } else {
        await _supabase.from('saved_products').insert({
          'profile_id': profileId,
          'pharmacy_medicine_id': pharmacyMedicineId,
        });
      }

      await loadFavorites();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFavorite(int pharmacyMedicineId) {
    return _removeFavorite(pharmacyMedicineId);
  }

  Future<bool> _removeFavorite(int pharmacyMedicineId) async {
    try {
      await _supabase
          .from('saved_products')
          .delete()
          .eq('profile_id', profileId)
          .eq('pharmacy_medicine_id', pharmacyMedicineId);

      await loadFavorites();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
