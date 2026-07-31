import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/pixel_button.dart';
import '../widgets/scanlines_overlay.dart';

class EditorScreen extends StatefulWidget {
  final Note note;
  final bool isNew;
  const EditorScreen({super.key, required this.note, required this.isNew});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late Note _note;
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late TextEditingController _tagInputCtrl;
  bool _previewMode = false;
  bool _unsaved = false;
  String _saveStatus = '✓ Saved';
  Timer? _autoSave;
  final FocusNode _contentFocus = FocusNode();

  // JP Stamps
  static const _stamps = ['✿', '★', '♪', '❋', '◆', '✦', '❀', '☆', '♦', '✸'];

  @override
  void initState() {
    super.initState();
    _note = widget.note.copyWith();
    _titleCtrl   = TextEditingController(text: _note.title);
    _contentCtrl = TextEditingController(text: _note.content);
    _tagInputCtrl = TextEditingController();

    _titleCtrl.addListener(_onEdit);
    _contentCtrl.addListener(_onEdit);

    _startAutoSave();
  }

  @override
  void dispose() {
    _autoSave?.cancel();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagInputCtrl.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  void _startAutoSave() {
    _autoSave = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_unsaved) _saveNote(silent: true);
    });
  }

  void _onEdit() {
    if (!_unsaved) setState(() { _unsaved = true; _saveStatus = '⏳ Unsaved…'; });
  }

  void _saveNote({bool silent = false}) {
    final title   = _titleCtrl.text.trim();
    final content = _contentCtrl.text;
    if (title.isEmpty && content.trim().isEmpty) {
      if (!silent) _showToast('📭 Add a title or content first!');
      return;
    }
    _note = _note.copyWith(
      title: title.isEmpty ? 'Untitled メモ' : title,
      content: content,
      modifiedAt: DateTime.now(),
    );
    context.read<NotesProvider>().upsertNote(_note);
    setState(() { _unsaved = false; _saveStatus = '✓ Saved'; });
    if (!silent) _showToast('💾 Note saved!');
  }

  void _deleteNote() async {
    final confirm = await _showConfirm(
      '🗑 DELETE NOTE?',
      'Permanently delete "${_note.displayTitle}"?',
    );
    if (confirm == true && mounted) {
      context.read<NotesProvider>().deleteNote(_note.id);
      Navigator.pop(context);
      _showScaffoldToast('🗑 Note deleted!');
    }
  }

  void _togglePin() {
    setState(() {
      _note = _note.copyWith(pinned: !_note.pinned);
    });
    context.read<NotesProvider>().upsertNote(_note);
    _showToast(_note.pinned ? '📌 Pinned!' : '📌 Unpinned');
  }

  void _archiveNote() {
    _saveNote(silent: true);
    context.read<NotesProvider>().toggleArchive(_note.id);
    Navigator.pop(context);
    _showScaffoldToast(_note.archived ? '🗃 Unarchived!' : '🗃 Archived!');
  }

  void _setColor(NoteColor c) {
    setState(() { _note = _note.copyWith(color: c); _unsaved = true; });
  }

  void _addTag(String raw) {
    final tag = raw.trim().toLowerCase().replaceAll(' ', '-');
    if (tag.isEmpty || _note.tags.contains(tag) || _note.tags.length >= 8) return;
    setState(() { _note = _note.copyWith(tags: [..._note.tags, tag]); });
    _tagInputCtrl.clear();
  }

  void _removeTag(String tag) {
    setState(() {
      _note = _note.copyWith(tags: _note.tags.where((t) => t != tag).toList());
    });
  }

  void _insertText(String prefix, {String suffix = '', String? full}) {
    final ctrl = _contentCtrl;
    final sel  = ctrl.selection;
    if (!sel.isValid) return;

    final text = ctrl.text;
    final selected = sel.textInside(text);
    final insert = full ?? '$prefix$selected$suffix';
    final before = text.substring(0, sel.start);
    final after  = text.substring(sel.end);
    ctrl.value = TextEditingValue(
      text: '$before$insert$after',
      selection: TextSelection.collapsed(offset: before.length + insert.length),
    );
    _contentFocus.requestFocus();
    _onEdit();
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: AppTheme.pixelStyle(size: 8)),
      backgroundColor: AppColors.navyMid,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      duration: const Duration(seconds: 2),
    ));
  }

  void _showScaffoldToast(String msg) {
    // Called after pop, so we can't use local ScaffoldMessenger
    // This is handled by the parent
  }

  Future<bool?> _showConfirm(String title, String msg) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyMid,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(title, style: AppTheme.pixelStyle(size: 9, color: AppColors.yellow)),
        content: Text(msg, style: AppTheme.jpStyle(size: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: AppTheme.pixelStyle(size: 7, color: AppColors.cyan)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('DELETE', style: AppTheme.pixelStyle(size: 7, color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _note.color;
    final words = _contentCtrl.text.trim().isEmpty
      ? 0
      : _contentCtrl.text.trim().split(RegExp(r'\s+')).length;
    final chars = _contentCtrl.text.length;

    return Consumer<NotesProvider>(
      builder: (ctx, prov, _) => Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.navy,
            body: Column(
              children: [
                // Fake OS window title bar
                _WindowTitleBar(
                  note: _note,
                  onClose: () {
                    if (_unsaved) _saveNote(silent: true);
                    Navigator.pop(context);
                  },
                  onPin: _togglePin,
                  onColor: _setColor,
                ),
                // Title input
                _TitleInput(ctrl: _titleCtrl, color: color),
                // Tags row
                _TagsRow(
                  tags: _note.tags,
                  ctrl: _tagInputCtrl,
                  onAdd: _addTag,
                  onRemove: _removeTag,
                ),
                // Toolbar
                _EditorToolbar(
                  previewMode: _previewMode,
                  onAction: _insertText,
                  onStamp: () => _insertText(
                    ' ${_stamps[DateTime.now().millisecondsSinceEpoch % _stamps.length]} ',
                  ),
                  onTogglePreview: () => setState(() => _previewMode = !_previewMode),
                ),
                // Editor / Preview
                Expanded(
                  child: _previewMode
                    ? _MarkdownPreview(content: _contentCtrl.text)
                    : _TextEditor(ctrl: _contentCtrl, focus: _contentFocus),
                ),
                // Footer
                _Footer(
                  chars: chars,
                  words: words,
                  saveStatus: _saveStatus,
                  onDelete: _deleteNote,
                  onArchive: _archiveNote,
                  onSave: () => _saveNote(),
                ),
              ],
            ),
          ),
          if (prov.crtEnabled) const IgnorePointer(child: ScanlinesOverlay()),
        ],
      ),
    );
  }
}

