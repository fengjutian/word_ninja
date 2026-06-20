import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/lib/ninja_theme/theme_data.dart';

/// App 根组件
class WordNinjaApp extends ConsumerWidget {
  final GoRouter router;

  const WordNinjaApp({super.key, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Word Ninja',
      debugShowCheckedModeBanner: false,
      theme: NinjaTheme.light,
      darkTheme: NinjaTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
