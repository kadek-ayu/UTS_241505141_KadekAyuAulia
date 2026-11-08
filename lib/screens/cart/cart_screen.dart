
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../orders/order_history_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0)}';
  }

  void _openOrderHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OrderHistoryScreen(),
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    CartProvider cart,
    int medicineId,
    String medicineName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Produk'),
          content: Text(
            'Apakah kamu yakin ingin menghapus $medicineName '
            'dari keranjang?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      cart.removeItem(medicineId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$medicineName berhasil dihapus.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildOrderHistoryButton(BuildContext context) {
    return InkWell(
      onTap: () => _openOrderHistory(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.pink.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.pink.shade100,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              color: Colors.pink,
              size: 25,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cek Pesanan Anda',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.pink,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Lihat status dan riwayat pesanan',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.pink.shade700,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOrderHistoryButton(context),
                const SizedBox(height: 100),
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 75,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Keranjang masih kosong',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tambahkan produk dari apotek terlebih dahulu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildOrderHistoryButton(context),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_pharmacy,
                            color: Colors.green,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Apotek pilihan',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cart.pharmacyName ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Produk dalam Keranjang',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${cart.itemCount} produk',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    ...cart.items.map((item) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.medical_services_outlined,
                                      color: Colors.green,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          _formatPrice(item.price),
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Subtotal: ${_formatPrice(item.subtotal)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Hapus produk',
                                    onPressed: () {
                                      _confirmRemove(
                                        context,
                                        cart,
                                        item.medicineId,
                                        item.name,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),

                              const Divider(height: 24),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Jumlah',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          cart.decreaseQuantity(
                                            item.medicineId,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed:
                                            item.quantity >=
                                                    item.stockQuantity
                                                ? null
                                                : () {
                                                    final success =
                                                        cart.increaseQuantity(
                                                      item.medicineId,
                                                    );

                                                    if (!success) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Jumlah sudah mencapai batas stok.',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              Text(
                                'Stok tersedia: ${item.stockQuantity}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Harga',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatPrice(cart.totalPrice),
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Harga berdasarkan data simulasi apotek.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const CheckoutScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.shopping_bag_outlined,
                          ),
                          label: const Text(
                            'Lanjutkan Pesanan',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
