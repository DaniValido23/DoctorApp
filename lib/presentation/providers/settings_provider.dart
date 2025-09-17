import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_app/data/models/doctor_settings.dart';

class SettingsNotifier extends StateNotifier<DoctorSettings?> {
  SettingsNotifier() : super(null);

  void updateSettings(DoctorSettings settings) {
    state = settings;
  }

  void clearSettings() {
    state = null;
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, DoctorSettings?>(
  (ref) => SettingsNotifier(),
);