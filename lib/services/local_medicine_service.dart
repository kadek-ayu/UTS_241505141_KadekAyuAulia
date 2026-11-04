
import '../models/medicine.dart';

class LocalMedicineService {
  Future<List<Medicine>> getMedicines() async {
    return const [
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
  }
}
