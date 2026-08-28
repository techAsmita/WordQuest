import 'package:flutter/material.dart';

/// Brief floating "+N" label above the grid after a find.
class PointsPopup extends StatefulWidget {
  const PointsPopup({
    super.key,
    required this.points,
    required this.onDone,
  });

  final int points;
  final VoidCallback onDone;

  @override
  State<PointsPopup> createState() => _PointsPopupState();
}

class _PointsPopupState extends State<PointsPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 35),
    ]).animate(_c);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: const Offset(0, -0.8),
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    _c.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _offset,
          child: Text(
            '+${widget.points}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.secondary,
                ),
          ),
        ),
      ),
    );
  }
}
