import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

// Animated AMOLED aurora background - heavy premium feel, cheap to render
class AuroraBg extends StatefulWidget {
  final Widget child;
  const AuroraBg({super.key, required this.child});

  @override
  State<AuroraBg> createState() => _AuroraBgState();
}

class _AuroraBgState extends State<AuroraBg> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(decoration: const BoxDecoration(gradient: AppTheme.bgGradient)),
        // glowing orbs with slow loop
        Positioned(
          top: -80, left: -60,
          child: _orb(220, AppTheme.accent.withValues(alpha: 0.35)),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .move(begin: const Offset(0, 0), end: const Offset(30, 40), duration: 6.seconds)
         .then().move(begin: const Offset(30, 40), end: const Offset(0, 0), duration: 6.seconds),
        Positioned(
          bottom: 100, right: -70,
          child: _orb(260, AppTheme.accent2.withValues(alpha: 0.28)),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .move(begin: const Offset(0, 0), end: const Offset(-30, -50), duration: 7.seconds)
         .then().move(begin: const Offset(-30, -50), end: const Offset(0, 0), duration: 7.seconds),
        widget.child,
      ],
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 120, spreadRadius: 20)],
      ),
      child: const SizedBox(),
    );
  }
}

// Glass card wrapper
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20)],
      ),
      child: child,
    );
  }
}
