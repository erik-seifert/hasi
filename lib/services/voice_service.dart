import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'hass_websocket_service.dart';

class VoiceService extends ChangeNotifier {
  final HassWebSocketService _ws;
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  VoiceService(this._ws) {
    _initTts();
  }

  bool get isSpeaking => _isSpeaking;

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        notifyListeners();
        debugPrint("TTS error: $msg");
      });
    } catch (e) {
      debugPrint("Could not initialize TTS: $e");
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint("Error during speak: $e");
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
    notifyListeners();
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
}