// ── Window title bar ──────────────────────────────────────────────────────────
class _WindowTitleBar extends StatelessWidget {
  final Note note;
  final VoidCallback onClose;
  final VoidCallback onPin;
  final ValueChanged<NoteColor> onColor;

  const _WindowTitleBar({
    required this.note,
    required this.onClose,
    required this.onPin,
    required this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        left: 12, right: 12, bottom: 8,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.navyLight, AppColors.purple, AppColors.navyLight]),
        border: Border(bottom: BorderSide(color: AppColors.pink, width: 2)),
      ),
      child: Row(
        children: [
          // Window dots
          _WinDot(color: const Color(0xFFFF5F57), onTap: onClose),
          const SizedBox(width: 6),
          _WinDot(
            color: const Color(0xFFFEBC2E),
            onTap: onPin,
            active: note.pinned,
          ),
          const SizedBox(width: 6),
          _WinDot(color: const Color(0xFF28C840), onTap: () {}),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              '✎ ${note.displayTitle} — メモ帳',
              style: AppTheme.pixelStyle(size: 7, color: AppColors.cream),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          // Color picker
          ...NoteColor.values.map((c) => GestureDetector(
            onTap: () => onColor(c),
            child: Container(
              width: 16, height: 16,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: c.border,
                shape: BoxShape.circle,
                border: Border.all(
                  color: note.color == c ? Colors.white : Colors.transparent,
                  width: 2,
                ),
                boxShadow: note.color == c
                  ? [BoxShadow(color: Colors.white.withValues(alpha: 0.7), blurRadius: 6)]
                  : null,
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _WinDot extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  final bool active;
  const _WinDot({required this.color, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 14, height: 14,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black26, width: 1.5),
          boxShadow: active
            ? [BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 8)]
            : null,
        ),
      ),
    );
  }
}

