part of 'reader_page.dart';

class _ArticleCard extends StatelessWidget {
  final _Article article;
  final VoidCallback onTap;

  const _ArticleCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.lg),
        title: Text(article.title, style: AppTextStyles.heading3),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Row(
            children: [
              Chip(
                label:
                    Text(article.level, style: const TextStyle(fontSize: 11)),
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('${article.wordCount} 词', style: AppTextStyles.bodySmall),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                  child: Text(article.source, style: AppTextStyles.caption)),
            ],
          ),
        ),
        trailing: const Icon(PhosphorIconsRegular.caretRight),
        onTap: onTap,
      ),
    );
  }
}

class _ImportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ImportButton(this.label, this.icon, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
