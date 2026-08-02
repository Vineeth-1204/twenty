import 'package:flutter_test/flutter_test.dart';
import 'package:secure_vault/services/security_service.dart';

void main() {
  group('SecurityService Tests', () {
    test('Derives key and hashes PIN consistently', () {
      final salt = SecurityService.generateSalt();
      final pin = '1234';

      final hash1 = SecurityService.hashPin(pin, salt);
      final hash2 = SecurityService.hashPin(pin, salt);

      expect(hash1, equals(hash2));
      expect(hash1.isNotEmpty, isTrue);
    });

    test('Encryption and Decryption roundtrip succeeds with correct key', () {
      final salt = SecurityService.generateSalt();
      final masterKey = SecurityService.deriveKey('4321', salt);
      const plaintext = 'SuperSecretP@ssw0rd!2026';

      final encryptedJson = SecurityService.encryptText(plaintext, masterKey);
      expect(encryptedJson, isNot(equals(plaintext)));

      final decrypted = SecurityService.decryptText(encryptedJson, masterKey);
      expect(decrypted, equals(plaintext));
    });

    test('Decryption fails with incorrect key', () {
      final salt1 = SecurityService.generateSalt();
      final key1 = SecurityService.deriveKey('1111', salt1);
      final key2 = SecurityService.deriveKey('2222', salt1);

      const plaintext = 'TopSecretNote';
      final encryptedJson = SecurityService.encryptText(plaintext, key1);

      final decrypted = SecurityService.decryptText(encryptedJson, key2);
      expect(decrypted, equals('[Decryption Failed]'));
    });

    test('Password Generator produces correct length and charsets', () {
      final pwd = SecurityService.generatePassword(
        length: 24,
        includeUppercase: true,
        includeLowercase: true,
        includeNumbers: true,
        includeSymbols: true,
      );

      expect(pwd.length, equals(24));
      expect(pwd.contains(RegExp(r'[A-Z]')), isTrue);
      expect(pwd.contains(RegExp(r'[a-z]')), isTrue);
      expect(pwd.contains(RegExp(r'[0-9]')), isTrue);
    });

    test('Evaluates password strength correctly', () {
      final weakResult = SecurityService.evaluatePasswordStrength('123456');
      expect((weakResult['score'] as double) < 0.5, isTrue);

      final strongResult = SecurityService.evaluatePasswordStrength(r'K9#mX2$pL7!vN4@w');
      expect((strongResult['score'] as double) >= 0.85, isTrue);
    });
  });
}
