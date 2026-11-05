
class Order {
  final int id;
  final int pharmacyId;
  final double totalPrice;
  final String orderStatus;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.pharmacyId,
    required this.totalPrice,
    required this.orderStatus,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: (json['id'] as num).toInt(),
      pharmacyId: (json['pharmacy_id'] as num).toInt(),
      totalPrice: (json['total_price'] as num).toDouble(),
      orderStatus: json['order_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
