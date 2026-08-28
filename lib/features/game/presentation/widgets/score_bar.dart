import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';

class ScoreBar extends StatelessWidget {
  const ScoreBar({
    super.key,
    required this.levelNumber,
    required this.levelName,
    required this.score,
    required this.elapsedSeconds,
    required this.foundCount,
    required this.totalWords,
    required this.hintsRemaining,
    this.onHint,
  });

  final int levelNumber;
  final String levelName;
  final int score;
  final int elapsedSeconds;
  final int foundCount;
  final int totalWords;
  final int hintsRemaining;
  final VoidCallback? onHint;

  static String formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final progress = totalWords == 0 ? 0.0 : foundCount / totalWords;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: AppTheme.softShadow(isDark ? Colors.black : cs.primary, opacity: isDark ? 0.25 : 0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${AppStrings.level} $levelNumber · $levelName',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: onHint == null ? cs.onSurface.withValues(alpha: 0.05) : cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: AppStrings.hints,
                  onPressed: onHint,
                  icon: Badge(
                    isLabelVisible: hintsRemaining > 0,
                    backgroundColor: AppTheme.amber,
                    label: Text('$hintsRemaining'),
                    child: Icon(
                      Icons.lightbulb_rounded,
                      color: onHint == null ? cs.onSurface.withValues(alpha: 0.28) : AppTheme.amber,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          Row(
            children: [
              _StatChip(
                icon: Icons.star_rounded,
                iconColor: cs.primary,
                label: '$score',
              ),
              const SizedBox(width: AppSizes.paddingS),
              _StatChip(
                icon: Icons.timer_rounded,
                iconColor: cs.onSurface.withValues(alpha: 0.6),
                label: formatTime(elapsedSeconds),
              ),
              const Spacer(),
              Text(
                '$foundCount / $totalWords',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              tween: Tween(begin: 0, end: progress),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: cs.onSurface.withValues(alpha: 0.07),
                color: cs.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.iconColor, required this.label});
  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
