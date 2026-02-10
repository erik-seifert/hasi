import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '../history_graph_widget.dart';
import '../../services/hass_websocket_service.dart';
import '../../models/dashboard.dart';
import '../../utils/date_utils.dart';

class SensorWidget extends StatelessWidget {
  final String entityId;
  final EntityConfig? config;
  final List<FlSpot>? mockHistoryData;

  const SensorWidget({
    super.key,
    required this.entityId,
    this.config,
    this.mockHistoryData,
  });

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
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
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
              trailing: Builder(
                builder: (context) {
                  final displayState = HaDateUtils.isHaTimestamp(state)
                      ? HaDateUtils.formatHaTimestamp(state)
                      : '$state$unit';
                  return Text(
                    displayState,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  );
                },
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
                    mockHistoryData: mockHistoryData,
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
  final historyDataString = context.knobs.string(
    label: 'History Data (comma separated)',
    initialValue:
        '5, 8, 6, 10, 15, 12, 18, 20, 16, 19, 17, 14, 10, 8, 5, 6, 9, 11, 13, 15',
  );

  List<FlSpot>? mockHistoryData;
  try {
    if (historyDataString.isNotEmpty) {
      final values = historyDataString
          .split(',')
          .map((s) => double.tryParse(s.trim()))
          .whereType<double>()
          .toList();

      mockHistoryData = List.generate(values.length, (index) {
        return FlSpot(index.toDouble(), values[index]);
      });
    } else {
      mockHistoryData = [];
    }
  } catch (e) {
    mockHistoryData = [];
  }

  return SensorWidget(
    entityId: 'sensor.room_temperature',
    mockHistoryData: mockHistoryData,
    config: EntityConfig(
      nameOverride: context.knobs.string(
        label: 'Name Override',
        initialValue: 'Room Temp',
      ),
      options: {
        'show_history': context.knobs.boolean(
          label: 'Show History',
          initialValue: true,
        ),
        'history_hours': context.knobs.double
            .slider(
              label: 'History Hours',
              initialValue: 24,
              min: 1,
              max: 72,
              divisions: 71,
            )
            .toInt(),
      },
    ),
  );
}

@widgetbook.UseCase(name: 'Humidity', type: SensorWidget)
Widget buildHumiditySensorUseCase(BuildContext context) {
  final historyDataString = context.knobs.string(
    label: 'History Data (comma separated)',
    initialValue:
        '45, 46, 48, 50, 52, 51, 50, 49, 48, 47, 46, 45, 44, 45, 46, 47',
  );

  List<FlSpot>? mockHistoryData;
  try {
    if (historyDataString.isNotEmpty) {
      final values = historyDataString
          .split(',')
          .map((s) => double.tryParse(s.trim()))
          .whereType<double>()
          .toList();

      mockHistoryData = List.generate(values.length, (index) {
        return FlSpot(index.toDouble(), values[index]);
      });
    } else {
      mockHistoryData = [];
    }
  } catch (e) {
    mockHistoryData = [];
  }

  return SensorWidget(
    entityId: 'sensor.room_humidity',
    mockHistoryData: mockHistoryData,
    config: EntityConfig(
      nameOverride: context.knobs.string(
        label: 'Name Override',
        initialValue: 'Room Humidity',
      ),
      options: {
        'show_history': context.knobs.boolean(
          label: 'Show History',
          initialValue: true,
        ),
        'history_hours': context.knobs.double
            .slider(
              label: 'History Hours',
              initialValue: 24,
              min: 1,
              max: 72,
              divisions: 71,
            )
            .toInt(),
      },
    ),
  );
}
