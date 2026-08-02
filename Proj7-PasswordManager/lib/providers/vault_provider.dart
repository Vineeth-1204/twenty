import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/vault_item.dart';
import '../services/security_service.dart';
import '../services/storage_service.dart';

class VaultProvider extends ChangeNotifier {
  List<VaultItem> _items = [];
  bool _isLoading = false;
  String _searchQuery = '';
  VaultCategory? _selectedCategory;
  bool _showFavoritesOnly = false;
  final _uuid = const Uuid();

  List<VaultItem> get allItems => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  VaultCategory? get selectedCategory => _selectedCategory;
  bool get showFavoritesOnly => _showFavoritesOnly;

  List<VaultItem> get filteredItems {
    return _items.where((item) {
      if (_showFavoritesOnly && !item.isFavorite) return false;
      if (_selectedCategory != null && item.category != _selectedCategory) return false;

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchUsername = item.username.toLowerCase().contains(q);
        final matchUrl = item.url.toLowerCase().contains(q);
        final matchTag = item.tags.any((t) => t.toLowerCase().contains(q));
        return matchTitle || matchUsername || matchUrl || matchTag;
      }

      return true;
    }).toList();
  }

  Future<void> loadVault(Uint8List masterKey) async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await StorageService.loadVault(masterKey);
    } catch (e) {
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem({
    required String title,
    required VaultCategory category,
    required String username,
    required String password,
    required String url,
    required String notes,
    required Uint8List masterKey,
    List<String> tags = const [],
    bool isFavorite = false,
  }) async {
    final newItem = VaultItem(
      id: _uuid.v4(),
      title: title,
      category: category,
      username: username,
      password: password,
      url: url,
      notes: notes,
      isFavorite: isFavorite,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: tags,
    );

    _items.insert(0, newItem);
    await StorageService.saveVault(_items, masterKey);
    notifyListeners();
  }

  Future<void> updateItem({
    required VaultItem updatedItem,
    required Uint8List masterKey,
  }) async {
    final index = _items.indexWhere((element) => element.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem.copyWith(updatedAt: DateTime.now());
      await StorageService.saveVault(_items, masterKey);
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String id, Uint8List masterKey) async {
    final index = _items.indexWhere((element) => element.id == id);
    if (index != -1) {
      final current = _items[index];
      _items[index] = current.copyWith(
        isFavorite: !current.isFavorite,
        updatedAt: DateTime.now(),
      );
      await StorageService.saveVault(_items, masterKey);
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id, Uint8List masterKey) async {
    _items.removeWhere((item) => item.id == id);
    await StorageService.saveVault(_items, masterKey);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(VaultCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleFavoritesFilter() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  // Security Audit Analytics
  Map<String, dynamic> calculateSecurityAudit() {
    if (_items.isEmpty) {
      return {
        'healthScore': 100,
        'weakCount': 0,
        'reusedCount': 0,
        'oldCount': 0,
        'totalCount': 0,
        'weakItems': <VaultItem>[],
        'reusedItems': <VaultItem>[],
        'oldItems': <VaultItem>[],
      };
    }

    final weakItems = <VaultItem>[];
    final passwordCounts = <String, int>{};
    final oldItems = <VaultItem>[];
    final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));

    for (final item in _items) {
      // Evaluate strength
      final eval = SecurityService.evaluatePasswordStrength(item.password);
      if ((eval['score'] as double) < 0.6) {
        weakItems.add(item);
      }

      // Count occurrences for reuse check
      if (item.password.isNotEmpty) {
        passwordCounts[item.password] = (passwordCounts[item.password] ?? 0) + 1;
      }

      // Outdated passwords (>90 days old)
      if (item.updatedAt.isBefore(ninetyDaysAgo)) {
        oldItems.add(item);
      }
    }

    final reusedPasswords = passwordCounts.entries.where((e) => e.value > 1).map((e) => e.key).toSet();
    final reusedItems = _items.where((item) => reusedPasswords.contains(item.password)).toList();

    // Deduce Score (Base 100)
    double score = 100.0;

    // Penalty for weak passwords (up to -40)
    final weakRatio = weakItems.length / _items.length;
    score -= (weakRatio * 40);

    // Penalty for reused passwords (up to -40)
    final reusedRatio = reusedItems.length / _items.length;
    score -= (reusedRatio * 40);

    // Penalty for old passwords (up to -20)
    final oldRatio = oldItems.length / _items.length;
    score -= (oldRatio * 20);

    final finalScore = score.clamp(0, 100).round();

    return {
      'healthScore': finalScore,
      'weakCount': weakItems.length,
      'reusedCount': reusedItems.length,
      'oldCount': oldItems.length,
      'totalCount': _items.length,
      'weakItems': weakItems,
      'reusedItems': reusedItems,
      'oldItems': oldItems,
    };
  }
}
