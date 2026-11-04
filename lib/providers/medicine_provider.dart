
import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../repositories/medicine_repository.dart';

class MedicineProvider extends ChangeNotifier {
  final MedicineRepository _repository;

  MedicineProvider({
    MedicineRepository? repository,
  }) : _repository = repository ?? MedicineRepository();

  List<Medicine> _medicines = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Medicine> get medicines => _medicines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMedicines() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _medicines = await _repository.getMedicines();
    } catch (error) {
      _errorMessage = 'Gagal memuat data produk.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
