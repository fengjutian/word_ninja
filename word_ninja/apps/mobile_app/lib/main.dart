import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/bootstrap.dart';
import 'app/app.dart';
import 'app/router.dart';

void main() async {
  // 初始化
  await AppBootstrap.init();

  // 创建路由
  final router = createRouter();

  // 启动 App
  runApp(
    ProviderScope(
      child: WordNinjaApp(router: router),
    ),
  );
}
