import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '../../services/hass_websocket_service.dart';

import '../../models/dashboard.dart';

class ClimateWidget extends StatelessWidget {
  final String entityId;
  final EntityConfig? config;

  const ClimateWidget({super.key, required this.entityId, this.config});

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
    final currentTemp = attributes['current_temperature'];
    final targetTemp =
        attributes['temperature'] ?? attributes['target_temp_low'] ?? 21.0;
    final hvacModes = attributes['hvac_modes'] ?? [];
    final fanModes = attributes['fan_modes'] ?? [];
    final presetModes = attributes['preset_modes'] ?? [];
    final hvacAction = attributes['hvac_action'];

    final minTemp = (attributes['min_temp'] ?? 7.0).toDouble();
    final maxTemp = (attributes['max_temp'] ?? 35.0).toDouble();

    final showHvacMode = config?.options['show_hvac_mode'] ?? true;
    final showPresetMode = config?.options['show_preset_mode'] ?? true;
    final showFanMode = config?.options['show_fan_mode'] ?? true;

    Color themeColor = _getStateColor(state);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friendlyName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            state.toUpperCase(),
                            style: TextStyle(
                              color: themeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (hvacAction != null &&
                            hvacAction != 'idle' &&
                            hvacAction != 'off')
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              _getActionIcon(hvacAction),
                              size: 16,
                              color: themeColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (currentTemp != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Current',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '$currentTemp°',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTempButton(
                  context,
                  entityId,
                  targetTemp - 0.5,
                  Icons.remove,
                  Colors.blue,
                  enabled: targetTemp > minTemp,
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: maxTemp > minTemp
                            ? (targetTemp - minTemp) / (maxTemp - minTemp)
                            : 0,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${targetTemp.toStringAsFixed(1)}°',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Target',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildTempButton(
                  context,
                  entityId,
                  targetTemp + 0.5,
                  Icons.add,
                  Colors.red,
                  enabled: targetTemp < maxTemp,
                ),
              ],
            ),
            if (showHvacMode && hvacModes.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'HVAC Mode',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: hvacModes.map<Widget>((mode) {
                    bool isSelected = state == mode;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(mode.toString().toUpperCase()),
                        selected: isSelected,
                        selectedColor: _getStateColor(
                          mode,
                        ).withValues(alpha: 0.3),
                        onSelected: (selected) {
                          if (selected) {
                            context.read<HassWebSocketService>().callService(
                              'climate',
                              'set_hvac_mode',
                              serviceData: {
                                'entity_id': entityId,
                                'hvac_mode': mode,
                              },
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            if (showFanMode && fanModes.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Fan Mode',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: fanModes.map<Widget>((mode) {
                    bool isSelected = attributes['fan_mode'] == mode;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(mode.toString()),
                        selected: isSelected,
                        onSelected: (selected) {
                          context.read<HassWebSocketService>().callService(
                            'climate',
                            'set_fan_mode',
                            serviceData: {
                              'entity_id': entityId,
                              'fan_mode': mode,
                            },
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            if (showPresetMode && presetModes.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Preset',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: presetModes.map<Widget>((mode) {
                    bool isSelected = attributes['preset_mode'] == mode;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(mode.toString()),
                        selected: isSelected,
                        onSelected: (selected) {
                          context.read<HassWebSocketService>().callService(
                            'climate',
                            'set_preset_mode',
                            serviceData: {
                              'entity_id': entityId,
                              'preset_mode': mode,
                            },
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTempButton(
    BuildContext context,
    String entityId,
    double newTemp,
    IconData icon,
    Color color, {
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? color.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: enabled ? color : Colors.grey),
        onPressed: enabled
            ? () {
                context.read<HassWebSocketService>().callService(
                  'climate',
                  'set_temperature',
                  serviceData: {'entity_id': entityId, 'temperature': newTemp},
                );
              }
            : null,
      ),
    );
  }

  Color _getStateColor(String state) {
    switch (state) {
      case 'heat':
        return Colors.redAccent;
      case 'cool':
        return Colors.blueAccent;
      case 'off':
        return Colors.grey;
      case 'auto':
        return Colors.greenAccent;
      case 'fan_only':
        return Colors.orangeAccent;
      case 'dry':
        return Colors.tealAccent;
      default:
        return Colors.orangeAccent;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'heating':
        return Icons.fireplace;
      case 'cooling':
        return Icons.ac_unit;
      case 'fan':
        return Icons.air;
      case 'drying':
        return Icons.water_drop;
      default:
        return Icons.circle;
    }
  }
}

@widgetbook.UseCase(name: 'Full Featured', type: ClimateWidget)
Widget buildClimateWidgetFullUseCase(BuildContext context) {
  return ClimateWidget(
    entityId: 'climate.nest',
    config: EntityConfig(
      nameOverride: context.knobs.string(
        label: 'Name Override',
        initialValue: 'Living Room',
      ),
      options: {
        'show_hvac_mode': context.knobs.boolean(
          label: 'Show HVAC Mode',
          initialValue: true,
        ),
        'show_preset_mode': context.knobs.boolean(
          label: 'Show Preset Mode',
          initialValue: true,
        ),
        'show_fan_mode': context.knobs.boolean(
          label: 'Show Fan Mode',
          initialValue: true,
        ),
      },
    ),
  );
}

@widgetbook.UseCase(name: 'Simple', type: ClimateWidget)
Widget buildClimateWidgetSimpleUseCase(BuildContext context) {
  return ClimateWidget(
    entityId: 'climate.simple',
    config: EntityConfig(
      nameOverride: context.knobs.string(
        label: 'Name Override',
        initialValue: 'Guest Room',
      ),
      options: {
        'show_hvac_mode': context.knobs.boolean(
          label: 'Show HVAC Mode',
          initialValue: false,
        ),
        'show_preset_mode': context.knobs.boolean(
          label: 'Show Preset Mode',
          initialValue: false,
        ),
      },
    ),
  );
}
