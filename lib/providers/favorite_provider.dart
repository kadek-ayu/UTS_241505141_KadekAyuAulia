import 'package:flutter/material.dart';

import '../models/openfda_product.dart';

class FavoriteProvider extends ChangeNotifier {
  final Map<String, OpenFdaProduct> _favorites = {};

  List<OpenFdaProduct> get favorites =>
      _favorites.values.toList();

  bool isFavorite(OpenFdaProduct product) {
    return _favorites.containsKey(product.productNdc);
  }

  void toggleFavorite(OpenFdaProduct product) {
    final productId = product.productNdc;

    if (productId.isEmpty) {
      return;
    }

    if (_favorites.containsKey(productId)) {
      _favorites.remove(productId);
    } else {
      _favorites[productId] = product;
    }

    notifyListeners();
  }

  void removeFavorite(OpenFdaProduct product) {
    _favorites.remove(product.productNdc);
    notifyListeners();
  }

  void clearFavorites() {
    _favorites.clear();
    notifyListeners();
  }
}