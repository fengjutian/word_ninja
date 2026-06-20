import 'package:flutter/material.dart';
import 'package:ui_kit/lib/ninja_theme/ninja_theme.dart';

/// 排行榜页面
class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('排行榜'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('今日', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('周榜', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('月榜', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          // 前三名特殊展示
          Row(
            children: [
              Expanded(child: _TopCard('2', 'Alice', 'Lv35', 980, size: 80)),
              Expanded(
                flex: 12,
                child: _TopCard('1', 'Bob', 'Lv42', 1250, size: 96, isFirst: true),
              ),
              Expanded(child: _TopCard('3', 'Charlie', 'Lv28', 720, size: 80)),
            ],
          ),
          const SizedBox(height: NinjaSpacing.xl),
          const Divider(),
          ...List.generate(17, (i) => _RankItem(i + 4, 'User${i + 4}', 'Lv${20 - i}', (500 - i * 25).clamp(0, 500))),
        ],
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  final String rank;
  final String name;
  final String level;
  final int exp;
  final double size;
  final bool isFirst;

  const _TopCard(this.rank, this.name, this.level, this.exp,
      {this.size = 80, this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: isFirst
                  ? [NinjaColors.accentGold, NinjaColors.accentGold.withValues(alpha: 0.5)]
                  : [NinjaColors.primary, NinjaColors.primary.withValues(alpha: 0.5)],
            ),
          ),
          child: Center(
            child: Text(rank,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w900,
                )),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: NinjaTextStyles.label),
        Text(level, style: NinjaTextStyles.caption),
        Text('$exp EXP', style: NinjaTextStyles.caption),
      ],
    );
  }
}

class _RankItem extends StatelessWidget {
  final int rank;
  final String name;
  final String level;
  final int exp;

  const _RankItem(this.rank, this.name, this.level, this.exp);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.xs),
      child: ListTile(
        leading: Text('$rank', style: NinjaTextStyles.heading2.copyWith(
          color: rank <= 3 ? NinjaColors.accentGold : NinjaColors.textSecondary,
        )),
        title: Text(name, style: NinjaTextStyles.bodyLarge),
        subtitle: Text(level, style: NinjaTextStyles.bodySmall),
        trailing: Text('$exp EXP', style: NinjaTextStyles.label),
      ),
    );
  }
}
