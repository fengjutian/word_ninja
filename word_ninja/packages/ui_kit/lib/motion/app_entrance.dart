import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A restrained entrance transition shared by WordFlow content cards.
class AppEntrance extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final double offsetY;

  const AppEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 6,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) return child;

    return child
        .animate(delay: delay)
        .fadeIn(duration: 180.ms, curve: Curves.easeOut)
        .moveY(begin: offsetY, end: 0, duration: 180.ms, curve: Curves.easeOut);
  }
}
