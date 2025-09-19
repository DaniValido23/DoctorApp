import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_app/data/models/patient.dart';
import 'package:doctor_app/data/repositories/patient_repository.dart';

class PatientNotifier extends StateNotifier<AsyncValue<List<Patient>>> {
  final PatientRepository _repository;

  PatientNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPatients();
  }

  Future<void> loadPatients() async {
    try {
      final patients = await _repository.getAllPatients();
      state = AsyncValue.data(patients);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addPatient(Patient patient) async {
    try {
      final id = await _repository.insertPatient(patient);
      final newPatient = patient.copyWith(id: id);

      state.whenData((patients) {
        state = AsyncValue.data([newPatient, ...patients]);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updatePatient(Patient updatedPatient) async {
    try {
      await _repository.updatePatient(updatedPatient);

      state.whenData((patients) {
        final updatedList = patients.map((patient) =>
          patient.id == updatedPatient.id ? updatedPatient : patient
        ).toList();
        state = AsyncValue.data(updatedList);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removePatient(int patientId) async {
    try {
      await _repository.deletePatient(patientId);

      state.whenData((patients) {
        final updatedList = patients.where((patient) => patient.id != patientId).toList();
        state = AsyncValue.data(updatedList);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<List<Patient>> searchPatients(String searchTerm) async {
    return await _repository.searchPatientsByName(searchTerm);
  }

  Future<Patient?> getPatientById(int id) async {
    return await _repository.getPatientById(id);
  }
}

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepository();
});

final patientProvider = StateNotifierProvider<PatientNotifier, AsyncValue<List<Patient>>>((ref) {
  final repository = ref.watch(patientRepositoryProvider);
  return PatientNotifier(repository);
});