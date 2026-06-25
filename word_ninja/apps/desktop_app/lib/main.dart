import 'package:flutter/foundation.dart';  
import 'package:flutter/material.dart';  
import 'package:flutter_riverpod/flutter_riverpod.dart';  
import 'package:window_manager/window_manager.dart';  
import 'package:core/logger/logger.dart';  
import 'app/desktop_app.dart';  
import 'app/bootstrap.dart';  
import 'app/di.dart';  
import 'debug_overlay.dart'; 
  
void main() async {  
  WidgetsFlutterBinding.ensureInitialized();  
  
  // Desktop window initialization  
  await windowManager.ensureInitialized(); 
  const windowOptions = WindowOptions(  
    title: 'Word Ninja',  
    size: Size(1280, 800),  
    minimumSize: Size(960, 640),  
    center: true,  
    backgroundColor: Colors.transparent,  
    skipTaskbar: false,  
    titleBarStyle: TitleBarStyle.normal,  
  ); 
  windowManager.waitUntilReadyToShow(windowOptions, () async {  
    await windowManager.show();  
    await windowManager.focus();  
  });  
  
  // App bootstrap (Isar, Preferences, etc.)  
  await AppBootstrap.init();  
  log.i('Word Ninja Desktop started'); 
  
  final router = createDesktopRouter();  
  
  runApp(  
    ProviderScope(  
      overrides: desktopOverrides,  
      child: WordNinjaDesktopApp(router: router),  
    ),  
  );  
} 
