import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';

class LetterCell extends StatelessWidget {
  const LetterCell({
    super.key,
    required this.letter,
    required this.isSelected,
    this.isFound = false,
    this.isInvalid = false,
    this.isHint = false,
    this.isJustFound = false,
  });

  final String letter;
  final bool isSelected;
  final bool isFound;
  final bool isInvalid;
  final bool isHint;
  final bool isJustFound;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    late Color background, foreground;
    late FontWeight weight;

    if (isJustFound) {
      background = cs.secondary.withValues(alpha: 0.5);
      foreground = cs.secondary;
      weight = FontWeight.w800;
    } else if (isFound) {
      background = cs.secondary.withValues(alpha: 0.28);
      foreground = cs.secondary;
      weight = FontWeight.w700;
    } else if (isHint) {
      background = const Color(0xFFFFC107).withValues(alpha: 0.45);
      foreground = const Color(0xFF5D4037);
      weight = FontWeight.w700;
    } else if (isInvalid) {
      background = cs.error.withValues(alpha: 0.22);
      foreground = cs.error;
      weight = FontWeight.w700;
    } else if (isSelected) {
      background = cs.primary;
      foreground = cs.onPrimary;
      weight = FontWeight.w700;
    } else {
      background = cs.surface;
      foreground = cs.onSurface;
      weight = FontWeight.w600;
    }

    return AnimatedScale(
      scale: isSelected || isJustFound ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          border: Border.all(
            color: isSelected || isFound || isInvalid || isHint || isJustFound
                ? Colors.transparent
                : cs.onSurface.withValues(alpha: 0.08),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            letter,
            style: theme.textTheme.titleMedium?.copyWith(
              color: foreground,
              fontWeight: weight,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
