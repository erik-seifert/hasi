import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dashboard.dart';
import '../models/custom_widget.dart';
import 'package:uuid/uuid.dart';

class DashboardService extends ChangeNotifier {
  final List<Dashboard> _dashboards = [];
  String? _activeDashboardId;
  String? _defaultDashboardId;

  List<Dashboard> get dashboards => List.unmodifiable(_dashboards);
  String? get activeDashboardId => _activeDashboardId;
  String? get defaultDashboardId => _defaultDashboardId;

  Dashboard? get activeDashboard {
    if (_activeDashboardId == null) return null;
    final index = _dashboards.indexWhere((d) => d.id == _activeDashboardId);
    if (index != -1) return _dashboards[index];
    return _dashboards.isNotEmpty ? _dashboards.first : null;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('dashboards');

    if (data != null) {
      _dashboards.clear();
      for (var jsonStr in data) {
        _dashboards.add(Dashboard.fromJson(jsonStr));
      }
    }

    _defaultDashboardId = prefs.getString('default_dashboard_id');

    // Set active dashboard if we have any
    if (_dashboards.isNotEmpty) {
      _activeDashboardId =
          _defaultDashboardId ??
          prefs.getString('active_dashboard_id') ??
          _dashboards.first.id;
    } else {
      _activeDashboardId = null;
    }

    notifyListeners();
  }

  Future<void> setDefaultDashboard(String? id) async {
    _defaultDashboardId = id;
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setString('default_dashboard_id', id);
    } else {
      await prefs.remove('default_dashboard_id');
    }
    notifyListeners();
  }

  Future<void> addDashboard(
    String name, {
    List<String>? entityIds,
    int columnCount = 2,
  }) async {
    final ids = entityIds ?? [];
    final columns = List.generate(columnCount, (_) => <String>[]);
    for (int i = 0; i < ids.length; i++) {
      columns[i % columnCount].add(ids[i]);
    }

    final dash = Dashboard(
      id: const Uuid().v4(),
      name: name,
      entityIds: ids,
      orderedEntityIds: ids,
      columns: columns,
      columnCount: columnCount,
    );
    _dashboards.add(dash);
    await save();
    _activeDashboardId = dash.id;
    await _saveActiveId();
    notifyListeners();
  }

  Future<void> updateDashboard(Dashboard updated) async {
    final index = _dashboards.indexWhere((d) => d.id == updated.id);
    if (index != -1) {
      _dashboards[index] = updated;
      await save();
      notifyListeners();
    }
  }

  Future<bool> deleteDashboard(String id) async {
    _dashboards.removeWhere((d) => d.id == id);

    // If we deleted the active dashboard, switch to another or clear
    if (_activeDashboardId == id) {
      _activeDashboardId = _dashboards.isNotEmpty ? _dashboards.first.id : null;
    }

    // If we deleted the default dashboard, clear it
    if (_defaultDashboardId == id) {
      await setDefaultDashboard(null);
    }

    await save();
    await _saveActiveId();
    notifyListeners();
    return true;
  }

  Future<void> setActiveDashboard(String id) async {
    _activeDashboardId = id;
    await _saveActiveId();
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _dashboards.map((d) => d.toJson()).toList();
    await prefs.setStringList('dashboards', data);
  }

  Future<void> _saveActiveId() async {
    final prefs = await SharedPreferences.getInstance();
    if (_activeDashboardId != null) {
      await prefs.setString('active_dashboard_id', _activeDashboardId!);
    }
  }

  // Custom widget management
  Future<void> addCustomWidget(String dashboardId, CustomWidget widget) async {
    final index = _dashboards.indexWhere((d) => d.id == dashboardId);
    if (index == -1) return;

    final dashboard = _dashboards[index];
    final updatedCustomWidgets = Map<String, CustomWidget>.from(
      dashboard.customWidgets,
    );
    updatedCustomWidgets[widget.id] = widget;

    // Add to columns (first column by default)
    final updatedColumns = List<List<String>>.from(dashboard.columns);
    if (updatedColumns.isEmpty) {
      updatedColumns.add([widget.id]);
    } else {
      updatedColumns[0] = [...updatedColumns[0], widget.id];
    }

    _dashboards[index] = dashboard.copyWith(
      customWidgets: updatedCustomWidgets,
      columns: updatedColumns,
    );

    await save();
    notifyListeners();
  }

  Future<void> updateCustomWidget(
    String dashboardId,
    CustomWidget widget,
  ) async {
    final index = _dashboards.indexWhere((d) => d.id == dashboardId);
    if (index == -1) return;

    final dashboard = _dashboards[index];
    final updatedCustomWidgets = Map<String, CustomWidget>.from(
      dashboard.customWidgets,
    );
    updatedCustomWidgets[widget.id] = widget;

    _dashboards[index] = dashboard.copyWith(
      customWidgets: updatedCustomWidgets,
    );

    await save();
    notifyListeners();
  }

  Future<void> removeCustomWidget(String dashboardId, String widgetId) async {
    final index = _dashboards.indexWhere((d) => d.id == dashboardId);
    if (index == -1) return;

    final dashboard = _dashboards[index];
    final updatedCustomWidgets = Map<String, CustomWidget>.from(
      dashboard.customWidgets,
    );
    updatedCustomWidgets.remove(widgetId);

    // Remove from columns
    final updatedColumns = dashboard.columns.map((col) {
      return col.where((id) => id != widgetId).toList();
    }).toList();

    _dashboards[index] = dashboard.copyWith(
      customWidgets: updatedCustomWidgets,
      columns: updatedColumns,
    );

    await save();
    notifyListeners();
  }
}
