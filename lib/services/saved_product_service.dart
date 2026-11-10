import 'package:supabase_flutter/supabase_flutter.dart';

class SavedProductService {
  final SupabaseClient _client = Supabase.instance.client;

  static const String tableName = 'saved_products';
  static const int profileId = 1;

  // Mengambil daftar kode produk yang tersimpan.
  Future<List<String>> getSavedProductNdc() async {
    final response = await _client
        .from(tableName)
        .select('product_ndc')
        .eq('profile_id', profileId);

    return response
        .map<String>(
          (item) => item['product_ndc'].toString(),
        )
        .toList();
  }

  // Menyimpan produk.
  Future<void> addSavedProduct(String productNdc) async {
    await _client.from(tableName).insert({
      'profile_id': profileId,
      'product_ndc': productNdc,
    });
  }

  // Menghapus produk tersimpan.
  Future<void> removeSavedProduct(String productNdc) async {
    await _client
        .from(tableName)
        .delete()
        .eq('profile_id', profileId)
        .eq('product_ndc', productNdc);
  }
}
