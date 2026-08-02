import 'dart:convert';

enum VaultCategory {
  login,
  card,
  note,
  server,
  wifi,
}

extension VaultCategoryExtension on VaultCategory {
  String get displayName {
    switch (this) {
      case VaultCategory.login:
        return 'Logins';
      case VaultCategory.card:
        return 'Cards';
      case VaultCategory.note:
        return 'Secure Notes';
      case VaultCategory.server:
        return 'Servers';
      case VaultCategory.wifi:
        return 'Wi-Fi';
    }
  }
}

class VaultItem {
  final String id;
  final String title;
  final VaultCategory category;
  final String username;
  final String password;
  final String url;
  final String notes;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  VaultItem({
    required this.id,
    required this.title,
    required this.category,
    required this.username,
    required this.password,
    required this.url,
    required this.notes,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  VaultItem copyWith({
    String? id,
    String? title,
    VaultCategory? category,
    String? username,
    String? password,
    String? url,
    String? notes,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return VaultItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category.name,
      'username': username,
      'password': password,
      'url': url,
      'notes': notes,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
    };
  }

  factory VaultItem.fromMap(Map<String, dynamic> map) {
    return VaultItem(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      category: VaultCategory.values.firstWhere(
        (c) => c.name == (map['category'] as String?),
        orElse: () => VaultCategory.login,
      ),
      username: map['username'] as String? ?? '',
      password: map['password'] as String? ?? '',
      url: map['url'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      isFavorite: map['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
      tags: List<String>.from(map['tags'] as List? ?? []),
    );
  }

  String toJson() => jsonEncode(toMap());
  factory VaultItem.fromJson(String source) => VaultItem.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
