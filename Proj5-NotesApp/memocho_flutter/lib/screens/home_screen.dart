import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/note_card.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/scanlines_overlay.dart';
import '../widgets/ticker_tape.dart';
import '../widgets/pixel_button.dart';
import 'editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openNewNote(BuildContext context) {
    final prov = context.read<NotesProvider>();
    final note = prov.createNote();
    Navigator.push(context, _slideRoute(EditorScreen(note: note, isNew: true)));
  }

  void _openNote(BuildContext context, note) {
    Navigator.push(context, _slideRoute(EditorScreen(note: note, isNew: false)));
  }

  PageRoute _slideRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, a, __) => page,
    transitionsBuilder: (_, anim, __, child) => SlideTransition(
      position: Tween(begin: const Offset(0, 1), end: Offset.zero)
          .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 350),
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (ctx, prov, _) {
        final tickerMsgs = [
          '✿ ようこそ！WELCOME TO MEMOCHŌ ✿',
          '★ ${prov.totalCount} NOTES STORED IN MEMORY ★',
          '♪ ${prov.totalWords} WORDS ACROSS ALL NOTES ♪',
          '❋ PRESS ＋ FOR A NEW NOTE ❋',
          '◆ 90s JAPANESE NOTES EXPERIENCE ◆',
        ];

        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.navy,
              body: Column(
                children: [
                  // App header
                  _AppHeader(
                    prov: prov,
                    onNewNote: () => _openNewNote(ctx),
                    onExport: () async {
                      final txt = prov.buildExportText();
                      if (txt.isEmpty) {
                        _showToast(ctx, '📭 No notes to export!');
                        return;
                      }
                      await Share.share(txt, subject: 'Memochō Export');
                    },
                  ),
                  // Ticker tape
                  TickerTape(messages: tickerMsgs),
                  // Main body
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sidebar (hide on narrow screens)
                        if (MediaQuery.of(ctx).size.width > 600)
                          const SidebarWidget(),
                        // Notes area
                        Expanded(child: _NotesArea(
                          prov: prov,
                          onOpen: (n) => _openNote(ctx, n),
                          onNew: () => _openNewNote(ctx),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              // FAB — new note (mobile)
              floatingActionButton: MediaQuery.of(ctx).size.width <= 600
                ? _RetroFAB(onTap: () => _openNewNote(ctx))
                : null,
            ),
            // CRT overlay
            if (prov.crtEnabled)
              const IgnorePointer(child: ScanlinesOverlay()),
            // Corner decorations
            const IgnorePointer(
              child: Stack(children: [
                CornerDeco(alignment: Alignment.topLeft),
                CornerDeco(alignment: Alignment.topRight),
                CornerDeco(alignment: Alignment.bottomLeft),
                CornerDeco(alignment: Alignment.bottomRight),
              ]),
            ),
          ],
        );
      },
    );
  }
}

void _showToast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg, style: AppTheme.pixelStyle(size: 8)),
      backgroundColor: AppColors.navyMid,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ),
  );
}

