import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dashboard.dart';
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

    if (_dashboards.isEmpty) {
      // Create a default dashboard
      final defaultDash = Dashboard(
        id: const Uuid().v4(),
        name: 'Lights & Climate',
        entityIds: [], // User needs to select entities now
      );
      _dashboards.add(defaultDash);
      await save();
    }

    _defaultDashboardId = prefs.getString('default_dashboard_id');

    // Always start with the default dashboard if set, otherwise last active
    _activeDashboardId =
        _defaultDashboardId ??
        prefs.getString('active_dashboard_id') ??
        _dashboards.first.id;

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

  Future<void> deleteDashboard(String id) async {
    if (_dashboards.length <= 1) return; // Keep at least one
    _dashboards.removeWhere((d) => d.id == id);
    if (_activeDashboardId == id) {
      _activeDashboardId = _dashboards.first.id;
    }
    if (_defaultDashboardId == id) {
      await setDefaultDashboard(null);
    }
    await save();
    await _saveActiveId();
    notifyListeners();
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
}
