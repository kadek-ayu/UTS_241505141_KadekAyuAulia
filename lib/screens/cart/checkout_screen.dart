
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0)}';
  }

  Future<void> _confirmOrder(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Pesanan'),
          content: const Text(
            'Apakah Anda yakin ingin mengonfirmasi pesanan ini? '
            'Pesanan ini merupakan simulasi dan perlu dikonfirmasi '
            'dalam waktu 24 jam.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Periksa Kembali'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Ya, Konfirmasi'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    final success = await orderProvider.createOrder(cart);

    if (!context.mounted) return;

    if (success) {
      final order = orderProvider.lastOrder;

      final orderId = order?['id']?.toString() ?? '-';

      final receiptNumber = orderId == '-'
          ? '-'
          : 'APT-${orderId.padLeft(6, '0')}';

      final totalPrice =
          (order?['total_price'] as num?)?.toDouble() ?? 0;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 55,
            ),
            title: const Text('Pesanan Berhasil!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pesanan Anda berhasil dibuat dan tersimpan.',
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nomor Resi',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  receiptNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Total Pesanan',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(totalPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Catatan: Pesanan ini merupakan simulasi. '
                  'Tidak ada transaksi pembayaran atau '
                  'pengambilan sungguhan.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  },
                  child: const Text('Baik'),
                ),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            orderProvider.errorMessage ??
                'Pesanan gagal dibuat.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pesanan'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return const Center(
              child: Text('Keranjang masih kosong.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Informasi Apotek',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.local_pharmacy,
                    color: Colors.green,
                  ),
                  title: Text(cart.pharmacyName ?? '-'),
                  subtitle: const Text('Apotek pilihan Anda'),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ringkasan Produk',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...cart.items.map(
                (item) => Card(
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                      '${item.quantity} x '
                      '${_formatPrice(item.price)}',
                    ),
                    trailing: Text(
                      _formatPrice(item.subtotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Total Pesanan',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatPrice(cart.totalPrice),
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Catatan: Ini merupakan pemesanan simulasi. '
                  'Pesanan perlu dikonfirmasi dalam waktu 24 jam. '
                  'Belum ada transaksi atau pengambilan sungguhan.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
              Consumer<OrderProvider>(
                builder: (context, orderProvider, child) {
                  return ElevatedButton(
                    onPressed: orderProvider.isLoading
                        ? null
                        : () => _confirmOrder(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ),
                    ),
                    child: orderProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Konfirmasi Pesanan'),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
