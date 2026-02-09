import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'hass_websocket_service.dart';

class VoiceService extends ChangeNotifier {
  final HassWebSocketService _ws;
  FlutterTts? _tts;
  bool _isSpeaking = false;
  bool _useNativeTts = false;
  String? _linuxTtsEngine;
  Process? _currentProcess;

  VoiceService(this._ws) {
    _initTts();
  }

  bool get isSpeaking => _isSpeaking;
  bool get useNativeTts => _useNativeTts;
  String? get linuxTtsEngine => _linuxTtsEngine;

  Future<void> _initTts() async {
    // Check if we're on Linux
    if (Platform.isLinux) {
      // Try to find available Linux TTS engines
      _linuxTtsEngine = await _detectLinuxTtsEngine();

      if (_linuxTtsEngine != null) {
        _useNativeTts = true;
        debugPrint("Using native Linux TTS engine: $_linuxTtsEngine");
        return;
      } else {
        debugPrint(
          "No native Linux TTS engine found. Please install espeak-ng or festival.",
        );
        debugPrint("Install with: sudo apt install espeak-ng");
      }
    }

    // Use flutter_tts for non-Linux platforms or as fallback
    try {
      _tts = FlutterTts();
      await _tts!.setLanguage("en-US");
      await _tts!.setSpeechRate(0.5);
      await _tts!.setVolume(1.0);
      await _tts!.setPitch(1.0);

      _tts!.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });

      _tts!.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _tts!.setErrorHandler((msg) {
        _isSpeaking = false;
        notifyListeners();
        debugPrint("TTS error: $msg");
      });

      debugPrint("Using flutter_tts");
    } catch (e) {
      debugPrint("Could not initialize TTS: $e");
    }
  }

  /// Detect available Linux TTS engines
  Future<String?> _detectLinuxTtsEngine() async {
    final engines = ['espeak-ng', 'espeak', 'festival'];

    for (final engine in engines) {
      try {
        final result = await Process.run('which', [engine]);
        if (result.exitCode == 0) {
          return engine;
        }
      } catch (e) {
        // Continue to next engine
      }
    }

    return null;
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    try {
      if (_useNativeTts && _linuxTtsEngine != null) {
        await _speakLinux(text);
      } else if (_tts != null) {
        await _tts!.speak(text);
      } else {
        debugPrint("No TTS engine available");
      }
    } catch (e) {
      debugPrint("Error during speak: $e");
    }
  }

  Future<void> _speakLinux(String text) async {
    try {
      _isSpeaking = true;
      notifyListeners();

      List<String> args;

      switch (_linuxTtsEngine) {
        case 'espeak-ng':
        case 'espeak':
          // espeak-ng options:
          // -v: voice (en-us)
          // -s: speed (150 words per minute)
          // -a: amplitude/volume (0-200, default 100)
          args = ['-v', 'en-us', '-s', '150', text];
          break;
        case 'festival':
          // festival reads from stdin
          args = ['--tts'];
          break;
        default:
          throw Exception('Unknown TTS engine: $_linuxTtsEngine');
      }

      if (_linuxTtsEngine == 'festival') {
        // Festival needs text via stdin
        _currentProcess = await Process.start(_linuxTtsEngine!, args);
        _currentProcess!.stdin.writeln(text);
        await _currentProcess!.stdin.close();
        await _currentProcess!.exitCode;
      } else {
        // espeak/espeak-ng take text as argument
        _currentProcess = await Process.start(_linuxTtsEngine!, args);
        await _currentProcess!.exitCode;
      }

      _isSpeaking = false;
      _currentProcess = null;
      notifyListeners();
    } catch (e) {
      debugPrint("Error during Linux TTS: $e");
      _isSpeaking = false;
      _currentProcess = null;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    if (_useNativeTts) {
      // Kill the current process if running
      _currentProcess?.kill();
      _currentProcess = null;
      _isSpeaking = false;
      notifyListeners();
    } else if (_tts != null) {
      await _tts!.stop();
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<String?> sendCommand(String text) async {
    try {
      final response = await _ws.processConversation(text);
      debugPrint('Assist response: $response');

      final speechText = response['response']?['speech']?['plain']?['speech'];
      if (speechText != null) {
        await speak(speechText);
        return speechText as String;
      }
      return null;
    } catch (e) {
      debugPrint('Error sending assist command: $e');
      await speak("Sorry, I encountered an error processing your command.");
      return null;
    }
  }

  // For now, let's add a placeholder for STT since Linux support is limited
  // In a real Linux app, we might use a shell command or a better plugin
  Future<void> startListening() async {
    // Placeholder
  }

  @override
  void dispose() {
    _currentProcess?.kill();
    super.dispose();
  }
}
