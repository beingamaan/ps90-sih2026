import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Cross-platform Audio Player Service (Web Implementation using dart:html)
class AudioPlayerService {
  html.AudioElement? _currentAudio;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  /// Plays base64 encoded MP3 audio or falls back to text-to-speech engine on web.
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
      if (audioB64.isNotEmpty) {
        _currentAudio = html.AudioElement(audioB64);
        _currentAudio!.onEnded.listen((_) {
          _isPlaying = false;
          if (onEnded != null) onEnded();
        });
        _currentAudio!.onPause.listen((_) {
          _isPlaying = false;
        });
        await _currentAudio!.play();
      } else {
        // Fallback to flutter_tts if backend MP3 audio was empty
        await _flutterTts.setLanguage(locale);
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setSpeechRate(0.85);
        await _flutterTts.speak(fallbackText);
        Timer(const Duration(seconds: 4), () {
          _isPlaying = false;
          if (onEnded != null) onEnded();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Web Audio Player Error: $e');
      }
      _isPlaying = false;
      if (onEnded != null) onEnded();
    }
  }

  /// Stops any currently playing audio.
  Future<void> stop() async {
    try {
      if (_currentAudio != null) {
        _currentAudio!.pause();
        _currentAudio = null;
      }
      await _flutterTts.stop();
    } catch (_) {}
    _isPlaying = false;
  }

  void dispose() {
    stop();
  }
}
