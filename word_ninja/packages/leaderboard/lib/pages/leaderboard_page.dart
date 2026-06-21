import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:auth/presentation/providers/auth_provider.dart';
import 'package:core/network/api_client.dart' show ApiClient;

/// 排行榜用户模型
class _RankUser {
  final String name;
  final int level;
  final int exp;
  final bool isMe;
  const _RankUser(this.name, this.level, this.exp, {this.isMe = false});
}

/// 排行榜时间范围
enum _RankRange { today, week, month }

/// 排行榜 Provider
final leaderboardProvider = FutureProvider.family<List<_RankUser>, _RankRange>((ref, range) async {
  // 尝试从 API 获取，失败则返回占位数据
  try {
    final api = ref.read(apiClientProvider);
    final res = await api.getLeaderboard(range.name);
    return (res as List).map((u) => _RankUser(u['nickname'] ?? '', u['level'] ?? 1, u['exp'] ?? 0)).toList();
  } catch (_) {
    return _getMockData(range);
  }
});

final apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('apiClientProvider must be overridden in app DI');
});

List<_RankUser> _getMockData(_RankRange range) {
  final me = _RankUser('我', 18, 600, isMe: true);
  switch (range) {
    case _RankRange.today:
      return [const _RankUser('Bob', 42, 1250), const _RankUser('Alice', 35, 980), me, ...List.generate(17, (i) => _RankUser('Player${i+4}', 20-i, 500-i*30))];
    case _RankRange.week:
      return [const _RankUser('Alice', 35, 4280), me, const _RankUser('Bob', 42, 3820), ...List.generate(7, (i) => _RankUser('Player${i+4}', 25-i, 3000-i*200))];
    case _RankRange.month:
      return [const _RankUser('Bob', 42, 15200), const _RankUser('Alice', 35, 13800), me, ...List.generate(7, (i) => _RankUser('Player${i+4}', 28-i, 10000-i*500))];
  }
}

/// 排行榜页
class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  _RankRange _range = _RankRange.today;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(leaderboardProvider(_range));

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
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('加载失败')),
        data: (users) {
          final top3 = users.take(3).toList();
          return ListView(
            padding: const EdgeInsets.all(NinjaSpacing.lg),
            children: [
              if (top3.length >= 3)
                Row(
                  children: [
                    Expanded(child: _TopCard('2', top3[1], size: 80)),
                    Expanded(flex: 12, child: _TopCard('1', top3[0], size: 96, isFirst: true)),
                    Expanded(child: _TopCard('3', top3[2], size: 80)),
                  ],
                )
              else
                const Center(child: Padding(padding: EdgeInsets.all(NinjaSpacing.xl), child: Text('暂无排行数据'))),
              const SizedBox(height: NinjaSpacing.xl),
              const Divider(),
              ...List.generate(users.length - 3 > 0 ? users.length - 3 : 0, (i) {
                final user = users[i + 3];
                return _RankItem(i + 4, user);
              }),
            ],
          );
        },
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
            border: user.isMe ? Border.all(color: NinjaColors.success, width: 2) : null,
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
        Text(user.name, style: NinjaTextStyles.label.copyWith(
          color: user.isMe ? NinjaColors.success : null,
        )),
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
      color: user.isMe ? NinjaColors.primary.withValues(alpha: 0.05) : null,
      child: ListTile(
        leading: Text('$rank', style: NinjaTextStyles.heading2.copyWith(
          color: rank <= 3 ? NinjaColors.accentGold : NinjaColors.textSecondary,
        )),
        title: Row(children: [
          Text(user.name, style: NinjaTextStyles.bodyLarge.copyWith(
            color: user.isMe ? NinjaColors.primary : null,
          )),
          if (user.isMe) ...[
            const SizedBox(width: 4),
            const Text('(你)', style: TextStyle(fontSize: 12, color: NinjaColors.success)),
          ],
        ]),
        subtitle: Text('Lv${user.level}', style: NinjaTextStyles.bodySmall),
        trailing: Text('${user.exp} EXP', style: NinjaTextStyles.label),
      ),
    );
  }
}
