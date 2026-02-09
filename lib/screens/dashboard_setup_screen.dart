import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dashboard_service.dart';
import '../services/hass_websocket_service.dart';
import '../l10n/app_localizations.dart';

class DashboardSetupScreen extends StatefulWidget {
  const DashboardSetupScreen({super.key});

  @override
  State<DashboardSetupScreen> createState() => _DashboardSetupScreenState();
}

class _DashboardSetupScreenState extends State<DashboardSetupScreen> {
  final Set<String> _selectedAreas = {};
  List<dynamic> _areas = [];
  Map<String, List<String>> _areaEntities = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load areas after the first frame when context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAreas();
    });
  }

  Future<void> _loadAreas() async {
    final ws = context.read<HassWebSocketService>();

    setState(() => _isLoading = true);

    try {
      // Wait for WebSocket to be ready
      int attempts = 0;
      while (!ws.isReady && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }

      if (!ws.isReady) {
        debugPrint('WebSocket not ready after waiting');
        if (mounted) {
          setState(() {
            _areas = [];
            _areaEntities = {};
            _isLoading = false;
          });
        }
        return;
      }

      final areas = ws.areas;
      final entities = ws.entities;
      final entityRegistry = ws.entityRegistry;
      final deviceRegistry = ws.deviceRegistry;

      debugPrint('Loaded ${areas.length} areas, ${entities.length} entities');
      debugPrint('Entity registry size: ${entityRegistry.length}');
      debugPrint('Device registry size: ${deviceRegistry.length}');

      // Build a map of area -> entities
      final Map<String, List<String>> areaEntitiesMap = {};

      for (var area in areas) {
        final areaId = area['area_id'];
        areaEntitiesMap[areaId] = [];
        debugPrint('Area: ${area['name']} (ID: $areaId)');
      }

      int entitiesWithArea = 0;
      int entitiesWithoutArea = 0;

      // Add entities to their respective areas
      for (var entity in entities) {
        final entityId = entity['entity_id'] as String;
        final domain = entityId.split('.').first;

        // Only include useful domains
        if (![
          'light',
          'switch',
          'climate',
          'sensor',
          'binary_sensor',
          'media_player',
          'camera',
          'weather',
          'cover',
          'fan',
        ].contains(domain)) {
          continue;
        }

        // Try to get area from entity registry
        final registryEntry = entityRegistry[entityId];
        String? areaId = registryEntry?['area_id'];

        // If no area in entity registry, try device registry
        if (areaId == null) {
          final deviceId = registryEntry?['device_id'];
          if (deviceId != null) {
            final device = deviceRegistry[deviceId];
            areaId = device?['area_id'];
          }
        }

        if (areaId != null && areaEntitiesMap.containsKey(areaId)) {
          areaEntitiesMap[areaId]!.add(entityId);
          entitiesWithArea++;
        } else {
          entitiesWithoutArea++;
        }
      }

      debugPrint(
        'Entities with area: $entitiesWithArea, without area: $entitiesWithoutArea',
      );

      // Remove areas with no entities
      areaEntitiesMap.removeWhere((key, value) => value.isEmpty);

      debugPrint('Found ${areaEntitiesMap.length} areas with entities');
      for (var entry in areaEntitiesMap.entries) {
        debugPrint('  ${entry.key}: ${entry.value.length} entities');
      }

      if (mounted) {
        setState(() {
          _areas = areas
              .where((a) => areaEntitiesMap.containsKey(a['area_id']))
              .toList();
          _areaEntities = areaEntitiesMap;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('Error loading areas: $e\n$stack');
      if (mounted) {
        setState(() {
          _areas = [];
          _areaEntities = {};
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createDashboards() async {
    final dashService = context.read<DashboardService>();
    final l10n = AppLocalizations.of(context)!;

    if (_selectedAreas.isEmpty) {
      // Create a generic empty dashboard
      await dashService.addDashboard(
        l10n.dashboard,
        entityIds: [],
        columnCount: 2,
      );
    } else {
      // Create dashboards for selected areas
      for (var areaId in _selectedAreas) {
        final area = _areas.firstWhere((a) => a['area_id'] == areaId);
        final areaName = area['name'] ?? areaId;
        final entities = _areaEntities[areaId] ?? [];

        await dashService.addDashboard(
          areaName,
          entityIds: entities,
          columnCount: 2,
        );
      }
    }

    // Don't pop - the parent widget will rebuild automatically
    // when dashboards are added via notifyListeners()
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.setupDashboards),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadAreas,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _areas.isEmpty
          ? _buildNoAreasView(l10n)
          : _buildAreasView(l10n, theme),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _createDashboards,
              icon: const Icon(Icons.check),
              label: Text(
                _selectedAreas.isEmpty
                    ? l10n.createEmptyDashboard
                    : l10n.createDashboards,
              ),
            ),
    );
  }

  Widget _buildNoAreasView(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              l10n.noAreasFoundSetup,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noAreasFoundSetupSub,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _createDashboards,
              icon: const Icon(Icons.add),
              label: Text(l10n.createEmptyDashboard),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreasView(AppLocalizations l10n, ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.welcomeToHasi,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.selectAreasToCreateDashboards,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedAreas.isNotEmpty)
                Chip(
                  label: Text('${_selectedAreas.length} ${l10n.areasSelected}'),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _areas.length,
            itemBuilder: (context, index) {
              final area = _areas[index];
              final areaId = area['area_id'];
              final areaName = area['name'] ?? areaId;
              final entityCount = _areaEntities[areaId]?.length ?? 0;
              final isSelected = _selectedAreas.contains(areaId);

              return CheckboxListTile(
                value: isSelected,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedAreas.add(areaId);
                    } else {
                      _selectedAreas.remove(areaId);
                    }
                  });
                },
                title: Text(areaName),
                subtitle: Text(
                  '$entityCount ${entityCount == 1 ? l10n.entity : l10n.entities}',
                ),
                secondary: CircleAvatar(child: Text(areaName[0].toUpperCase())),
              );
            },
          ),
        ),
      ],
    );
  }
}
