
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() =>
      _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrderProvider>().loadOrders();
      }
    });
  }

  String _formatPrice(dynamic price) {
    final value = double.tryParse(price.toString()) ?? 0;

    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Belum ditentukan';

    final parsed = DateTime.tryParse(date.toString());
    if (parsed == null) return '-';

    final d = parsed.toLocal();

    const months = [
      'Januari', 'Februari', 'Maret', 'April',
      'Mei', 'Juni', 'Juli', 'Agustus',
      'September', 'Oktober', 'November', 'Desember',
    ];

    return '${d.day} ${months[d.month - 1]} ${d.year}, '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'processing':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'processing':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _changePickupDate(
    Map<String, dynamic> order,
  ) async {
    final orderId = int.tryParse(order['id'].toString());
    if (orderId == null) return;

    final currentPickup = order['pickup_at'] == null
        ? null
        : DateTime.tryParse(order['pickup_at'].toString())?.toLocal();

    // Gunakan tanggal awal pesanan sebagai patokan.
    // Untuk pesanan lama yang belum memiliki original_pickup_at,
    // sementara gunakan pickup_at.
    final originalPickup = order['original_pickup_at'] == null
        ? currentPickup
        : DateTime.tryParse(
            order['original_pickup_at'].toString(),
          )?.toLocal();

    if (originalPickup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal awal pesanan tidak dapat dibaca.'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final originalDate = DateTime(
      originalPickup.year,
      originalPickup.month,
      originalPickup.day,
    );

    // Maksimal dua hari setelah tanggal awal pesanan.
    final maxDate = originalDate.add(
      const Duration(days: 2),
    );

    if (today.isAfter(maxDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Batas perubahan jadwal sudah lewat. '
            'Jadwal hanya dapat diubah sampai dua hari '
            'setelah tanggal awal.',
          ),
        ),
      );
      return;
    }

    final initialDate = currentPickup != null &&
            !currentPickup.isBefore(today) &&
            !DateTime(
              currentPickup.year,
              currentPickup.month,
              currentPickup.day,
            ).isAfter(maxDate)
        ? DateTime(
            currentPickup.year,
            currentPickup.month,
            currentPickup.day,
          )
        : today;

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: maxDate,
      helpText: 'Pilih tanggal pengambilan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (selected == null || !mounted) return;

    final initialTime = currentPickup != null
        ? TimeOfDay.fromDateTime(currentPickup)
        : const TimeOfDay(hour: 6, minute: 0);

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Pilih jam pengambilan (06.00–22.00)',
    );

    if (selectedTime == null || !mounted) return;

    final pickupDate = DateTime(
      selected.year,
      selected.month,
      selected.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Jam pengambilan hanya boleh pukul 06.00 sampai 22.00.
    final isWithinPickupHours =
        (selectedTime.hour > 6 ||
            (selectedTime.hour == 6 &&
                selectedTime.minute == 0)) &&
        (selectedTime.hour < 22 ||
            (selectedTime.hour == 22 &&
                selectedTime.minute == 0));

    if (!isWithinPickupHours) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pengambilan hanya tersedia pukul 06.00–22.00.',
          ),
        ),
      );
      return;
    }

    // Tanggal dan jam yang dipilih harus belum lewat.
    if (!pickupDate.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tanggal dan jam harus di masa depan.',
          ),
        ),
      );
      return;
    }

    // Pastikan jadwal tidak melewati batas dua hari.
    final lastAllowedTime = DateTime(
      maxDate.year,
      maxDate.month,
      maxDate.day,
      22,
      0,
    );

    if (pickupDate.isAfter(lastAllowedTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jadwal maksimal dua hari setelah tanggal awal.',
          ),
        ),
      );
      return;
    }

    final success = await context
        .read<OrderProvider>()
        .updatePickupDate(
          orderId: orderId,
          pickupDate: pickupDate,
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Tanggal pengambilan berhasil diperbarui.'
              : 'Gagal mengubah tanggal. '
                  'Pastikan pesanan masih menunggu.',
        ),
      ),
    );
  }

  Future<void> _cancelOrder(
    Map<String, dynamic> order,
  ) async {
    final orderId = int.tryParse(order['id'].toString());
    if (orderId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: const Text(
          'Apakah kamu yakin ingin membatalkan pesanan ini? '
          'Pesanan yang sudah diproses tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await context
        .read<OrderProvider>()
        .cancelOrder(orderId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Pesanan berhasil dibatalkan.'
              : 'Pesanan tidak dapat dibatalkan '
                  'karena statusnya sudah berubah.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: () {
              context.read<OrderProvider>().loadOrders();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null &&
              provider.orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text('Gagal memuat pesanan.'),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: provider.loadOrders,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 72,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum Ada Pesanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pesanan kamu akan muncul di sini.',
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadOrders,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.orders.length,
              itemBuilder: (context, index) {
                final order = provider.orders[index];
                final pharmacy = _asMap(order['pharmacies']);
                final items = _asMapList(order['order_items']);

                final status =
                    order['order_status']?.toString() ?? 'unknown';

                final isPending =
                    status.toLowerCase() == 'pending';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.local_pharmacy_outlined,
                              color: Colors.pink,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pharmacy['name']?.toString() ??
                                        'Apotek',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Pesanan #${order['id']}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(_statusLabel(status)),
                              backgroundColor: _statusColor(status)
                                  .withValues(alpha: 0.12),
                              labelStyle: TextStyle(
                                color: _statusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dipesan: '
                          '${_formatDate(order['created_at'])}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const Divider(height: 24),
                        const Text(
                          'Produk Pesanan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...items.map((item) {
                          final medicine =
                              _asMap(item['medicines']);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    medicine['name']?.toString() ??
                                        'Produk',
                                  ),
                                ),
                                Text('x${item['quantity']}'),
                                const SizedBox(width: 12),
                                Text(
                                  _formatPrice(item['subtotal']),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pesanan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatPrice(order['total_price']),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.pink,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tanggal Pengambilan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.pink,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _formatDate(order['pickup_at']),
                              ),
                            ),
                          ],
                        ),
                        if (isPending) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _changePickupDate(order);
                              },
                              icon: const Icon(
                                Icons.edit_calendar,
                              ),
                              label: const Text(
                                'Ubah Tanggal Pengambilan',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () {
                                _cancelOrder(order);
                              },
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                              ),
                              label: const Text(
                                'Batalkan Pesanan',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ] else
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                              'Pesanan tidak dapat diubah '
                              'pada status ini.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
