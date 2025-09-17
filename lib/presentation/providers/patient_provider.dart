import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_app/data/models/patient.dart';

class PatientNotifier extends StateNotifier<List<Patient>> {
  PatientNotifier() : super([]);

  void addPatient(Patient patient) {
    state = [...state, patient];
  }

  void updatePatient(Patient updatedPatient) {
    state = [
      for (final patient in state)
        if (patient.id == updatedPatient.id) updatedPatient else patient
    ];
  }

  void removePatient(int patientId) {
    state = state.where((patient) => patient.id != patientId).toList();
  }
}

final patientProvider = StateNotifierProvider<PatientNotifier, List<Patient>>(
  (ref) => PatientNotifier(),
);