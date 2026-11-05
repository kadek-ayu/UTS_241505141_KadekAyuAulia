
import 'package:flutter/material.dart';

import '../models/openfda_product.dart';
import '../repositories/openfda_repository.dart';

class OpenFdaProvider extends ChangeNotifier {
  final OpenFdaRepository _repository;

  OpenFdaProvider({
    OpenFdaRepository? repository,
  }) : _repository = repository ?? OpenFdaRepository();

  List<OpenFdaProduct> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OpenFdaProduct> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.getProducts();
    } catch (error) {
      _errorMessage = 'Gagal memuat data dari OpenFDA.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
