part of 'writing_page.dart';

class _IeltsBar extends StatelessWidget {
  final String label;
  final dynamic value;
  const _IeltsBar(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final v = (value is num) ? value.toDouble() : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
              width: 80, child: Text(label, style: AppTextStyles.bodySmall)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (v / 9).clamp(0.0, 1.0),
                minHeight: 6,
                valueColor: AlwaysStoppedAnimation<Color>(
                  v >= 7
                      ? AppColors.success
                      : v >= 5
                          ? AppColors.warning
                          : AppColors.error,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
              width: 30,
              child: Text(v.toStringAsFixed(1), style: AppTextStyles.caption)),
        ],
      ),
    );
  }
}
