import 'package:core/logger/logger.dart';

/// TTS (Text-to-Speech) service.
///
/// Currently a no-op on Windows until flutter_tts native build
/// requirements (nuget.exe) are satisfied.
/// Add `flutter_tts: ^4.0.0` to pubspec.yaml and uncomment
/// the real implementation below to enable.
class TtsService {
  bool _initialized = false;

  Future<bool> get isAvailable async {
    try {
      // ignore: avoid_dynamic_calls
      final tts = await _tryInit();
      return tts != null;
    } catch (_) {
      return false;
    }
  }

  dynamic _tryInit() {
    // When flutter_tts is available, uncomment:
    // return FlutterTts();
    return null;
  }

  Future<void> speak(String text, {String? language, double? rate}) async {
    if (text.trim().isEmpty) return;
    if (!_initialized) {
      log.w('TTS not available — install flutter_tts and nuget.exe to enable');
      _initialized = true;
    }
  }

  Future<void> stop() async {}

  Future<void> setLanguage(String language) async {}

  Future<void> setRate(double rate) async {}

  Future<void> setPitch(double pitch) async {}

  Future<void> setVolume(double volume) async {}

  Future<bool> isSpeaking() async => false;

  void dispose() {}
}
