import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            gradient: AppTheme.heroGradient,
            shape: BoxShape.circle,
            boxShadow: AppTheme.softShadow(theme.colorScheme.primary, opacity: 0.35),
          ),
          child: const Icon(Icons.grid_view_rounded, size: 48, color: Colors.white),
        ),
        const SizedBox(height: AppSizes.paddingXL),
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.heroGradient.createShader(bounds),
          child: Text(
            AppStrings.appName,
            style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          AppStrings.tagline,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
