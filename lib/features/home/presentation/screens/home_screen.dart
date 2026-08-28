import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/home_hero.dart';
import '../widgets/how_to_play_dialog.dart';
import '../widgets/menu_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.06),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingM,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 3),
                    const HomeHero(),
                    const Spacer(flex: 3),
                    MenuButton(
                      label: AppStrings.play,
                      icon: Icons.play_arrow_rounded,
                      isPrimary: true,
                      onPressed: () => context.goNamed('levels'),
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    MenuButton(
                      label: AppStrings.howToPlay,
                      icon: Icons.help_outline_rounded,
                      onPressed: () => showHowToPlayDialog(context),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    MenuButton(
                      label: AppStrings.settings,
                      icon: Icons.settings_outlined,
                      onPressed: () => context.goNamed('settings'),
                    ),
                    const Spacer(),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                        children: [
                          const TextSpan(text: 'Crafted with '),
                          TextSpan(
                            text: 'Flutter 💙',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const TextSpan(text: '  by  '),
                          TextSpan(
                            text: 'Asmita Roy',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
