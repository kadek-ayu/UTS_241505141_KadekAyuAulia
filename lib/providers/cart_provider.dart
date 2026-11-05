
import 'package:flutter/foundation.dart';

class CartItem {
  final int pharmacyId;
  final String pharmacyName;
  final int medicineId;
  final String name;
  final double price;
  final int stockQuantity;
  int quantity;

  CartItem({
    required this.pharmacyId,
    required this.pharmacyName,
    required this.medicineId,
    required this.name,
    required this.price,
    required this.stockQuantity,
    this.quantity = 1,
  });

  double get subtotal => price * quantity;
}

enum CartAddResult {
  added,
  differentPharmacy,
  outOfStock,
  insufficientStock,
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  int? _pharmacyId;
  String? _pharmacyName;

  List<CartItem> get items => List.unmodifiable(_items);

  int? get pharmacyId => _pharmacyId;

  String? get pharmacyName => _pharmacyName;

  bool get isEmpty => _items.isEmpty;

  int get itemCount {
    return _items.fold(
      0,
      (total, item) => total + item.quantity,
    );
  }

  double get totalPrice {
    return _items.fold(
      0,
      (total, item) => total + item.subtotal,
    );
  }

  CartAddResult addItem({
    required int pharmacyId,
    required String pharmacyName,
    required int medicineId,
    required String name,
    required double price,
    required int stockQuantity,
  }) {
    if (stockQuantity <= 0) {
      return CartAddResult.outOfStock;
    }

    if (_items.isNotEmpty && _pharmacyId != pharmacyId) {
      return CartAddResult.differentPharmacy;
    }

    final existingIndex = _items.indexWhere(
      (item) => item.medicineId == medicineId,
    );

    if (existingIndex != -1) {
      final existingItem = _items[existingIndex];

      if (existingItem.quantity >= existingItem.stockQuantity) {
        return CartAddResult.insufficientStock;
      }

      existingItem.quantity++;
    } else {
      _pharmacyId = pharmacyId;
      _pharmacyName = pharmacyName;

      _items.add(
        CartItem(
          pharmacyId: pharmacyId,
          pharmacyName: pharmacyName,
          medicineId: medicineId,
          name: name,
          price: price,
          stockQuantity: stockQuantity,
        ),
      );
    }

    notifyListeners();
    return CartAddResult.added;
  }

  bool increaseQuantity(int medicineId) {
    final index = _items.indexWhere(
      (item) => item.medicineId == medicineId,
    );

    if (index == -1) return false;

    final item = _items[index];

    if (item.quantity >= item.stockQuantity) {
      return false;
    }

    item.quantity++;
    notifyListeners();
    return true;
  }

  bool decreaseQuantity(int medicineId) {
    final index = _items.indexWhere(
      (item) => item.medicineId == medicineId,
    );

    if (index == -1) return false;

    final item = _items[index];

    if (item.quantity > 1) {
      item.quantity--;
      notifyListeners();
      return true;
    }

    return false;
  }

  void removeItem(int medicineId) {
    _items.removeWhere(
      (item) => item.medicineId == medicineId,
    );

    _resetPharmacyIfEmpty();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _pharmacyId = null;
    _pharmacyName = null;
    notifyListeners();
  }

  void _resetPharmacyIfEmpty() {
    if (_items.isEmpty) {
      _pharmacyId = null;
      _pharmacyName = null;
    }
  }
}
