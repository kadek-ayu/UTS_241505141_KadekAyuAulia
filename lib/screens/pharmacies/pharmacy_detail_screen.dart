
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/cart_provider.dart';

class PharmacyDetailScreen extends StatelessWidget {
  final Map<String, dynamic> pharmacy;

  const PharmacyDetailScreen({
    super.key,
    required this.pharmacy,
  });

  Future<List<Map<String, dynamic>>> _loadProducts() async {
    final pharmacyId = pharmacy['id'];

    final response = await Supabase.instance.client
        .from('pharmacy_medicines')
        .select('''
          id,
          price,
          stock_quantity,
          availability_status,
          medicines (
            id,
            name,
            category,
            description,
            packaging
          )
        ''')
        .eq('pharmacy_id', pharmacyId)
        .order('id');

    return List<Map<String, dynamic>>.from(response);
  }

  void _addToCart(
    BuildContext context, {
    required int pharmacyId,
    required String pharmacyName,
    required int medicineId,
    required String medicineName,
    required double price,
    required int stock,
  }) {
    final cartProvider = context.read<CartProvider>();

    final result = cartProvider.addItem(
      pharmacyId: pharmacyId,
      pharmacyName: pharmacyName,
      medicineId: medicineId,
      name: medicineName,
      price: price,
      stockQuantity: stock,
    );

    String message;

    switch (result) {
      case CartAddResult.added:
        message = '$medicineName berhasil ditambahkan ke keranjang.';
        break;
      case CartAddResult.differentPharmacy:
        message =
            'Keranjang hanya dapat berisi produk dari satu apotek. '
            'Kosongkan keranjang terlebih dahulu untuk memilih apotek ini.';
        break;
      case CartAddResult.outOfStock:
        message = 'Produk sedang tidak tersedia.';
        break;
      case CartAddResult.insufficientStock:
        message = 'Jumlah produk sudah mencapai batas stok.';
        break;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final pharmacyId = (pharmacy['id'] as num).toInt();
    final name =
        pharmacy['name']?.toString() ?? 'Nama tidak tersedia';
    final address =
        pharmacy['address']?.toString() ?? 'Alamat tidak tersedia';
    final city = pharmacy['city']?.toString() ?? '';
    final phone = pharmacy['phone']?.toString() ?? '';
    final openingHours =
        pharmacy['opening_hours']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Apotek'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_pharmacy,
                      size: 48,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Profil Apotek ApoTech',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Informasi Apotek',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _buildInfoTile(
              Icons.location_on_outlined,
              'Alamat',
              city.isEmpty ? address : '$address, $city',
            ),

            if (phone.isNotEmpty)
              _buildInfoTile(
                Icons.phone_outlined,
                'Nomor Telepon',
                phone,
              ),

            if (openingHours.isNotEmpty)
              _buildInfoTile(
                Icons.access_time,
                'Jam Operasional',
                openingHours,
              ),

            const SizedBox(height: 28),

            const Text(
              'Ketersediaan Produk',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Informasi produk berdasarkan data simulasi apotek.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 16),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildMessage(
                    'Gagal memuat produk.\n${snapshot.error}',
                    isError: true,
                  );
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return _buildMessage(
                    'Belum ada produk untuk apotek ini.',
                  );
                }

                return Column(
                  children: products.map((item) {
                    final medicine = item['medicines'];

                    if (medicine == null) {
                      return const SizedBox.shrink();
                    }

                    final product =
                        Map<String, dynamic>.from(medicine);

                    final medicineId =
                        (product['id'] as num).toInt();

                    final productName =
                        product['name']?.toString() ??
                            'Produk tidak tersedia';

                    final category =
                        product['category']?.toString() ?? '';

                    final packaging =
                        product['packaging']?.toString() ?? '';

                    final stock =
                        (item['stock_quantity'] as num?)
                                ?.toInt() ??
                            0;

                    final price =
                        (item['price'] as num?)?.toDouble() ?? 0;

                    final status =
                        item['availability_status']?.toString() ??
                            '';

                    final isAvailable =
                        status == 'available' && stock > 0;

                    return _buildProductCard(
                      context: context,
                      pharmacyId: pharmacyId,
                      pharmacyName: name,
                      medicineId: medicineId,
                      name: productName,
                      category: category,
                      packaging: packaging,
                      stock: stock,
                      price: price,
                      isAvailable: isAvailable,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required BuildContext context,
    required int pharmacyId,
    required String pharmacyName,
    required int medicineId,
    required String name,
    required String category,
    required String packaging,
    required int stock,
    required double price,
    required bool isAvailable,
  }) {
    return Opacity(
      opacity: isAvailable ? 1 : 0.55,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (category.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          category,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  isAvailable
                      ? Icons.check_circle
                      : Icons.cancel,
                  color:
                      isAvailable ? Colors.green : Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              'Rp ${price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Kemasan: ${packaging.isEmpty ? '-' : packaging}',
              style: const TextStyle(fontSize: 12),
            ),

            const SizedBox(height: 4),

            Text(
              'Stok: $stock',
              style: const TextStyle(fontSize: 12),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isAvailable
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isAvailable ? 'Tersedia' : 'Stok habis',
                style: TextStyle(
                  color:
                      isAvailable ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if (isAvailable) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _addToCart(
                      context,
                      pharmacyId: pharmacyId,
                      pharmacyName: pharmacyName,
                      medicineId: medicineId,
                      medicineName: name,
                      price: price,
                      stock: stock,
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Tambah ke Keranjang'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(
    String message, {
    bool isError = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? Colors.red : Colors.black54,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.green,
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
