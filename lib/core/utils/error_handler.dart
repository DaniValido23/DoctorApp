import 'package:flutter/material.dart';
import 'package:doctor_app/services/file_organization_service.dart';
import 'package:doctor_app/core/utils/utils.dart';

/// Centralized error handling utility for the application
class ErrorHandler {

  /// Handle file operation errors and show appropriate user messages
  static void handleFileError(BuildContext context, dynamic error) {
    String userMessage;

    if (error is FileSizeException) {
      userMessage = error.message;
    } else if (error is DiskSpaceException) {
      userMessage = error.message;
    } else if (error is FileSystemException) {
      userMessage = error.message;
    } else if (error.toString().contains('No space left') ||
               error.toString().contains('not enough space') ||
               error.toString().contains('disk full')) {
      userMessage = 'No hay suficiente espacio en disco para guardar el archivo. '
                   'Libere espacio e intente nuevamente.';
    } else if (error.toString().contains('permission') ||
               error.toString().contains('access denied')) {
      userMessage = 'No se tienen permisos para acceder a esta ubicación. '
                   'Verifique los permisos de la carpeta.';
    } else {
      userMessage = 'Error al procesar el archivo. Intente nuevamente.';
      appLogger.e('Unhandled file error', error: error);
    }

    // Log error to file
    ErrorLogger.logError(
      message: 'File operation error: $userMessage',
      error: error,
      context: {'errorType': 'file_operation', 'userMessage': userMessage},
    );

    _showErrorSnackBar(context, userMessage, isFileError: true);
  }

  /// Handle general application errors
  static void handleGeneralError(BuildContext context, dynamic error, {String? customMessage}) {
    String userMessage = customMessage ?? 'Ha ocurrido un error inesperado. Intente nuevamente.';

    // Log the actual error for debugging
    appLogger.e('General application error', error: error);

    // Log error to file
    ErrorLogger.logError(
      message: 'General application error: $userMessage',
      error: error,
      context: {'errorType': 'general', 'userMessage': userMessage},
    );

    _showErrorSnackBar(context, userMessage, isFileError: false);
  }

  /// Handle database operation errors
  static void handleDatabaseError(BuildContext context, dynamic error) {
    String userMessage;

    if (error.toString().contains('database is locked')) {
      userMessage = 'La base de datos está ocupada. Intente nuevamente en un momento.';
    } else if (error.toString().contains('constraint')) {
      userMessage = 'Error de validación de datos. Verifique la información ingresada.';
    } else {
      userMessage = 'Error al acceder a los datos. Intente nuevamente.';
    }

    appLogger.e('Database error', error: error);

    // Log error to file
    ErrorLogger.logError(
      message: 'Database error: $userMessage',
      error: error,
      context: {'errorType': 'database', 'userMessage': userMessage},
    );

    _showErrorSnackBar(context, userMessage, isFileError: false);
  }

  /// Handle PDF generation/save errors
  static void handlePdfError(BuildContext context, dynamic error) {
    String userMessage;

    if (error is DiskSpaceException) {
      userMessage = error.message;
    } else if (error.toString().contains('space')) {
      userMessage = 'No hay suficiente espacio para generar el PDF. '
                   'Libere espacio e intente nuevamente.';
    } else {
      userMessage = 'Error al generar el PDF. Verifique que tenga permisos de escritura.';
    }

    appLogger.e('PDF generation error', error: error);

    // Log error to file
    ErrorLogger.logError(
      message: 'PDF generation error: $userMessage',
      error: error,
      context: {'errorType': 'pdf', 'userMessage': userMessage},
    );

    _showErrorSnackBar(context, userMessage, isFileError: true);
  }

  /// Show error snackbar with appropriate styling
  static void _showErrorSnackBar(BuildContext context, String message, {required bool isFileError}) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isFileError ? Icons.folder_open : Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: Duration(seconds: isFileError ? 5 : 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success message
  static void showSuccessMessage(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}