import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:core/network/api_client.dart' show ApiClient;

/// Word Ninja 管理后台
void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Ninja Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const AdminDashboard(),
    );
  }
}

/// 管理面板主页
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  int _userCount = 1234;
  int _wordCount = 56789;
  int _activeToday = 456;
  int _memberCount = 234;
  bool _isRefreshing = false;

  final _pages = <Widget>[];

  @override
  void initState() {
    super.initState();
    _refreshStats();
  }

  Future<void> _refreshStats() async {
    setState(() => _isRefreshing = true);
    // 模拟从 API 获取数据
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _isRefreshing = false;
        // 使用递增数据展示刷新效果
        _userCount = 1234 + (DateTime.now().second % 100);
        _wordCount = 56789 + (DateTime.now().second * 10);
        _activeToday = 456 + (DateTime.now().second % 50);
        _memberCount = 234 + (DateTime.now().second % 20);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Ninja 管理后台'),
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(PhosphorIcons.regular.arrowsClockwise),
              tooltip: '刷新数据',
              onPressed: _refreshStats,
            ),
          IconButton(
            icon: const Icon(PhosphorIcons.regular.signOut),
            tooltip: '退出',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('管理员登出')),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(PhosphorIcons.regular.squaresFour), label: Text('概览')),
              NavigationRailDestination(icon: Icon(PhosphorIcons.regular.users), label: Text('用户')),
              NavigationRailDestination(icon: Icon(PhosphorIcons.regular.bookOpen), label: Text('单词')),
              NavigationRailDestination(icon: Icon(PhosphorIcons.regular.gear), label: Text('设置')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _buildPage()),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardTab(
          userCount: _formatNumber(_userCount),
          wordCount: _formatNumber(_wordCount),
          activeToday: _formatNumber(_activeToday),
          memberCount: _formatNumber(_memberCount),
        );
      case 1:
        return _UsersTab(onRefresh: _refreshStats);
      case 2:
        return _WordsTab(onRefresh: _refreshStats);
      case 3:
        return _SettingsTab(onRefresh: _refreshStats);
      default:
        return const SizedBox();
    }
  }

  String _formatNumber(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}万';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

class _DashboardTab extends StatelessWidget {
  final String userCount, wordCount, activeToday, memberCount;
  const _DashboardTab({required this.userCount, required this.wordCount, required this.activeToday, required this.memberCount});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      padding: const EdgeInsets.all(24),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _StatCard('总用户', userCount, PhosphorIcons.regular.users, Colors.blue),
        _StatCard('单词总数', wordCount, PhosphorIcons.regular.bookOpen, Colors.green),
        _StatCard('今日活跃', activeToday, PhosphorIcons.regular.trendUp, Colors.orange),
        _StatCard('会员数', memberCount, PhosphorIcons.regular.star, Colors.purple),
        _StatCard('AI对话', '12,345', PhosphorIcons.regular.chats, Colors.teal),
        _StatCard('同步请求', '89,012', PhosphorIcons.regular.arrowsClockwise, Colors.indigo),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const Spacer(),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  final VoidCallback onRefresh;
  const _UsersTab({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('用户管理', style: Theme.of(context).textTheme.headlineSmall),
          TextButton.icon(onPressed: onRefresh, icon: const Icon(PhosphorIcons.regular.arrowsClockwise, size: 18), label: const Text('刷新')),
        ]),
        const SizedBox(height: 16),
        Card(
          child: DataTable(columns: const [
            DataColumn(label: Text('邮箱')),
            DataColumn(label: Text('昵称')),
            DataColumn(label: Text('等级'), numeric: true),
            DataColumn(label: Text('经验'), numeric: true),
            DataColumn(label: Text('操作')),
          ], rows: [
            _userRow('alice@example.com', 'Alice', 35, 980),
            _userRow('bob@example.com', 'Bob', 42, 1250),
            _userRow('charlie@example.com', 'Charlie', 28, 720),
            _userRow('david@example.com', 'David', 25, 650),
            _userRow('eve@example.com', 'Eve', 23, 600),
          ]),
        ),
      ],
    );
  }

  DataRow _userRow(String email, String name, int level, int exp) => DataRow(cells: [
    DataCell(Text(email)),
    DataCell(Text(name)),
    DataCell(Text('$level')),
    DataCell(Text('$exp')),
    DataCell(Row(children: [
      IconButton(icon: const Icon(PhosphorIcons.regular.pencilSimple, size: 18), onPressed: () {}),
      IconButton(icon: const Icon(PhosphorIcons.regular.trash, size: 18, color: Colors.red), onPressed: () {}),
    ])),
  ]);
}

class _WordsTab extends StatelessWidget {
  final VoidCallback onRefresh;
  const _WordsTab({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('单词管理', style: Theme.of(context).textTheme.headlineSmall),
          Row(children: [
            TextButton.icon(onPressed: onRefresh, icon: const Icon(PhosphorIcons.regular.arrowsClockwise, size: 18), label: const Text('刷新')),
            FilledButton.icon(onPressed: () {}, icon: const Icon(PhosphorIcons.regular.plus, size: 18), label: const Text('添加单词')),
          ]),
        ]),
        const SizedBox(height: 16),
        Card(
          child: DataTable(columns: const [
            DataColumn(label: Text('单词')),
            DataColumn(label: Text('释义')),
            DataColumn(label: Text('难度'), numeric: true),
            DataColumn(label: Text('掌握度'), numeric: true),
            DataColumn(label: Text('操作')),
          ], rows: [
            _wordRow('ubiquitous', '无处不在的', 3, 85),
            _wordRow('prolific', '多产的', 2, 60),
            _wordRow('eloquent', '雄辩的', 2, 45),
            _wordRow('pragmatic', '务实的', 1, 90),
            _wordRow('resilient', '有韧性的', 2, 70),
          ]),
        ),
      ],
    );
  }

  DataRow _wordRow(String word, String meaning, int diff, int mastery) => DataRow(cells: [
    DataCell(Text(word, style: const TextStyle(fontWeight: FontWeight.w600))),
    DataCell(Text(meaning)),
    DataCell(Text('$diff')),
    DataCell(Row(children: [
      SizedBox(width: 100, child: LinearProgressIndicator(value: mastery / 100, minHeight: 6)),
      const SizedBox(width: 8),
      Text('$mastery%'),
    ])),
    DataCell(Row(children: [
      IconButton(icon: const Icon(PhosphorIcons.regular.pencilSimple, size: 18), onPressed: () {}),
      IconButton(icon: const Icon(PhosphorIcons.regular.trash, size: 18, color: Colors.red), onPressed: () {}),
    ])),
  ]);
}

class _SettingsTab extends StatelessWidget {
  final VoidCallback onRefresh;
  const _SettingsTab({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('系统设置', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Card(
          child: Column(children: [
            SwitchListTile(title: const Text('允许新用户注册'), value: true, onChanged: (_) {}),
            SwitchListTile(title: const Text('AI 服务开关'), value: true, onChanged: (_) {}),
            SwitchListTile(title: const Text('调试模式'), value: false, onChanged: (_) {}),
            ListTile(title: const Text('API 限流'), subtitle: const Text('当前: 100 req/min'), trailing: const Icon(PhosphorIcons.regular.caretRight), onTap: () {}),
            ListTile(title: const Text('缓存管理'), subtitle: const Text('当前缓存: 256 MB'), trailing: TextButton(onPressed: () {}, child: const Text('清除'))),
          ]),
        ),
      ],
    );
  }
}
