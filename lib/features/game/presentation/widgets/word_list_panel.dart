import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

class WordListPanel extends StatelessWidget {
  const WordListPanel({super.key, required this.words, required this.foundWords});
  final List<String> words;
  final Set<String> foundWords;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppStrings.words} · ${foundWords.length}/${words.length}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Wrap(
          spacing: AppSizes.paddingS,
          runSpacing: AppSizes.paddingS,
          children: [
            for (final w in words) _WordChip(word: w, isFound: foundWords.contains(w)),
          ],
        ),
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({required this.word, required this.isFound});
  final String word;
  final bool isFound;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM, vertical: 10),
      decoration: BoxDecoration(
        color: isFound ? cs.secondary.withValues(alpha: 0.14) : cs.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: isFound ? cs.secondary.withValues(alpha: 0.35) : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFound) ...[
            Icon(Icons.check_circle_rounded, size: 14, color: cs.secondary),
            const SizedBox(width: 6),
          ],
          Text(
            word,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: isFound ? cs.secondary : cs.onSurface.withValues(alpha: 0.85),
              decoration: isFound ? TextDecoration.lineThrough : null,
              decorationColor: cs.secondary,
              decorationThickness: 2,
            ),
          ),
        ],
      ),
    );
  }
}
