import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Theme-aware loading skeleton used by WordFlow pages.
class AppSkeleton extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const AppSkeleton({
    super.key,
    required this.enabled,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      ignorePointers: enabled,
      effect: ShimmerEffect(
        baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        highlightColor: Theme.of(context).colorScheme.surface,
      ),
      child: child,
    );
  }
}
