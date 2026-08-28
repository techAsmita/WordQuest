import 'position.dart';

enum LineStatus { valid, notStraight, outOfBounds }

class LineResult {
  const LineResult._({required this.status, required this.cells});
  factory LineResult.valid(List<Position> cells) =>
      LineResult._(status: LineStatus.valid, cells: cells);
  factory LineResult.invalid(LineStatus status) =>
      LineResult._(status: status, cells: const []);
  final LineStatus status;
  final List<Position> cells;
  bool get isValid => status == LineStatus.valid;
}

class SelectionGeometry {
  SelectionGeometry._();
  static LineResult resolveLine({
    required Position start, required Position end, required int size,
  }) {
    if (!_inBounds(start, size) || !_inBounds(end, size)) {
      return LineResult.invalid(LineStatus.outOfBounds);
    }
    final dRow = end.row - start.row;
    final dCol = end.col - start.col;
    if (dRow == 0 && dCol == 0) return LineResult.valid([start]);
    final absRow = dRow.abs();
    final absCol = dCol.abs();
    final isHorizontal = dRow == 0;
    final isVertical = dCol == 0;
    final isDiagonal = absRow == absCol;
    if (!isHorizontal && !isVertical && !isDiagonal) {
      return LineResult.invalid(LineStatus.notStraight);
    }
    final steps = absRow > absCol ? absRow : absCol;
    final stepRow = dRow ~/ steps;
    final stepCol = dCol ~/ steps;
    final cells = <Position>[];
    for (var i = 0; i <= steps; i++) {
      cells.add(Position(start.row + stepRow * i, start.col + stepCol * i));
    }
    return LineResult.valid(cells);
  }
  static bool _inBounds(Position p, int size) =>
      p.row >= 0 && p.row < size && p.col >= 0 && p.col < size;
}
