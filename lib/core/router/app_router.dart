import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/game/presentation/screens/game_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/levels/presentation/screens/level_select_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../audio/game_feedback.dart';
import '../storage/storage.dart';

class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String game = '/game';
  static const String settings = '/settings';
  static const String levels = '/levels';

  static ProgressRepository? _progress;
  static SettingsRepository? _settings;
  static GameFeedback? _feedback;

  static ProgressRepository get progressRepository {
    final p = _progress;
    if (p == null) {
      throw StateError('Call AppRouter.bindRepositories before runApp');
    }
    return p;
  }

  static SettingsRepository get settingsRepository {
    final s = _settings;
    if (s == null) {
      throw StateError('Call AppRouter.bindRepositories before runApp');
    }
    return s;
  }

  static GameFeedback get feedback {
    final f = _feedback;
    if (f == null) {
      throw StateError('Call AppRouter.bindRepositories before runApp');
    }
    return f;
  }

  static void bindRepositories({
    required ProgressRepository progress,
    required SettingsRepository settings,
  }) {
    _progress = progress;
    _settings = settings;
    _feedback = GameFeedback(settings);
  }

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: levels,
        name: 'levels',
        builder: (context, state) => LevelSelectScreen(
          progressRepository: progressRepository,
        ),
      ),
      GoRoute(
        path: game,
        name: 'game',
        builder: (context, state) {
          final raw = state.uri.queryParameters['level'];
          final level = int.tryParse(raw ?? '') ?? 1;
          return GameScreen(
            progressRepository: progressRepository,
            feedback: feedback,
            initialLevelNumber: level,
          );
        },
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => SettingsScreen(
          settings: settingsRepository,
          progress: progressRepository,
          feedback: feedback,
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
}
