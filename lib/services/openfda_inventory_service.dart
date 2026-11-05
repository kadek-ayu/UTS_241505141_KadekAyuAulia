import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/openfda_product.dart';

class OpenFdaInventoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> saveProduct(OpenFdaProduct product) async {
    if (product.productNdc.isEmpty) {
      throw Exception('Kode produk NDC tidak tersedia.');
    }

    final existing = await _supabase
        .from('medicines')
        .select('id')
        .eq('product_ndc', product.productNdc)
        .maybeSingle();

    if (existing != null) {
      return false;
    }

    final description = [
      'Nama generik: ${product.genericName}',
      'Produsen: ${product.manufacturer}',
      'Bahan aktif: ${product.activeIngredients.join(', ')}',
    ].join('\n');

    await _supabase.from('medicines').insert({
      'product_ndc': product.productNdc,
      'name': product.brandName.isNotEmpty
          ? product.brandName
          : product.genericName,
      'category': product.productType,
      'description': description,
      'packaging': product.dosageForm,
      'stock': 0,
    });

    return true;
  }
}