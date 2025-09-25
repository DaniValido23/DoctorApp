import 'package:flutter_test/flutter_test.dart';
import 'package:doctor_app/core/utils/secure_file_naming.dart';

void main() {
  group('SecureFileNaming Tests', () {
    test('sanitizes basic patient names correctly', () {
      // Normal cases
      expect(SecureFileNaming.sanitizePatientName('Juan Perez'), 'Juan Perez');
      expect(SecureFileNaming.sanitizePatientName('María José'), 'María José');

      // Special characters
      expect(SecureFileNaming.sanitizePatientName('José/María'), 'José_maría');
      expect(SecureFileNaming.sanitizePatientName('Dr. O\'Connor'), 'Dr. O\'connor');
    });

    test('handles dangerous characters', () {
      // Windows forbidden characters
      expect(SecureFileNaming.sanitizeFileName('file<>:"/\\|?*name'), 'file_________name');

      // Path traversal attempts
      expect(SecureFileNaming.sanitizeFileName('../../etc/passwd'), '_._etc_passwd');
      expect(SecureFileNaming.sanitizeFileName('..\\windows\\system32'), '_windows_system32');
    });

    test('handles reserved Windows names', () {
      expect(SecureFileNaming.sanitizeFileName('CON'), 'Safe_CON');
      expect(SecureFileNaming.sanitizeFileName('PRN.txt'), 'Safe_PRN.txt');
      expect(SecureFileNaming.sanitizeFileName('AUX'), 'Safe_AUX');
      expect(SecureFileNaming.sanitizeFileName('con'), 'Safe_con');
    });

    test('handles very long names', () {
      final longName = 'A' * 300;
      final result = SecureFileNaming.sanitizeFileName(longName);

      expect(result.length, lessThanOrEqualTo(SecureFileNaming.maxFilenameLength));
      // For long names without extension, it gets truncated
      expect(result.length, greaterThan(0));
    });

    test('generates unique patient folders', () {
      final result1 = SecureFileNaming.generateUniquePatientFolder('Juan Perez', 123);
      final result2 = SecureFileNaming.generateUniquePatientFolder('Juan Perez', 456);

      expect(result1, contains('_123'));
      expect(result2, contains('_456'));
      expect(result1, isNot(equals(result2)));
    });

    test('validates path security', () {
      // Should not throw for valid paths
      expect(() => SecureFileNaming.validatePath('/valid/path/file.txt'),
             returnsNormally);

      // Should throw for dangerous paths
      expect(() => SecureFileNaming.validatePath('../../../etc/passwd'),
             throwsA(isA<SecurityException>()));

      expect(() => SecureFileNaming.validatePath('path/with/../traversal'),
             throwsA(isA<SecurityException>()));
    });

    test('handles empty and null inputs', () {
      expect(() => SecureFileNaming.sanitizePatientName(''),
             throwsA(isA<ArgumentError>()));

      expect(SecureFileNaming.sanitizeFileName(''),
             matches(RegExp(r'Patient_\d+')));
    });

    test('preserves extensions correctly', () {
      final longNameWithExt = '${'A' * 300}.pdf';
      final result = SecureFileNaming.sanitizeFileName(longNameWithExt);

      expect(result.endsWith('.pdf'), true);
      expect(result.contains('...'), true);
      expect(result.length, lessThanOrEqualTo(SecureFileNaming.maxFilenameLength));
    });
  });
}