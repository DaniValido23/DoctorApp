import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:doctor_app/data/models/patient.dart';
import 'package:doctor_app/core/utils/utils.dart';

class FileOrganizationService {
  static const String appFolderName = 'Doctor App';

  // File size limits in bytes
  static const int maxFileSizeBytes = 50 * 1024 * 1024; // 50 MB
  static const int maxFileSizeMB = 50;

  /// Get the main app directory path
  static Future<String> getAppDirectoryPath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return '${documentsDirectory.path}/$appFolderName';
  }

  /// Get patient directory path with secure sanitization
  static Future<String> getPatientDirectoryPath(String patientName) async {
    final appPath = await getAppDirectoryPath();

    // Use secure file naming (no ID needed since names are unique)
    final cleanName = SecureFileNaming.sanitizePatientName(patientName);

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

      // Create app folder if it doesn't exist
      if (await appDirectory.exists()) {
        appLogger.d('App folder already exists at: $appPath');

        // Verify folder structure integrity
        await _verifyFolderStructure(appPath);
      } else {
        await appDirectory.create(recursive: true);
        appLogger.i('App folder created at: $appPath');
      }
    } catch (e) {
      appLogger.e('Error initializing app folder', error: e);
      rethrow;
    }
  }

  /// Initialize patient folders for existing patients in database
  static Future<void> initializeExistingPatientFolders(List<Patient> patients) async {
    try {
      appLogger.d('Initializing folders for ${patients.length} existing patients');

      for (final patient in patients) {
        try {
          await createPatientFolder(patient);
        } catch (e) {
          appLogger.w('Failed to create folder for patient ${patient.name}: $e');
          // Continue with other patients even if one fails
        }
      }

      appLogger.i('Completed patient folder initialization');
    } catch (e) {
      appLogger.e('Error during patient folder initialization', error: e);
      // Don't rethrow - app should continue even if folder creation fails
    }
  }

  /// Verify and repair folder structure integrity
  static Future<void> _verifyFolderStructure(String appPath) async {
    try {

      // Check if app directory is accessible and readable
      appLogger.d('App folder structure verified successfully');

    } catch (e) {
      appLogger.w('Issue with folder structure, attempting repair: $e');
      try {
        // Attempt to recreate the directory if there are permission issues
        final appDir = Directory(appPath);
        await appDir.create(recursive: true);
        appLogger.i('Folder structure repaired successfully');
      } catch (repairError) {
        appLogger.e('Failed to repair folder structure: $repairError');
        rethrow;
      }
    }
  }

  /// Create patient folder
  static Future<String> createPatientFolder(Patient patient) async {
    try {
      final patientPath = await getPatientDirectoryPath(patient.name);
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
      final patientPath = await getPatientDirectoryPath(patient.name);
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
    final patientPath = await getPatientDirectoryPath(patient.name);
    final folderName = await _generateConsultationFolderName(patient, consultationDate);
    return '$patientPath/$folderName';
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
    final patientPath = await getPatientDirectoryPath(patient.name);
    // Ensure patient folder exists before returning file path
    await createPatientFolder(patient);
    return '$patientPath/$fileName';
  }

  /// Format date and time for folder naming (DD_MM_YYYY_HH_MM)
  static String _formatDateTimeForFolder(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}_'
        '${date.month.toString().padLeft(2, '0')}_'
        '${date.year}_'
        '${date.hour.toString().padLeft(2, '0')}_'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  /// Generate consultation folder name with date and time (DD_MM_YYYY_HH_MM)
  static Future<String> _generateConsultationFolderName(Patient patient, DateTime consultationDate) async {
    // Simply return the formatted date-time string - no need to check for duplicates
    // since each consultation will have a unique timestamp
    return _formatDateTimeForFolder(consultationDate);
  }


  /// Generate PDF file name for consultation with secure naming
  static String generateConsultationPDFName(Patient patient, DateTime consultationDate) {
    final dateStr = '${consultationDate.year}-${consultationDate.month.toString().padLeft(2, '0')}-${consultationDate.day.toString().padLeft(2, '0')}';

    // Use secure naming for patient name component
    final safeName = SecureFileNaming.sanitizeFileName(patient.name);
    final fileName = 'Receta_${safeName}_$dateStr.pdf';

    // Apply final sanitization to entire filename
    return SecureFileNaming.sanitizeFileName(fileName);
  }

  /// Get all files in patient folder
  static Future<List<File>> getPatientFiles(Patient patient) async {
    try {
      final patientPath = await getPatientDirectoryPath(patient.name);
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

  /// Check available disk space in the destination directory
  static Future<void> validateDiskSpace(String filePath, String destinationDir) async {
    try {
      final file = File(filePath);
      final fileSizeBytes = await file.length();


      // For cross-platform compatibility, we'll use a more basic approach
      // Try to create a temporary file to test write permissions and space
      final tempFile = File('$destinationDir/temp_space_check_${DateTime.now().millisecondsSinceEpoch}');

      // Check if we can write to the destination
      try {
        await tempFile.writeAsString('test');
        await tempFile.delete();
      } catch (e) {
        if (e.toString().contains('No space left') ||
            e.toString().contains('not enough space') ||
            e.toString().contains('disk full') ||
            e.toString().toLowerCase().contains('space')) {
          throw DiskSpaceException(
            'No hay suficiente espacio en disco para guardar el archivo. '
            'Libere espacio e intente nuevamente.'
          );
        }
        throw FileSystemException(
          'No se puede escribir en la carpeta de destino. Verifique los permisos.',
          e.toString()
        );
      }

      appLogger.d('Disk space validation passed for file size: ${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB');
    } catch (e) {
      if (e is DiskSpaceException || e is FileSystemException) {
        rethrow;
      }
      appLogger.e('Error validating disk space', error: e);
      throw FileSystemException(
        'Error al verificar el espacio disponible en disco.',
        e.toString()
      );
    }
  }

  /// Validate file size before processing
  static Future<void> validateFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      final fileSizeBytes = await file.length();

      if (fileSizeBytes > maxFileSizeBytes) {
        final fileSizeMB = (fileSizeBytes / (1024 * 1024)).toStringAsFixed(1);
        throw FileSizeException(
          'El archivo es demasiado grande: ${fileSizeMB}MB. '
          'El límite máximo es ${maxFileSizeMB}MB.'
        );
      }

      appLogger.d('File size validated: ${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB');
    } catch (e) {
      if (e is FileSizeException) {
        rethrow;
      }
      appLogger.e('Error validating file size for: $filePath', error: e);
      rethrow;
    }
  }

  /// Copy file to consultation folder
  static Future<String> copyFileToConsultationFolder(Patient patient, DateTime consultationDate, String sourceFilePath) async {
    try {
      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: $sourceFilePath');
      }

      // Validate file size before copying
      await validateFileSize(sourceFilePath);

      final fileName = sourceFile.path.split(Platform.pathSeparator).last;
      final destinationPath = await getConsultationFilePath(patient, consultationDate, fileName);
      final destinationDir = destinationPath.substring(0, destinationPath.lastIndexOf(Platform.pathSeparator));

      // Validate disk space before copying
      await validateDiskSpace(sourceFilePath, destinationDir);

      try {
        await sourceFile.copy(destinationPath);
        appLogger.i('File copied to consultation folder: $destinationPath');
        return destinationPath;
      } catch (e) {
        // Catch specific disk space and file system errors during copy
        if (e.toString().contains('No space left') ||
            e.toString().contains('not enough space') ||
            e.toString().contains('disk full') ||
            e.toString().toLowerCase().contains('space')) {
          throw DiskSpaceException(
            'No hay suficiente espacio en disco para guardar el archivo. '
            'Libere espacio e intente nuevamente.'
          );
        }

        if (e.toString().contains('permission') ||
            e.toString().contains('access') ||
            e.toString().contains('denied')) {
          throw FileSystemException(
            'No se tienen permisos para guardar el archivo en esta ubicación.',
            e.toString()
          );
        }

        throw FileSystemException(
          'Error al guardar el archivo. Intente nuevamente.',
          e.toString()
        );
      }
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
      final patientPath = await getPatientDirectoryPath(patient.name);
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

  /// Verify if a file exists at the given path
  static Future<bool> verifyFileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      appLogger.w('Error verifying file existence: $filePath - $e');
      return false;
    }
  }

  /// Get missing files from a list of file paths
  static Future<List<String>> getMissingFiles(List<String> filePaths) async {
    final List<String> missingFiles = [];

    for (final filePath in filePaths) {
      if (!await verifyFileExists(filePath)) {
        missingFiles.add(filePath);
        appLogger.w('Missing file detected: $filePath');
      }
    }

    return missingFiles;
  }

  /// Rename patient folder when patient name is updated
  static Future<void> renamePatientFolder(Patient oldPatient, Patient updatedPatient) async {
    try {
      // Skip if name hasn't changed
      if (oldPatient.name == updatedPatient.name) {
        return;
      }

      final oldPatientPath = await getPatientDirectoryPath(oldPatient.name);
      final newPatientPath = await getPatientDirectoryPath(updatedPatient.name);

      final oldDirectory = Directory(oldPatientPath);
      final newDirectory = Directory(newPatientPath);

      // Check if old directory exists
      if (!await oldDirectory.exists()) {
        appLogger.w('Old patient folder does not exist: $oldPatientPath');
        // Create new folder for updated patient
        await createPatientFolder(updatedPatient);
        return;
      }

      // Check if new directory already exists (shouldn't happen since names are unique)
      if (await newDirectory.exists()) {
        appLogger.w('New patient folder already exists: $newPatientPath');
        throw Exception('Destination folder already exists - patient name might be duplicated');
      }

      // Rename the directory
      await oldDirectory.rename(newPatientPath);
      appLogger.i('Patient folder renamed from: $oldPatientPath to: $newPatientPath');

    } catch (e) {
      appLogger.e('Error renaming patient folder from ${oldPatient.name} to ${updatedPatient.name}', error: e);

      // Fallback: create new folder if rename fails
      try {
        await createPatientFolder(updatedPatient);
        appLogger.w('Created new folder as fallback after rename failure');
      } catch (fallbackError) {
        appLogger.e('Fallback folder creation also failed', error: fallbackError);
        rethrow;
      }
    }
  }
}

/// Custom exception for file size validation errors
class FileSizeException implements Exception {
  final String message;

  FileSizeException(this.message);

  @override
  String toString() => 'FileSizeException: $message';
}

/// Custom exception for disk space errors
class DiskSpaceException implements Exception {
  final String message;

  DiskSpaceException(this.message);

  @override
  String toString() => 'DiskSpaceException: $message';
}

/// Custom exception for file system errors
class FileSystemException implements Exception {
  final String message;
  final String originalError;

  FileSystemException(this.message, this.originalError);

  @override
  String toString() => 'FileSystemException: $message';
}