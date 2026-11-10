
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorite_provider.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FavoriteProvider>().loadFavorites();
    });
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is List && value.isNotEmpty &&
        value.first is Map<String, dynamic>) {
      return value.first as Map<String, dynamic>;
    }

    return {};
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatPrice(dynamic value) {
    return 'Rp ${_toDouble(value).toStringAsFixed(0)}';
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  void _addToCart({
    required Map<String, dynamic> pharmacyMedicine,
    required Map<String, dynamic> medicine,
    required Map<String, dynamic> pharmacy,
  }) {
    final pharmacyId = _toInt(
      pharmacyMedicine['pharmacy_id'] ?? pharmacy['id'],
    );

    final medicineId = _toInt(medicine['id']);
    final stock = _toInt(pharmacyMedicine['stock_quantity']);
    final price = _toDouble(pharmacyMedicine['price']);

    final pharmacyName =
        pharmacy['name']?.toString() ?? 'Apotek';

    final medicineName =
        medicine['name']?.toString() ?? 'Produk';

    if (pharmacyId == 0 || medicineId == 0) {
      _showMessage('Informasi produk tidak lengkap.');
      return;
    }

    final result = context.read<CartProvider>().addItem(
      pharmacyId: pharmacyId,
      pharmacyName: pharmacyName,
      medicineId: medicineId,
      name: medicineName,
      price: price,
      stockQuantity: stock,
    );

    switch (result) {
      case CartAddResult.added:
        _showMessage('$medicineName ditambahkan ke keranjang.');

      case CartAddResult.differentPharmacy:
        _showMessage(
          'Keranjang hanya dapat berisi produk dari satu apotek.',
        );

      case CartAddResult.outOfStock:
        _showMessage('Stok produk sedang habis.');

      case CartAddResult.insufficientStock:
        _showMessage('Jumlah produk sudah mencapai batas stok.');
    }
  }

  Future<void> _confirmRemove(
    int pharmacyMedicineId,
    String medicineName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Produk'),
          content: Text(
            'Apakah kamu yakin ingin menghapus $medicineName '
            'dari Produk Tersimpan?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final success = await context
        .read<FavoriteProvider>()
        .removeFavorite(pharmacyMedicineId);

    if (!mounted) return;

    _showMessage(
      success
          ? '$medicineName berhasil dihapus dari Produk Tersimpan.'
          : 'Gagal menghapus produk. Silakan coba lagi.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Produk Tersimpan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          if (favoriteProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (favoriteProvider.error != null) {
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
                    const Text('Gagal memuat produk tersimpan.'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: favoriteProvider.loadFavorites,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final favorites = favoriteProvider.favorites;

          if (favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada produk tersimpan.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tekan ikon bintang pada produk di apotek.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: favoriteProvider.loadFavorites,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite = favorites[index];

                final pharmacyMedicine =
                    _toMap(favorite['pharmacy_medicines']);

                final medicine =
                    _toMap(pharmacyMedicine['medicines']);

                final pharmacy =
                    _toMap(pharmacyMedicine['pharmacies']);

                final favoriteId =
                    _toInt(pharmacyMedicine['id'] ??
                        favorite['pharmacy_medicine_id']);

                final medicineName =
                    medicine['name']?.toString() ?? 'Produk';

                final category =
                    medicine['category']?.toString() ??
                        'Kategori tidak tersedia';

                final pharmacyName =
                    pharmacy['name']?.toString() ?? 'Apotek';

                final pharmacyAddress =
                    pharmacy['address']?.toString() ??
                        'Alamat tidak tersedia';

                final price = pharmacyMedicine['price'];
                final stock =
                    _toInt(pharmacyMedicine['stock_quantity']);

                final status =
                    pharmacyMedicine['availability_status']
                        ?.toString()
                        .toLowerCase() ?? '';

                final isAvailable = stock > 0 &&
                    ![
                      'unavailable',
                      'out_of_stock',
                      'habis',
                      'tidak tersedia',
                    ].contains(status);

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.10),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.medication_outlined,
                                color: AppTheme.primaryColor,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    medicineName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _formatPrice(price),
                                    style: const TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 24),

                        Row(
                          children: [
                            const Icon(
                              Icons.store_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pharmacyName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pharmacyAddress,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text('Stok: $stock'),
                            const Spacer(),
                            Text(
                              isAvailable
                                  ? 'Tersedia'
                                  : 'Tidak tersedia',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isAvailable
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: FilledButton.icon(
                                onPressed: isAvailable
                                    ? () => _addToCart(
                                          pharmacyMedicine:
                                              pharmacyMedicine,
                                          medicine: medicine,
                                          pharmacy: pharmacy,
                                        )
                                    : null,
                                icon: const Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Tambah ke Keranjang',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      AppTheme.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: OutlinedButton.icon(
                                onPressed: favoriteId == 0
                                    ? null
                                    : () => _confirmRemove(
                                          favoriteId,
                                          medicineName,
                                        ),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 8,
                                  ),
                                  side: const BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
