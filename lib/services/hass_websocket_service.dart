import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'logger_service.dart';
import 'ha_log_database_service.dart';

class HassWebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  bool _isAuthenticated = false;
  bool _isReady = false;
  int _idCounter = 1;
  final Map<int, Completer<dynamic>> _pendingRequests = {};
  final Map<String, dynamic> _entities = {};
  final Map<String, dynamic> _entityRegistry = {};
  final Map<String, dynamic> _deviceRegistry = {};
  final List<dynamic> _areas = [];
  final _eventController = StreamController<dynamic>.broadcast();

  Stream<dynamic> get eventStream => _eventController.stream;

  // connection details
  String? _url;
  String? _token;
  bool _isManuallyDisconnected = false;

  // Heartbeat and Reconnection
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  static const _pingInterval = Duration(seconds: 30);
  static const _reconnectDelay = Duration(seconds: 5);

  String? _connectionError;

  bool get isConnected => _isConnected;
  bool get isAuthenticated => _isAuthenticated;
  bool get isReady => _isReady;
  String? get connectionError => _connectionError;
  Map<String, dynamic> get entitiesMap => _entities;
  List<dynamic> get entities => _entities.values.toList();
  List<dynamic> get areas => _areas;
  Map<String, dynamic> get entityRegistry => _entityRegistry;
  Map<String, dynamic> get deviceRegistry => _deviceRegistry;

  Future<void> connect(String baseUrl, String token) async {
    _isManuallyDisconnected = false;
    _url = baseUrl.replaceFirst(RegExp(r'^http'), 'ws');
    _token = token;

    _connectionError = null;
    await _establishConnection();
  }

  Future<void> _establishConnection() async {
    if (_url == null || _token == null) return;

    // If already connected, do nothing
    if (_isConnected && _channel != null) return;

    _cleanup();

    try {
      final wsUrl = Uri.parse('$_url/api/websocket');
      AppLogger.i('Connecting to $wsUrl');

      _channel = WebSocketChannel.connect(wsUrl);
      _isConnected = true;
      _connectionError = null;
      notifyListeners();

      _subscription = _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onDone: () {
          AppLogger.i('WebSocket connection closed');
          _handleDisconnect();
        },
        onError: (error) {
          AppLogger.e('WebSocket error: $error');
          _handleDisconnect();
        },
      );

      _startPingTimer();
    } catch (e) {
      AppLogger.e('Connection failed: $e');
      _connectionError =
          'Could not connect to Home Assistant. Please check your URL and network.';
      _handleDisconnect(isError: true);
    }
  }

  void _handleDisconnect({bool isError = false}) {
    _isConnected = false;
    _isAuthenticated = false;
    _isReady = false;
    _stopPingTimer();
    notifyListeners();
    _cleanup();

    if (!_isManuallyDisconnected && !isError) {
      _scheduleReconnection();
    }
  }

  void _scheduleReconnection() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_isConnected && !_isManuallyDisconnected) {
        AppLogger.i('Attempting to reconnect...');
        _establishConnection();
      }
    });
  }

  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      _sendPing();
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _sendPing() {
    if (_isConnected) {
      _sendJson({'id': _idCounter++, 'type': 'ping'});
    }
  }

  void _handleMessage(dynamic message) {
    if (message is! String) return; // HA sends text frames (JSON)

    HaLogDatabaseService.log('RECEIVED', message);

    final data = jsonDecode(message);
    final type = data['type'];

    if (type == 'auth_required') {
      _sendAuth();
    } else if (type == 'auth_ok') {
      _isAuthenticated = true;
      notifyListeners();
      AppLogger.i('Authenticated with Home Assistant');
      _subscribeToEvents();
      refreshData();
    } else if (type == 'auth_invalid') {
      AppLogger.w('Authentication failed: ${data['message']}');
      _connectionError = 'auth_invalid';
      _handleDisconnect(isError: true);
    } else if (type == 'pong') {
      // Received pong, connection is alive
    } else if (type == 'result') {
      final id = data['id'];
      if (_pendingRequests.containsKey(id)) {
        if (data['success'] == true) {
          _pendingRequests[id]!.complete(data['result']);
        } else {
          _pendingRequests[id]!.completeError(data['error'] ?? 'Unknown error');
        }
        _pendingRequests.remove(id);
      }
    } else if (type == 'event') {
      _eventController.add(data['event']);
      if (data['event'] != null &&
          data['event']['event_type'] == 'state_changed') {
        final newState = data['event']['data']['new_state'];
        if (newState != null) {
          _entities[newState['entity_id']] = newState;
          notifyListeners();
        }
      }
    }
  }

  void _sendAuth() {
    if (_token == null) return;
    _sendJson({'type': 'auth', 'access_token': _token});
  }

  void _subscribeToEvents() {
    _sendJson({
      'id': _idCounter++,
      'type': 'subscribe_events',
      'event_type': 'state_changed',
    });
  }

  Future<void> refreshData() async {
    try {
      // Fetch registries first
      final areaReg = await getAreaRegistry();
      if (areaReg is List) {
        _areas.clear();
        _areas.addAll(areaReg);
      }

      final entityReg = await getEntityRegistry();
      if (entityReg is List) {
        _entityRegistry.clear();
        for (var entry in entityReg) {
          _entityRegistry[entry['entity_id']] = entry;
        }
      }

      final deviceReg = await getDeviceRegistry();
      if (deviceReg is List) {
        _deviceRegistry.clear();
        for (var entry in deviceReg) {
          _deviceRegistry[entry['id']] = entry;
        }
      }

      final states = await getStates();
      if (states is List) {
        for (var state in states) {
          _entities[state['entity_id']] = state;
        }
        _isReady = true;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.e('Error fetching initial data: $e');
    }
  }

  Future<dynamic> getAreaRegistry() {
    final id = _idCounter++;
    final completer = Completer<dynamic>();
    _pendingRequests[id] = completer;
    _sendJson({'id': id, 'type': 'config/area_registry/list'});
    return completer.future;
  }

  Future<dynamic> getEntityRegistry() {
    final id = _idCounter++;
    final completer = Completer<dynamic>();
    _pendingRequests[id] = completer;
    _sendJson({'id': id, 'type': 'config/entity_registry/list'});
    return completer.future;
  }

  Future<dynamic> getDeviceRegistry() {
    final id = _idCounter++;
    final completer = Completer<dynamic>();
    _pendingRequests[id] = completer;
    _sendJson({'id': id, 'type': 'config/device_registry/list'});
    return completer.future;
  }

  void _sendJson(Map<String, dynamic> data) {
    if (_channel != null) {
      final json = jsonEncode(data);
      HaLogDatabaseService.log('SENT', data);
      _channel!.sink.add(json);
    }
  }

  Future<dynamic> callService(
    String domain,
    String service, {
    Map<String, dynamic>? serviceData,
    bool returnResponse = false,
  }) {
    final id = _idCounter++;
    final completer = Completer<dynamic>();
    _pendingRequests[id] = completer;

    _sendJson({
      'id': id,
      'type': 'call_service',
      'domain': domain,
      'service': service,
      'service_data': serviceData ?? {},
      if (returnResponse) 'return_response': true,
    });

    return completer.future;
  }

  Future<dynamic> processConversation(String text) {
    final id = _idCounter++;
    final completer = Completer<dynamic>();
    _pendingRequests[id] = completer;

    _sendJson({'id': id, 'type': 'conversation/process', 'text': text});

    return completer.future;
  }

  /// Starts the Assist pipeline for voice interaction.
  /// Returns the subscription ID (which is the message ID).
  int runAssistPipeline({
    String startStage = 'stt',
    String endStage = 'tts',
    int sampleRate = 16000,
  }) {
    final id = _idCounter++;
    _sendJson({
      'id': id,
      'type': 'assist_pipeline/run',
      'start_stage': startStage,
      'end_stage': endStage,
      'input': {'sample_rate': sampleRate},
    });
    return id;
  }

  /// Sends a chunk of binary audio data to the WebSocket.
  void sendAudioChunk(Uint8List chunk) {
    if (_channel != null) {
      _channel!.sink.add(chunk);
    }
  }

  Future<dynamic> getStates() {
    final id = _idCounter++;
    final completer = Completer<dynamic>();
    _pendingRequests[id] = completer;

    _sendJson({'id': id, 'type': 'get_states'});

    return completer.future;
  }

  Future<void> disconnect() async {
    _isManuallyDisconnected = true;
    _reconnectTimer?.cancel();
    _stopPingTimer();

    if (_channel != null) {
      await _channel!.sink.close(status.normalClosure);
      _channel = null;
    }
    _eventController.add(null);
    _cleanup();
    _entities.clear();
    _entityRegistry.clear();
    _deviceRegistry.clear();
    _areas.clear();
    _isConnected = false;
    _isAuthenticated = false;
    _isReady = false;
    notifyListeners();
  }

  void _cleanup() {
    _subscription?.cancel();
    _subscription = null;

    // Clear pending requests
    for (var completer in _pendingRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError('Connection closed');
      }
    }
    _pendingRequests.clear();
  }

  /// Explicitly check connection and reconnect if needed.
  /// Useful when app resumes from background.
  void reconnectIfNeeded() {
    if (_isManuallyDisconnected) return;

    if (!_isConnected || _channel == null) {
      AppLogger.i('Reconnecting after lifecycle change...');
      _establishConnection();
    } else {
      // Even if connected, send a ping to verify
      _sendPing();
    }
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _stopPingTimer();
    disconnect();
    super.dispose();
  }
}
