import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';

/// 排行榜时间范围
enum _RankRange { today, week, month }

/// 排行榜用户数据模型
class _RankUser {
  final String name;
  final int level;
  final int exp;
  const _RankUser(this.name, this.level, this.exp);
}

/// 模拟排行榜数据（不同时间范围）
const _rankData = {
  _RankRange.today: [
    _RankUser('Bob', 42, 1250),
    _RankUser('Alice', 35, 980),
    _RankUser('Charlie', 28, 720),
    _RankUser('David', 25, 650),
    _RankUser('Eve', 23, 600),
    _RankUser('Frank', 22, 550),
    _RankUser('Grace', 20, 500),
    _RankUser('Henry', 19, 475),
    _RankUser('Ivy', 18, 450),
    _RankUser('Jack', 17, 425),
    _RankUser('Kate', 16, 400),
    _RankUser('Leo', 15, 375),
    _RankUser('Mia', 14, 350),
    _RankUser('Noah', 13, 325),
    _RankUser('Olivia', 12, 300),
    _RankUser('Peter', 11, 275),
    _RankUser('Quinn', 10, 250),
    _RankUser('Rose', 9, 225),
    _RankUser('Sam', 8, 200),
    _RankUser('Tina', 7, 175),
  ],
  _RankRange.week: [
    _RankUser('Alice', 35, 4280),
    _RankUser('Charlie', 28, 3950),
    _RankUser('Bob', 42, 3820),
    _RankUser('David', 25, 3100),
    _RankUser('Eve', 23, 2800),
    _RankUser('Grace', 20, 2600),
    _RankUser('Frank', 22, 2400),
    _RankUser('Ivy', 18, 2200),
    _RankUser('Henry', 19, 2100),
    _RankUser('Jack', 17, 1900),
  ],
  _RankRange.month: [
    _RankUser('Bob', 42, 15200),
    _RankUser('Alice', 35, 13800),
    _RankUser('Charlie', 28, 12100),
    _RankUser('David', 25, 10500),
    _RankUser('Eve', 23, 9800),
    _RankUser('Grace', 20, 8500),
    _RankUser('Frank', 22, 8200),
    _RankUser('Ivy', 18, 7600),
    _RankUser('Jack', 17, 7100),
    _RankUser('Henry', 19, 6800),
  ],
};

/// 排行榜页
class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  _RankRange _range = _RankRange.today;

  List<_RankUser> get _users => _rankData[_range] ?? [];

  @override
  Widget build(BuildContext context) {
    final users = _users;
    final top3 = users.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('排行榜'),
        actions: [
          for (final range in _RankRange.values)
            TextButton(
              onPressed: () => setState(() => _range = range),
              child: Text(
                range == _RankRange.today ? '今日' : range == _RankRange.week ? '周榜' : '月榜',
                style: TextStyle(
                  color: _range == range ? Colors.white : Colors.white70,
                  fontWeight: _range == range ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          // 前三名
          if (top3.length >= 3)
            Row(
              children: [
                Expanded(child: _TopCard('2', top3[1], size: 80)),
                Expanded(
                  flex: 12,
                  child: _TopCard('1', top3[0], size: 96, isFirst: true),
                ),
                Expanded(child: _TopCard('3', top3[2], size: 80)),
              ],
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(NinjaSpacing.xl),
                child: Text('暂无排行数据', style: NinjaTextStyles.bodyLarge),
              ),
            ),
          const SizedBox(height: NinjaSpacing.xl),
          const Divider(),
          // 4-20名
          ...List.generate(users.length - 3, (i) {
            final user = users[i + 3];
            return _RankItem(i + 4, user);
          }),
        ],
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  final String rank;
  final _RankUser user;
  final double size;
  final bool isFirst;

  const _TopCard(this.rank, this.user, {this.size = 80, this.isFirst = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: isFirst
                  ? [NinjaColors.accentGold, NinjaColors.accentGold.withValues(alpha: 0.5)]
                  : [NinjaColors.primary, NinjaColors.primary.withValues(alpha: 0.5)],
            ),
          ),
          child: Center(
            child: Text(rank, style: TextStyle(color: Colors.white, fontSize: size * 0.4, fontWeight: FontWeight.w900)),
          ),
        ),
        const SizedBox(height: 4),
        Text(user.name, style: NinjaTextStyles.label),
        Text('Lv${user.level}', style: NinjaTextStyles.caption),
        Text('${user.exp} EXP', style: NinjaTextStyles.caption),
      ],
    );
  }
}

class _RankItem extends StatelessWidget {
  final int rank;
  final _RankUser user;

  const _RankItem(this.rank, this.user);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.xs),
      child: ListTile(
        leading: Text('$rank', style: NinjaTextStyles.heading2.copyWith(
          color: rank <= 3 ? NinjaColors.accentGold : NinjaColors.textSecondary,
        )),
        title: Text(user.name, style: NinjaTextStyles.bodyLarge),
        subtitle: Text('Lv${user.level}', style: NinjaTextStyles.bodySmall),
        trailing: Text('${user.exp} EXP', style: NinjaTextStyles.label),
      ),
    );
  }
}
