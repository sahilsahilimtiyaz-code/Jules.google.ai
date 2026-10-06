import 'dart:math' as math;
import 'package:flutter/material.dart';

// Endless conical glow border.
// Colors loop: blue -> green -> purple -> red -> white -> violet -> blue
// active=true  = rotating + glow (AI working/coding)
// active=false = dim static border, no animation (off, saves battery)
class ConicalGlowBorder extends StatefulWidget {
  final Widget child;
  final bool active;
  final double borderWidth;
  final double radius;
  final Duration duration;

  const ConicalGlowBorder({
    super.key,
    required this.child,
    required this.active,
    this.borderWidth = 2.2,
    this.radius = 22,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ConicalGlowBorder> createState() => _ConicalGlowBorderState();
}

class _ConicalGlowBorderState extends State<ConicalGlowBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _glowColors = [
    Color(0xFF3B82F6), // blue
    Color(0xFF22C55E), // green
    Color(0xFFA855F7), // purple
    Color(0xFFEF4444), // red
    Color(0xFFFFFFFF), // white
    Color(0xFF8B5CF6), // violet
    Color(0xFF3B82F6), // loop back to blue
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    if (widget.active) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(ConicalGlowBorder old) {
    super.didUpdateWidget(old);
    if (widget.active && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.active && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      // OFF state: dim static border, no glow, no animation
      return Container(
        padding: EdgeInsets.all(widget.borderWidth),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          color: Colors.white.withOpacity(0.03),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius - 2),
          child: widget.child,
        ),
      );
    }

    // ON state: endless rotating conical border + glow
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final angle = _ctrl.value * 2 * math.pi;
        return Container(
          padding: EdgeInsets.all(widget.borderWidth),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: SweepGradient(
              colors: _glowColors,
              stops: const [0.0, 0.18, 0.36, 0.55, 0.72, 0.88, 1.0],
              transform: GradientRotation(angle),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF715CD7).withOpacity(0.55),
                blurRadius: 22,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.35),
                blurRadius: 44,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius - 2),
              color: Colors.black,
            ),
            clipBehavior: Clip.antiAlias,
            child: widget.child,
          ),
        );
      },
    );
  }
}
