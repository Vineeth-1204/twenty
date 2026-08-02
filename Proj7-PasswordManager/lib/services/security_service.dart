import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:pointycastle/api.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

class SecurityService {
  static const int _pbkdf2Iterations = 100000;
  static const int _keyLength = 32; // 256 bits

  /// Generates a cryptographically secure random 16-byte salt as base64.
  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// Derives a 256-bit Key from PIN and Salt using PBKDF2-HMAC-SHA256.
  static Uint8List deriveKey(String pin, String saltBase64) {
    final saltBytes = base64.decode(saltBase64);
    final pinBytes = utf8.encode(pin);

    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(Uint8List.fromList(saltBytes), _pbkdf2Iterations, _keyLength));

    return pbkdf2.process(Uint8List.fromList(pinBytes));
  }

  /// Hashes PIN for verification using PBKDF2 + SHA256 digest.
  static String hashPin(String pin, String saltBase64) {
    final derivedKey = deriveKey(pin, saltBase64);
    final hmac = HMac(SHA256Digest(), 64)..init(KeyParameter(derivedKey));
    final digest = hmac.process(Uint8List.fromList(utf8.encode('PIN_VERIFY_TOKEN')));
    return base64.encode(digest);
  }

  /// Encrypts plaintext string using AES-256 with CBC & PKCS7 padding.
  /// Returns a JSON string containing the ciphertext and IV.
  static String encryptText(String plaintext, Uint8List masterKey) {
    if (plaintext.isEmpty) return '';
    final key = encrypt_pkg.Key(masterKey);
    final iv = encrypt_pkg.IV.fromSecureRandom(16);
    final encrypter = encrypt_pkg.Encrypter(
      encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc),
    );

    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return jsonEncode({
      'ct': encrypted.base64,
      'iv': iv.base64,
    });
  }

  /// Decrypts encrypted payload using masterKey.
  static String decryptText(String encryptedJson, Uint8List masterKey) {
    if (encryptedJson.isEmpty) return '';
    try {
      final map = jsonDecode(encryptedJson) as Map<String, dynamic>;
      final ct = map['ct'] as String;
      final ivBase64 = map['iv'] as String;

      final key = encrypt_pkg.Key(masterKey);
      final iv = encrypt_pkg.IV.fromBase64(ivBase64);
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(key, mode: encrypt_pkg.AESMode.cbc),
      );

      return encrypter.decrypt(encrypt_pkg.Encrypted.fromBase64(ct), iv: iv);
    } catch (e) {
      return '[Decryption Failed]';
    }
  }

  /// Password Strength Evaluator (0 to 100).
  /// Returns map with score, label, color, feedback.
  static Map<String, dynamic> evaluatePasswordStrength(String password) {
    if (password.isEmpty) {
      return {
        'score': 0.0,
        'label': 'Empty',
        'entropy': 0,
        'feedback': ['Password cannot be empty.'],
      };
    }

    int score = 0;
    final feedback = <String>[];

    // Length checks
    if (password.length >= 8) score += 15;
    if (password.length >= 12) score += 20;
    if (password.length >= 16) score += 15;

    // Character diversity
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (hasLower) score += 10;
    if (hasUpper) score += 10;
    if (hasDigits) score += 15;
    if (hasSpecial) score += 15;

    // Deduct for sequential / repeated patterns
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) {
      score -= 10;
      feedback.add('Avoid repeating characters (e.g. "aaa").');
    }
    if (RegExp(r'(1234|abcd|qwerty|password|admin|123456)', caseSensitive: false).hasMatch(password)) {
      score -= 25;
      feedback.add('Avoid common predictable patterns or dictionary words.');
    }

    if (!hasUpper) feedback.add('Add uppercase letters (A-Z).');
    if (!hasLower) feedback.add('Add lowercase letters (a-z).');
    if (!hasDigits) feedback.add('Add numbers (0-9).');
    if (!hasSpecial) feedback.add('Add special symbols (!@#\$...).');
    if (password.length < 12) feedback.add('Make password at least 12 characters.');

    final normalizedScore = (score.clamp(0, 100)) / 100.0;

    String label;
    if (normalizedScore < 0.3) {
      label = 'Very Weak';
    } else if (normalizedScore < 0.5) {
      label = 'Weak';
    } else if (normalizedScore < 0.75) {
      label = 'Moderate';
    } else if (normalizedScore < 0.9) {
      label = 'Strong';
    } else {
      label = 'Very Strong';
    }

    return {
      'score': normalizedScore,
      'label': label,
      'feedback': feedback,
    };
  }

  /// Cryptographically secure password generator.
  static String generatePassword({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
    bool excludeSimilar = false,
  }) {
    String lower = 'abcdefghijklmnopqrstuvwxyz';
    String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    String numbers = '0123456789';
    String symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    if (excludeSimilar) {
      lower = lower.replaceAll(RegExp(r'[lI1O0o]'), '');
      upper = upper.replaceAll(RegExp(r'[lI1O0o]'), '');
      numbers = numbers.replaceAll(RegExp(r'[lI1O0o]'), '');
    }

    String pool = '';
    final requiredChars = <String>[];
    final random = Random.secure();

    if (includeLowercase && lower.isNotEmpty) {
      pool += lower;
      requiredChars.add(lower[random.nextInt(lower.length)]);
    }
    if (includeUppercase && upper.isNotEmpty) {
      pool += upper;
      requiredChars.add(upper[random.nextInt(upper.length)]);
    }
    if (includeNumbers && numbers.isNotEmpty) {
      pool += numbers;
      requiredChars.add(numbers[random.nextInt(numbers.length)]);
    }
    if (includeSymbols && symbols.isNotEmpty) {
      pool += symbols;
      requiredChars.add(symbols[random.nextInt(symbols.length)]);
    }

    if (pool.isEmpty) pool = lower + numbers;

    final resultChars = List<String>.from(requiredChars);

    while (resultChars.length < length) {
      resultChars.add(pool[random.nextInt(pool.length)]);
    }

    resultChars.shuffle(random);
    return resultChars.join();
  }
}
