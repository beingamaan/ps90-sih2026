import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Cross-platform Audio Player Service (Native Stub: Android, iOS, Desktop)
class AudioPlayerService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  /// Plays base64 encoded MP3 audio or falls back to text-to-speech engine.
  Future<void> playAudioB64(
    String audioB64, {
    required String fallbackText,
    required String langCode,
    required String locale,
    VoidCallback? onEnded,
  }) async {
    await stop();
    _isPlaying = true;

    try {
      // On native mobile/desktop platforms, use FlutterTts for reliable offline voice audio
      await _flutterTts.setLanguage(locale);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.85);
      await _flutterTts.speak(fallbackText);

      // Simulate completion callback after speech duration
      Timer(const Duration(seconds: 4), () {
        _isPlaying = false;
        if (onEnded != null) onEnded();
      });
    } catch (e) {
      _isPlaying = false;
      if (onEnded != null) onEnded();
    }
  }

  /// Stops any currently playing audio.
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
    _isPlaying = false;
  }

  void dispose() {
    stop();
  }
}
