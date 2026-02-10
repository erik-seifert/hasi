import 'hass_websocket_service.dart';

class MockHassWebSocketService extends HassWebSocketService {
  final Map<String, dynamic> _mockEntities = {};

  @override
  Map<String, dynamic> get entitiesMap => _mockEntities;

  @override
  List<dynamic> get entities => _mockEntities.values.toList();

  void setMockEntity(String entityId, Map<String, dynamic> state) {
    _mockEntities[entityId] = state;
    notifyListeners();
  }

  @override
  bool get isConnected => true;

  @override
  bool get isAuthenticated => true;

  @override
  bool get isReady => true;

  @override
  Future<void> connect(String baseUrl, String token) async {
    // Do nothing
  }

  @override
  Future<void> refreshData() async {
    // Do nothing
  }

  @override
  Future<dynamic> callService(
    String domain,
    String service, {
    Map<String, dynamic>? serviceData,
    bool returnResponse = false,
  }) async {
    print('Mock callService: $domain.$service with $serviceData');

    if (serviceData != null && serviceData.containsKey('entity_id')) {
      final entityId = serviceData['entity_id'];
      if (_mockEntities.containsKey(entityId)) {
        final entity = Map<String, dynamic>.from(_mockEntities[entityId]!);
        final attributes = Map<String, dynamic>.from(
          entity['attributes'] ?? {},
        );

        if (service == 'turn_on') {
          entity['state'] = 'on';
          if (domain == 'light' && serviceData.containsKey('brightness')) {
            attributes['brightness'] = serviceData['brightness'];
          }
          if (domain == 'light' && serviceData.containsKey('rgb_color')) {
            attributes['rgb_color'] = serviceData['rgb_color'];
          }
        } else if (service == 'turn_off') {
          entity['state'] = 'off';
        } else if (service == 'toggle') {
          entity['state'] = entity['state'] == 'on' ? 'off' : 'on';
        } else if (domain == 'climate') {
          if (service == 'set_hvac_mode') {
            entity['state'] = serviceData['hvac_mode'];
            attributes['hvac_action'] = serviceData['hvac_mode'] == 'off'
                ? 'off'
                : 'heating'; // simplistic mock
          } else if (service == 'set_temperature') {
            attributes['temperature'] = serviceData['temperature'];
          } else if (service == 'set_fan_mode') {
            attributes['fan_mode'] = serviceData['fan_mode'];
          } else if (service == 'set_preset_mode') {
            attributes['preset_mode'] = serviceData['preset_mode'];
          }
        }

        entity['attributes'] = attributes;
        _mockEntities[entityId] = entity;
        notifyListeners();
      }
    }
    return null;
  }
}
