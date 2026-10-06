import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../src/core/tokens.dart';

/// Endless conical glow border driven by [active].
///
/// - ON (`active: true`): rotating [AppColors.glowLoop] sweep
///   (blue → green → purple → red → white → violet) + outer glow.
///   Wire to [AgentState.isWorking] so it shines while the AI codes.
/// - OFF: dim static border, animation stopped (saves battery).
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
    this.radius = AppRadius.lg,
    this.duration = AppDurations.glowLoop,
  });

  @override
  State<ConicalGlowBorder> createState() => _ConicalGlowBorderState();
}

class _ConicalGlowBorderState extends State<ConicalGlowBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

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
      return Container(
        padding: EdgeInsets.all(widget.borderWidth),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
              color: Theme.of(context)
                  .dividerColor
                  .withValues(alpha: 0.5)),
          color: Theme.of(context)
              .disabledColor
              .withValues(alpha: 0.05),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius - 2),
          child: widget.child,
        ),
      );
    }

    return Semantics(
      liveRegion: true,
      label: 'AI working',
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final angle = _ctrl.value * 2 * math.pi;
          return RepaintBoundary(
            child: Container(
              padding: EdgeInsets.all(widget.borderWidth),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.radius),
                gradient: SweepGradient(
                  colors: AppColors.glowLoop,
                  stops: const [
                    0.0, 0.18, 0.36, 0.55, 0.72, 0.88, 1.0
                  ],
                  transform: GradientRotation(angle),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.55),
                    blurRadius: 22,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.35),
                    blurRadius: 44,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(widget.radius - 2),
                  color: AppColors.ink,
                ),
                clipBehavior: Clip.antiAlias,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
