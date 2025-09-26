import 'dart:io';
import 'dart:convert';
import 'package:doctor_app/services/file_organization_service.dart';
import 'package:doctor_app/core/utils/app_logger.dart';

/// Error logger that writes only error logs to a file for support purposes
class ErrorLogger {
  static const String logFileName = 'error_logs.log';
  static const String logsFolderName = 'logs';
  static const int maxLogEntries = 50;

  static File? _logFile;
  static bool _initialized = false;

  /// Initialize the error logger
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final appPath = await FileOrganizationService.getAppDirectoryPath();
      final logsDir = Directory('$appPath/$logsFolderName');

      // Create logs directory if it doesn't exist
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final logFilePath = '${logsDir.path}/$logFileName';
      _logFile = File(logFilePath);

      // Create log file if it doesn't exist
      if (!await _logFile!.exists()) {
        await _logFile!.create(recursive: true);
        await _logFile!.writeAsString('=== Doctor App Error Log ===\n');
        appLogger.i('Error log file created: $logFilePath');
      }

      // Clean old logs on initialization
      await _cleanOldLogs();

      _initialized = true;
      appLogger.d('Error logger initialized successfully');
    } catch (e) {
      appLogger.e('Failed to initialize error logger', error: e);
      // Don't rethrow - app should continue even if logging fails
    }
  }

  /// Log an error to the file
  static Future<void> logError({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    if (!_initialized || _logFile == null) {
      await initialize();
      if (!_initialized || _logFile == null) return;
    }

    try {
      final timestamp = DateTime.now().toIso8601String();

      final logEntry = {
        'timestamp': timestamp,
        'level': 'ERROR',
        'message': message,
        'error': error?.toString(),
        'stackTrace': stackTrace?.toString(),
        'context': context,
      };

      final logLine = '${jsonEncode(logEntry)}\n';

      // Append to log file
      await _logFile!.writeAsString(logLine, mode: FileMode.append);

      // Clean logs if needed (asynchronously)
      _cleanOldLogsIfNeeded();

    } catch (e) {
      appLogger.e('Failed to write error log', error: e);
      // Don't rethrow - logging failures shouldn't crash the app
    }
  }

  /// Clean old logs to keep only the last maxLogEntries
  static Future<void> _cleanOldLogs() async {
    if (_logFile == null || !await _logFile!.exists()) return;

    try {
      final content = await _logFile!.readAsString();
      final lines = content.split('\n');

      // Keep header and last maxLogEntries actual log entries
      final List<String> cleanedLines = [];

      // Add header if exists
      if (lines.isNotEmpty && lines.first.contains('=== Doctor App Error Log ===')) {
        cleanedLines.add(lines.first);
      }

      // Filter actual JSON log entries (skip header and empty lines)
      final logEntries = lines
          .where((line) => line.trim().isNotEmpty && line.startsWith('{'))
          .toList();

      // Keep only the last maxLogEntries
      final entriesToKeep = logEntries.length > maxLogEntries
          ? logEntries.sublist(logEntries.length - maxLogEntries)
          : logEntries;

      cleanedLines.addAll(entriesToKeep);

      // Write cleaned content back
      await _logFile!.writeAsString('${cleanedLines.join('\n')}\n');

      appLogger.d('Error logs cleaned - kept ${entriesToKeep.length} entries');
    } catch (e) {
      appLogger.e('Failed to clean error logs', error: e);
    }
  }

  /// Clean logs if needed (non-blocking)
  static void _cleanOldLogsIfNeeded() {
    // Run cleaning asynchronously without blocking
    Future.microtask(() async {
      try {
        if (_logFile == null || !await _logFile!.exists()) return;

        final content = await _logFile!.readAsString();
        final logLines = content.split('\n')
            .where((line) => line.trim().isNotEmpty && line.startsWith('{'))
            .length;

        if (logLines > maxLogEntries + 10) { // Clean when we have 10+ extra entries
          await _cleanOldLogs();
        }
      } catch (e) {
        // Silently ignore cleanup errors
      }
    });
  }

  /// Get the log file path for support purposes
  static Future<String?> getLogFilePath() async {
    if (!_initialized) await initialize();
    return _logFile?.path;
  }

  /// Read recent error logs (for debugging/support)
  static Future<List<Map<String, dynamic>>> getRecentErrorLogs({int limit = 10}) async {
    if (!_initialized || _logFile == null || !await _logFile!.exists()) {
      return [];
    }

    try {
      final content = await _logFile!.readAsString();
      final lines = content.split('\n')
          .where((line) => line.trim().isNotEmpty && line.startsWith('{'))
          .toList();

      final recentLines = lines.length > limit
          ? lines.sublist(lines.length - limit)
          : lines;

      final List<Map<String, dynamic>> logs = [];
      for (final line in recentLines.reversed) {
        try {
          final logEntry = jsonDecode(line) as Map<String, dynamic>;
          logs.add(logEntry);
        } catch (e) {
          // Skip malformed entries
        }
      }

      return logs;
    } catch (e) {
      appLogger.e('Failed to read error logs', error: e);
      return [];
    }
  }

  /// Get log file size in KB
  static Future<double> getLogFileSize() async {
    if (!_initialized || _logFile == null || !await _logFile!.exists()) {
      return 0.0;
    }

    try {
      final stat = await _logFile!.stat();
      return stat.size / 1024; // Size in KB
    } catch (e) {
      return 0.0;
    }
  }
}