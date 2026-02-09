import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard.dart';
import '../services/dashboard_service.dart';
import '../services/hass_websocket_service.dart';
import '../l10n/app_localizations.dart';

class EditDashboardScreen extends StatefulWidget {
  final Dashboard dashboard;

  const EditDashboardScreen({super.key, required this.dashboard});

  @override
  State<EditDashboardScreen> createState() => _EditDashboardScreenState();
}

class _EditDashboardScreenState extends State<EditDashboardScreen> {
  late TextEditingController _nameController;
  late TextEditingController _searchController;

  // Local filter state, not saved to dashboard
  final List<String> _filterDomains = [];
  final List<String> _filterAreas = [];

  late List<String> _selectedEntityIds;
  List<dynamic> _allEntities = [];
  List<dynamic> _allAreas = [];
  bool _isLoading = true;
  String _searchQuery = '';
  late int _columnCount;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dashboard.name);
    _searchController = TextEditingController();
    _selectedEntityIds = List.from(widget.dashboard.entityIds);
    _columnCount = widget.dashboard.columnCount;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final ws = context.read<HassWebSocketService>();
    if (ws.isConnected) {
      await ws.refreshData(); // Refresh registries and states
      final entities = ws.entities; // Get the refreshed entities
      if (mounted) {
        setState(() {
          _allEntities = entities;
          _allAreas = ws.areas;
          _isLoading = false;
        });
      }
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
      final areaId = registryEntry?['area_id'];

      // Filter out already selected entities from the discovery list
      if (_selectedEntityIds.contains(entityId)) return false;

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
        title: Text(l10n.editDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: _showDeleteConfirm,
          ),
          IconButton(icon: const Icon(Icons.check), onPressed: _saveDashboard),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.dashboardName,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.layout,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text(l10n.columns),
                      subtitle: Text(
                        "$_columnCount ${l10n.columns.toLowerCase()}",
                      ),
                      contentPadding: EdgeInsets.zero,
                      trailing: SizedBox(
                        width: 200,
                        child: Slider(
                          value: _columnCount.toDouble(),
                          min: 1,
                          max: 4,
                          divisions: 3,
                          label: _columnCount.toString(),
                          onChanged: (val) {
                            setState(() => _columnCount = val.toInt());
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer<DashboardService>(
                      builder: (context, dashService, _) {
                        final isDefault =
                            dashService.defaultDashboardId ==
                            widget.dashboard.id;
                        return SwitchListTile(
                          title: Text(l10n.setAsDefault),
                          subtitle: Text(l10n.defaultDashboardSub),
                          value: isDefault,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            dashService.setDefaultDashboard(
                              val ? widget.dashboard.id : null,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildFilterSection(
                      title: l10n.includedDomains,
                      chips: [
                        'light',
                        'climate',
                        'switch',
                        'sensor',
                        'media_player',
                        'camera',
                        'binary_sensor',
                      ],
                      selectedList: _filterDomains,
                    ),
                    const SizedBox(height: 24),
                    _buildAreaFilterSection(),
                    const SizedBox(height: 24),
                    Text(
                      l10n.entitiesToDisplay,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      l10n.manuallySelectEntities,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedEntityIds.isNotEmpty) ...[
                      Text(
                        l10n.selected,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 0,
                        children: _selectedEntityIds.map((id) {
                          final entity = _allEntities.firstWhere(
                            (e) => e['entity_id'] == id,
                            orElse: () => {
                              'attributes': {'friendly_name': id},
                            },
                          );
                          final name =
                              entity['attributes']['friendly_name'] ?? id;
                          return Chip(
                            label: Text(
                              name,
                              style: const TextStyle(fontSize: 11),
                            ),
                            onDeleted: () =>
                                setState(() => _selectedEntityIds.remove(id)),
                            deleteIconColor: Colors.redAccent,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildSearchAndTools(),
                    const SizedBox(height: 8),
                    _buildEntityList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> chips,
    required List<String> selectedList,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: chips.map((value) {
            final isSelected = selectedList.contains(value);
            return FilterChip(
              label: Text(value),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    selectedList.add(value);
                  } else {
                    selectedList.remove(value);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAreaFilterSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.findByArea, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _allAreas.isEmpty
            ? Text(
                l10n.noAreasFound,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              )
            : Wrap(
                spacing: 8,
                children: _allAreas.map((area) {
                  final areaId = area['area_id'];
                  final areaName = area['name'] ?? areaId;
                  final isSelected = _filterAreas.contains(areaId);
                  return FilterChip(
                    label: Text(areaName),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _filterAreas.add(areaId);
                        } else {
                          _filterAreas.remove(areaId);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildSearchAndTools() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n.searchEntities,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Found: ${_filteredEntities.length} entities (${_selectedEntityIds.length} ${l10n.selected.toLowerCase()})",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _selectedEntityIds.clear()),
              icon: const Icon(Icons.layers_clear, size: 16),
              label: Text(l10n.deselectAll),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEntityList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredEntities.length,
      itemBuilder: (context, index) {
        final entity = _filteredEntities[index];
        final entityId = entity['entity_id'];
        final friendlyName = entity['attributes']['friendly_name'] ?? entityId;
        final isSelected = _selectedEntityIds.contains(entityId);

        return CheckboxListTile(
          title: Text(friendlyName),
          subtitle: Text(entityId),
          value: isSelected,
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _selectedEntityIds.add(entityId);
              } else {
                _selectedEntityIds.remove(entityId);
              }
            });
          },
        );
      },
    );
  }

  Future<void> _showDeleteConfirm() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDashboard),
        content: Text(l10n.deleteConfirm(widget.dashboard.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final dashService = context.read<DashboardService>();
      await dashService.deleteDashboard(widget.dashboard.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _saveDashboard() async {
    final dashService = context.read<DashboardService>();
    final updated = widget.dashboard.copyWith(
      name: _nameController.text,
      entityIds: _selectedEntityIds,
      columnCount: _columnCount,
    );

    await dashService.updateDashboard(updated);
    if (mounted) Navigator.pop(context);
  }
}
