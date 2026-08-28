import 'position.dart';
import 'puzzle.dart';

class GameState {
  const GameState({
    required this.puzzle,
    required this.foundWords,
    required this.score,
    required this.startedAt,
    this.completedAt,
    this.lastSelectedCells = const [],
  });

  factory GameState.initial(Puzzle puzzle, {required DateTime startedAt}) =>
      GameState(
        puzzle: puzzle,
        foundWords: const {},
        score: 0,
        startedAt: startedAt,
      );

  final Puzzle puzzle;
  final Set<String> foundWords;
  final int score;
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<Position> lastSelectedCells;

  bool get isComplete =>
      foundWords.length >= puzzle.words.toSet().length;

  bool get isTimerRunning => completedAt == null && !isComplete;

  Set<String> get remainingWords =>
      puzzle.words.toSet().difference(foundWords);

  int get totalWords => puzzle.words.toSet().length;
  int get foundCount => foundWords.length;

  Duration elapsedAt(DateTime now) {
    final end = completedAt ?? now;
    final delta = end.difference(startedAt);
    return delta.isNegative ? Duration.zero : delta;
  }

  int elapsedSecondsAt(DateTime now) => elapsedAt(now).inSeconds;

  GameState copyWith({
    Set<String>? foundWords,
    int? score,
    DateTime? startedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    List<Position>? lastSelectedCells,
  }) {
    return GameState(
      puzzle: puzzle,
      foundWords: foundWords ?? this.foundWords,
      score: score ?? this.score,
      startedAt: startedAt ?? this.startedAt,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
      lastSelectedCells: lastSelectedCells ?? this.lastSelectedCells,
    );
  }
}
