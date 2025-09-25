import 'package:logger/logger.dart';

/// Logger global de la aplicación
///
/// Uso:
/// - appLogger.d('Debug message');
/// - appLogger.i('Info message');
/// - appLogger.w('Warning message');
/// - appLogger.e('Error message');
final Logger appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 2, // Número de métodos a mostrar en el stack trace
    errorMethodCount: 8, // Número de métodos a mostrar para errores
    lineLength: 120, // Ancho de línea
    colors: true, // Usar colores en consola
    printEmojis: true, // Usar emojis
    dateTimeFormat: DateTimeFormat.none, // No mostrar timestamp (Flutter ya lo hace)
  ),
);