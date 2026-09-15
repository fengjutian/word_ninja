part of 'desktop_app.dart';

class DesktopShell extends StatefulWidget {
  const DesktopShell({super.key, required this.child});
  final Widget child;

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  bool _expanded = false;

  static const _items = <({IconData icon, String label})>[
    (icon: FluentIcons.home, label: '首页'),
    (icon: FluentIcons.bookmarks, label: '单词'),
    (icon: FluentIcons.share, label: '知识图谱'),
    (icon: FluentIcons.reading_mode, label: '阅读'),
    (icon: FluentIcons.headset, label: '听力'),
    (icon: FluentIcons.microphone, label: '口语'),
    (icon: FluentIcons.chat, label: 'AI 导师'),
    (icon: FluentIcons.design, label: '写作'),
    (icon: FluentIcons.task_list, label: '学习计划'),
  ];

  static const _footerItems = <({IconData icon, String label})>[
    (icon: FluentIcons.settings, label: '模型配置'),
    (icon: FluentIcons.contact, label: '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = FluentTheme.of(context).brightness == Brightness.dark;
    final materialTheme = AppTheme.build(
      AppThemeCatalog.indigo,
      dark ? Brightness.dark : Brightness.light,
    );
    final tokens = AppColorTokens.forPreset(
      AppThemeCatalog.indigo,
      dark ? Brightness.dark : Brightness.light,
    );
    final selected = _calcIndex(context);

    return mt.Theme(
      data: materialTheme,
      child: mt.Material(
        color: tokens.canvas,
        child: Column(
          children: [
            _buildTitleBar(context, dark),
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: _expanded ? 220 : 58,
                    decoration: BoxDecoration(
                      color: tokens.sidebar,
                      border: Border(right: BorderSide(color: tokens.border)),
                    ),
                    child: Column(
                      children: [
                        if (_expanded)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '学习空间',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: tokens.mutedText,
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            itemCount: _items.length,
                            itemBuilder: (context, index) => _NavButton(
                              icon: _items[index].icon,
                              label: _items[index].label,
                              expanded: _expanded,
                              selected: selected == index,
                              onTap: () => _navigate(context, index),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(7, 6, 7, 10),
                          child: Column(
                            children: List.generate(_footerItems.length, (
                              offset,
                            ) {
                              final index = _items.length + offset;
                              return _NavButton(
                                icon: _footerItems[offset].icon,
                                label: _footerItems[offset].label,
                                expanded: _expanded,
                                selected: selected == index,
                                onTap: () => _navigate(context, index),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: mt.ScaffoldMessenger(child: widget.child)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context, bool dark) {
    final foreground = dark ? AppColors.textOnDark : AppColors.textPrimary;
    return GestureDetector(
      onDoubleTap: () => windowManager.isMaximized().then(
        (maximized) =>
            maximized ? windowManager.unmaximize() : windowManager.maximize(),
      ),
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 46,
        color: dark ? AppColors.surfaceDark : AppColors.surface,
        child: Row(
          children: [
            const SizedBox(width: 8),
            mt.IconButton(
              tooltip: _expanded ? '折叠导航' : '展开导航',
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(
                _expanded ? FluentIcons.back : FluentIcons.global_nav_button,
                size: 17,
              ),
            ),
            Container(
              width: 27,
              height: 27,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppThemeCatalog.indigo.seed,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Text(
                'W',
                style: TextStyle(
                  color: mt.Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Text(
              'WordFlow',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
            const Spacer(),
            _windowButton('—', '最小化', dark, () => windowManager.minimize()),
            _windowButton(
              '□',
              '最大化',
              dark,
              () => windowManager.isMaximized().then(
                (maximized) => maximized
                    ? windowManager.unmaximize()
                    : windowManager.maximize(),
              ),
            ),
            _windowButton(
              '×',
              '关闭',
              dark,
              () => windowManager.close(),
              close: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _windowButton(
    String label,
    String tooltip,
    bool dark,
    VoidCallback onTap, {
    bool close = false,
  }) {
    return mt.Tooltip(
      message: tooltip,
      child: mt.InkWell(
        onTap: onTap,
        hoverColor: close
            ? const Color(0xFFE81123)
            : AppColors.divider.withValues(alpha: 0.35),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: dark ? AppColors.textOnDark : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _calcIndex(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    if (uri.startsWith(DesktopRoutes.wordGraph)) return 2;
    if (uri.startsWith(DesktopRoutes.vocabulary)) return 1;
    if (uri.startsWith(DesktopRoutes.reading)) return 3;
    if (uri.startsWith(DesktopRoutes.listening)) return 4;
    if (uri.startsWith(DesktopRoutes.speaking)) return 5;
    if (uri.startsWith(DesktopRoutes.aiTutor)) return 6;
    if (uri.startsWith(DesktopRoutes.writing)) return 7;
    if (uri.startsWith(DesktopRoutes.studyPlan)) return 8;
    if (uri.startsWith(DesktopRoutes.modelConfig)) return 9;
    if (uri.startsWith(DesktopRoutes.profile) ||
        uri.startsWith(DesktopRoutes.settings))
      return 10;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    final routes = [
      DesktopRoutes.home,
      DesktopRoutes.vocabulary,
      DesktopRoutes.wordGraph,
      DesktopRoutes.reading,
      DesktopRoutes.listening,
      DesktopRoutes.speaking,
      DesktopRoutes.aiTutor,
      DesktopRoutes.writing,
      DesktopRoutes.studyPlan,
      DesktopRoutes.modelConfig,
      DesktopRoutes.profile,
    ];
    context.go(routes[index]);
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.expanded,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool expanded, selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appColors;
    final primary = mt.Theme.of(context).colorScheme.primary;
    final content = mt.InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 42,
        padding: EdgeInsets.symmetric(horizontal: expanded ? 11 : 0),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.09)
              : mt.Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: expanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: selected ? primary : tokens.mutedText),
            if (expanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? primary
                        : mt.Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: expanded ? content : mt.Tooltip(message: label, child: content),
    );
  }
}
