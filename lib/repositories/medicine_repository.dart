
import '../models/medicine.dart';
import '../services/local_medicine_service.dart';

class MedicineRepository {
  final LocalMedicineService _service;

  MedicineRepository({
    LocalMedicineService? service,
  }) : _service = service ?? LocalMedicineService();

  Future<List<Medicine>> getMedicines() {
    return _service.getMedicines();
  }
}
