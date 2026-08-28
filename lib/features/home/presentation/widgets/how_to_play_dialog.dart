import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

Future<void> showHowToPlayDialog(BuildContext context) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;

  Widget bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 7),
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
          ],
        ),
      );

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.help_outline_rounded, color: cs.primary, size: 28),
      ),
      title: const Text(AppStrings.howToPlay, textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find every word hidden in the grid.',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            bullet('Press a letter, drag in a straight line (horizontal, vertical, or diagonal), then release.'),
            bullet('Words may appear forwards or backwards.'),
            bullet('Score: 10 points per letter in each new word.'),
            bullet('Hints: lightbulb (3 per level). Briefly shows one word (−15 points).'),
            bullet('Clear a level to unlock the next.'),
            bullet('Best score and time per level are saved on this device.'),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ),
      ],
    ),
  );
}
