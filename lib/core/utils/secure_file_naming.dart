import 'dart:io';
import 'package:path/path.dart' as path;

/// Secure file naming utility with comprehensive path sanitization
class SecureFileNaming {
  // Windows path length limits
  static const int maxFilenameLength = 200;
  static const int maxPathLength = 260;

  // Reserved Windows names
  static const List<String> reservedNames = [
    'CON', 'PRN', 'AUX', 'NUL',
    'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
    'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9',
  ];

  /// Securely sanitize a filename for cross-platform compatibility
  static String sanitizeFileName(String fileName) {
    if (fileName.isEmpty) {
      return _generateDefaultName();
    }

    String cleaned = fileName;

    // 1. Remove/replace dangerous characters
    cleaned = _removeDangerousCharacters(cleaned);

    // 2. Handle reserved names
    cleaned = _handleReservedNames(cleaned);

    // 3. Handle length limits
    cleaned = _handleLengthLimits(cleaned);

    // 4. Ensure valid result
    cleaned = _ensureValidResult(cleaned);

    return cleaned;
  }

  /// Sanitize patient name specifically for folder creation
  static String sanitizePatientName(String patientName) {
    if (patientName.isEmpty) {
      throw ArgumentError('Patient name cannot be empty');
    }

    String cleaned = patientName;

    // 1. Basic sanitization
    cleaned = sanitizeFileName(cleaned);

    // 2. Patient-specific rules
    cleaned = _applyPatientSpecificRules(cleaned);

    // 3. Ensure uniqueness capability (add ID suffix space)
    if (cleaned.length > maxFilenameLength - 10) {
      cleaned = cleaned.substring(0, maxFilenameLength - 10);
    }

    return cleaned;
  }

  /// Validate full path security
  static void validatePath(String fullPath, {String? allowedBasePath}) {
    if (fullPath.isEmpty) {
      throw SecurityException('Path cannot be empty');
    }

    if (fullPath.length > maxPathLength) {
      throw SecurityException('Path too long: ${fullPath.length} chars (max: $maxPathLength)');
    }

    // Check for path traversal attempts
    if (_containsPathTraversal(fullPath)) {
      throw SecurityException('Path traversal detected: $fullPath');
    }

    // Check base path restriction if provided
    if (allowedBasePath != null) {
      final canonicalPath = _getCanonicalPath(fullPath);
      final canonicalBase = _getCanonicalPath(allowedBasePath);

      if (!canonicalPath.startsWith(canonicalBase)) {
        throw SecurityException('Path outside allowed directory: $fullPath');
      }
    }
  }

  /// Generate unique patient folder name with ID fallback
  static String generateUniquePatientFolder(String patientName, int patientId) {
    final baseName = sanitizePatientName(patientName);

    // If name becomes too generic after sanitization, use ID
    if (baseName.length < 3 || baseName.replaceAll('_', '').length < 3) {
      return 'Patient_$patientId';
    }

    // Append ID for uniqueness
    return '${baseName}_$patientId';
  }

  // Private helper methods

  static String _removeDangerousCharacters(String input) {
    return input
        // Remove control characters (0x00-0x1F)
        .replaceAll(RegExp(r'[\x00-\x1F]'), '')
        // Replace Windows forbidden characters
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        // Replace dangerous shell characters
        .replaceAll(RegExp(r'[;&|`$(){}[\]~]'), '_')
        // Replace multiple dots (path traversal prevention)
        .replaceAll(RegExp(r'\.{2,}'), '.')
        // Replace multiple spaces with single space
        .replaceAll(RegExp(r'\s+'), ' ')
        // Remove leading/trailing spaces and dots
        .trim()
        .replaceAll(RegExp(r'^\.+|\.+$'), '');
  }

  static String _handleReservedNames(String input) {
    // Split by extension if present
    final parts = input.split('.');
    final nameWithoutExt = parts.first.toUpperCase();

    if (reservedNames.contains(nameWithoutExt)) {
      return input;
    }

    return input;
  }

  static String _handleLengthLimits(String input) {
    if (input.length <= maxFilenameLength) {
      return input;
    }

    // Try to preserve extension
    final extension = path.extension(input);
    if (extension.isNotEmpty && extension.length < 10) {
      final nameWithoutExt = path.basenameWithoutExtension(input);
      final maxNameLength = maxFilenameLength - extension.length - 3; // -3 for "..."

      return '${nameWithoutExt.substring(0, maxNameLength)}...$extension';
    }

    // No extension or extension too long
    return '${input.substring(0, maxFilenameLength - 3)}...';
  }

  static String _ensureValidResult(String input) {
    if (input.isEmpty || input == '.' || input == '..') {
      return _generateDefaultName();
    }

    // Ensure doesn't end with space or dot (Windows requirement)
    while (input.endsWith(' ') || input.endsWith('.')) {
      input = input.substring(0, input.length - 1);
      if (input.isEmpty) {
        return _generateDefaultName();
      }
    }

    return input;
  }

  static String _applyPatientSpecificRules(String patientName) {
    // Convert to title case for consistency
    return patientName
        .split(' ')
        .map((word) => word.isEmpty ? '' :
             word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  static String _generateDefaultName() {
    return 'Patient_${DateTime.now().millisecondsSinceEpoch}';
  }

  static bool _containsPathTraversal(String path) {
    // Check for various path traversal patterns
    final traversalPatterns = [
      '..',
      '~',
      '\\.\\.',  // Windows
      '/../',    // Unix
      '\\..\\',  // Windows
    ];

    final normalizedPath = path.toLowerCase().replaceAll('\\', '/');

    for (final pattern in traversalPatterns) {
      if (normalizedPath.contains(pattern.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  static String _getCanonicalPath(String inputPath) {
    try {
      return File(inputPath).absolute.path;
    } catch (e) {
      return path.normalize(path.absolute(inputPath));
    }
  }
}

/// Custom exception for security-related path issues
class SecurityException implements Exception {
  final String message;

  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}