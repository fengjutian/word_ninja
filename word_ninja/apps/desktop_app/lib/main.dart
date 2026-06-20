import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/lib/logger/logger.dart';
import 'app/desktop_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  log.i('Word Ninja Desktop started');

  final router = createDesktopRouter();

  runApp(ProviderScope(
    child: MaterialApp.router(
      title: 'Word Ninja Desktop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      routerConfig: router,
    ),
  ));
}
