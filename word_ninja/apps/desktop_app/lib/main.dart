import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:app_links/app_links.dart';
import 'package:core/logger/logger.dart';
import 'app/desktop_app.dart';
import 'app/bootstrap.dart';
import 'app/di.dart';
import 'debug_overlay.dart';
import 'pages/wallpaper_page.dart';
import 'providers/wallpaper_provider.dart';

/// Normal mode window geometry, saved for restoration
Size _normalSize = const Size(1280, 800);
Offset _normalPos = Offset.zero;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();

  const windowOptions = WindowOptions(
    title: 'Word Ninja',
    size: Size(1280, 800),
    minimumSize: Size(960, 640),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Track window geometry changes
  windowManager.addListener(() {
    windowManager.getBounds().then((rect) {
      if (rect.width > 100 && rect.height > 100) {
        _normalSize = rect.size;
        _normalPos = rect.topLeft;
      }
    });
  });

  // Alt+W: toggle wallpaper mode
  await hotKeyManager.register(
    HotKey(KeyCode.keyW, modifiers: [KeyModifier.alt]),
    keyDownHandler: (_) => _toggleWallpaper(),
  );

  await AppBootstrap.init();
  log.i('Word Ninja Desktop started');

  final router = createDesktopRouter();
  final container = ProviderContainer(overrides: desktopOverrides);

  // Deep link handling (wordninja://)
  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen((uri) {
    log.i('Deep link received: $uri');
    // wordninja://vocabulary/add?word=hello -> /vocabulary/add?word=hello
    final path = uri.toString().replaceFirst('wordninja://', '/');
    router.go(path);
  });
  // Handle cold-start deep link
  final initialUri = await appLinks.getInitialLink();
  if (initialUri != null) {
    log.i('Cold-start deep link: $initialUri');
    final path = initialUri.toString().replaceFirst('wordninja://', '/');
    router.go(path);
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: _AppShell(
        router: router,
        container: container,
      ),
    ),
  );
}

Future<void> _toggleWallpaper() async {
  final isMax = await windowManager.isMaximized();
  final bounds = await windowManager.getBounds();
  final display = await windowManager.getCurrentDisplay();
  final screenSize = display?.size ?? const Size(1920, 1080);

  if (isMax && (bounds.size.width >= screenSize.width - 1)) {
    // Exit wallpaper mode: restore normal window
    await windowManager.setSize(_normalSize);
    await windowManager.setPosition(_normalPos);
    await windowManager.setSkipTaskbar(false);
    await windowManager.setAlwaysOnBottom(false);
    await windowManager.focus();
  } else {
    // Enter wallpaper mode: fullscreen, behind icons
    _normalSize = bounds.size;
    _normalPos = bounds.topLeft;
    await windowManager.setSize(screenSize);
    await windowManager.setPosition(const Offset(0, 0));
    await windowManager.setSkipTaskbar(true);
    await windowManager.setAlwaysOnBottom(true);
  }
}

/// Root shell: switches between normal app and wallpaper overlay
class _AppShell extends ConsumerStatefulWidget {
  final GoRouter router;
  final ProviderContainer container;

  const _AppShell({
    required this.router,
    required this.container,
  });

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    // Periodically push wallpaper window to bottom
    _keepWallpaperOnBottom();
  }

  void _keepWallpaperOnBottom() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 5));
      if (mounted && ref.read(wallpaperModeProvider)) {
        await windowManager.setAlwaysOnBottom(true);
      }
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWallpaper = ref.watch(wallpaperModeProvider);

    if (isWallpaper) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: Colors.transparent),
        home: Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            onDoubleTap: () {
              ref.read(wallpaperModeProvider.notifier).state = false;
              _toggleWallpaper();
            },
            child: WallpaperPage(),
          ),
        ),
      );
    }

    return WordNinjaDesktopApp(router: widget.router);
  }

  @override
  void onWindowFocus() {}
}
