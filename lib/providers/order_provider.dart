
import 'package:flutter/foundation.dart';

import '../services/order_service.dart';
import 'cart_provider.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _lastOrder;
  List<Map<String, dynamic>> _orders = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get lastOrder => _lastOrder;
  List<Map<String, dynamic>> get orders => List.unmodifiable(_orders);

  Future<bool> createOrder(
    CartProvider cart, {
    required DateTime pickupDate,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastOrder = await _orderService.createOrder(
        cart: cart,
        pickupDate: pickupDate,
      );

      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.getOrders();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePickupDate({
    required int orderId,
    required DateTime pickupDate,
  }) async {
    try {
      final success = await _orderService.updatePickupDate(
        orderId: orderId,
        pickupDate: pickupDate,
      );

      if (success) await loadOrders();
      return success;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    try {
      final success = await _orderService.cancelOrder(orderId);

      if (success) await loadOrders();
      return success;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }
}
