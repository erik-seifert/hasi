import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '../history_graph_widget.dart';
import '../../services/hass_websocket_service.dart';
import '../../models/dashboard.dart';

class SensorWidget extends StatelessWidget {
  final String entityId;
  final EntityConfig? config;

  const SensorWidget({super.key, required this.entityId, this.config});

  @override
  Widget build(BuildContext context) {
    final entity = context.select<HassWebSocketService, Map<String, dynamic>?>(
      (ws) => ws.entitiesMap[entityId],
    );

    if (entity == null) return const SizedBox.shrink();

    final state = entity['state'] ?? 'unknown';
    final attributes = entity['attributes'] ?? {};
    final friendlyName =
        config?.nameOverride ?? attributes['friendly_name'] ?? entityId;
    final unit = attributes['unit_of_measurement'] ?? '';

    // History is visible by default for temp/humidity unless configured otherwise
    final isTempOrHumidity =
        entityId.contains('temperature') || entityId.contains('humidity');
    final showHistory = config?.options['show_history'] ?? isTempOrHumidity;
    final historyHours = config?.options['history_hours'] ?? 24;

    IconData icon = Icons.sensors;
    Color iconColor = Colors.blue;

    if (entityId.contains('temperature')) {
      icon = Icons.thermostat;
      iconColor = Colors.redAccent;
    } else if (entityId.contains('humidity')) {
      icon = Icons.water_drop;
      iconColor = Colors.blueAccent;
    } else if (entityId.contains('battery')) {
      icon = Icons.battery_charging_full;
      iconColor = Colors.green;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor),
              ),
              title: Text(
                friendlyName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                '$state$unit',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            if (showHistory)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  height: 150, // Fixed height for histogram
                  child: HistoryGraphWidget(
                    entityId: entityId,
                    friendlyName: friendlyName,
                    historyHours: historyHours,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

@widgetbook.UseCase(name: 'Temperature', type: SensorWidget)
Widget buildTemperatureSensorUseCase(BuildContext context) {
  return const SensorWidget(entityId: 'sensor.room_temp');
}

@widgetbook.UseCase(name: 'Humidity', type: SensorWidget)
Widget buildHumiditySensorUseCase(BuildContext context) {
  return const SensorWidget(entityId: 'sensor.room_humidity');
}
