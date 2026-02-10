import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/hass_websocket_service.dart';
import '../models/custom_widget.dart';
import '../l10n/app_localizations.dart';
import '../screens/custom_widget_config_dialog.dart';
import '../widgets/entities/light_widget.dart';
import '../widgets/entities/climate_widget.dart';
import '../widgets/entities/sensor_widget.dart';
import '../widgets/entities/camera_widget.dart';
import '../widgets/entities/media_player_widget.dart';
import '../widgets/entities/weather_widget.dart';

class AddWidgetScreen extends StatefulWidget {
  final String dashboardId;
  final int columnIndex;
  final int? insertAtIndex; // null means append to end

  const AddWidgetScreen({
    super.key,
    required this.dashboardId,
    required this.columnIndex,
    this.insertAtIndex,
  });

  @override
  State<AddWidgetScreen> createState() => _AddWidgetScreenState();
}

class _AddWidgetScreenState extends State<AddWidgetScreen> {
  String _searchQuery = '';
  final List<String> _filterDomains = [];
  final List<String> _filterAreas = [];
  List<dynamic> _allEntities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final ws = context.read<HassWebSocketService>();
    if (mounted) {
      setState(() {
        _allEntities = ws.entities;
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredEntities {
    final ws = context.read<HassWebSocketService>();
    return _allEntities.where((entity) {
      final entityId = entity['entity_id'] as String;
      final friendlyName = (entity['attributes']['friendly_name'] ?? '')
          .toString()
          .toLowerCase();
      final domain = entityId.split('.').first;
      final registryEntry = ws.entityRegistry[entityId];
      String? areaId = registryEntry?['area_id'];

      // Try device registry if no area in entity registry
      if (areaId == null) {
        final deviceId = registryEntry?['device_id'];
        if (deviceId != null) {
          final device = ws.deviceRegistry[deviceId];
          areaId = device?['area_id'];
        }
      }

      // Filter by domain
      if (_filterDomains.isNotEmpty && !_filterDomains.contains(domain)) {
        return false;
      }

      // Filter by area
      if (_filterAreas.isNotEmpty && !_filterAreas.contains(areaId)) {
        return false;
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty &&
          !entityId.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !friendlyName.contains(_searchQuery.toLowerCase())) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Widget'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchEntities,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Custom widgets section
                Card(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Custom Widgets',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.text_fields),
                        title: const Text('Text Widget'),
                        subtitle: const Text('Add custom text with formatting'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _addCustomWidget(CustomWidgetType.text),
                      ),
                      ListTile(
                        leading: const Icon(Icons.image),
                        title: const Text('Image Widget'),
                        subtitle: const Text('Add an image from your device'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _addCustomWidget(CustomWidgetType.image),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Home Assistant Entities',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                // Entities list
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredEntities.length,
                    itemBuilder: (context, index) {
                      final entity = _filteredEntities[index];
                      final entityId = entity['entity_id'] as String;
                      final friendlyName =
                          entity['attributes']['friendly_name'] ?? entityId;
                      final domain = entityId.split('.').first;

                      IconData icon;
                      switch (domain) {
                        case 'light':
                          icon = Icons.lightbulb;
                          break;
                        case 'switch':
                          icon = Icons.power_settings_new;
                          break;
                        case 'climate':
                          icon = Icons.thermostat;
                          break;
                        case 'sensor':
                          icon = Icons.sensors;
                          break;
                        case 'camera':
                          icon = Icons.camera_alt;
                          break;
                        case 'media_player':
                          icon = Icons.speaker;
                          break;
                        case 'weather':
                          icon = Icons.wb_sunny;
                          break;
                        default:
                          icon = Icons.device_unknown;
                      }

                      return ListTile(
                        leading: Icon(icon),
                        title: Text(friendlyName),
                        subtitle: Text(entityId),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showEntityPreview(entityId, entity),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _addCustomWidget(CustomWidgetType type) async {
    final customWidget = await showDialog<CustomWidget>(
      context: context,
      builder: (context) => CustomWidgetConfigDialog(initialType: type),
    );

    if (customWidget != null && mounted) {
      Navigator.pop(context, {'type': 'custom', 'widget': customWidget});
    }
  }

  void _showEntityPreview(String entityId, Map<String, dynamic> entity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WidgetPreviewScreen(
          entityId: entityId,
          entity: entity,
          dashboardId: widget.dashboardId,
          columnIndex: widget.columnIndex,
          insertAtIndex: widget.insertAtIndex,
        ),
      ),
    );
  }
}

class WidgetPreviewScreen extends StatelessWidget {
  final String entityId;
  final Map<String, dynamic> entity;
  final String dashboardId;
  final int columnIndex;
  final int? insertAtIndex;

  const WidgetPreviewScreen({
    super.key,
    required this.entityId,
    required this.entity,
    required this.dashboardId,
    required this.columnIndex,
    this.insertAtIndex,
  });

  @override
  Widget build(BuildContext context) {
    final friendlyName = entity['attributes']['friendly_name'] ?? entityId;

    return Scaffold(
      appBar: AppBar(title: Text(friendlyName)),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _buildPreviewWidget(context),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () {
                        // Pop twice: preview screen and add widget screen
                        Navigator.pop(context);
                        Navigator.pop(context, {
                          'type': 'entity',
                          'entityId': entityId,
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Widget'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewWidget(BuildContext context) {
    // Determine which widget to show based on entity ID
    if (entityId.startsWith('light.')) {
      return LightWidget(entityId: entityId);
    } else if (entityId.startsWith('climate.')) {
      return ClimateWidget(entityId: entityId);
    } else if (entityId.startsWith('sensor.')) {
      return SensorWidget(entityId: entityId);
    } else if (entityId.startsWith('camera.')) {
      return CameraWidget(entityId: entityId);
    } else if (entityId.startsWith('media_player.')) {
      return MediaWidget(entityId: entityId);
    } else if (entityId.startsWith('weather.')) {
      return WeatherWidget(entityId: entityId);
    }

    // Fallback for other entities
    return Card(
      child: ListTile(
        leading: Icon(_getIconForEntity(entityId)),
        title: Text(entity['attributes']['friendly_name'] ?? entityId),
        subtitle: Text(entity['state'] ?? 'unknown'),
      ),
    );
  }

  IconData _getIconForEntity(String entityId) {
    if (entityId.startsWith('switch.')) {
      return Icons.toggle_on;
    }
    if (entityId.startsWith('binary_sensor.')) {
      return Icons.check_circle_outline;
    }
    if (entityId.startsWith('cover.')) {
      return Icons.curtains;
    }
    if (entityId.startsWith('person.')) {
      return Icons.person;
    }
    if (entityId.startsWith('device_tracker.')) {
      return Icons.location_on;
    }
    return Icons.device_unknown;
  }
}
