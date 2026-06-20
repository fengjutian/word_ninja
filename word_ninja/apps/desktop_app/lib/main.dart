import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/lib/logger/logger.dart';
import 'package:core/lib/storage/secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.init();
  log.i('Word Ninja Desktop started');

  runApp(const ProviderScope(
    child: DesktopApp(),
  ));
}

class DesktopApp extends StatelessWidget {
  const DesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Ninja',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Word Ninja Desktop'),
        ),
      ),
    );
  }
}
