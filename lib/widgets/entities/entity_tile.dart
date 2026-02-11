import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '../../services/hass_websocket_service.dart';
import '../../models/dashboard.dart';

class EntityTile extends StatelessWidget {
  final String entityId;
  final EntityConfig? config;

  const EntityTile({super.key, required this.entityId, this.config});

  @override
  Widget build(BuildContext context) {
    return Selector<HassWebSocketService, Map<String, dynamic>?>(
      selector: (_, ws) => ws.entitiesMap[entityId],
      builder: (context, entity, _) {
        if (entity == null) return const SizedBox.shrink();

        final state = entity['state'] ?? 'unknown';
        final attributes = entity['attributes'] ?? {};
        final friendlyName =
            config?.nameOverride ?? attributes['friendly_name'] ?? entityId;

        IconData icon = _getIconForEntity(entityId, attributes);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: ListTile(
            leading: Icon(icon),
            title: Text(friendlyName),
            subtitle: Text(state),
            onTap: () => _handleTap(context, entityId, state),
          ),
        );
      },
    );
  }

  IconData _getIconForEntity(String entityId, Map<String, dynamic> attributes) {
    if (entityId.startsWith('switch.')) return Icons.toggle_on;
    if (entityId.startsWith('binary_sensor.')) {
      return Icons.radio_button_checked;
    }
    if (entityId.startsWith('input_boolean.')) return Icons.check_box;
    if (entityId.startsWith('automation.')) return Icons.play_circle_outline;
    if (entityId.startsWith('script.')) return Icons.description;
    if (entityId.startsWith('scene.')) return Icons.palette;
    if (entityId.startsWith('group.')) return Icons.group_work;
    if (entityId.startsWith('person.')) return Icons.person;
    if (entityId.startsWith('sun.')) return Icons.wb_sunny;

    return Icons.device_unknown;
  }

  void _handleTap(BuildContext context, String entityId, String state) {
    final domain = entityId.split('.').first;
    final ws = context.read<HassWebSocketService>();

    if (domain == 'switch' || domain == 'input_boolean' || domain == 'light') {
      final service = state == 'on' ? 'turn_off' : 'turn_on';
      ws.callService(domain, service, serviceData: {'entity_id': entityId});
    } else if (domain == 'automation' ||
        domain == 'script' ||
        domain == 'scene') {
      ws.callService(domain, 'turn_on', serviceData: {'entity_id': entityId});
    }
  }
}

@widgetbook.UseCase(name: 'Switch', type: EntityTile)
Widget buildEntityTileSwitchUseCase(BuildContext context) {
  return const EntityTile(entityId: 'switch.coffee_maker');
}

@widgetbook.UseCase(name: 'Binary Sensor', type: EntityTile)
Widget buildEntityTileBinarySensorUseCase(BuildContext context) {
  return const EntityTile(entityId: 'binary_sensor.front_door');
}

@widgetbook.UseCase(name: 'Default', type: EntityTile)
Widget buildEntityTileDefaultUseCase(BuildContext context) {
  return const EntityTile(entityId: 'unknown.entity');
}