// ── Title input ───────────────────────────────────────────────────────────────
class _TitleInput extends StatelessWidget {
  final TextEditingController ctrl;
  final NoteColor color;
  const _TitleInput({required this.ctrl, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: ctrl,
        style: AppTheme.jpStyle(size: 22, weight: FontWeight.w900),
        decoration: const InputDecoration(
          hintText: 'タイトル… Enter Title…',
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.pink, width: 2),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.pink, width: 2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.pink, width: 2),
          ),
          contentPadding: EdgeInsets.zero,
          isDense: true,
          filled: false,
        ),
        maxLines: 1,
        textInputAction: TextInputAction.next,
      ),
    );
  }
}

// ── Tags row ──────────────────────────────────────────────────────────────────
class _TagsRow extends StatelessWidget {
  final List<String> tags;
  final TextEditingController ctrl;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _TagsRow({
    required this.tags,
    required this.ctrl,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text('🏷', style: AppTheme.pixelStyle(size: 7, color: AppColors.cyan)),
          const SizedBox(width: 6),
          Expanded(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...tags.map((t) => _TagBadge(label: t, onRemove: () => onRemove(t))),
                SizedBox(
                  width: 100,
                  height: 26,
                  child: TextField(
                    controller: ctrl,
                    style: AppTheme.pixelStyle(size: 7),
                    decoration: const InputDecoration(
                      hintText: 'Add tag…',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      filled: false,
                    ),
                    onSubmitted: onAdd,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _TagBadge({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      color: AppColors.cyan,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTheme.pixelStyle(size: 6, color: AppColors.navy)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Text('✕', style: AppTheme.pixelStyle(size: 6, color: AppColors.navy)),
          ),
        ],
      ),
    );
  }
}

// ── Editor toolbar ────────────────────────────────────────────────────────────
class _EditorToolbar extends StatelessWidget {
  final bool previewMode;
  final Function(String prefix, {String suffix, String? full}) onAction;
  final VoidCallback onStamp;
  final VoidCallback onTogglePreview;

  const _EditorToolbar({
    required this.previewMode,
    required this.onAction,
    required this.onStamp,
    required this.onTogglePreview,
  });

  @override
  Widget build(BuildContext context) {
    final tools = [
      ('𝐁', () => onAction('**', suffix: '**'), 'Bold'),
      ('𝑰', () => onAction('*', suffix: '*'), 'Italic'),
      ('S̶', () => onAction('~~', suffix: '~~'), 'Strike'),
      ('H1', () => onAction('\n# '), 'Heading 1'),
      ('H2', () => onAction('\n## '), 'Heading 2'),
      ('• List', () => onAction('\n- '), 'Bullet'),
      ('# List', () => onAction('\n1. '), 'Numbered'),
      ('☑', () => onAction('\n- [ ] '), 'Checkbox'),
      ('───', () => onAction('', full: '\n\n---\n\n'), 'HR'),
      ('印', () => onStamp(), 'Stamp'),
    ];

    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        border: Border.all(color: AppColors.pink.withValues(alpha: 0.3), width: 2),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...tools.map((t) => _ToolBtn(label: t.$1, onTap: t.$2, tooltip: t.$3)),
          const _ToolSep(),
          _ToolBtn(
            label: previewMode ? '✎ Edit' : '👁 Preview',
            onTap: onTogglePreview,
            tooltip: 'Toggle preview',
            active: previewMode,
          ),
        ],
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String tooltip;
  final bool active;
  const _ToolBtn({required this.label, required this.onTap, required this.tooltip, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.cyan.withValues(alpha: 0.1) : Colors.transparent,
            border: Border(right: BorderSide(color: AppColors.pink.withValues(alpha: 0.15), width: 1)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTheme.pixelStyle(
              size: 7,
              color: active ? AppColors.cyan : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolSep extends StatelessWidget {
  const _ToolSep();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      color: AppColors.pink.withValues(alpha: 0.3),
    );
  }
}

// ── Text editor ───────────────────────────────────────────────────────────────
class _TextEditor extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focus;
  const _TextEditor({required this.ctrl, required this.focus});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border.all(color: AppColors.pink.withValues(alpha: 0.2), width: 2),
      ),
      child: TextField(
        controller: ctrl,
        focusNode: focus,
        style: AppTheme.jpStyle(size: 14),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: const InputDecoration(
          hintText: 'ここに書いてください… Write your note here…\n\nSupports Markdown: **bold** *italic* # Heading\n- Bullet lists\n[ ] Checkboxes',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
          isDense: true,
          filled: false,
        ),
        keyboardType: TextInputType.multiline,
      ),
    );
  }
}

// ── Markdown preview ──────────────────────────────────────────────────────────
class _MarkdownPreview extends StatelessWidget {
  final String content;
  const _MarkdownPreview({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3), width: 2),
      ),
      child: Markdown(
        data: content.isEmpty ? '*No content to preview…*' : content,
        styleSheet: MarkdownStyleSheet(
          p: AppTheme.jpStyle(size: 14),
          h1: AppTheme.jpStyle(size: 22, weight: FontWeight.w900, color: AppColors.pink),
          h2: AppTheme.jpStyle(size: 18, weight: FontWeight.w700, color: AppColors.cyan),
          h3: AppTheme.jpStyle(size: 15, weight: FontWeight.w700, color: AppColors.yellow),
          strong: AppTheme.jpStyle(size: 14, weight: FontWeight.w900, color: AppColors.pinkLight),
          em: AppTheme.jpStyle(size: 14, color: AppColors.cyan),
          del: AppTheme.jpStyle(size: 14, color: Colors.white38)
              .copyWith(decoration: TextDecoration.lineThrough),
          blockquoteDecoration: const BoxDecoration(
            border: Border(left: BorderSide(color: AppColors.pink, width: 3)),
          ),
          blockquotePadding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
          code: AppTheme.monoStyle(size: 16, color: AppColors.yellow),
          codeblockDecoration: BoxDecoration(
            color: Colors.black45,
            border: Border.all(color: AppColors.pink.withValues(alpha: 0.3)),
          ),
          listBullet: AppTheme.jpStyle(size: 14, color: AppColors.pink),
        ),
        shrinkWrap: false,
        selectable: true,
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  final int chars;
  final int words;
  final String saveStatus;
  final VoidCallback onDelete;
  final VoidCallback onArchive;
  final VoidCallback onSave;

  const _Footer({
    required this.chars,
    required this.words,
    required this.saveStatus,
    required this.onDelete,
    required this.onArchive,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x33FF3EA5), width: 1)),
      ),
      child: Row(
        children: [
          // Meta
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                Text('$chars chars', style: AppTheme.pixelStyle(size: 6, color: Colors.white38)),
                Text('•', style: AppTheme.pixelStyle(size: 6, color: Colors.white24)),
                Text('$words words', style: AppTheme.pixelStyle(size: 6, color: Colors.white38)),
                Text('•', style: AppTheme.pixelStyle(size: 6, color: Colors.white24)),
                Text(saveStatus, style: AppTheme.pixelStyle(size: 6, color: AppColors.cyan)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PixelButton.danger(label: '🗑', onTap: onDelete, fontSize: 10),
              const SizedBox(width: 6),
              PixelButton.secondary(label: '🗃', onTap: onArchive, fontSize: 10),
              const SizedBox(width: 6),
              PixelButton(label: '💾 SAVE', onTap: onSave, fontSize: 7),
            ],
          ),
        ],
      ),
    );
  }
}
