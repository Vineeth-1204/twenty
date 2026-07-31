import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (ctx, prov, _) => Container(
        width: 220,
        color: AppColors.navyMid,
        child: Column(
          children: [
            // Top border accent
            Container(height: 3, color: AppColors.pink),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // Search
                  _SearchBox(prov: prov),
                  const SizedBox(height: 16),

                  // Filter chips
                  const _SectionLabel(label: '◆ CATEGORIES ◆'),
                  const SizedBox(height: 6),
                  _FilterChips(prov: prov),
                  const SizedBox(height: 16),

                  // Sort
                  const _SectionLabel(label: '◆ SORT BY ◆'),
                  const SizedBox(height: 6),
                  _SortButtons(prov: prov),
                  const SizedBox(height: 16),

                  // Tags
                  const _SectionLabel(label: '◆ TAGS ◆'),
                  const SizedBox(height: 6),
                  _TagCloud(prov: prov),
                  const SizedBox(height: 16),

                  // Stats
                  const _SectionLabel(label: '◆ STATS ◆'),
                  const SizedBox(height: 6),
                  _StatsGrid(prov: prov),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search ────────────────────────────────────────────────────────────────────
class _SearchBox extends StatefulWidget {
  final NotesProvider prov;
  const _SearchBox({required this.prov});

  @override
  State<_SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<_SearchBox> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navy,
        border: Border.all(color: AppColors.pink, width: 2),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text('🔍', style: TextStyle(fontSize: 14)),
          ),
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: AppTheme.jpStyle(size: 12),
              decoration: const InputDecoration(
                hintText: '検索… Search…',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                isDense: true,
              ),
              onChanged: widget.prov.setSearch,
            ),
          ),
          if (_ctrl.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _ctrl.clear();
                widget.prov.setSearch('');
              },
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Text('✕', style: TextStyle(color: AppColors.pink, fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Filter chips ──────────────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  final NotesProvider prov;
  const _FilterChips({required this.prov});

  @override
  Widget build(BuildContext context) {
    final filters = [
      (FilterMode.all,      'ALL (${prov.totalCount})'),
      (FilterMode.pinned,   '📌 PINNED'),
      (FilterMode.archived, '🗃 ARCHIVED'),
    ];
    return Column(
      children: filters.map((f) {
        final active = prov.filter == f.$1;
        return GestureDetector(
          onTap: () => prov.setFilter(f.$1),
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: active ? AppColors.pink : AppColors.navy,
              border: Border.all(
                color: active ? AppColors.pink : AppColors.pink.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: active
                ? [const BoxShadow(color: AppColors.magenta, offset: Offset(2, 2), blurRadius: 0)]
                : null,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                f.$2,
                style: AppTheme.pixelStyle(
                  size: 7,
                  color: active ? AppColors.navy : AppColors.cream,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Sort buttons ──────────────────────────────────────────────────────────────
class _SortButtons extends StatelessWidget {
  final NotesProvider prov;
  const _SortButtons({required this.prov});

  @override
  Widget build(BuildContext context) {
    final sorts = [
      (SortMode.modified, 'MODIFIED'),
      (SortMode.created,  'CREATED'),
      (SortMode.title,    'TITLE A-Z'),
    ];
    return Column(
      children: sorts.map((s) {
        final active = prov.sort == s.$1;
        return GestureDetector(
          onTap: () => prov.setSort(s.$1),
          child: Container(
            margin: const EdgeInsets.only(bottom: 3),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            decoration: BoxDecoration(
              color: active ? AppColors.yellow.withValues(alpha: 0.08) : AppColors.navy,
              border: Border.all(
                color: active ? AppColors.yellow : Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                s.$2,
                style: AppTheme.pixelStyle(
                  size: 6.5,
                  color: active ? AppColors.yellow : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Tag cloud ─────────────────────────────────────────────────────────────────
class _TagCloud extends StatelessWidget {
  final NotesProvider prov;
  const _TagCloud({required this.prov});

  @override
  Widget build(BuildContext context) {
    final tags = prov.allTags;
    if (tags.isEmpty) {
      return Text(
        'No tags yet!',
        style: AppTheme.pixelStyle(size: 6, color: Colors.white38),
      );
    }
    final sorted = tags.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: sorted.map((e) {
        final active = prov.activeTagFilter == e.key;
        return GestureDetector(
          onTap: () => prov.setTagFilter(active ? null : e.key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: active ? AppColors.cyan : AppColors.navy,
              border: Border.all(color: AppColors.cyan, width: 1),
            ),
            child: Text(
              '${e.key} (${e.value})',
              style: AppTheme.pixelStyle(
                size: 5.5,
                color: active ? AppColors.navy : AppColors.cyan,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final NotesProvider prov;
  const _StatsGrid({required this.prov});

  @override
  Widget build(BuildContext context) {
    final words = prov.totalWords;
    final wordsStr = words > 999 ? '${(words / 1000).toStringAsFixed(1)}k' : '$words';
    final stats = [
      ('${prov.totalCount}', 'TOTAL'),
      ('${prov.pinnedCount}', 'PINNED'),
      (wordsStr, 'WORDS'),
    ];
    return Row(
      children: stats.map((s) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.navy,
            border: Border.all(color: AppColors.pink.withValues(alpha: 0.2), width: 2),
          ),
          child: Column(
            children: [
              Text(
                s.$1,
                style: AppTheme.monoStyle(size: 26, color: AppColors.cyan),
              ),
              const SizedBox(height: 2),
              Text(
                s.$2,
                style: AppTheme.pixelStyle(size: 5, color: Colors.white38),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x55FF3EA5), width: 1)),
      ),
      child: Text(
        label,
        style: AppTheme.pixelStyle(size: 6, color: AppColors.pink),
      ),
    );
  }
}
