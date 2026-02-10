import 'dart:async';
import 'package:flutter/material.dart';
import '../services/hass_websocket_service.dart';

class LightController extends ChangeNotifier {
  final String entityId;
  final HassWebSocketService _ws;

  Timer? _debounceTimer;

  DateTime? _lastCommandAt;

  // Local state to keep sliders smooth
  int? _lastSentBrightness;
  int? _lastSentColorTemp;
  int? _localBrightness;
  int? _localColorTemp;
  List<int>? _localRgbColor;

  LightController(this.entityId, this._ws);

  int getBrightness(int remoteValue) {
    if (_localBrightness != null) return _localBrightness!;
    if (_lastCommandAt != null &&
        DateTime.now().difference(_lastCommandAt!) <
            const Duration(seconds: 2)) {
      if (_lastSentBrightness != null) return _lastSentBrightness!;
    }
    return remoteValue;
  }

  int getColorTemp(int remoteValue) {
    if (_localColorTemp != null) return _localColorTemp!;
    if (_lastCommandAt != null &&
        DateTime.now().difference(_lastCommandAt!) <
            const Duration(seconds: 2)) {
      if (_lastSentColorTemp != null) return _lastSentColorTemp!;
    }
    return remoteValue;
  }

  List<int> getRgbColor(List<int> remoteValue) => _localRgbColor ?? remoteValue;

  void toggle(bool turnOn) {
    _ws.callService(
      'light',
      turnOn ? 'turn_on' : 'turn_off',
      serviceData: {'entity_id': entityId},
    );
  }

  void setBrightness(double value) {
    _localBrightness = value.round();
    notifyListeners();
    _debounce(() {
      _lastSentBrightness = _localBrightness;
      _lastCommandAt = DateTime.now();
      _ws.callService(
        'light',
        'turn_on',
        serviceData: {'entity_id': entityId, 'brightness': _localBrightness},
      );
      _localBrightness = null;
      notifyListeners();
    });
  }

  void setColorTemp(double value) {
    _localColorTemp = value.round();
    notifyListeners();
    _debounce(() {
      _lastSentColorTemp = _localColorTemp;
      _lastCommandAt = DateTime.now();
      _ws.callService(
        'light',
        'turn_on',
        serviceData: {'entity_id': entityId, 'color_temp': _localColorTemp},
      );
      _localColorTemp = null;
      notifyListeners();
    });
  }

  void setRgbColor(Color color) {
    _localRgbColor = [
      (color.r * 255).round(),
      (color.g * 255).round(),
      (color.b * 255).round(),
    ];
    notifyListeners();
    _ws.callService(
      'light',
      'turn_on',
      serviceData: {'entity_id': entityId, 'rgb_color': _localRgbColor},
    );
    _localRgbColor = null;
  }

  void _debounce(VoidCallback action) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), action);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
