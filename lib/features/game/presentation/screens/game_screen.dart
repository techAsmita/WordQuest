import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/audio/game_feedback.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/storage/storage.dart';
import '../../domain/domain.dart';
import '../widgets/letter_grid.dart';
import '../widgets/points_popup.dart';
import '../widgets/score_bar.dart';
import '../widgets/word_list_panel.dart';
import '../../../../core/theme/app_theme.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.progressRepository,
    required this.feedback,
    this.initialLevelNumber = 1,
  });

  final ProgressRepository progressRepository;
  final GameFeedback feedback;
  final int initialLevelNumber;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late LevelProgress _progress;
  late GameController _controller;
  Timer? _ticker;

  Set<Position> _selectedCells = {};
  Position? _dragStart;
  Set<Position> _invalidCells = {};
  Timer? _invalidFlashTimer;
  Set<Position> _hintCells = {};
  Timer? _hintFlashTimer;
  Set<Position> _justFoundCells = {};
  Timer? _justFoundTimer;

  int? _pointsPopupValue;
  int _pointsPopupKey = 0;

  LevelRecord? _bestRecord;
  LevelRecord? _lastSaved;
  bool _isNewRecord = false;
  bool _savedThisCompletion = false;

  late AnimationController _celebrateController;
  late Animation<double> _celebrateScale;

  @override
  void initState() {
    super.initState();
    _progress = LevelProgress(
      random: Random(),
      startIndex: widget.initialLevelNumber - 1,
    );
    _celebrateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _celebrateScale = CurvedAnimation(
      parent: _celebrateController,
      curve: Curves.elasticOut,
    );
    _startLevel();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _invalidFlashTimer?.cancel();
    _hintFlashTimer?.cancel();
    _justFoundTimer?.cancel();
    _celebrateController.dispose();
    super.dispose();
  }

  Future<void> _loadBest() async {
    final record = await widget.progressRepository
        .recordForLevel(_progress.current.levelNumber);
    if (mounted) setState(() => _bestRecord = record);
  }

  void _startLevel() {
    _ticker?.cancel();
    _invalidFlashTimer?.cancel();
    _hintFlashTimer?.cancel();
    _justFoundTimer?.cancel();
    _selectedCells = {};
    _invalidCells = {};
    _hintCells = {};
    _justFoundCells = {};
    _dragStart = null;
    _pointsPopupValue = null;
    _isNewRecord = false;
    _savedThisCompletion = false;
    _lastSaved = null;
    _celebrateController.reset();
    final puzzle = _progress.generatePuzzle();
    _controller = GameController(puzzle);
    _loadBest();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_controller.state.isComplete) {
        _ticker?.cancel();
        _onLevelComplete();
        return;
      }
      setState(() {});
    });
  }

  Future<void> _onLevelComplete() async {
    if (_savedThisCompletion) {
      if (mounted) setState(() {});
      return;
    }
    _savedThisCompletion = true;
    await widget.feedback.levelComplete();
    final score = _controller.state.score;
    final time = _controller.elapsedSeconds;
    final level = _progress.current.levelNumber;
    final previous =
        await widget.progressRepository.recordForLevel(level);
    final saved = await widget.progressRepository.saveIfBetter(
      levelNumber: level,
      score: score,
      timeSeconds: time,
    );
    final isNew = LevelRecord(bestScore: score, bestTimeSeconds: time)
        .isBetterThan(previous);
    if (!mounted) return;
    setState(() {
      _lastSaved = saved;
      _bestRecord = saved;
      _isNewRecord = isNew;
    });
    _celebrateController.forward(from: 0);
  }

  void _restartCurrentLevel() => setState(_startLevel);

  void _goToNextLevel() {
    if (!_progress.advance()) {
      context.goNamed('levels');
      return;
    }
    setState(_startLevel);
  }

  Set<Position> get _foundCells {
    final cells = <Position>{};
    final found = _controller.state.foundWords;
    for (final placement in _controller.state.puzzle.placements) {
      if (found.contains(placement.word)) cells.addAll(placement.cells);
    }
    return cells;
  }

  void _onSelectionStart(Position cell) {
    if (_controller.state.isComplete) return;
    _invalidFlashTimer?.cancel();
    setState(() {
      _invalidCells = {};
      _dragStart = cell;
      _selectedCells = {cell};
    });
  }

  void _onSelectionUpdate(Position cell) {
    final start = _dragStart;
    if (start == null || _controller.state.isComplete) return;
    final line = SelectionGeometry.resolveLine(
      start: start,
      end: cell,
      size: _controller.state.puzzle.size,
    );
    setState(() {
      _selectedCells = line.isValid ? line.cells.toSet() : {start, cell};
    });
  }

  void _onSelectionEnd(Position cell) {
    final start = _dragStart;
    _dragStart = null;
    if (start == null || _controller.state.isComplete) {
      setState(() => _selectedCells = {});
      return;
    }
    final result = _controller.select(start, cell);
    setState(() {
      _selectedCells = {};
      if (result.status == SelectionStatus.found) {
        _invalidCells = {};
        _justFoundCells = result.cells.toSet();
        _justFoundTimer?.cancel();
        _justFoundTimer = Timer(const Duration(milliseconds: 480), () {
          if (mounted) setState(() => _justFoundCells = {});
        });
        if (result.pointsAwarded > 0) {
          _pointsPopupKey++;
          _pointsPopupValue = result.pointsAwarded;
        }
        widget.feedback.validSelection();
      } else if (result.status == SelectionStatus.alreadyFound) {
        _invalidCells = {};
        widget.feedback.invalidSelection();
      } else if (result.cells.isNotEmpty) {
        _invalidCells = result.cells.toSet();
        _invalidFlashTimer?.cancel();
        _invalidFlashTimer = Timer(const Duration(milliseconds: 420), () {
          if (mounted) setState(() => _invalidCells = {});
        });
        widget.feedback.invalidSelection();
      }
    });
    if (result.status == SelectionStatus.found &&
        _controller.state.isComplete) {
      _ticker?.cancel();
      _onLevelComplete();
    }
    _showSelectionFeedback(result);
  }

  void _showSelectionFeedback(SelectionResult result) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    switch (result.status) {
      case SelectionStatus.found:
        messenger.showSnackBar(SnackBar(
          content: Text('Found ${result.word}! +${result.pointsAwarded}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1000),
        ));
      case SelectionStatus.alreadyFound:
        messenger.showSnackBar(SnackBar(
          content: Text('${result.word} already found'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 800),
        ));
      default:
        break;
    }
  }

  void _useHint() {
    final result = _controller.useHint();
    if (!result.isSuccess) return;
    widget.feedback.hintUsed();
    _hintFlashTimer?.cancel();
    setState(() => _hintCells = result.cells.toSet());
    _hintFlashTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _hintCells = {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final level = _progress.current;
    final elapsed = _controller.elapsedSeconds;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: AppStrings.back,
          onPressed: () => context.goNamed('levels'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: AppStrings.restart,
            onPressed: _restartCurrentLevel,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.paddingM,
            AppSizes.paddingS,
            AppSizes.paddingM,
            AppSizes.paddingS + bottomInset * 0.25,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScoreBar(
                levelNumber: level.levelNumber,
                levelName: level.name,
                score: state.score,
                elapsedSeconds: elapsed,
                foundCount: state.foundCount,
                totalWords: state.totalWords,
                hintsRemaining: _controller.hintsRemaining,
                onHint: _controller.canUseHint ? _useHint : null,
              ),
              if (_bestRecord != null) ...[
                const SizedBox(height: 6),
                Text(
                  '${AppStrings.bestScore}: ${_bestRecord!.bestScore}  ·  '
                  '${AppStrings.bestTime}: ${ScoreBar.formatTime(_bestRecord!.bestTimeSeconds)}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
              const SizedBox(height: AppSizes.paddingS),
              Expanded(
                flex: 5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Absorb vertical drag so outer scroll doesn't fight selection
                    NotificationListener<ScrollNotification>(
                      onNotification: (_) => true,
                      child: Center(
                        child: LetterGrid(
                          grid: state.puzzle.grid,
                          selectedCells: _selectedCells,
                          foundCells: _foundCells,
                          invalidCells: _invalidCells,
                          hintCells: _hintCells,
                          justFoundCells: _justFoundCells,
                          onSelectionStart: _onSelectionStart,
                          onSelectionUpdate: _onSelectionUpdate,
                          onSelectionEnd: _onSelectionEnd,
                        ),
                      ),
                    ),
                    if (_pointsPopupValue != null)
                      PointsPopup(
                        key: ValueKey(_pointsPopupKey),
                        points: _pointsPopupValue!,
                        onDone: () {
                          if (mounted) {
                            setState(() => _pointsPopupValue = null);
                          }
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingS),
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      WordListPanel(
                        words: state.puzzle.words,
                        foundWords: state.foundWords,
                      ),
                      if (state.isComplete) ...[
                        const SizedBox(height: AppSizes.paddingM),
                        ScaleTransition(
                          scale: _celebrateScale,
                          child: _CompletionBanner(
                            elapsedSeconds: elapsed,
                            score: state.score,
                            currentLevel: level,
                            nextLevel: _progress.nextLevel,
                            isNewRecord: _isNewRecord,
                            bestRecord: _lastSaved ?? _bestRecord,
                            onNext: _goToNextLevel,
                            onReplay: _restartCurrentLevel,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSizes.paddingS),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner({
    required this.elapsedSeconds,
    required this.score,
    required this.currentLevel,
    required this.nextLevel,
    required this.isNewRecord,
    required this.bestRecord,
    required this.onNext,
    required this.onReplay,
  });

  final int elapsedSeconds;
  final int score;
  final LevelConfig currentLevel;
  final LevelConfig? nextLevel;
  final bool isNewRecord;
  final LevelRecord? bestRecord;
  final VoidCallback onNext;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final timeLabel = ScoreBar.formatTime(elapsedSeconds);
    final hasNext = nextLevel != null;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.secondary.withValues(alpha: 0.16),
            cs.secondary.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: cs.secondary.withValues(alpha: 0.25)),
        boxShadow: AppTheme.softShadow(cs.secondary, opacity: 0.18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.secondary.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.celebration_rounded, color: cs.secondary, size: 26),
              ),
              const SizedBox(width: AppSizes.paddingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.foundAll,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppStrings.score}: $score   ·   ${AppStrings.time}: $timeLabel',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${AppStrings.level} ${currentLevel.levelNumber} · ${currentLevel.name}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                    if (isNewRecord)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          AppStrings.newRecord,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    else if (bestRecord != null)
                      Text(
                        '${AppStrings.bestScore}: ${bestRecord!.bestScore}  ·  '
                        '${AppStrings.bestTime}: ${ScoreBar.formatTime(bestRecord!.bestTimeSeconds)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    if (hasNext)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Up next: ${AppStrings.level} ${nextLevel!.levelNumber} — ${nextLevel!.name}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReplay,
                  child: const Text(AppStrings.playAgain),
                ),
              ),
              const SizedBox(width: AppSizes.paddingS),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  child: Text(
                    hasNext ? AppStrings.nextLevel : AppStrings.levels,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
