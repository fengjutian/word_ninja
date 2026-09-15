part of 'desktop_app.dart';

class DesktopShell extends StatelessWidget {
  final Widget child;
  const DesktopShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;
    return NavigationView(
      titleBar: _buildTitleBar(context, isDark),
      paneBodyBuilder: (item, body) {
        return mt.Theme(
          data: AppTheme.build(AppThemeCatalog.indigo,
              isDark ? Brightness.dark : Brightness.light),
          child: Builder(
            builder: (ctx) =>
                mt.Material(child: mt.ScaffoldMessenger(child: child)),
          ),
        );
      },
      pane: NavigationPane(
        selected: _calcIndex(context),
        onChanged: (i) => _navigate(context, i),
        displayMode: PaneDisplayMode.compact,
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Text(
            'W',
            style: TextStyle(
              fontSize: 28,
              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
            ),
          ),
        ),
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text('首页'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.bookmarks),
            title: const Text('单词'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.reading_mode),
            title: const Text('阅读'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.headset),
            title: const Text('听力'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.microphone),
            title: const Text('口语'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.chat),
            title: const Text('AI 导师'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.design),
            title: const Text('写作'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.task_list),
            title: const Text('学习计划'),
            body: const SizedBox.shrink(),
          ),
        ],
        footerItems: [
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('模型配置'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.contact),
            title: const Text('我的'),
            body: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Custom title bar with window controls (drag, min/max/close)
  Widget _buildTitleBar(BuildContext context, bool isDark) {
    return GestureDetector(
      onDoubleTap: () => windowManager.isMaximized().then(
        (m) => m ? windowManager.unmaximize() : windowManager.maximize(),
      ),
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 36,
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  const PaneToggleButton(),
                  const SizedBox(width: 4),
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppThemeCatalog.indigo.seed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('W', style: TextStyle(color: mt.Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WordFlow',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textOnDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _WindowBtn(
              label: '\u{2014}',
              tooltip: 'Minimize',
              isDark: isDark,
              onTap: () => windowManager.minimize(),
            ),
            _WindowBtn(
              label: '\u{25A1}',
              tooltip: 'Maximize',
              isDark: isDark,
              onTap: () => windowManager.isMaximized().then(
                (m) =>
                    m ? windowManager.unmaximize() : windowManager.maximize(),
              ),
            ),
            _WindowBtn(
              label: '\u{2715}',
              tooltip: 'Close',
              isDark: isDark,
              isClose: true,
              onTap: () => windowManager.close(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _WindowBtn({
    required String label,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
    bool isClose = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: mt.Material(
        color: mt.Colors.transparent,
        child: mt.InkWell(
          onTap: onTap,
          hoverColor: isClose
              ? AppColors.primary
              : AppColors.divider.withValues(alpha: 0.3),
          child: Container(
            width: 46,
            height: 36,
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _calcIndex(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    if (uri.startsWith(DesktopRoutes.vocabulary)) return 1;
    if (uri.startsWith(DesktopRoutes.reading)) return 2;
    if (uri.startsWith(DesktopRoutes.listening)) return 3;
    if (uri.startsWith(DesktopRoutes.speaking)) return 4;
    if (uri.startsWith(DesktopRoutes.aiTutor)) return 5;
    if (uri.startsWith(DesktopRoutes.writing)) return 6;
    if (uri.startsWith(DesktopRoutes.studyPlan)) return 7;
    if (uri.startsWith(DesktopRoutes.modelConfig)) return 8;
    if (uri.startsWith(DesktopRoutes.profile) ||
        uri.startsWith(DesktopRoutes.settings))
      return 9;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(DesktopRoutes.home);
      case 1:
        context.go(DesktopRoutes.vocabulary);
      case 2:
        context.go(DesktopRoutes.reading);
      case 3:
        context.go(DesktopRoutes.listening);
      case 4:
        context.go(DesktopRoutes.speaking);
      case 5:
        context.go(DesktopRoutes.aiTutor);
      case 6:
        context.go(DesktopRoutes.writing);
      case 7:
        context.go(DesktopRoutes.studyPlan);
      case 8:
        context.go(DesktopRoutes.modelConfig);
      case 9:
        context.go(DesktopRoutes.profile);
    }
  }
}