// ── App Header ────────────────────────────────────────────────────────────────
class _AppHeader extends StatelessWidget {
  final NotesProvider prov;
  final VoidCallback onNewNote;
  final VoidCallback onExport;
  const _AppHeader({required this.prov, required this.onNewNote, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16, right: 16, bottom: 10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.navyMid,
        border: Border(bottom: BorderSide(color: AppColors.pink, width: 3)),
        boxShadow: [BoxShadow(color: Color(0x99FF3EA5), blurRadius: 16, spreadRadius: -4)],
      ),
      child: Row(
        children: [
          // Logo
          const Text('📓', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('メモ帳', style: AppTheme.jpStyle(size: 20, weight: FontWeight.w900, color: AppColors.pink)),
              Text('MEMOCHŌ', style: AppTheme.pixelStyle(size: 6, color: AppColors.cyan)),
            ],
          ),
          const SizedBox(width: 8),
          // Version badges
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                color: AppColors.pink,
                child: Text('v1.99', style: AppTheme.pixelStyle(size: 5, color: AppColors.navy)),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                color: AppColors.cyan,
                child: Text('©1999', style: AppTheme.pixelStyle(size: 5, color: AppColors.navy)),
              ),
            ],
          ),
          const Spacer(),
          // New note button
          PixelButton(label: '＋ NEW', onTap: onNewNote, fontSize: 7),
          const SizedBox(width: 8),
          // CRT toggle
          GestureDetector(
            onTap: prov.toggleCrt,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.navyLight,
                border: Border.all(color: AppColors.pinkLight, width: 2),
              ),
              child: Text(
                prov.crtEnabled ? '📺' : '🖥',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Export
          GestureDetector(
            onTap: onExport,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.navyLight,
                border: Border.all(color: AppColors.pinkLight, width: 2),
              ),
              child: const Text('💾', style: TextStyle(fontSize: 18)),
            ),
          ),
          // View toggle (tablet+)
          if (MediaQuery.of(context).size.width > 600) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: prov.toggleGridView,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.navyLight,
                  border: Border.all(color: AppColors.pink.withValues(alpha: 0.5), width: 2),
                ),
                child: Text(
                  prov.gridView ? '▦' : '☰',
                  style: const TextStyle(fontSize: 18, color: AppColors.pink),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Notes Area ────────────────────────────────────────────────────────────────
class _NotesArea extends StatelessWidget {
  final NotesProvider prov;
  final ValueChanged<dynamic> onOpen;
  final VoidCallback onNew;
  const _NotesArea({required this.prov, required this.onOpen, required this.onNew});

  @override
  Widget build(BuildContext context) {
    final notes = prov.filteredNotes;
    final isGrid = prov.gridView;

    return Column(
      children: [
        // Toolbar bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Text(
                '${notes.length} note${notes.length != 1 ? 's' : ''}',
                style: AppTheme.pixelStyle(size: 7, color: Colors.white38),
              ),
            ],
          ),
        ),
        // Notes list/grid
        Expanded(
          child: notes.isEmpty
            ? _EmptyState(onNew: onNew)
            : isGrid
              ? _GridView(notes: notes, onOpen: onOpen)
              : _ListView(notes: notes, onOpen: onOpen),
        ),
      ],
    );
  }
}

class _GridView extends StatelessWidget {
  final List notes;
  final ValueChanged onOpen;
  const _GridView({required this.notes, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width > 900 ? 3 : width > 600 ? 2 : 2;
    return MasonryGridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: cols,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: notes.length,
      itemBuilder: (_, i) => NoteCard(
        key: ValueKey(notes[i].id),
        note: notes[i],
        onTap: () => onOpen(notes[i]),
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  final List notes;
  final ValueChanged onOpen;
  const _ListView({required this.notes, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => NoteCard(
        key: ValueKey(notes[i].id),
        note: notes[i],
        onTap: () => onOpen(notes[i]),
      ),
    );
  }
}

class _EmptyState extends StatefulWidget {
  final VoidCallback onNew;
  const _EmptyState({required this.onNew});

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, -6 * _ctrl.value),
              child: child,
            ),
            child: const Text('📝', style: TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 16),
          Text('No notes yet!', style: AppTheme.pixelStyle(size: 10, color: AppColors.pink)),
          const SizedBox(height: 8),
          Text('まだメモがありません', style: AppTheme.jpStyle(size: 14, color: Colors.white38)),
          const SizedBox(height: 20),
          PixelButton(label: 'CREATE FIRST NOTE', onTap: widget.onNew, fontSize: 8),
        ],
      ),
    );
  }
}

// ── Retro FAB ─────────────────────────────────────────────────────────────────
class _RetroFAB extends StatelessWidget {
  final VoidCallback onTap;
  const _RetroFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: AppColors.pink,
          border: const Border(
            bottom: BorderSide(color: AppColors.magenta, width: 3),
            right:  BorderSide(color: AppColors.magenta, width: 3),
            top:    BorderSide(color: AppColors.pinkLight, width: 1),
            left:   BorderSide(color: AppColors.pinkLight, width: 1),
          ),
          boxShadow: [BoxShadow(color: AppColors.pink.withValues(alpha: 0.5), blurRadius: 12)],
        ),
        child: Center(
          child: Text('＋', style: AppTheme.pixelStyle(size: 18, color: AppColors.navy)),
        ),
      ),
    );
  }
}
