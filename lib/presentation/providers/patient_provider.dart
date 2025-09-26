import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_app/data/models/patient.dart';
import 'package:doctor_app/data/repositories/patient_repository.dart';
import 'package:doctor_app/services/services.dart';

class PatientNotifier extends StateNotifier<AsyncValue<List<Patient>>> {
  final PatientRepository _repository;

  PatientNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPatients();
  }

  Future<void> loadPatients() async {
    try {
      final patients = await _repository.getAllPatients();
      state = AsyncValue.data(patients);

      // Initialize folders for existing patients (async, don't wait)
      FileOrganizationService.initializeExistingPatientFolders(patients);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addPatient(Patient patient) async {
    try {
      final id = await _repository.insertPatient(patient);
      final newPatient = patient.copyWith(id: id);

      // Create patient folder
      await FileOrganizationService.createPatientFolder(newPatient);

      state.whenData((patients) {
        state = AsyncValue.data([newPatient, ...patients]);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updatePatient(Patient updatedPatient) async {
    try {
      // Get the old patient data before updating
      final oldPatient = await _repository.getPatientById(updatedPatient.id!);

      // Update in database
      await _repository.updatePatient(updatedPatient);

      // Rename folder if patient name changed
      if (oldPatient != null) {
        await FileOrganizationService.renamePatientFolder(oldPatient, updatedPatient);
      }

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
      // Get patient data before deleting from database
      final patient = await _repository.getPatientById(patientId);

      // Delete from database
      await _repository.deletePatient(patientId);

      // Delete patient folder if patient exists
      if (patient != null) {
        await FileOrganizationService.deletePatientFolder(patient);
      }

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

  Future<bool> checkPatientNameExists(String name, {int? excludeId}) async {
    return await _repository.patientExistsByName(name, excludeId: excludeId);
  }

  void refresh() {
    loadPatients();
  }
}

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepository();
});

final patientProvider = StateNotifierProvider<PatientNotifier, AsyncValue<List<Patient>>>((ref) {
  final repository = ref.watch(patientRepositoryProvider);
  return PatientNotifier(repository);
});