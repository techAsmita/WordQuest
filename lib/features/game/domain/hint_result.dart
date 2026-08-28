import 'position.dart';

enum HintStatus {
  revealed,
  noHintsLeft,
  puzzleComplete,
  noUnfoundWords,
}

class HintResult {
  const HintResult({
    required this.status,
    this.word,
    this.cells = const [],
    this.pointsDeducted = 0,
    this.hintsRemaining = 0,
  });

  final HintStatus status;
  final String? word;
  final List<Position> cells;
  final int pointsDeducted;
  final int hintsRemaining;

  bool get isSuccess => status == HintStatus.revealed;
}
