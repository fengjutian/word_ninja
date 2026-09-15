import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:core/network/api_client.dart' show ApiClient;

part 'admin_tabs.dart';

/// WordFlow 管理后台
void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordFlow Admin',
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
        title: const Text('WordFlow 管理后台'),
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(PhosphorIconsRegular.arrowsClockwise),
              tooltip: '刷新数据',
              onPressed: _refreshStats,
            ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.signOut),
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
              NavigationRailDestination(
                  icon: Icon(PhosphorIconsRegular.house), label: Text('概览')),
              NavigationRailDestination(
                  icon: Icon(PhosphorIconsRegular.users), label: Text('用户')),
              NavigationRailDestination(
                  icon: Icon(PhosphorIconsRegular.bookOpen), label: Text('单词')),
              NavigationRailDestination(
                  icon: Icon(PhosphorIconsRegular.gear), label: Text('设置')),
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
