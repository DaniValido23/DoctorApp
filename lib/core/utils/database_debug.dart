import 'package:doctor_app/data/database/database_helper.dart';

class DatabaseDebug {
  /// Elimina y recrea la base de datos - SOLO PARA DESARROLLO
  static Future<void> resetDatabase() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteDatabase();
    // La próxima llamada a database recreará todas las tablas
    await dbHelper.database;
  }
}