import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 壁纸模式状态
final wallpaperModeProvider = StateProvider<bool>((ref) => false);

/// 壁纸模式下的浮动面板是否可见
final wallpaperPanelProvider = StateProvider<bool>((ref) => true);
