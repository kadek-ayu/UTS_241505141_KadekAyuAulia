
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/cart_provider.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> createOrder({
    required CartProvider cart,
    required DateTime pickupDate,
  }) async {
    if (cart.isEmpty || cart.pharmacyId == null) {
      throw Exception('Keranjang masih kosong.');
    }

    final order = await _supabase
        .from('orders')
        .insert({
          'pharmacy_id': cart.pharmacyId,
          'total_price': cart.totalPrice,
          'order_status': 'pending',
          'pickup_at': pickupDate.toUtc().toIso8601String(),
        })
        .select()
        .single();

    final orderId = order['id'];

    try {
      final orderItems = cart.items.map((item) {
        return {
          'order_id': orderId,
          'medicine_id': item.medicineId,
          'quantity': item.quantity,
          'unit_price': item.price,
          'subtotal': item.subtotal,
        };
      }).toList();

      await _supabase.from('order_items').insert(orderItems);

      return order;
    } catch (error) {
      await _supabase
          .from('orders')
          .delete()
          .eq('id', orderId);

      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await _supabase.from('orders').select('''
      id,
      pharmacy_id,
      total_price,
      order_status,
      created_at,
      pickup_at,
      pharmacies (
        name,
        address
      ),
      order_items (
        id,
        medicine_id,
        quantity,
        unit_price,
        subtotal,
        medicines (
          name,
          category,
          packaging
        )
      )
    ''').order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<bool> updatePickupDate({
    required int orderId,
    required DateTime pickupDate,
  }) async {
    final result = await _supabase
        .from('orders')
        .update({
          'pickup_at': pickupDate.toUtc().toIso8601String(),
        })
        .eq('id', orderId)
        .eq('order_status', 'pending')
        .select('id')
        .maybeSingle();

    return result != null;
  }

  Future<bool> cancelOrder(int orderId) async {
    final result = await _supabase
        .from('orders')
        .update({
          'order_status': 'cancelled',
        })
        .eq('id', orderId)
        .eq('order_status', 'pending')
        .select('id')
        .maybeSingle();

    return result != null;
  }
}
