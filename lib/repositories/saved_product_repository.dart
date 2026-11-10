import '../services/saved_product_service.dart';

class SavedProductRepository {
  final SavedProductService _service;

  SavedProductRepository({
    SavedProductService? service,
  }) : _service = service ?? SavedProductService();

  Future<List<String>> getSavedProductNdc() {
    return _service.getSavedProductNdc();
  }

  Future<void> addSavedProduct(String productNdc) {
    return _service.addSavedProduct(productNdc);
  }

  Future<void> removeSavedProduct(String productNdc) {
    return _service.removeSavedProduct(productNdc);
  }
}