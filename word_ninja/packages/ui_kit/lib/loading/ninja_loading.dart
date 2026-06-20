import 'package:flutter/material.dart';
import '../ninja_theme/ninja_theme.dart';

/// 加载指示器
class NinjaLoading extends StatelessWidget {
  final String? message;

  const NinjaLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: NinjaColors.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: NinjaSpacing.md),
            Text(message!, style: NinjaTextStyles.bodyMedium),
          ],
        ],
      ),
    );
  }
}
