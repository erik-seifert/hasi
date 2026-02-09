import 'dart:async';
import 'package:flutter/foundation.dart';
import 'hass_websocket_service.dart';
import 'notification_service.dart';

class AlertRule {
  final String entityId;
  final double threshold;
  final bool above; // true if alert when above, false if alert when below
  final String title;
  final String body;

  AlertRule({
    required this.entityId,
    required this.threshold,
    required this.above,
    required this.title,
    required this.body,
  });
}

class AlertService extends ChangeNotifier {
  final HassWebSocketService _ws;
  final NotificationService _notifications;
  StreamSubscription? _subscription;

  final List<AlertRule> _rules = [];

  AlertService(this._ws, this._notifications) {
    _subscription = _ws.eventStream.listen(_handleEvent);

    // Add some example rules
    _rules.add(
      AlertRule(
        entityId: 'sensor.living_room_temperature',
        threshold: 25.0,
        above: true,
        title: 'High Temperature',
        body: 'Living room temperature is above 25°C!',
      ),
    );

    _rules.add(
      AlertRule(
        entityId: 'sensor.kitchen_humidity',
        threshold: 30.0,
        above: false,
        title: 'Low Humidity',
        body: 'Kitchen humidity is below 30%!',
      ),
    );
  }

  void _handleEvent(dynamic event) {
    if (event == null || event['data'] == null) return;

    final newState = event['data']['new_state'];
    if (newState == null) return;

    final entityId = newState['entity_id'];
    final stateStr = newState['state'];
    final stateValue = double.tryParse(stateStr ?? '');

    if (stateValue == null) return;

    for (var rule in _rules) {
      if (rule.entityId == entityId) {
        bool triggered = rule.above
            ? (stateValue > rule.threshold)
            : (stateValue < rule.threshold);
        if (triggered) {
          _notifications.showNotification(
            id: rule.entityId.hashCode,
            title: rule.title,
            body: rule.body,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
