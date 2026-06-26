import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:window_manager/window_manager.dart';

/// Custom title bar with minimize, maximize/restore, and close buttons.
/// Used because [TitleBarStyle.hidden] is set in main.dart, hiding the native OS title bar.
class WindowTitleBar extends StatefulWidget {
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const WindowTitleBar({
    super.key,
    this.height = 40,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<WindowTitleBar> createState() => _WindowTitleBarState();
}

class _WindowTitleBarState extends State<WindowTitleBar>
    with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _checkMaximized();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _checkMaximized() async {
    final maximized = await windowManager.isMaximized();
    if (mounted) setState(() => _isMaximized = maximized);
  }

  @override
  void onWindowMaximize() {
    setState(() => _isMaximized = true);
  }

  @override
  void onWindowUnmaximize() {
    setState(() => _isMaximized = false);
  }

  Future<void> _onMinimize() => windowManager.minimize();

  Future<void> _onMaximizeOrRestore() async {
    if (_isMaximized) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  Future<void> _onClose() => windowManager.close();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = widget.backgroundColor ?? theme.colorScheme.surface;
    final fg = widget.foregroundColor ?? theme.colorScheme.onSurface;

    return SizedBox(
      height: widget.height,
      child: Row(
        children: [
          // Draggable area (the app title)
          Expanded(
            child: DragToMoveArea(
              child: Container(
                color: bg,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsBold.sword,
                      size: 18,
                      color: fg.withOpacity(0.7),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Word Ninja',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: fg.withOpacity(0.85),
                      ),
                    ),
                    // Subtle separator
                    Container(
                      margin: const EdgeInsets.only(left: 16),
                      width: 1,
                      height: 22,
                      color: fg.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Window control buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _WindowButton(
                icon: PhosphorIconsRegular.minus,
                onPressed: _onMinimize,
                fg: fg,
                bg: bg,
              ),
              _WindowButton(
                icon: _isMaximized
                    ? PhosphorIconsRegular.copy
                    : PhosphorIconsRegular.square,
                onPressed: _onMaximizeOrRestore,
                fg: fg,
                bg: bg,
              ),
              _WindowButton(
                icon: PhosphorIconsRegular.x,
                onPressed: _onClose,
                fg: fg,
                bg: bg,
                isClose: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WindowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color fg;
  final Color bg;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    required this.fg,
    required this.bg,
    this.isClose = false,
  });

  @override
  Widget build(BuildContext context) {
    const btnSize = 46.0;
    return SizedBox(
      width: btnSize,
      height: btnSize,
      child: HoverBuilder(
        builder: (context, isHovered) {
          Color btnBg;
          Color iconColor;
          if (isClose && isHovered) {
            btnBg = Colors.redAccent.shade200;
            iconColor = Colors.white;
          } else if (isHovered) {
            btnBg = fg.withOpacity(0.08);
            iconColor = fg;
          } else {
            btnBg = Colors.transparent;
            iconColor = fg.withOpacity(0.65);
          }
          return GestureDetector(
            onTap: onPressed,
            child: Container(
              color: btnBg,
              alignment: Alignment.center,
              child: Icon(icon, size: 16, color: iconColor),
            ),
          );
        },
      ),
    );
  }
}

/// Simple hover-detection builder.
class HoverBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;
  const HoverBuilder({super.key, required this.builder});

  @override
  State<HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: widget.builder(context, _isHovered),
    );
  }
}
