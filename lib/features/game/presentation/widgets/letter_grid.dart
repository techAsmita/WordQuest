import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/position.dart';
import 'letter_cell.dart';

/// Responsive N×N grid. Uses Listener + GestureDetector so parent scroll
/// views do not steal the drag.
class LetterGrid extends StatefulWidget {
  const LetterGrid({
    super.key,
    required this.grid,
    required this.selectedCells,
    required this.foundCells,
    required this.onSelectionStart,
    required this.onSelectionUpdate,
    required this.onSelectionEnd,
    this.invalidCells = const {},
    this.hintCells = const {},
    this.justFoundCells = const {},
  });

  final List<List<String>> grid;
  final Set<Position> selectedCells;
  final Set<Position> foundCells;
  final Set<Position> invalidCells;
  final Set<Position> hintCells;
  final Set<Position> justFoundCells;

  final ValueChanged<Position> onSelectionStart;
  final ValueChanged<Position> onSelectionUpdate;
  final ValueChanged<Position> onSelectionEnd;

  @override
  State<LetterGrid> createState() => _LetterGridState();
}

class _LetterGridState extends State<LetterGrid> {
  final GlobalKey _gridKey = GlobalKey();
  double _gridSide = 0;
  Position? _lastCell;
  bool _dragging = false;

  int get _n => widget.grid.length;
  static const double _gap = AppSizes.paddingXS;

  Position? _cellAtGlobal(Offset global) {
    final box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || _gridSide <= 0 || _n <= 0) return null;

    final local = box.globalToLocal(global);
    if (local.dx < -4 ||
        local.dy < -4 ||
        local.dx > _gridSide + 4 ||
        local.dy > _gridSide + 4) {
      return _lastCell;
    }

    final cellSide = (_gridSide - _gap * (_n - 1)) / _n;
    if (cellSide <= 0) return null;

    final stride = cellSide + _gap;
    final dx = local.dx.clamp(0.0, _gridSide - 0.001);
    final dy = local.dy.clamp(0.0, _gridSide - 0.001);

    final col = (dx / stride).floor().clamp(0, _n - 1);
    final row = (dy / stride).floor().clamp(0, _n - 1);
    return Position(row, col);
  }

  void _onStart(Offset global) {
    final cell = _cellAtGlobal(global);
    if (cell == null) return;
    _dragging = true;
    _lastCell = cell;
    widget.onSelectionStart(cell);
  }

  void _onUpdate(Offset global) {
    if (!_dragging) return;
    final cell = _cellAtGlobal(global);
    if (cell == null || cell == _lastCell) return;
    _lastCell = cell;
    widget.onSelectionUpdate(cell);
  }

  void _onEnd() {
    if (!_dragging) return;
    final cell = _lastCell;
    _dragging = false;
    if (cell != null) widget.onSelectionEnd(cell);
    _lastCell = null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSide = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        // Phone-friendly: leave room for HUD + word list
        _gridSide = maxSide.clamp(180.0, 420.0);
        final n = _n;

        return Listener(
          onPointerDown: (e) => _onStart(e.position),
          onPointerMove: (e) => _onUpdate(e.position),
          onPointerUp: (_) => _onEnd(),
          onPointerCancel: (_) => _onEnd(),
          child: SizedBox(
            key: _gridKey,
            width: _gridSide,
            height: _gridSide,
            child: Column(
              children: [
                for (var r = 0; r < n; r++) ...[
                  if (r > 0) const SizedBox(height: _gap),
                  Expanded(
                    child: Row(
                      children: [
                        for (var c = 0; c < n; c++) ...[
                          if (c > 0) const SizedBox(width: _gap),
                          Expanded(
                            child: LetterCell(
                              letter: widget.grid[r][c],
                              isSelected: widget.selectedCells
                                  .contains(Position(r, c)),
                              isFound: widget.foundCells
                                  .contains(Position(r, c)),
                              isInvalid: widget.invalidCells
                                  .contains(Position(r, c)),
                              isHint: widget.hintCells
                                  .contains(Position(r, c)),
                              isJustFound: widget.justFoundCells
                                  .contains(Position(r, c)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
