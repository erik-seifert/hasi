import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'hass_websocket_service.dart';

class VoiceService extends ChangeNotifier {
  final HassWebSocketService _ws;
  FlutterTts? _tts;
  final _audioRecorder = AudioRecorder();
  StreamSubscription<Uint8List>? _audioSubscription;
  StreamSubscription<dynamic>? _wsSubscription;

  bool _isSpeaking = false;
  bool _isListening = false;
  bool _useNativeTts = false;
  String? _linuxTtsEngine;
  Process? _currentProcess;

  VoiceService(this._ws) {
    _initTts();
  }

  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;
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
          args = ['-v', 'en-us', '-s', '150', text];
          break;
        case 'festival':
          args = ['--tts'];
          break;
        default:
          throw Exception('Unknown TTS engine: $_linuxTtsEngine');
      }

      if (_linuxTtsEngine == 'festival') {
        _currentProcess = await Process.start(_linuxTtsEngine!, args);
        _currentProcess!.stdin.writeln(text);
        await _currentProcess!.stdin.close();
        await _currentProcess!.exitCode;
      } else {
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
    if (_isListening) {
      await stopListening();
    }

    if (_useNativeTts) {
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

  Future<void> startListening() async {
    if (_isListening) return;

    try {
      if (await _audioRecorder.hasPermission()) {
        _isListening = true;
        notifyListeners();

        // 1. Start HA Assist pipeline
        _ws.runAssistPipeline(
          startStage: 'stt',
          endStage: 'tts',
          sampleRate: 16000,
        );

        // 2. Listen for WebSocket responses for this pipeline
        _wsSubscription = _ws.eventStream.listen((event) async {
          if (event == null) return;
          final type = event['type'];

          if (type == 'run-end') {
            await stopListening();
          } else if (type == 'intent-end') {
            final speechText =
                event['data']?['intent_output']?['response']?['speech']?['plain']?['speech'];
            if (speechText != null) {
              debugPrint('Assist response: $speechText');
            }
          } else if (type == 'tts-end') {
            // Note: If endStage is tts, HA will send a URL to the spoken response.
            // We usually let HA process the whole pipeline if requested.
          }
        });

        // 3. Start recording and streaming audio
        const config = RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        );

        final stream = await _audioRecorder.startStream(config);
        _audioSubscription = stream.listen((chunk) {
          _ws.sendAudioChunk(Uint8List.fromList(chunk));
        });
      }
    } catch (e) {
      debugPrint("Error starting listener: $e");
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _audioRecorder.stop();
      await _audioSubscription?.cancel();
      await _wsSubscription?.cancel();
      _audioSubscription = null;
      _wsSubscription = null;

      // Send an empty chunk to indicate end of stream if needed,
      // but HA usually detects end of stream or expects a specific message.
      // For assist_pipeline/run, we just stop sending binary data.
      _ws.sendAudioChunk(Uint8List(0));

      _isListening = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error stopping listener: $e");
    }
  }

  Future<String?> sendCommand(String text) async {
    try {
      final response = await _ws.processConversation(text);
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

  @override
  void dispose() {
    _currentProcess?.kill();
    _audioRecorder.dispose();
    _audioSubscription?.cancel();
    _wsSubscription?.cancel();
    super.dispose();
  }
}
