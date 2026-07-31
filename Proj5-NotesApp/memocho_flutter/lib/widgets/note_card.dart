import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/note.dart';

class NoteCard extends StatefulWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scale  = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _offset = Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final color = note.color;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => SlideTransition(
        position: _offset,
        child: ScaleTransition(scale: _scale, child: child),
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color.bg,
            border: Border.all(color: color.border, width: 3),
            boxShadow: [
              BoxShadow(
                color: color.border.withValues(alpha: 0.5),
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card header strip
                  _CardHeader(note: note),
                  // Card body
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.displayTitle,
                          style: AppTheme.jpStyle(
                            size: 13,
                            weight: FontWeight.w700,
                            color: color.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          note.excerpt.isEmpty ? '…' : note.excerpt,
                          style: AppTheme.jpStyle(
                            size: 11.5,
                            color: color.textColor.withValues(alpha: 0.72),
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Tags
                  if (note.tags.isNotEmpty) _CardTags(note: note),
                ],
              ),
              // Archived overlay
              if (note.archived)
                Container(
                  color: AppColors.navyMid.withValues(alpha: 0.55),
                  child: Center(
                    child: Text(
                      '🗃 ARCHIVED',
                      style: AppTheme.pixelStyle(size: 8, color: AppColors.cyan),
                    ),
                  ),
                ),
              // Pin ribbon
              if (note.pinned)
                const Positioned(
                  top: -2,
                  right: 10,
                  child: Text('📌', style: TextStyle(fontSize: 18)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final Note note;
  const _CardHeader({required this.note});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.month.toString().padLeft(2,'0')}/${dt.day.toString().padLeft(2,'0')}/${dt.year % 100}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: note.color.border, width: 2),
        ),
      ),
      child: Row(
        children: [
          Text(note.color.emoji, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(
            _formatDate(note.modifiedAt),
            style: AppTheme.pixelStyle(size: 6, color: note.color.textColor.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

class _CardTags extends StatelessWidget {
  final Note note;
  const _CardTags({required this.note});

  @override
  Widget build(BuildContext context) {
    final shown = note.tags.take(4).toList();
    final extra = note.tags.length - 4;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: note.color.border, width: 2)),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          ...shown.map((t) => _TagLabel(label: t, color: note.color)),
          if (extra > 0) _TagLabel(label: '+$extra', color: note.color),
        ],
      ),
    );
  }
}

class _TagLabel extends StatelessWidget {
  final String label;
  final NoteColor color;
  const _TagLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      color: color.textColor.withValues(alpha: 0.12),
      child: Text(
        label,
        style: AppTheme.pixelStyle(size: 5.5, color: color.textColor.withValues(alpha: 0.8)),
      ),
    );
  }
}
