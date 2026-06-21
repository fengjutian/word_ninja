import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/logger/logger.dart';
import 'app/desktop_app.dart';
import 'app/di.dart';
import 'debug_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  log.i('Word Ninja Desktop started');

  // 🔍 调试模式：页面分析辅助线（需要时取消注释）
  // DebugOverlay.enableAll();

  final router = createDesktopRouter();

  runApp(ProviderScope(
    overrides: desktopOverrides(),
    child: MaterialApp.router(
      title: 'Word Ninja Desktop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      routerConfig: router,
      builder: kDebugMode ? _debugBuilder : null,
    ),
  ));
}

/// 🔍 调试模式：右下角浮动按钮切换辅助线
Widget _debugBuilder(BuildContext context, Widget? child) {
  return Stack(
    children: [
      if (child != null) child,
      Positioned(
        right: 16,
        bottom: 40,
        child: FloatingActionButton.small(
          heroTag: '__debug_toggle__',
          backgroundColor:
              DebugOverlay.isActive ? Colors.lightGreen : Colors.grey.shade400,
          onPressed: DebugOverlay.toggleAll,
          child: Icon(
            DebugOverlay.isActive ? Icons.visibility : Icons.visibility_off,
            size: 20,
          ),
        ),
      ),
    ],
  );
}
