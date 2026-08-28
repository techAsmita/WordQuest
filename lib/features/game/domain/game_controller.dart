import 'game_state.dart';
import 'hint_config.dart';
import 'hint_result.dart';
import 'position.dart';
import 'puzzle.dart';
import 'selection.dart';
import 'selection_result.dart';

typedef Clock = DateTime Function();

class GameController {
  GameController(
    Puzzle puzzle, {
    Clock? clock,
    int? initialHints,
  })  : _clock = clock ?? DateTime.now,
        _hintsRemaining = initialHints ?? HintConfig.hintsPerLevel,
        _state = GameState.initial(
          puzzle,
          startedAt: (clock ?? DateTime.now)(),
        );

  final Clock _clock;
  GameState _state;
  int _hintsRemaining;

  GameState get state => _state;
  int get hintsRemaining => _hintsRemaining;
  bool get canUseHint =>
      _hintsRemaining > 0 &&
      !_state.isComplete &&
      _state.remainingWords.isNotEmpty;

  Duration get elapsed => _state.elapsedAt(_clock());
  int get elapsedSeconds => _state.elapsedSecondsAt(_clock());

  static int pointsFor(int wordLength) => wordLength * 10;

  SelectionResult select(Position start, Position end) {
    if (_state.isComplete) {
      return const SelectionResult(
        status: SelectionStatus.alreadyFound,
        cells: [],
      );
    }

    final size = _state.puzzle.size;
    final line = SelectionGeometry.resolveLine(
      start: start, end: end, size: size,
    );

    if (line.status == LineStatus.outOfBounds) {
      return const SelectionResult(
        status: SelectionStatus.outOfBounds, cells: []);
    }
    if (line.status == LineStatus.notStraight) {
      return const SelectionResult(
        status: SelectionStatus.notStraight, cells: []);
    }

    final cells = line.cells;
    if (cells.length < 2) {
      _state = _state.copyWith(lastSelectedCells: cells);
      return SelectionResult(status: SelectionStatus.tooShort, cells: cells);
    }

    final letters =
        cells.map((p) => _state.puzzle.grid[p.row][p.col]).join();
    final reversed = letters.split('').reversed.join();

    String? matchedWord;
    for (final w in _state.puzzle.words.toSet()) {
      if (w == letters || w == reversed) {
        matchedWord = w;
        break;
      }
    }

    if (matchedWord == null) {
      _state = _state.copyWith(lastSelectedCells: cells);
      return SelectionResult(status: SelectionStatus.notAWord, cells: cells);
    }

    if (_state.foundWords.contains(matchedWord)) {
      _state = _state.copyWith(lastSelectedCells: cells);
      return SelectionResult(
        status: SelectionStatus.alreadyFound,
        cells: cells,
        word: matchedWord,
      );
    }

    final points = pointsFor(matchedWord.length);
    final newFound = Set<String>.from(_state.foundWords)..add(matchedWord);
    final willComplete =
        newFound.length >= _state.puzzle.words.toSet().length;

    _state = _state.copyWith(
      foundWords: newFound,
      score: _state.score + points,
      lastSelectedCells: cells,
      completedAt: willComplete ? _clock() : null,
    );

    return SelectionResult(
      status: SelectionStatus.found,
      cells: cells,
      word: matchedWord,
      pointsAwarded: points,
    );
  }

  HintResult useHint() {
    if (_state.isComplete) {
      return HintResult(
        status: HintStatus.puzzleComplete,
        hintsRemaining: _hintsRemaining,
      );
    }
    if (_hintsRemaining <= 0) {
      return const HintResult(
        status: HintStatus.noHintsLeft,
        hintsRemaining: 0,
      );
    }
    final remaining = _state.remainingWords;
    if (remaining.isEmpty) {
      return HintResult(
        status: HintStatus.noUnfoundWords,
        hintsRemaining: _hintsRemaining,
      );
    }

    final word = remaining.first;
    final placement = _state.puzzle.placements.firstWhere(
      (p) => p.word == word,
    );

    final cost = HintConfig.pointsCost;
    final previousScore = _state.score;
    final newScore = previousScore >= cost ? previousScore - cost : 0;
    final deducted = previousScore - newScore;

    _hintsRemaining--;
    _state = _state.copyWith(score: newScore);

    return HintResult(
      status: HintStatus.revealed,
      word: placement.word,
      cells: List<Position>.from(placement.cells),
      pointsDeducted: deducted,
      hintsRemaining: _hintsRemaining,
    );
  }

  void reset(Puzzle puzzle, {int? hints}) {
    _state = GameState.initial(puzzle, startedAt: _clock());
    _hintsRemaining = hints ?? HintConfig.hintsPerLevel;
  }

  void clearLastSelection() {
    _state = _state.copyWith(lastSelectedCells: const []);
  }
}
