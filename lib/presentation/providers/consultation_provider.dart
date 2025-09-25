import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_app/data/models/models.dart';
import 'package:doctor_app/data/repositories/repositories.dart';

class ConsultationNotifier extends StateNotifier<AsyncValue<List<Consultation>>> {
  final ConsultationRepository _repository;

  ConsultationNotifier(this._repository) : super(const AsyncValue.data([]));

  Future<Consultation> addConsultation(Consultation consultation) async {
    try {
      final id = await _repository.insertConsultation(consultation);
      final newConsultation = consultation.copyWith(id: id);

      state.whenData((consultations) {
        state = AsyncValue.data([newConsultation, ...consultations]);
      });

      return newConsultation;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> loadConsultationsByPatient(int patientId) async {
    try {
      state = const AsyncValue.loading();
      final consultations = await _repository.getConsultationsByPatientId(patientId);
      state = AsyncValue.data(consultations);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Consultation?> getConsultationById(int id) async {
    return await _repository.getConsultationById(id);
  }

  Future<List<Consultation>> getConsultationsByPatientId(int patientId) async {
    return await _repository.getConsultationsByPatientId(patientId);
  }

  Future<void> updateConsultation(Consultation consultation) async {
    try {
      await _repository.updateConsultation(consultation);

      state.whenData((consultations) {
        final updatedList = consultations.map((c) =>
          c.id == consultation.id ? consultation : c
        ).toList();
        state = AsyncValue.data(updatedList);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteConsultation(int consultationId) async {
    try {
      await _repository.deleteConsultation(consultationId);

      state.whenData((consultations) {
        final updatedList = consultations.where((c) => c.id != consultationId).toList();
        state = AsyncValue.data(updatedList);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final consultationRepositoryProvider = Provider<ConsultationRepository>((ref) {
  return ConsultationRepository();
});

final consultationProvider = StateNotifierProvider<ConsultationNotifier, AsyncValue<List<Consultation>>>((ref) {
  final repository = ref.watch(consultationRepositoryProvider);
  return ConsultationNotifier(repository);
});