import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';

enum SortMode { modified, created, title }
enum FilterMode { all, pinned, archived }

class NotesProvider extends ChangeNotifier {
  List<Note> _notes = [];
  String _search = '';
  FilterMode _filter = FilterMode.all;
  SortMode _sort = SortMode.modified;
  String? _activeTagFilter;
  bool _gridView = true;
  bool _crtEnabled = true;

  // ── Getters ──────────────────────────────────────────────────────────
  List<Note> get allNotes => _notes;
  String get search => _search;
  FilterMode get filter => _filter;
  SortMode get sort => _sort;
  String? get activeTagFilter => _activeTagFilter;
  bool get gridView => _gridView;
  bool get crtEnabled => _crtEnabled;

  List<Note> get filteredNotes {
    var notes = List<Note>.from(_notes);

    // Apply filter
    switch (_filter) {
      case FilterMode.pinned:
        notes = notes.where((n) => n.pinned && !n.archived).toList();
        break;
      case FilterMode.archived:
        notes = notes.where((n) => n.archived).toList();
        break;
      case FilterMode.all:
        if (_activeTagFilter != null) {
          notes = notes.where((n) => n.tags.contains(_activeTagFilter)).toList();
        } else {
          notes = notes.where((n) => !n.archived).toList();
        }
        break;
    }

    // Apply search
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      notes = notes.where((n) =>
        n.title.toLowerCase().contains(q) ||
        n.content.toLowerCase().contains(q) ||
        n.tags.any((t) => t.toLowerCase().contains(q))
      ).toList();
    }

    // Sort — pinned first
    notes.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      switch (_sort) {
        case SortMode.created:
          return b.createdAt.compareTo(a.createdAt);
        case SortMode.title:
          return a.displayTitle.compareTo(b.displayTitle);
        case SortMode.modified:
          return b.modifiedAt.compareTo(a.modifiedAt);
      }
    });

    return notes;
  }

  int get totalCount   => _notes.where((n) => !n.archived).length;
  int get pinnedCount  => _notes.where((n) => n.pinned).length;
  int get totalWords   => _notes.fold(0, (acc, n) => acc + n.wordCount);

  Map<String, int> get allTags {
    final map = <String, int>{};
    for (final note in _notes) {
      for (final tag in note.tags) {
        map[tag] = (map[tag] ?? 0) + 1;
      }
    }
    return map;
  }

  // ── Init / Persistence ────────────────────────────────────────────────
  Future<void> init() async {
    await _loadNotes();
    if (_notes.isEmpty) _seedDemoNotes();
    notifyListeners();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('memocho_notes_v1');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _notes = list.map((j) => Note.fromJson(j as Map<String, dynamic>)).toList();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('memocho_notes_v1', jsonEncode(_notes.map((n) => n.toJson()).toList()));
  }

  // ── CRUD ─────────────────────────────────────────────────────────────
  Note createNote({NoteColor? color}) {
    const colors = NoteColor.values;
    final c = color ?? colors[DateTime.now().millisecondsSinceEpoch % colors.length];
    return Note(color: c);
  }

  Future<void> upsertNote(Note note) async {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      _notes[idx] = note;
    } else {
      _notes.insert(0, note);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> togglePin(String id) async {
    final idx = _notes.indexWhere((n) => n.id == id);
    if (idx < 0) return;
    _notes[idx] = _notes[idx].copyWith(
      pinned: !_notes[idx].pinned,
      modifiedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  Future<void> toggleArchive(String id) async {
    final idx = _notes.indexWhere((n) => n.id == id);
    if (idx < 0) return;
    _notes[idx] = _notes[idx].copyWith(
      archived: !_notes[idx].archived,
      modifiedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  // ── UI State ─────────────────────────────────────────────────────────
  void setSearch(String q) { _search = q; notifyListeners(); }
  void setFilter(FilterMode f) { _filter = f; _activeTagFilter = null; notifyListeners(); }
  void setSort(SortMode s) { _sort = s; notifyListeners(); }
  void setTagFilter(String? tag) { _activeTagFilter = tag; _filter = FilterMode.all; notifyListeners(); }
  void toggleGridView() { _gridView = !_gridView; notifyListeners(); }
  void toggleCrt() { _crtEnabled = !_crtEnabled; notifyListeners(); }

  // ── Export ────────────────────────────────────────────────────────────
  String buildExportText() {
    final visible = _notes.where((n) => !n.archived).toList();
    return visible.map((n) {
      final divider = '─' * 40;
      return '=== ${n.displayTitle} ===\n[${n.color.name}] Tags: ${n.tags.join(', ')}\nModified: ${n.modifiedAt}\n\n${n.content}\n\n$divider';
    }).join('\n\n');
  }

  // ── Seed Demo ─────────────────────────────────────────────────────────
  void _seedDemoNotes() {
    final now = DateTime.now();
    _notes = [
      Note(
        title: 'ようこそ！Welcome to Memochō',
        content: '''# ✿ Welcome to Memochō! ✿

This is your **90s Japanese-style** notes app!

## Features
- ✦ **Write** notes in Markdown
- ✦ **Color-code** with 6 pastel themes
- ✦ **Tag** and organize your thoughts
- ✦ **Pin** important notes
- ✦ **Search** across all your notes
- ✦ **Preview** rendered Markdown

> Write beautifully. Remember everything. ♪

*Enjoy your Memochō experience!*''',
        color: NoteColor.sakura,
        tags: ['welcome', 'guide'],
        pinned: true,
        createdAt: now.subtract(const Duration(days: 3)),
        modifiedAt: now.subtract(const Duration(days: 3)),
      ),
      Note(
        title: '買い物リスト — Shopping List',
        content: '''# 🛒 今週の買い物

- [ ] Matcha green tea powder
- [ ] Mochi (strawberry flavor)
- [x] Soy sauce
- [ ] Instant ramen × 5
- [ ] Pocky sticks
- [x] Seaweed snacks

---
**Budget:** ¥3,500''',
        color: NoteColor.mint,
        tags: ['shopping', 'list'],
        createdAt: now.subtract(const Duration(days: 2)),
        modifiedAt: now.subtract(const Duration(days: 2)),
      ),
      Note(
        title: '夢日記 — Dream Journal',
        content: '''## 🌙 Last Night's Dream

I was wandering through **Shibuya at night**, 1999.

Neon signs everywhere — pink, cyan, magenta. The streets were empty but the arcades were *full of light*.

> "The city remembers what you forget."

### Notes
- The dream had a **VHS aesthetic**
- Colors were oversaturated like an old anime OP
- Woke up at 3:33 AM ✦''',
        color: NoteColor.lavender,
        tags: ['journal', 'dreams'],
        createdAt: now.subtract(const Duration(days: 1)),
        modifiedAt: now.subtract(const Duration(days: 1)),
      ),
      Note(
        title: '覚書 — Quick Reminders',
        content: '''# ⭐ Today's Reminders

1. Call Tanaka-san before 5PM
2. Submit project report
3. Water the ferns
4. Download the new City Pop album

---
✸ *Don't forget the umbrella — rain forecast!* ✸''',
        color: NoteColor.yolk,
        tags: ['todo', 'reminders'],
        createdAt: now,
        modifiedAt: now,
      ),
    ];
  }
}
