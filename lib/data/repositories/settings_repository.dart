import 'package:shared_preferences/shared_preferences.dart';
import 'package:doctor_app/data/models/doctor_settings.dart';
import 'dart:convert';

class SettingsRepository {
  static const String _settingsKey = 'doctor_settings';

  // Save doctor settings
  Future<void> saveDoctorSettings(DoctorSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = json.encode(settings.toJson());
    await prefs.setString(_settingsKey, settingsJson);
  }

  // Load doctor settings
  Future<DoctorSettings?> loadDoctorSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);

    if (settingsJson != null) {
      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      return DoctorSettings.fromJson(settingsMap);
    }

    return null;
  }

  // Check if settings exist
  Future<bool> hasSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_settingsKey);
  }

  // Clear settings
  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settingsKey);
  }

  // Update specific setting
  Future<void> updateDoctorName(String doctorName) async {
    final settings = await loadDoctorSettings();
    if (settings != null) {
      final updatedSettings = settings.copyWith(doctorName: doctorName);
      await saveDoctorSettings(updatedSettings);
    }
  }

  Future<void> updateSpecialty(String specialty) async {
    final settings = await loadDoctorSettings();
    if (settings != null) {
      final updatedSettings = settings.copyWith(specialty: specialty);
      await saveDoctorSettings(updatedSettings);
    }
  }

  Future<void> updateLogoPath(String logoPath) async {
    final settings = await loadDoctorSettings();
    if (settings != null) {
      final updatedSettings = settings.copyWith(logoPath: logoPath);
      await saveDoctorSettings(updatedSettings);
    }
  }
}