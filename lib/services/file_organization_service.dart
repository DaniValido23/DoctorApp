import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:doctor_app/data/models/patient.dart';
import 'package:doctor_app/core/utils/utils.dart';

class FileOrganizationService {
  static const String appFolderName = 'Doctor App';

  /// Get the main app directory path
  static Future<String> getAppDirectoryPath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return '${documentsDirectory.path}/$appFolderName';
  }

  /// Get patient directory path with secure sanitization
  static Future<String> getPatientDirectoryPath(String patientName, {int? patientId}) async {
    final appPath = await getAppDirectoryPath();

    // Use secure file naming with optional patient ID for uniqueness
    final cleanName = patientId != null
        ? SecureFileNaming.generateUniquePatientFolder(patientName, patientId)
        : SecureFileNaming.sanitizePatientName(patientName);

    final fullPath = '$appPath/$cleanName';

    // Validate path security before returning
    SecureFileNaming.validatePath(fullPath, allowedBasePath: appPath);

    return fullPath;
  }

  /// Initialize app folder structure on startup
  static Future<void> initializeAppFolder() async {
    try {
      final appPath = await getAppDirectoryPath();
      final appDirectory = Directory(appPath);

      // Create app folder if it doesn't exist, or recreate if it exists
      if (await appDirectory.exists()) {
        // If folder exists, we keep it (don't delete existing patient data)
        appLogger.d('App folder already exists at: $appPath');
      } else {
        await appDirectory.create(recursive: true);
        appLogger.i('App folder created at: $appPath');
      }
    } catch (e) {
      appLogger.e('Error initializing app folder', error: e);
      rethrow;
    }
  }

  /// Create patient folder
  static Future<String> createPatientFolder(Patient patient) async {
    try {
      final patientPath = await getPatientDirectoryPath(patient.name, patientId: patient.id);
      final patientDirectory = Directory(patientPath);

      // Create patient folder if it doesn't exist, or recreate if it exists
      if (await patientDirectory.exists()) {
        // If folder exists, we keep it (don't delete existing files)
        appLogger.d('Patient folder already exists at: $patientPath');
      } else {
        await patientDirectory.create(recursive: true);
        appLogger.i('Patient folder created at: $patientPath');
      }

      return patientPath;
    } catch (e) {
      appLogger.e('Error creating patient folder for ${patient.name}', error: e);
      rethrow;
    }
  }

  /// Delete patient folder and all its contents
  static Future<void> deletePatientFolder(Patient patient) async {
    try {
      final patientPath = await getPatientDirectoryPath(patient.name, patientId: patient.id);
      final patientDirectory = Directory(patientPath);

      if (await patientDirectory.exists()) {
        await patientDirectory.delete(recursive: true);
        appLogger.i('Patient folder deleted: $patientPath');
      } else {
        appLogger.w('Patient folder does not exist: $patientPath');
      }
    } catch (e) {
      appLogger.e('Error deleting patient folder for ${patient.name}', error: e);
      rethrow;
    }
  }

  /// Get consultation directory path
  static Future<String> getConsultationDirectoryPath(Patient patient, DateTime consultationDate) async {
    final patientPath = await getPatientDirectoryPath(patient.name, patientId: patient.id);
    final dateStr = _formatDateForFolder(consultationDate);
    return '$patientPath/$dateStr';
  }

  /// Create consultation folder
  static Future<String> createConsultationFolder(Patient patient, DateTime consultationDate) async {
    try {
      // Ensure patient folder exists first
      await createPatientFolder(patient);

      final consultationPath = await getConsultationDirectoryPath(patient, consultationDate);
      final consultationDirectory = Directory(consultationPath);

      if (!await consultationDirectory.exists()) {
        await consultationDirectory.create(recursive: true);
        appLogger.i('Consultation folder created at: $consultationPath');
      } else {
        appLogger.d('Consultation folder already exists at: $consultationPath');
      }

      return consultationPath;
    } catch (e) {
      appLogger.e('Error creating consultation folder for ${patient.name} on $consultationDate', error: e);
      rethrow;
    }
  }

  /// Get file path for saving files in consultation folder
  static Future<String> getConsultationFilePath(Patient patient, DateTime consultationDate, String fileName) async {
    final consultationPath = await createConsultationFolder(patient, consultationDate);
    return '$consultationPath/$fileName';
  }

  /// Get file path for saving files in patient folder (deprecated - use consultation folder instead)
  @Deprecated('Use getConsultationFilePath instead for better organization')
  static Future<String> getPatientFilePath(Patient patient, String fileName) async {
    final patientPath = await getPatientDirectoryPath(patient.name, patientId: patient.id);
    // Ensure patient folder exists before returning file path
    await createPatientFolder(patient);
    return '$patientPath/$fileName';
  }

  /// Format date for folder naming (DD-MM-YYYY)
  static String _formatDateForFolder(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }


  /// Generate PDF file name for consultation with secure naming
  static String generateConsultationPDFName(Patient patient, DateTime consultationDate) {
    final dateStr = '${consultationDate.year}-${consultationDate.month.toString().padLeft(2, '0')}-${consultationDate.day.toString().padLeft(2, '0')}';
    final timeStr = '${consultationDate.hour.toString().padLeft(2, '0')}-${consultationDate.minute.toString().padLeft(2, '0')}';

    // Use secure naming for patient name component
    final safeName = SecureFileNaming.sanitizeFileName(patient.name);
    final fileName = 'Receta_${safeName}_${dateStr}_$timeStr.pdf';

    // Apply final sanitization to entire filename
    return SecureFileNaming.sanitizeFileName(fileName);
  }

  /// Get all files in patient folder
  static Future<List<File>> getPatientFiles(Patient patient) async {
    try {
      final patientPath = await getPatientDirectoryPath(patient.name, patientId: patient.id);
      final patientDirectory = Directory(patientPath);

      if (!await patientDirectory.exists()) {
        return [];
      }

      final entities = await patientDirectory.list().toList();
      return entities.whereType<File>().toList();
    } catch (e) {
      appLogger.e('Error getting patient files for ${patient.name}', error: e);
      return [];
    }
  }

  /// Copy file to consultation folder
  static Future<String> copyFileToConsultationFolder(Patient patient, DateTime consultationDate, String sourceFilePath) async {
    try {
      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: $sourceFilePath');
      }

      final fileName = sourceFile.path.split(Platform.pathSeparator).last;
      final destinationPath = await getConsultationFilePath(patient, consultationDate, fileName);

      await sourceFile.copy(destinationPath);
      appLogger.i('File copied to consultation folder: $destinationPath');

      return destinationPath;
    } catch (e) {
      appLogger.e('Error copying file to consultation folder', error: e);
      rethrow;
    }
  }

  /// Copy file to patient folder (deprecated - use consultation folder instead)
  @Deprecated('Use copyFileToConsultationFolder instead for better organization')
  static Future<String> copyFileToPatientFolder(Patient patient, String sourceFilePath) async {
    try {
      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: $sourceFilePath');
      }

      final fileName = sourceFile.path.split(Platform.pathSeparator).last;
      final destinationPath = await getPatientFilePath(patient, fileName);

      await sourceFile.copy(destinationPath);
      appLogger.i('File copied to patient folder: $destinationPath');

      return destinationPath;
    } catch (e) {
      appLogger.e('Error copying file to patient folder', error: e);
      rethrow;
    }
  }

  /// Get all consultation folders for a patient
  static Future<List<Directory>> getPatientConsultationFolders(Patient patient) async {
    try {
      final patientPath = await getPatientDirectoryPath(patient.name, patientId: patient.id);
      final patientDirectory = Directory(patientPath);

      if (!await patientDirectory.exists()) {
        return [];
      }

      final entities = await patientDirectory.list().toList();
      return entities.whereType<Directory>().toList();
    } catch (e) {
      appLogger.e('Error getting consultation folders for ${patient.name}', error: e);
      return [];
    }
  }

  /// Get all files in consultation folder
  static Future<List<File>> getConsultationFiles(Patient patient, DateTime consultationDate) async {
    try {
      final consultationPath = await getConsultationDirectoryPath(patient, consultationDate);
      final consultationDirectory = Directory(consultationPath);

      if (!await consultationDirectory.exists()) {
        return [];
      }

      final entities = await consultationDirectory.list().toList();
      return entities.whereType<File>().toList();
    } catch (e) {
      appLogger.e('Error getting consultation files for ${patient.name} on $consultationDate', error: e);
      return [];
    }
  }
}