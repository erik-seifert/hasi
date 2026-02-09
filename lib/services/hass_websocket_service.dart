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

  bool get isConnected => _isConnected;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic> get entitiesMap => _entities;
  List<dynamic> get entities => _entities.values.toList();
  List<dynamic> get areas => _areas;
  Map<String, dynamic> get entityRegistry => _entityRegistry;
  Map<String, dynamic> get deviceRegistry => _deviceRegistry;

  Future<void> connect(String baseUrl, String token) async {
    // If already checking/connected to same URL/token, return?
    // For now, simplify: disconnect if exists, then connect.
    await disconnect();

    _url = baseUrl.replaceFirst(RegExp(r'^http'), 'ws');
    _token = token;

    try {
      final wsUrl = Uri.parse('$_url/api/websocket');
      AppLogger.i('Connecting to $wsUrl');

      _channel = WebSocketChannel.connect(wsUrl);
      _isConnected = true;
      notifyListeners();

      _subscription = _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onDone: () {
          AppLogger.i('WebSocket connection closed');
          _isConnected = false;
          _isAuthenticated = false;
          notifyListeners();
          _cleanup();
        },
        onError: (error) {
          AppLogger.e('WebSocket error: $error');
          _isConnected = false;
          _isAuthenticated = false;
          notifyListeners();
          _cleanup();
        },
      );
    } catch (e) {
      AppLogger.e('Connection failed: $e');
      _isConnected = false;
      notifyListeners();
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
      disconnect();
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

    // Notify specifically for data changes if needed,
    // but usually specific subscriptions handle their own callbacks.
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

  Future<dynamic> getStates() {
    final id = _idCounter++;
    final completer = Completer<dynamic>();
    _pendingRequests[id] = completer;

    _sendJson({'id': id, 'type': 'get_states'});

    return completer.future;
  }

  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close(status.normalClosure);
      _channel = null;
    }
    _eventController.add(null);
    _cleanup();
    _isConnected = false;
    _isAuthenticated = false;
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

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
