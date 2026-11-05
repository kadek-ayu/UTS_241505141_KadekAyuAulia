
import '../models/openfda_product.dart';
import '../services/openfda_service.dart';

class OpenFdaRepository {
  final OpenFdaService _service;

  OpenFdaRepository({
    OpenFdaService? service,
  }) : _service = service ?? OpenFdaService();

  Future<List<OpenFdaProduct>> getProducts() {
    return _service.getProducts();
  }
}
