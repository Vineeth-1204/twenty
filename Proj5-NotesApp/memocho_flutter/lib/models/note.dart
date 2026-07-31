import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';

const _uuid = Uuid();

class Note {
  final String id;
  String title;
  String content;
  NoteColor color;
  List<String> tags;
  bool pinned;
  bool archived;
  final DateTime createdAt;
  DateTime modifiedAt;

  Note({
    String? id,
    this.title = '',
    this.content = '',
    this.color = NoteColor.sakura,
    List<String>? tags,
    this.pinned = false,
    this.archived = false,
    DateTime? createdAt,
    DateTime? modifiedAt,
  })  : id = id ?? _uuid.v4(),
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now();

  Note copyWith({
    String? title,
    String? content,
    NoteColor? color,
    List<String>? tags,
    bool? pinned,
    bool? archived,
    DateTime? modifiedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      tags: tags ?? List.from(this.tags),
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'color': color.name,
    'tags': tags,
    'pinned': pinned,
    'archived': archived,
    'createdAt': createdAt.toIso8601String(),
    'modifiedAt': modifiedAt.toIso8601String(),
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    content: json['content'] as String? ?? '',
    color: NoteColorExt.fromString(json['color'] as String? ?? 'sakura'),
    tags: List<String>.from(json['tags'] as List? ?? []),
    pinned: json['pinned'] as bool? ?? false,
    archived: json['archived'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    modifiedAt: DateTime.tryParse(json['modifiedAt'] as String? ?? '') ?? DateTime.now(),
  );

  String get displayTitle => title.isEmpty ? 'Untitled メモ' : title;

  int get wordCount {
    final t = content.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).length;
  }

  String get excerpt {
    final clean = content.replaceAll(RegExp(r'[#*_~`>\[\]!]'), '').trim();
    if (clean.length <= 150) return clean;
    return '${clean.substring(0, 150)}…';
  }
}
