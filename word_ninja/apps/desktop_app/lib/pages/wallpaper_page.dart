import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:core/storage/preferences.dart';
import '../providers/wallpaper_provider.dart';

/// 桌面壁纸页面 — 半透明叠加层，显示学习信息
class WallpaperPage extends ConsumerStatefulWidget {
  final WidgetRef? appRef;
  const WallpaperPage({super.key, this.appRef});

  @override
  ConsumerState<WallpaperPage> createState() => _WallpaperPageState();
}

class _WallpaperPageState extends ConsumerState<WallpaperPage> {
  int _quoteIndex = 0;

  static const _quotes = [
    ('The limits of my language mean the limits of my world.', 'Ludwig Wittgenstein'),
    ('To have another language is to possess a second soul.', 'Charlemagne'),
    ('Language is the road map of a culture.', 'Rita Mae Brown'),
    ('A different language is a different vision of life.', 'Federico Fellini'),
    ('One language sets you in a corridor for life. Two languages open every door.', 'Frank Smith'),
    ('Learning is a treasure that will follow its owner everywhere.', 'Chinese Proverb'),
    ('The beautiful thing about learning is nobody can take it away from you.', 'B.B. King'),
    ('He who knows no foreign languages knows nothing of his own.', 'Goethe'),
  ];

  @override
  void initState() {
    super.initState();
    _quoteIndex = Random().nextInt(_quotes.length);
  }

  @override
  Widget build(BuildContext context) {
    final dailyGoal = Preferences.getInt('daily_word_goal', defaultValue: 20);
    final dailyReading = Preferences.getInt('daily_reading_goal', defaultValue: 1);
    final quote = _quotes[_quoteIndex];

    return Stack(
      children: [
        // 主壁纸内容 — 居中卡片
        Center(
          child: Container(
            margin: const EdgeInsets.all(40),
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                Text(
                  'Word Ninja',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: NinjaColors.primary.withValues(alpha: 0.6),
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 24),
                // 每日目标卡片
                _InfoCard(
                  icon: Icons.trending_up,
                  title: '今日学习',
                  children: [
                    _StatRow('单词目标', '$dailyGoal 词/天'),
                    _StatRow('阅读目标', '$dailyReading 篇/天'),
                  ],
                ),
                const SizedBox(height: 16),
                // 名言卡片
                _InfoCard(
                  icon: Icons.format_quote,
                  title: '每日一句',
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            '"${quote.$1}"',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: NinjaColors.textPrimary.withValues(alpha: 0.8),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '— ${quote.$2}',
                            style: TextStyle(
                              fontSize: 12,
                              color: NinjaColors.textSecondary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // 迷你浮动面板 — 右下角
        Positioned(
          right: 24,
          bottom: 24,
          child: _MiniFloatingPanel(),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.icon, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NinjaColors.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NinjaColors.divider.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: NinjaColors.primary.withValues(alpha: 0.7)),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: NinjaColors.textPrimary.withValues(alpha: 0.8))),
          ]),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: NinjaColors.textSecondary.withValues(alpha: 0.8)))),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: NinjaColors.primary.withValues(alpha: 0.8))),
      ]),
    );
  }
}

/// 迷你浮动快捷面板 — 右下角半透明按钮组
class _MiniFloatingPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: NinjaColors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NinjaColors.divider.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _QuickButton(Icons.auto_stories, '阅读', () {
              ref.read(wallpaperModeProvider.notifier).state = false;
            }),
            _QuickButton(Icons.menu_book, '单词本', () {
              ref.read(wallpaperModeProvider.notifier).state = false;
            }),
            _QuickButton(Icons.psychology, 'AI导师', () {
              ref.read(wallpaperModeProvider.notifier).state = false;
            }),
            Container(width: 1, height: 20, color: NinjaColors.divider.withValues(alpha: 0.3)),
            _QuickButton(Icons.close_fullscreen, '退出', () {
              ref.read(wallpaperModeProvider.notifier).state = false;
            }),
          ],
        ),
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _QuickButton(this.icon, this.tooltip, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: NinjaColors.primary.withValues(alpha: 0.8)),
        ),
      ),
    );
  }
}
