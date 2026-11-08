
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  DateTime? _pickupDateTime;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Batas pengambilan maksimal 14 hari dari hari pemesanan.
  DateTime get _lastPickupDate {
    return _today.add(const Duration(days: 14));
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectPickupDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _pickupDateTime ?? _today,
      firstDate: _today,
      lastDate: _lastPickupDate,
      helpText: 'Pilih Tanggal Pengambilan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (selected == null || !mounted) return;

    setState(() {
      _pickupDateTime = DateTime(
        selected.year,
        selected.month,
        selected.day,
        7,
      );
    });
  }

  Future<void> _selectPickupTime() async {
    if (_pickupDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pilih tanggal pengambilan terlebih dahulu.',
          ),
        ),
      );
      return;
    }

    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _pickupDateTime!.hour,
        minute: _pickupDateTime!.minute,
      ),
      helpText: 'Pilih Jam Pengambilan',
    );

    if (selected == null || !mounted) return;

    final selectedDateTime = DateTime(
      _pickupDateTime!.year,
      _pickupDateTime!.month,
      _pickupDateTime!.day,
      selected.hour,
      selected.minute,
    );

    // Batas jam sementara: 07.00 sampai 22.00.
    final isWithinOpeningHours =
        (selected.hour > 7 ||
            (selected.hour == 7 && selected.minute >= 0)) &&
        (selected.hour < 22 ||
            (selected.hour == 22 && selected.minute == 0));

    if (!isWithinOpeningHours) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pengambilan hanya tersedia pukul 07.00–22.00.',
          ),
        ),
      );
      return;
    }

    if (!selectedDateTime.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pilih waktu pengambilan yang belum lewat.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _pickupDateTime = selectedDateTime;
    });
  }

  Future<void> _confirmOrder(BuildContext context) async {
    if (_pickupDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan tentukan tanggal dan jam pengambilan.',
          ),
        ),
      );
      return;
    }

    if (!_pickupDateTime!.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jadwal pengambilan sudah lewat. Silakan pilih jadwal lain.',
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Pesanan'),
          content: Text(
            'Apakah Anda yakin ingin mengonfirmasi pesanan ini?\n\n'
            'Jadwal Pengambilan:\n'
            '${_formatDate(_pickupDateTime!)} '
            'pukul ${_formatTime(_pickupDateTime!)}',
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

    final success = await orderProvider.createOrder(
      cart,
      pickupDate: _pickupDateTime!,
    );

    if (!context.mounted) return;

    if (success) {
  // Kosongkan keranjang setelah pesanan berhasil disimpan.
  cart.clearCart();

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
                const SizedBox(height: 16),
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
                  'Jadwal Pengambilan',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(_pickupDateTime!)} '
                  'pukul ${_formatTime(_pickupDateTime!)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
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
                'Jadwal Pengambilan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih tanggal pengambilan maksimal '
                '14 hari sejak tanggal pemesanan.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.calendar_month,
                        color: Colors.green,
                      ),
                      title: const Text('Tanggal Pengambilan'),
                      subtitle: Text(
                        _pickupDateTime == null
                            ? 'Belum dipilih'
                            : _formatDate(_pickupDateTime!),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _selectPickupDate,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.access_time,
                        color: Colors.green,
                      ),
                      title: const Text('Jam Pengambilan'),
                      subtitle: Text(
                        _pickupDateTime == null
                            ? 'Belum dipilih'
                            : _formatTime(_pickupDateTime!),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _selectPickupTime,
                    ),
                  ],
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
                      const Text('Total Pesanan'),
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
                  'Catatan: Pesanan ini merupakan simulasi. '
                  'Pastikan Anda mengambil pesanan sesuai '
                  'jadwal yang telah dipilih.',
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
