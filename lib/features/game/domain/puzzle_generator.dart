import 'dart:math';
import 'direction.dart';
import 'position.dart';
import 'puzzle.dart';
import 'word_placement.dart';

class PuzzleConfig {
  const PuzzleConfig({
    this.size = 8,
    this.allowReverse = true,
    this.allowDiagonal = true,
    this.maxAttemptsPerWord = 50,
    this.fillEmptyWithRandom = true,
    this.seed,
  });
  final int size;
  final bool allowReverse;
  final bool allowDiagonal;
  final int maxAttemptsPerWord;
  final bool fillEmptyWithRandom;
  final int? seed;
}

class PuzzleGenerator {
  PuzzleGenerator({Random? random}) : _random = random ?? Random();
  final Random _random;

  Puzzle generate(List<String> words, {PuzzleConfig config = const PuzzleConfig()}) {
    final normalized = _normalize(words, config.size);
    final random = config.seed != null ? Random(config.seed) : _random;
    final grid = List.generate(config.size, (_) => List<String?>.filled(config.size, null));
    final placements = <WordPlacement>[];
    final directions = _availableDirections(config);
    final sorted = List<String>.from(normalized)..sort((a, b) => b.length.compareTo(a.length));

    for (final word in sorted) {
      final placement = _placeWord(
        word: word, grid: grid, directions: directions,
        maxAttempts: config.maxAttemptsPerWord, random: random);
      if (placement != null) placements.add(placement);
    }

    if (config.fillEmptyWithRandom) {
      _fillEmpty(grid, random);
    } else {
      for (var r = 0; r < config.size; r++) {
        for (var c = 0; c < config.size; c++) { grid[r][c] ??= '.'; }
      }
    }

    final finalGrid = grid.map((row) => row.map((c) => c!).toList()).toList();
    final placedWords = placements.map((p) => p.word).toList();
    return Puzzle(grid: finalGrid, placements: placements, words: placedWords);
  }

  List<String> _normalize(List<String> words, int size) {
    final result = <String>[];
    for (final raw in words) {
      final w = raw.trim().toUpperCase();
      if (w.isEmpty) continue;
      if (!RegExp(r'^[A-Z]+$').hasMatch(w)) {
        throw ArgumentError('Word "$raw" contains non-letter characters');
      }
      if (w.length > size) {
        throw ArgumentError('Word "$w" (length ${w.length}) exceeds grid size $size');
      }
      result.add(w);
    }
    if (result.isEmpty) throw ArgumentError('At least one valid word is required');
    return result;
  }

  List<Direction> _availableDirections(PuzzleConfig config) {
    var dirs = <Direction>[Direction.horizontal, Direction.vertical];
    if (config.allowDiagonal) {
      dirs.addAll([Direction.diagonalDownRight, Direction.diagonalDownLeft]);
    }
    if (config.allowReverse) {
      dirs = [...dirs, ...dirs.map(_reverseOf).whereType<Direction>()];
    }
    return dirs;
  }

  Direction? _reverseOf(Direction d) {
    switch (d) {
      case Direction.horizontal: return Direction.horizontalReverse;
      case Direction.vertical: return Direction.verticalReverse;
      case Direction.diagonalDownRight: return Direction.diagonalUpLeft;
      case Direction.diagonalDownLeft: return Direction.diagonalUpRight;
      default: return null;
    }
  }

  WordPlacement? _placeWord({
    required String word,
    required List<List<String?>> grid,
    required List<Direction> directions,
    required int maxAttempts,
    required Random random,
  }) {
    final size = grid.length;
    final candidates = <_Candidate>[];
    for (final dir in directions) {
      for (var r = 0; r < size; r++) {
        for (var c = 0; c < size; c++) {
          final start = Position(r, c);
          if (_fits(word, start, dir, size) && _canPlace(word, start, dir, grid)) {
            candidates.add(_Candidate(start, dir));
          }
        }
      }
    }
    if (candidates.isEmpty) return null;
    candidates.shuffle(random);
    final attempts = min(maxAttempts, candidates.length);
    for (var i = 0; i < attempts; i++) {
      final cand = candidates[i];
      if (_canPlace(word, cand.start, cand.direction, grid)) {
        _write(word, cand.start, cand.direction, grid);
        return WordPlacement(word: word, start: cand.start, direction: cand.direction);
      }
    }
    return null;
  }

  bool _fits(String word, Position start, Direction dir, int size) {
    final endRow = start.row + dir.dRow * (word.length - 1);
    final endCol = start.col + dir.dCol * (word.length - 1);
    return endRow >= 0 && endRow < size && endCol >= 0 && endCol < size;
  }

  bool _canPlace(String word, Position start, Direction dir, List<List<String?>> grid) {
    for (var i = 0; i < word.length; i++) {
      final pos = start.offset(dir.dRow * i, dir.dCol * i);
      final existing = grid[pos.row][pos.col];
      if (existing != null && existing != word[i]) return false;
    }
    return true;
  }

  void _write(String word, Position start, Direction dir, List<List<String?>> grid) {
    for (var i = 0; i < word.length; i++) {
      final pos = start.offset(dir.dRow * i, dir.dCol * i);
      grid[pos.row][pos.col] = word[i];
    }
  }

  void _fillEmpty(List<List<String?>> grid, Random random) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (var r = 0; r < grid.length; r++) {
      for (var c = 0; c < grid[r].length; c++) {
        grid[r][c] ??= letters[random.nextInt(letters.length)];
      }
    }
  }
}

class _Candidate {
  const _Candidate(this.start, this.direction);
  final Position start;
  final Direction direction;
}
