import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/hass_websocket_service.dart';
import '../services/dashboard_service.dart';
import '../models/dashboard.dart';
import '../widgets/entities/light_widget.dart';
import '../widgets/entities/climate_widget.dart';
import '../widgets/entities/sensor_widget.dart';
import '../widgets/entities/camera_widget.dart';
import '../widgets/entities/media_player_widget.dart';
import '../widgets/entities/weather_widget.dart';
import '../widgets/entities/entity_tile.dart';
import '../widgets/voice_assistant_widget.dart';
import '../widgets/custom_widgets.dart';
import '../l10n/app_localizations.dart';
import '../models/custom_widget.dart';
import 'package:uuid/uuid.dart';

import 'theme_settings_screen.dart';
import 'dashboard_setup_screen.dart';
import 'add_widget_screen.dart';
import '../widgets/tts_test_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectIfNeeded();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HassWebSocketService>().reconnectIfNeeded();
    }
  }

  Future<void> _connectIfNeeded() async {
    final auth = context.read<AuthService>();
    final ws = context.read<HassWebSocketService>();

    if (!ws.isConnected && auth.baseUrl != null && auth.token != null) {
      await ws.connect(auth.baseUrl!, auth.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final dashService = context.watch<DashboardService>();
    final activeDash = dashService.activeDashboard;
    final l10n = AppLocalizations.of(context)!;

    // Use read for ws to avoid rebuilds on every state change.
    // Use select for specific properties that should trigger a rebuild.
    final wsRead = context.read<HassWebSocketService>();
    final isAuthenticated = context.select<HassWebSocketService, bool>(
      (ws) => ws.isAuthenticated,
    );
    final isReady = context.select<HassWebSocketService, bool>(
      (ws) => ws.isReady,
    );

    final connectionError = context.select<HassWebSocketService, String?>(
      (ws) => ws.connectionError,
    );

    // If auth is invalid, we should log out and go to login screen
    if (connectionError == 'auth_invalid') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        wsRead.disconnect();
        auth.logout();
      });
    }

    // Show setup screen if no dashboards exist (but only when WebSocket is ready)
    if (dashService.dashboards.isEmpty && connectionError == null) {
      if (!isReady) {
        // Show loading while waiting for connection
        return Scaffold(
          appBar: AppBar(title: Text(l10n.dashboard)),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.connectingToHA),
              ],
            ),
          ),
        );
      }
      return const DashboardSetupScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activeDash?.name ?? l10n.dashboard),
        actions: [
          if (_isEditMode && activeDash != null) ...[
            IconButton(
              icon: const Icon(Icons.view_column),
              onPressed: null,
              disabledColor: Colors.white70,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: activeDash.columnCount > 1
                  ? () {
                      final newCount = activeDash.columnCount - 1;
                      final updatedColumns = _normalizeColumns(
                        activeDash.columns,
                        newCount,
                        activeDash.entityIds,
                      );
                      final updated = activeDash.copyWith(
                        columnCount: newCount,
                        columns: updatedColumns,
                      );
                      dashService.updateDashboard(updated);
                    }
                  : null,
              tooltip: 'Remove Column',
            ),
            Text(
              '${activeDash.columnCount}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: activeDash.columnCount < 6
                  ? () {
                      final newCount = activeDash.columnCount + 1;
                      final updatedColumns = _normalizeColumns(
                        activeDash.columns,
                        newCount,
                        activeDash.entityIds,
                      );
                      final updated = activeDash.copyWith(
                        columnCount: newCount,
                        columns: updatedColumns,
                      );
                      dashService.updateDashboard(updated);
                    }
                  : null,
              tooltip: 'Add Column',
            ),
            const VerticalDivider(width: 1, indent: 12, endIndent: 12),
          ],
          IconButton(
            icon: Icon(_isEditMode ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
            tooltip: _isEditMode ? l10n.save : l10n.editMode,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isAuthenticated ? () => wsRead.getStates() : null,
          ),
        ],
      ),
      drawer: _buildDrawer(context, dashService, auth, wsRead, l10n),
      body: isReady
          ? _buildBody(wsRead, activeDash, dashService, l10n)
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (connectionError != null) ...[
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        connectionError,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              wsRead.disconnect();
                              auth.logout();
                            },
                            icon: const Icon(Icons.logout),
                            label: Text(l10n.logout),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (auth.baseUrl != null && auth.token != null) {
                                wsRead.connect(auth.baseUrl!, auth.token!);
                              }
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ] else ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(l10n.connectingToHA),
                    ],
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: const VoiceAssistantWidget(),
            ),
          );
        },
        child: const Icon(Icons.mic),
      ),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    DashboardService dashService,
    AuthService auth,
    HassWebSocketService ws,
    AppLocalizations l10n,
  ) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Center(
              child: Text(
                'Hasi Dashboards',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text(
                    l10n.myDashboards,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...dashService.dashboards.map(
                  (d) => ListTile(
                    leading: Icon(
                      Icons.dashboard,
                      color: d.id == dashService.activeDashboardId
                          ? Colors.blue
                          : null,
                    ),
                    title: Text(d.name),
                    onTap: () {
                      dashService.setActiveDashboard(d.id);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: Text(l10n.addDashboard),
                  onTap: () =>
                      _showAddDashboardDialog(context, dashService, ws, l10n),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(l10n.appearance),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeSettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.record_voice_over),
            title: const Text('TTS Test'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TtsTestWidget()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.logout),
            onTap: () {
              ws.disconnect();
              auth.logout();
            },
          ),
        ],
      ),
    );
  }

  void _showAddDashboardDialog(
    BuildContext context,
    DashboardService dashService,
    HassWebSocketService ws,
    AppLocalizations l10n,
  ) {
    // Refresh data to catch any newly added devices
    ws.refreshData();

    final nameController = TextEditingController();
    String? selectedAreaId;
    int columnCount = 2;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.newDashboard),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.dashboardName),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedAreaId,
                decoration: const InputDecoration(
                  labelText: 'Optional: Pre-fill from Area',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Manual / Empty'),
                  ),
                  ...ws.areas.map((area) {
                    return DropdownMenuItem(
                      value: area['area_id'],
                      child: Text(area['name'] ?? area['area_id']),
                    );
                  }),
                ],
                onChanged: (val) {
                  setDialogState(() => selectedAreaId = val);
                  if (val != null && nameController.text.isEmpty) {
                    final area = ws.areas.firstWhere(
                      (a) => a['area_id'] == val,
                    );
                    nameController.text = area['name'] ?? 'Area Dashboard';
                  }
                },
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Number of Columns',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              Slider(
                value: columnCount.toDouble(),
                min: 1,
                max: 4,
                divisions: 3,
                label: columnCount.toString(),
                onChanged: (val) {
                  setDialogState(() => columnCount = val.toInt());
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  List<String> entityIds = [];
                  if (selectedAreaId != null) {
                    // Find entities in this area
                    entityIds = ws.entities
                        .where((e) {
                          final id = e['entity_id'] as String;
                          final domain = id.split('.').first;
                          final registryEntry = ws.entityRegistry[id];

                          // 1. Direct Area Check
                          var areaId = registryEntry?['area_id'];

                          // 2. Device Area Inheritance Check
                          if (areaId == null &&
                              registryEntry?['device_id'] != null) {
                            final device =
                                ws.deviceRegistry[registryEntry?['device_id']];
                            areaId = device?['area_id'];
                          }

                          // 3. Group Membership Check
                          // If it's a group, check if any of its members are in this area
                          bool isRelevantGroup = false;
                          if (domain == 'group') {
                            final members = e['attributes']?['entity_id'];
                            if (members is List) {
                              for (var memberId in members) {
                                if (memberId is String) {
                                  final memberReg = ws.entityRegistry[memberId];
                                  var memberAreaId = memberReg?['area_id'];

                                  if (memberAreaId == null &&
                                      memberReg?['device_id'] != null) {
                                    final memberDevice = ws
                                        .deviceRegistry[memberReg?['device_id']];
                                    memberAreaId = memberDevice?['area_id'];
                                  }

                                  if (memberAreaId == selectedAreaId) {
                                    final memberDomain = memberId
                                        .split('.')
                                        .first;
                                    if ([
                                      'light',
                                      'climate',
                                      'weather',
                                    ].contains(memberDomain)) {
                                      isRelevantGroup = true;
                                      break;
                                    }
                                  }
                                }
                              }
                            }
                          }

                          if (areaId != selectedAreaId && !isRelevantGroup) {
                            return false;
                          }

                          // Only include domains we can actually render
                          return [
                            'light',
                            'climate',
                            'sensor',
                            'camera',
                            'media_player',
                            'weather',
                            'switch',
                            'binary_sensor',
                            'group',
                          ].contains(domain);
                        })
                        .map((e) => e['entity_id'] as String)
                        .toList();

                    debugPrint(
                      'Found ${entityIds.length} entities/groups for area $selectedAreaId',
                    );
                  }

                  dashService.addDashboard(
                    nameController.text,
                    entityIds: entityIds,
                    columnCount: columnCount,
                  );
                  Navigator.pop(context);
                  Navigator.pop(context); // Close drawer
                }
              },
              child: Text(l10n.create),
            ),
          ],
        ),
      ),
    );
  }

  List<List<String>> _normalizeColumns(
    List<List<String>> currentColumns,
    int targetCount, [
    List<String>? fallbackIds,
  ]) {
    final newColumns = List.generate(targetCount, (_) => <String>[]);

    if (currentColumns.isNotEmpty) {
      if (targetCount >= currentColumns.length) {
        // More columns or same: copy existing
        for (int i = 0; i < currentColumns.length; i++) {
          newColumns[i].addAll(currentColumns[i]);
        }
      } else {
        // Fewer columns: append removed ones to the last remaining column
        for (int i = 0; i < targetCount - 1; i++) {
          newColumns[i].addAll(currentColumns[i]);
        }
        for (int i = targetCount - 1; i < currentColumns.length; i++) {
          newColumns[targetCount - 1].addAll(currentColumns[i]);
        }
      }
    } else if (fallbackIds != null) {
      // Initialize from flat list
      for (int i = 0; i < fallbackIds.length; i++) {
        newColumns[i % targetCount].add(fallbackIds[i]);
      }
    }
    return newColumns;
  }

  List<List<String>> _getNormalizedColumns(
    Dashboard dash,
    List<String> entityIdsToShow,
  ) {
    // 1. Get stable normalized columns from model
    List<List<String>> columns = _normalizeColumns(
      dash.columns,
      dash.columnCount,
      dash.orderedEntityIds.isNotEmpty ? dash.orderedEntityIds : dash.entityIds,
    );

    // 2. Sync with actual entities we want to show (filter out non-existent)
    for (var col in columns) {
      col.removeWhere((id) => !entityIdsToShow.contains(id));
    }

    // 3. Ensure all visible entities are in some column
    final allInColumns = columns.expand((c) => c).toSet();
    final missing = entityIdsToShow
        .where((id) => !allInColumns.contains(id))
        .toList();

    for (int i = 0; i < missing.length; i++) {
      columns[i % columns.length].add(missing[i]);
    }

    return columns;
  }

  void _moveEntity(
    Dashboard activeDash,
    DashboardService dashService,
    String entityId,
    int targetColIndex,
    String? targetBeforeId,
    List<List<String>> unused, // Renamed from _ignored
  ) {
    debugPrint('D&D: Moving $entityId to col $targetColIndex');
    try {
      // 1. Get current columns from model and normalize count
      List<List<String>> newColumns = _normalizeColumns(
        activeDash.columns,
        activeDash.columnCount,
        activeDash.entityIds,
      );

      // Ensure index is within bounds
      if (targetColIndex >= newColumns.length) {
        targetColIndex = newColumns.length - 1;
      }
      if (targetColIndex < 0) targetColIndex = 0;

      // 2. Remove from wherever it was
      for (var col in newColumns) {
        col.remove(entityId);
      }

      // 3. Insert into target column
      if (targetBeforeId == null) {
        newColumns[targetColIndex].add(entityId);
      } else {
        final index = newColumns[targetColIndex].indexOf(targetBeforeId);
        if (index == -1) {
          newColumns[targetColIndex].add(entityId);
        } else {
          newColumns[targetColIndex].insert(index, entityId);
        }
      }

      // 4. Update orderedEntityIds as well for backward compatibility
      final allEntities = newColumns.expand((c) => c).toList();

      final updated = activeDash.copyWith(
        columns: newColumns,
        orderedEntityIds: allEntities,
      );
      dashService.updateDashboard(updated);
    } catch (e, stack) {
      debugPrint('Error moving entity: $e\n$stack');
    }
  }

  Widget _buildBody(
    HassWebSocketService ws,
    Dashboard? activeDash,
    DashboardService dashService,
    AppLocalizations l10n,
  ) {
    final allEntities = context
        .select<HassWebSocketService, Map<String, dynamic>>(
          (ws) => ws.entitiesMap,
        );

    if (allEntities.isEmpty) {
      return Center(child: Text(l10n.noEntitiesFound));
    }

    List<String> entityIdsToShow;
    if (activeDash != null) {
      entityIdsToShow = activeDash.entityIds.where((widgetId) {
        // If it's a custom widget, it belongs to the dashboard directly
        if (activeDash.customWidgets.containsKey(widgetId)) return true;

        // If it's an entity widget, check if the base entity still exists
        final entityId = widgetId.contains('[')
            ? widgetId.substring(0, widgetId.indexOf('['))
            : widgetId;
        return allEntities.containsKey(entityId);
      }).toList();
    } else {
      entityIdsToShow = allEntities.keys.toList();
    }

    if (entityIdsToShow.isEmpty) {
      return Center(child: Text(l10n.noEntitiesMatch));
    }

    if (activeDash == null) {
      return _buildSimpleWrap(entityIdsToShow, ws, l10n);
    }

    // Use helper to get current column state
    final columns = _getNormalizedColumns(activeDash, entityIdsToShow);

    return SingleChildScrollView(
      key: PageStorageKey('dash_${activeDash.id}'),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(activeDash.columnCount, (colIndex) {
            return Expanded(
              child: _buildColumn(
                colIndex,
                columns[colIndex],
                columns, // Pass current columns for the move logic
                activeDash,
                dashService,
                ws,
                l10n,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSimpleWrap(
    List<String> entityIds,
    HassWebSocketService ws,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 16.0,
          children: entityIds.map((entityId) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 24) / 2,
              child: _buildEntityWrapper(entityId, null),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildColumn(
    int colIndex,
    List<String> entityIds,
    List<List<String>> currentColumns,
    Dashboard activeDash,
    DashboardService dashService,
    HassWebSocketService ws,
    AppLocalizations l10n,
  ) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        final draggedId = details.data;
        _moveEntity(
          activeDash,
          dashService,
          draggedId,
          colIndex,
          null,
          currentColumns,
        );
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? Colors.blue.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Add button at the top in edit mode
              if (_isEditMode && entityIds.isEmpty)
                _buildAddWidgetButton(colIndex, 0, activeDash, dashService),

              // Build widgets with add buttons between them in edit mode
              for (int i = 0; i < entityIds.length; i++) ...[
                if (_isEditMode && i == 0)
                  _buildAddWidgetButton(colIndex, 0, activeDash, dashService),
                _buildDraggableEntity(
                  entityIds[i],
                  colIndex,
                  currentColumns,
                  activeDash,
                  dashService,
                  ws,
                  l10n,
                ),
                // Regular spacing between widgets
                if (!_isEditMode && i < entityIds.length - 1)
                  const SizedBox(height: 16),

                if (_isEditMode)
                  _buildAddWidgetButton(
                    colIndex,
                    i + 1,
                    activeDash,
                    dashService,
                  ),
              ],

              // Empty space at bottom to allow dropping at end
              DragTarget<String>(
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) {
                  _moveEntity(
                    activeDash,
                    dashService,
                    details.data,
                    colIndex,
                    null,
                    currentColumns,
                  );
                },
                builder: (context, candidateData, rejectedData) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: candidateData.isNotEmpty
                        ? 100
                        : (_isEditMode ? 80 : 50),
                    width: double.infinity,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: candidateData.isNotEmpty
                          ? Colors.blue.withValues(alpha: 0.1)
                          : (_isEditMode
                                ? Colors.grey.withValues(alpha: 0.05)
                                : Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                      border: candidateData.isNotEmpty
                          ? Border.all(
                              color: Colors.blue.withValues(alpha: 0.5),
                            )
                          : (_isEditMode
                                ? Border.all(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    style: BorderStyle.solid,
                                  )
                                : null),
                    ),
                    child: candidateData.isNotEmpty
                        ? const Center(
                            child: Icon(Icons.add, color: Colors.blue),
                          )
                        : (_isEditMode
                              ? const Center(
                                  child: Icon(
                                    Icons.move_to_inbox,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                )
                              : null),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableEntity(
    String entityId,
    int colIndex,
    List<List<String>> currentColumns,
    Dashboard activeDash,
    DashboardService dashService,
    HassWebSocketService ws,
    AppLocalizations l10n,
  ) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data != entityId,
      onAcceptWithDetails: (details) {
        _moveEntity(
          activeDash,
          dashService,
          details.data,
          colIndex,
          entityId,
          currentColumns,
        );
      },
      builder: (context, candidateData, rejectedData) {
        return Column(
          children: [
            if (candidateData.isNotEmpty)
              Container(
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            // Only make draggable in edit mode
            if (_isEditMode)
              LongPressDraggable<String>(
                key: ValueKey(entityId),
                data: entityId,
                axis: null,
                delay: const Duration(milliseconds: 500),
                feedback: Material(
                  elevation: 10,
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.transparent,
                  child: Opacity(
                    opacity: 0.9,
                    child: SizedBox(
                      width:
                          MediaQuery.of(context).size.width /
                          (activeDash.columnCount + 0.5),
                      child: _buildEntityPreview(entityId, activeDash, ws),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _buildEntityWrapper(entityId, activeDash),
                ),
                child: _buildEntityWithSettings(
                  entityId,
                  activeDash,
                  dashService,
                  ws,
                  l10n,
                ),
              )
            else
              _buildEntityWrapper(entityId, activeDash),
          ],
        );
      },
    );
  }

  Widget _buildEntityWithSettings(
    String entityId,
    Dashboard activeDash,
    DashboardService dashService,
    HassWebSocketService ws,
    AppLocalizations l10n,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final baseEntityId = entityId.contains('[')
              ? entityId.substring(0, entityId.indexOf('['))
              : entityId;
          final entity = ws.entitiesMap[baseEntityId];
          if (entity != null) {
            _showEntityConfigDialog(
              entity,
              entityId,
              activeDash,
              dashService,
              l10n,
            );
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Disable all widget interactions in edit mode
            IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: 0.8,
                child: _buildEntityWrapper(entityId, activeDash),
              ),
            ),
            // Subtle edit mode overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.4),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntityPreview(
    String widgetId,
    Dashboard activeDash,
    HassWebSocketService ws,
  ) {
    // A lightweight version of the widget for dragging feedback
    final entityId = widgetId.contains('[')
        ? widgetId.substring(0, widgetId.indexOf('['))
        : widgetId;
    final entity = ws.entitiesMap[entityId];
    if (entity == null) return const SizedBox.shrink();

    final attributes = entity['attributes'] ?? {};
    final friendlyName =
        activeDash.entityConfigs[widgetId]?.nameOverride ??
        attributes['friendly_name'] ??
        entityId;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        title: Text(
          friendlyName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildEntityWrapper(String widgetId, Dashboard? activeDash) {
    // Check if this is a custom widget first
    if (activeDash != null && activeDash.customWidgets.containsKey(widgetId)) {
      final customWidget = activeDash.customWidgets[widgetId]!;
      switch (customWidget.type) {
        case CustomWidgetType.image:
          return CustomImageWidget(widget: customWidget);
        case CustomWidgetType.text:
          return CustomTextWidget(widget: customWidget);
      }
    }

    // Otherwise, treat as HA entity (possibly with instance ID)
    final entityId = widgetId.contains('[')
        ? widgetId.substring(0, widgetId.indexOf('['))
        : widgetId;

    final config = activeDash?.entityConfigs[widgetId];

    if (entityId.startsWith('light.')) {
      return LightWidget(entityId: entityId, config: config);
    } else if (entityId.startsWith('climate.')) {
      return ClimateWidget(entityId: entityId, config: config);
    } else if (entityId.startsWith('sensor.')) {
      return SensorWidget(entityId: entityId, config: config);
    } else if (entityId.startsWith('camera.')) {
      return CameraWidget(entityId: entityId, config: config);
    } else if (entityId.startsWith('media_player.')) {
      return MediaWidget(entityId: entityId, config: config);
    } else if (entityId.startsWith('weather.')) {
      return WeatherWidget(entityId: entityId, config: config);
    }

    return EntityTile(entityId: entityId, config: config);
  }

  void _showEntityConfigDialog(
    Map<String, dynamic> entity,
    String widgetId,
    Dashboard activeDash,
    DashboardService dashService,
    AppLocalizations l10n,
  ) {
    final entityId = entity['entity_id'] as String;
    final config = activeDash.entityConfigs[widgetId] ?? EntityConfig();
    final nameController = TextEditingController(
      text:
          config.nameOverride ??
          (entity['attributes']['friendly_name'] ?? entityId),
    );
    bool showForecast = config.options['show_forecast'] ?? true;
    String forecastType = config.options['forecast_type'] ?? 'daily';
    final forecastCountController = TextEditingController(
      text: (config.options['forecast_count'] ?? 5).toString(),
    );
    final isSensor = entityId.startsWith('sensor.');
    bool showHistory =
        config.options['show_history'] ??
        (entityId.contains('temperature') || entityId.contains('humidity'));
    final historyHoursController = TextEditingController(
      text: (config.options['history_hours'] ?? 24).toString(),
    );
    final isLight = entityId.startsWith('light.');
    bool showBrightness = config.options['show_brightness'] ?? true;
    bool showColor = config.options['show_color'] ?? true;
    final isClimate = entityId.startsWith('climate.');
    bool showHvacMode = config.options['show_hvac_mode'] ?? true;
    bool showPresetMode = config.options['show_preset_mode'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            widgetId.contains('[')
                ? '$entityId (Instance: ${widgetId.substring(widgetId.indexOf('[') + 1, widgetId.indexOf(']'))})'
                : entityId,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name Override',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (entityId.startsWith('weather.')) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Show Forecast'),
                    value: showForecast,
                    onChanged: (val) {
                      setDialogState(() => showForecast = val);
                    },
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: forecastType,
                    decoration: const InputDecoration(
                      labelText: 'Forecast Type',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'hourly', child: Text('Hourly')),
                      DropdownMenuItem(
                        value: 'twice_daily',
                        child: Text('Twice Daily'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => forecastType = val);
                      }
                    },
                  ),
                  TextField(
                    controller: forecastCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Forecast Count',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                if (isLight) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Show Brightness Control'),
                    value: showBrightness,
                    onChanged: (val) {
                      setDialogState(() => showBrightness = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Show Color Control'),
                    value: showColor,
                    onChanged: (val) {
                      setDialogState(() => showColor = val);
                    },
                  ),
                ],
                if (isClimate) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Show HVAC Mode'),
                    value: showHvacMode,
                    onChanged: (val) {
                      setDialogState(() => showHvacMode = val);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Show Preset Mode'),
                    value: showPresetMode,
                    onChanged: (val) {
                      setDialogState(() => showPresetMode = val);
                    },
                  ),
                ],
                if (isSensor) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Show History'),
                    value: showHistory,
                    onChanged: (val) {
                      setDialogState(() => showHistory = val);
                    },
                  ),
                  TextField(
                    controller: historyHoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'History Duration (Hours)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close config dialog
                _confirmDeleteWidget(widgetId, activeDash, dashService, l10n);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.delete),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final newConfig = EntityConfig(
                  nameOverride: nameController.text.isNotEmpty
                      ? nameController.text
                      : null,
                  options: {
                    ...config.options,
                    if (entityId.startsWith('weather.')) ...{
                      'show_forecast': showForecast,
                      'forecast_type': forecastType,
                      'forecast_count':
                          int.tryParse(forecastCountController.text) ?? 5,
                    },
                    if (isLight) ...{
                      'show_brightness': showBrightness,
                      'show_color': showColor,
                    },
                    if (isClimate) ...{
                      'show_hvac_mode': showHvacMode,
                      'show_preset_mode': showPresetMode,
                    },
                    if (isSensor) 'show_history': showHistory,
                    if (isSensor)
                      'history_hours':
                          int.tryParse(historyHoursController.text) ?? 24,
                  },
                );

                final newConfigs = Map<String, EntityConfig>.from(
                  activeDash.entityConfigs,
                );
                newConfigs[widgetId] = newConfig;

                final updated = activeDash.copyWith(entityConfigs: newConfigs);
                dashService.updateDashboard(updated);
                Navigator.pop(context);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddWidgetButton(
    int columnIndex,
    int insertAtIndex,
    Dashboard activeDash,
    DashboardService dashService,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: OutlinedButton.icon(
        onPressed: () => _showAddWidgetScreen(
          columnIndex,
          insertAtIndex,
          activeDash,
          dashService,
        ),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Widget'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 40),
          side: BorderSide(
            color: Colors.blue.withValues(alpha: 0.5),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddWidgetScreen(
    int columnIndex,
    int insertAtIndex,
    Dashboard activeDash,
    DashboardService dashService,
  ) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddWidgetScreen(
          dashboardId: activeDash.id,
          columnIndex: columnIndex,
          insertAtIndex: insertAtIndex,
        ),
      ),
    );

    if (result != null && mounted) {
      final type = result['type'] as String;

      if (type == 'entity') {
        final entityId = result['entityId'] as String;
        await _addEntityToColumn(
          activeDash,
          dashService,
          entityId,
          columnIndex,
          insertAtIndex,
        );
      } else if (type == 'custom') {
        final customWidget = result['widget'] as CustomWidget;
        await _addCustomWidgetToColumn(
          activeDash,
          dashService,
          customWidget,
          columnIndex,
          insertAtIndex,
        );
      }
    }
  }

  Future<void> _addEntityToColumn(
    Dashboard activeDash,
    DashboardService dashService,
    String entityId,
    int columnIndex,
    int insertAtIndex,
  ) async {
    final updatedColumns = List<List<String>>.from(
      activeDash.columns.map((col) => List<String>.from(col)),
    );

    // Generate a unique widget ID for this instance
    final widgetId = '$entityId[${const Uuid().v4().substring(0, 8)}]';

    // Ensure we have enough columns
    while (updatedColumns.length <= columnIndex) {
      updatedColumns.add([]);
    }

    // Insert at the specified index
    updatedColumns[columnIndex].insert(insertAtIndex, widgetId);

    // Also add to entityIds and orderedEntityIds
    final updatedEntityIds = List<String>.from(activeDash.entityIds);
    updatedEntityIds.add(widgetId);

    final updatedOrderedEntityIds = List<String>.from(
      activeDash.orderedEntityIds,
    );
    updatedOrderedEntityIds.add(widgetId);

    await dashService.updateDashboard(
      activeDash.copyWith(
        entityIds: updatedEntityIds,
        columns: updatedColumns,
        orderedEntityIds: updatedOrderedEntityIds,
      ),
    );
  }

  Future<void> _addCustomWidgetToColumn(
    Dashboard activeDash,
    DashboardService dashService,
    CustomWidget customWidget,
    int columnIndex,
    int insertAtIndex,
  ) async {
    // First add the custom widget to the dashboard
    await dashService.addCustomWidget(activeDash.id, customWidget);

    // Then update columns to insert at the right position
    final updatedDash = dashService.dashboards.firstWhere(
      (d) => d.id == activeDash.id,
    );

    final updatedColumns = List<List<String>>.from(
      updatedDash.columns.map((col) => List<String>.from(col)),
    );

    // Remove from where it was added (end of first column)
    for (var col in updatedColumns) {
      col.remove(customWidget.id);
    }

    // Ensure we have enough columns
    while (updatedColumns.length <= columnIndex) {
      updatedColumns.add([]);
    }

    // Insert at the specified index
    updatedColumns[columnIndex].insert(insertAtIndex, customWidget.id);

    await dashService.updateDashboard(
      updatedDash.copyWith(columns: updatedColumns),
    );
  }

  Future<void> _confirmDeleteWidget(
    String widgetId,
    Dashboard activeDash,
    DashboardService dashService,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Widget'),
        content: const Text(
          'Are you sure you want to remove this widget from the dashboard?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Check if it's a custom widget or entity
      if (activeDash.customWidgets.containsKey(widgetId)) {
        await dashService.removeCustomWidget(activeDash.id, widgetId);
      } else {
        // Remove entity from dashboard
        final updatedColumns = activeDash.columns.map((col) {
          return col.where((id) => id != widgetId).toList();
        }).toList();

        final updatedEntityIds = activeDash.entityIds
            .where((id) => id != widgetId)
            .toList();

        final updatedConfigs = Map<String, EntityConfig>.from(
          activeDash.entityConfigs,
        );
        updatedConfigs.remove(widgetId);

        final updatedOrderedEntityIds = activeDash.orderedEntityIds
            .where((id) => id != widgetId)
            .toList();

        await dashService.updateDashboard(
          activeDash.copyWith(
            entityIds: updatedEntityIds,
            columns: updatedColumns,
            entityConfigs: updatedConfigs,
            orderedEntityIds: updatedOrderedEntityIds,
          ),
        );
      }
    }
  }
}
