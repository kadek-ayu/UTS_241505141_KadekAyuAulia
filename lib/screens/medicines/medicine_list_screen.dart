
import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';
import '../../models/medicine.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() =>
      _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  String searchQuery = '';

  final List<Medicine> medicines = const [
    Medicine(
      id: 1,
      name: 'Vitamin C',
      category: 'Vitamin',
      description: 'Produk vitamin C.',
      packaging: 'Botol',
      stock: 20,
    ),
    Medicine(
      id: 2,
      name: 'Masker Medis',
      category: 'Perawatan',
      description: 'Produk perlengkapan kesehatan.',
      packaging: 'Kotak',
      stock: 15,
    ),
    Medicine(
      id: 3,
      name: 'Termometer Digital',
      category: 'Alat Kesehatan',
      description: 'Alat pengukur suhu digital.',
      packaging: 'Unit',
      stock: 10,
    ),
    Medicine(
      id: 4,
      name: 'Hand Sanitizer',
      category: 'Perawatan',
      description: 'Produk kebersihan tangan.',
      packaging: 'Botol',
      stock: 12,
    ),
  ];

  List<Medicine> get filteredMedicines {
    return medicines.where((medicine) {
      final name = medicine.name.toLowerCase();
      final category = medicine.category.toLowerCase();
      final query = searchQuery.toLowerCase();

      return name.contains(query) ||
          category.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayedMedicines = filteredMedicines;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Katalog Produk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama atau kategori produk...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppTheme.blueAccent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Daftar Produk (${displayedMedicines.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: displayedMedicines.isEmpty
                  ? const Center(
                      child: Text(
                        'Produk tidak ditemukan.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: displayedMedicines.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final medicine = displayedMedicines[index];

                        return Card(
                          elevation: 1,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppTheme.blueAccent,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.medication_outlined,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        medicine.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        medicine.category,
                                        style: const TextStyle(
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        medicine.description,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Kemasan: ${medicine.packaging} '
                                        '| Stok: ${medicine.stock}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
