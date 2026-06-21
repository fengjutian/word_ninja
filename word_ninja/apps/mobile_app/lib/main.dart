import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/bootstrap.dart';
import 'app/app.dart';
import 'app/di.dart';
import 'app/router.dart';
import 'debug_overlay.dart';

void main() async {
  // 初始化
  await AppBootstrap.init();

  // 🔍 调试模式：页面分析辅助线（需要时取消注释）
  // DebugOverlay.enableAll();

  // 创建路由
  final router = createRouter();

  // 启动 App（注入所有 Provider overrides）
  runApp(
    ProviderScope(
      overrides: diOverrides,
      child: WordNinjaApp(router: router),
    ),
  );
}
