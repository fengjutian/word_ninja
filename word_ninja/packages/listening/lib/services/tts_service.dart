import 'package:flutter_tts/flutter_tts.dart';

/// TTS (Text-to-Speech) service wrapping flutter_tts
class TtsService {
  final FlutterTts _tts = FlutterTts();

  FlutterTts get engine => _tts;

  Future<void> speak(String text, {String? language, double? rate}) async {
    if (text.trim().isEmpty) return;
    await _tts.setLanguage(language ?? 'en-US');
    if (rate != null) await _tts.setSpeechRate(rate);
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();

  Future<void> setLanguage(String language) => _tts.setLanguage(language);

  Future<void> setRate(double rate) => _tts.setSpeechRate(rate);

  Future<void> setPitch(double pitch) => _tts.setPitch(pitch);

  Future<void> setVolume(double volume) => _tts.setVolume(volume);

  Future<bool> isSpeaking() async =>
      (await _tts.isSpeaking) ?? false;

  void dispose() {
    _tts.stop();
  }
}
