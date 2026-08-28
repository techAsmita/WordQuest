import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/storage/storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../game/domain/domain.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({
    super.key,
    required this.progressRepository,
  });

  final ProgressRepository progressRepository;

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  Map<int, LevelRecord> _records = {};
  bool _loading = true;
  int _highestUnlocked = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await widget.progressRepository.allRecords();
    var highest = 1;
    for (final entry in all.entries) {
      if (entry.key >= highest) {
        highest = entry.key + 1;
      }
    }
    final maxLevel = LevelCatalog.levels.length;
    if (highest > maxLevel) highest = maxLevel;
    if (!mounted) return;
    setState(() {
      _records = all;
      _highestUnlocked = highest < 1 ? 1 : highest;
      _loading = false;
    });
  }

  void _openLevel(int levelNumber) {
    context.goNamed(
      'game',
      queryParameters: {'level': '$levelNumber'},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final levels = LevelCatalog.levels;
    final completedCount = _records.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.levels),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.goNamed('home'),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.paddingL, AppSizes.paddingS, AppSizes.paddingL, AppSizes.paddingM,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events_rounded, color: cs.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$completedCount of ${levels.length} levels completed',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.paddingL, 0, AppSizes.paddingL, AppSizes.paddingL,
                    ),
                    itemCount: levels.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSizes.paddingM),
                    itemBuilder: (context, index) {
                      final level = levels[index];
                      final n = level.levelNumber;
                      final record = _records[n];
                      final unlocked = n <= _highestUnlocked;
                      final completed = record != null;

                      return _LevelCard(
                        number: n,
                        name: level.name,
                        unlocked: unlocked,
                        completed: completed,
                        record: record,
                        onTap: unlocked ? () => _openLevel(n) : null,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.number,
    required this.name,
    required this.unlocked,
    required this.completed,
    required this.record,
    required this.onTap,
  });

  final int number;
  final String name;
  final bool unlocked;
  final bool completed;
  final LevelRecord? record;
  final VoidCallback? onTap;

  static String _fmt(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: unlocked ? (isDark ? AppTheme.cardDark : Colors.white) : cs.onSurface.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: unlocked ? AppTheme.softShadow(isDark ? Colors.black : cs.primary, opacity: isDark ? 0.28 : 0.06) : null,
        border: unlocked
            ? null
            : Border.all(color: cs.onSurface.withValues(alpha: 0.06)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: unlocked ? AppTheme.heroGradient : null,
                    color: unlocked ? null : cs.onSurface.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Center(
                    child: unlocked
                        ? Text(
                            '$number',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.lock_outline_rounded,
                            color: cs.onSurface.withValues(alpha: 0.3),
                          ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppStrings.level} $number · $name',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: unlocked ? cs.onSurface : cs.onSurface.withValues(alpha: 0.38),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unlocked
                            ? (completed
                                ? '${AppStrings.bestScore}: ${record!.bestScore}  ·  '
                                    '${AppStrings.bestTime}: ${_fmt(record!.bestTimeSeconds)}'
                                : 'Tap to play')
                            : AppStrings.locked,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (completed)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cs.secondary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded, color: cs.secondary, size: 18),
                  )
                else if (unlocked)
                  Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
