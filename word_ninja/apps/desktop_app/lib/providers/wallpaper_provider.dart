import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/storage/preferences.dart';

/// 壁纸模式状态 — synced with Preferences for cross-page toggle
final wallpaperModeProvider = StateProvider<bool>((ref) {
  return Preferences.getBool('wallpaper_mode');
});

/// Toggle wallpaper mode (both in Preferences and provider state)
void toggleWallpaperMode(StateProvider<bool> provider, WidgetRef ref) {
  final current = ref.read(provider);
  final next = !current;
  Preferences.setBool('wallpaper_mode', next);
  ref.read(provider.notifier).state = next;
}
