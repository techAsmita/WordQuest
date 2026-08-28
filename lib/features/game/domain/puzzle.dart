import 'word_placement.dart';

class Puzzle {
  const Puzzle({required this.grid, required this.placements, required this.words});
  final List<List<String>> grid;
  final List<WordPlacement> placements;
  final List<String> words;
  int get size => grid.length;
  String wordAt(WordPlacement placement) =>
      placement.cells.map((p) => grid[p.row][p.col]).join();
  bool get isValid {
    if (placements.length != words.length) return false;
    for (final p in placements) {
      if (wordAt(p) != p.word) return false;
    }
    return true;
  }
  @override
  String toString() {
    final b = StringBuffer();
    for (final row in grid) { b.writeln(row.join(' ')); }
    return b.toString();
  }
}
