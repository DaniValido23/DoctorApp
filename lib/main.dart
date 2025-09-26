import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_app/app/app.dart';
import 'package:doctor_app/services/file_organization_service.dart';
import 'package:doctor_app/core/utils/utils.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // Ensure that plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize app folder structure
  try {
    await FileOrganizationService.initializeAppFolder();
  } catch (e) {
    // Log error but continue app startup
    appLogger.e('Error initializing app folder structure', error: e);
  }

  // Initialize error logging
  try {
    await ErrorLogger.initialize();
  } catch (e) {
    // Log error but continue app startup
    appLogger.e('Error initializing error logger', error: e);
  }

  runApp(
    const ProviderScope(
      child: DoctorApp(),
    ),
  );
}
