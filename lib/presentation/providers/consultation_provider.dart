import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_app/data/models/models.dart';
import 'package:doctor_app/data/repositories/repositories.dart';
import 'package:doctor_app/services/file_organization_service.dart';
import 'package:doctor_app/core/utils/utils.dart';
import 'dart:io';

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
      // Get consultation data before deleting from database
      final consultation = await _repository.getConsultationById(consultationId);

      // Delete from database first
      await _repository.deleteConsultation(consultationId);

      // Delete consultation folder if consultation exists
      if (consultation != null) {
        await _deleteConsultationFolder(consultation);
      }

      state.whenData((consultations) {
        final updatedList = consultations.where((c) => c.id != consultationId).toList();
        state = AsyncValue.data(updatedList);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Delete consultation folder and all its contents
  Future<void> _deleteConsultationFolder(Consultation consultation) async {
    try {
      final patient = await PatientRepository().getPatientById(consultation.patientId);
      if (patient == null) {
        appLogger.w('Patient not found for consultation ${consultation.id}, cannot delete folder');
        return;
      }

      final consultationPath = await FileOrganizationService.getConsultationDirectoryPath(
        patient,
        consultation.date
      );

      final consultationDirectory = Directory(consultationPath);

      if (await consultationDirectory.exists()) {
        await consultationDirectory.delete(recursive: true);
        appLogger.i('Consultation folder deleted: $consultationPath');
      } else {
        appLogger.w('Consultation folder does not exist: $consultationPath');
      }
    } catch (e) {
      appLogger.e('Error deleting consultation folder for consultation ${consultation.id}', error: e);
      // Don't rethrow - folder deletion failure shouldn't prevent consultation deletion
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