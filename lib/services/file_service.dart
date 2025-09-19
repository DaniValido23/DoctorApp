import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class FileService {
  /// Get the application documents directory
  Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Get the application support directory
  Future<Directory> getSupportDirectory() async {
    return await getApplicationSupportDirectory();
  }

  /// Save bytes to a file
  Future<String> saveFile(String fileName, Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Read bytes from a file
  Future<Uint8List?> readFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      // Error reading file: $e
      return null;
    }
  }

  /// Check if a file exists
  Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  /// Delete a file
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      // Error deleting file: $e
      return false;
    }
  }

  /// Pick a file using file picker
  Future<File?> pickFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          return File(path);
        }
      }
      return null;
    } catch (e) {
      // Error picking file: $e
      return null;
    }
  }

  /// Pick multiple files
  Future<List<File>> pickMultipleFiles({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
      }
      return [];
    } catch (e) {
      // Error picking files: $e
      return [];
    }
  }

  /// Copy a file to application directory
  Future<String?> copyFileToAppDirectory(String sourcePath, String fileName) async {
    try {
      final source = File(sourcePath);
      if (!await source.exists()) {
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final destinationPath = '${directory.path}/$fileName';
      final destination = File(destinationPath);

      await source.copy(destinationPath);
      return destination.path;
    } catch (e) {
      // Error copying file: $e
      return null;
    }
  }

  /// Get file size in bytes
  Future<int?> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      // Error getting file size: $e
      return null;
    }
  }

  /// Get file extension
  String? getFileExtension(String filePath) {
    try {
      return filePath.split('.').last.toLowerCase();
    } catch (e) {
      return null;
    }
  }

  /// Format file size for display
  String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }
}