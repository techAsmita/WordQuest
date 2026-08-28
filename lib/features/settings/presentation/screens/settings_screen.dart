import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/audio/game_feedback.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/storage/storage.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.progress,
    required this.feedback,
  });

  final SettingsRepository settings;
  final ProgressRepository progress;
  final GameFeedback feedback;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _sound = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final sound = await widget.settings.getSoundEnabled();
      if (!mounted) return;
      setState(() {
        _sound = sound;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleSound(bool value) async {
    setState(() => _sound = value);
    await widget.settings.setSoundEnabled(value);
    widget.feedback.setSoundEnabled(value);
  }

  Future<void> _resetProgress() async {
    final theme = Theme.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 28),
        ),
        title: const Text('Reset progress?', textAlign: TextAlign.center),
        content: const Text(
          'Clears best scores and times for every level. Cannot be undone.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.progress.resetAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progress reset')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.goNamed('home'),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              children: [
                _SettingsCard(
                  isDark: isDark,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sound'),
                    subtitle: const Text('Clicks and alerts (haptics always on)'),
                    value: _sound,
                    onChanged: _toggleSound,
                    secondary: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _sound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                _SettingsCard(
                  isDark: isDark,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.delete_outline_rounded, color: cs.error),
                    ),
                    title: const Text('Reset progress'),
                    subtitle: const Text('Clear best scores and times'),
                    trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.3)),
                    onTap: _resetProgress,
                  ),
                ),
              ],
            ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child, required this.isDark});
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: AppTheme.softShadow(isDark ? Colors.black : cs.primary, opacity: isDark ? 0.25 : 0.05),
      ),
      child: child,
    );
  }
}
