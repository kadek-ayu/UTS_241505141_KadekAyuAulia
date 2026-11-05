import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/openfda_provider.dart';

class OpenFdaTestScreen extends StatelessWidget {
  const OpenFdaTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengujian OpenFDA'),
      ),
      body: Consumer<OpenFdaProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Pengujian REST API OpenFDA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tekan tombol untuk mengambil data produk '
                  'dari OpenFDA.',
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () => provider.loadProducts(),
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Uji Koneksi OpenFDA'),
                ),
                const SizedBox(height: 16),
                if (provider.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (provider.errorMessage != null)
                  Expanded(
                    child: Center(
                      child: Text(provider.errorMessage!),
                    ),
                  )
                else if (provider.products.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Belum ada data. Tekan tombol pengujian.',
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.products.length,
                      itemBuilder: (context, index) {
                        final product = provider.products[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              product.brandName.isNotEmpty
                                  ? product.brandName
                                  : product.genericName,
                            ),
                            subtitle: Text(
                              'Nama generik: ${product.genericName}\n'
                              'Produsen: ${product.manufacturer}\n'
                              'NDC: ${product.productNdc}',
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
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