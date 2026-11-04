
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_theme.dart';
import '../../models/openfda_product.dart';
import '../../providers/favorite_provider.dart';

class OpenFdaProductDetailScreen extends StatelessWidget {
  final OpenFdaProduct product;

  const OpenFdaProductDetailScreen({
    super.key,
    required this.product,
  });

  String _displayValue(String value) {
    return value.isEmpty ? 'Tidak tersedia' : value;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildListInfo(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title),
          if (items.isEmpty)
            const Text(
              'Tidak tersedia',
              style: TextStyle(color: Colors.grey),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return Chip(
                  label: Text(item),
                  backgroundColor: AppTheme.blueAccent,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = product.brandName.isNotEmpty
        ? product.brandName
        : product.genericName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          final isFavorite =
              favoriteProvider.isFavorite(product);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.blueAccent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.medication_outlined,
                      size: 55,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    _displayValue(displayName),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Chip(
                    label: Text('Data OpenFDA'),
                    backgroundColor: AppTheme.blueAccent,
                  ),
                ),

                const SizedBox(height: 16),

                // Tombol bintang Produk Tersimpan
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: product.productNdc.isEmpty
                        ? null
                        : () {
                            favoriteProvider.toggleFavorite(
                              product,
                            );

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFavorite
                                        ? 'Produk dihapus dari tersimpan.'
                                        : 'Produk berhasil disimpan.',
                                  ),
                                ),
                              );
                          },
                    icon: Icon(
                      isFavorite
                          ? Icons.star
                          : Icons.star_border,
                      color: isFavorite
                          ? Colors.amber.shade700
                          : AppTheme.primaryColor,
                    ),
                    label: Text(
                      isFavorite
                          ? 'Hapus dari Produk Tersimpan'
                          : 'Simpan Produk',
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                _buildSectionTitle('Informasi Produk'),
                const Divider(),
                _buildInfoRow(
                  'Nama merek',
                  _displayValue(product.brandName),
                ),
                _buildInfoRow(
                  'Nama generik',
                  _displayValue(product.genericName),
                ),
                _buildInfoRow(
                  'Produsen',
                  _displayValue(product.manufacturer),
                ),
                _buildInfoRow(
                  'Bentuk sediaan',
                  _displayValue(product.dosageForm),
                ),
                _buildInfoRow(
                  'Jenis produk',
                  _displayValue(product.productType),
                ),
                _buildInfoRow(
                  'NDC',
                  _displayValue(product.productNdc),
                ),
                const Divider(),
                const SizedBox(height: 20),

                _buildListInfo(
                  'Bahan Aktif',
                  product.activeIngredients,
                ),
                _buildListInfo(
                  'Rute Penggunaan',
                  product.routes,
                ),

                _buildSectionTitle('Ketersediaan ApoTech'),
                const Divider(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Belum masuk inventaris',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Informasi stok dan ketersediaan produk '
                        'akan dikelola melalui database ApoTech.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Sumber informasi: OpenFDA. Data ini merupakan '
                  'informasi produk dan bukan rekomendasi penggunaan obat.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
