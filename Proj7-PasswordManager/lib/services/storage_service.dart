import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../models/vault_item.dart';
import 'security_service.dart';

class StorageService {
  static const _secureStorage = FlutterSecureStorage();

  static const String _keySalt = 'secure_vault_salt';
  static const String _keyPinHash = 'secure_vault_pinhash';
  static const String _keyIsSetupDone = 'secure_vault_setup_done';
  static const String _vaultFileName = 'encrypted_vault.dat';

  // Secure Storage Helpers
  static Future<bool> isSetupComplete() async {
    final value = await _secureStorage.read(key: _keyIsSetupDone);
    return value == 'true';
  }

  static Future<void> saveProfileSetup({
    required String pin,
    required String salt,
  }) async {
    final pinHash = SecurityService.hashPin(pin, salt);
    await _secureStorage.write(key: _keySalt, value: salt);
    await _secureStorage.write(key: _keyPinHash, value: pinHash);
    await _secureStorage.write(key: _keyIsSetupDone, value: 'true');
  }

  static Future<String?> getSalt() async {
    return await _secureStorage.read(key: _keySalt);
  }

  static Future<bool> verifyPin(String pin) async {
    final salt = await getSalt();
    final storedHash = await _secureStorage.read(key: _keyPinHash);
    if (salt == null || storedHash == null) return false;

    final computedHash = SecurityService.hashPin(pin, salt);
    return computedHash == storedHash;
  }

  static Future<void> updatePin(String oldPin, String newPin) async {
    final salt = await getSalt();
    if (salt == null) throw Exception('No salt found.');

    final isValid = await verifyPin(oldPin);
    if (!isValid) throw Exception('Current PIN is incorrect.');

    // Derive old key & load existing items
    final oldKey = SecurityService.deriveKey(oldPin, salt);
    final items = await loadVault(oldKey);

    // Derive new key & re-save items
    final newKey = SecurityService.deriveKey(newPin, salt);
    final newPinHash = SecurityService.hashPin(newPin, salt);

    await _secureStorage.write(key: _keyPinHash, value: newPinHash);
    await saveVault(items, newKey);
  }

  // Vault File System Helpers
  static Future<File> _getVaultFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_vaultFileName');
  }

  static Future<void> saveVault(List<VaultItem> items, Uint8List masterKey) async {
    final file = await _getVaultFile();
    final jsonList = items.map((e) => e.toMap()).toList();
    final rawJson = jsonEncode(jsonList);

    final encryptedPayload = SecurityService.encryptText(rawJson, masterKey);
    await file.writeAsString(encryptedPayload);
  }

  static Future<List<VaultItem>> loadVault(Uint8List masterKey) async {
    final file = await _getVaultFile();
    if (!await file.exists()) {
      return [];
    }

    final encryptedPayload = await file.readAsString();
    if (encryptedPayload.isEmpty) return [];

    final decryptedJson = SecurityService.decryptText(encryptedPayload, masterKey);
    if (decryptedJson == '[Decryption Failed]') {
      throw Exception('Failed to decrypt vault with provided master key.');
    }

    if (decryptedJson.isEmpty) return [];

    final List<dynamic> jsonList = jsonDecode(decryptedJson);
    return jsonList.map((e) => VaultItem.fromMap(e as Map<String, dynamic>)).toList();
  }

  // Export Encrypted Backup
  static Future<String> exportBackup(List<VaultItem> items, String exportPassword) async {
    final backupSalt = SecurityService.generateSalt();
    final backupKey = SecurityService.deriveKey(exportPassword, backupSalt);

    final jsonList = items.map((e) => e.toMap()).toList();
    final rawJson = jsonEncode(jsonList);

    final encryptedData = SecurityService.encryptText(rawJson, backupKey);

    final backupPayload = jsonEncode({
      'version': '1.0',
      'salt': backupSalt,
      'data': encryptedData,
      'timestamp': DateTime.now().toIso8601String(),
    });

    final dir = await getApplicationDocumentsDirectory();
    final backupFile = File('${dir.path}/SecureVault_Backup_${DateTime.now().millisecondsSinceEpoch}.securevault');
    await backupFile.writeAsString(backupPayload);

    return backupFile.path;
  }

  // Import Encrypted Backup
  static Future<List<VaultItem>> importBackup(String filePath, String exportPassword) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Backup file does not exist.');
    }

    final content = await file.readAsString();
    final backupMap = jsonDecode(content) as Map<String, dynamic>;

    final backupSalt = backupMap['salt'] as String;
    final encryptedData = backupMap['data'] as String;

    final backupKey = SecurityService.deriveKey(exportPassword, backupSalt);
    final decryptedJson = SecurityService.decryptText(encryptedData, backupKey);

    if (decryptedJson == '[Decryption Failed]' || decryptedJson.isEmpty) {
      throw Exception('Incorrect backup password or corrupted backup file.');
    }

    final List<dynamic> jsonList = jsonDecode(decryptedJson);
    return jsonList.map((e) => VaultItem.fromMap(e as Map<String, dynamic>)).toList();
  }

  static Future<void> wipeAllData() async {
    await _secureStorage.deleteAll();
    final file = await _getVaultFile();
    if (await file.exists()) {
      await file.delete();
    }
  }
}
