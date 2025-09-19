import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_app/data/models/doctor_settings.dart';
import 'package:doctor_app/data/repositories/settings_repository.dart';

class SettingsNotifier extends StateNotifier<AsyncValue<DoctorSettings?>> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final settings = await _repository.loadDoctorSettings();
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSettings(DoctorSettings settings) async {
    try {
      await _repository.saveDoctorSettings(settings);
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> clearSettings() async {
    try {
      await _repository.clearSettings();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<DoctorSettings?>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});