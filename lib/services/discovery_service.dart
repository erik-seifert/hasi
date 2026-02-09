import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nsd/nsd.dart';
import '../models/ha_instance.dart';
import 'logger_service.dart';

class DiscoveryService extends ChangeNotifier {
  final List<HAInstance> _instances = [];
  Discovery? _discovery;
  bool _isScanning = false;

  List<HAInstance> get instances => List.unmodifiable(_instances);
  bool get isScanning => _isScanning;

  Future<void> startScan() async {
    if (_isScanning) return;

    // On Linux/Windows, discovery might fail if dependencies aren't installed.
    // We'll try, but handle errors gracefully.

    _isScanning = true;
    _instances.clear();
    notifyListeners();

    try {
      _discovery = await startDiscovery(
        '_home-assistant._tcp',
        autoResolve: true,
      );
      _discovery!.addListener(() {
        _updateInstances();
      });
      // Initial list check
      _updateInstances();
    } on PlatformException catch (e) {
      if (e.code == 'MissingPluginException' ||
          e.message?.contains('MissingPluginException') == true) {
        AppLogger.w("Discovery not supported on this platform: ${e.message}");
      } else {
        AppLogger.e("Discovery platform error: $e");
      }
      _isScanning = false;
      notifyListeners();
    } catch (e) {
      // NsdError often wraps the underlying exception
      if (e.toString().contains("MissingPluginException")) {
        AppLogger.w("Discovery plugin missing or not configured: $e");
      } else {
        AppLogger.e("Discovery error: $e");
      }
      _isScanning = false;
      notifyListeners();
    }
  }

  void _updateInstances() {
    if (_discovery == null) return;

    final services = _discovery!.services;
    final newInstances = <HAInstance>[];

    for (var service in services) {
      final name = service.name ?? 'Unknown Home Assistant';
      final host = service.host;
      final port = service.port;

      if (host != null && port != null) {
        // Construct URL
        // Usually HA is http unless configured otherwise, but mDNS might not tell us protocol.
        // default to http, maybe try https if port is 8123?
        // _home-assistant._tcp usually implies http on 8123.
        String url = 'http://$host:$port';

        // Sometimes host is just a hostname, not IP.
        // We'll accept it as is.

        newInstances.add(
          HAInstance(name: name, url: url, ip: host, port: port),
        );
      }
    }

    // Update list if changed
    // Simple check: different count or different names
    bool changed = false;
    if (newInstances.length != _instances.length) {
      changed = true;
    } else {
      for (int i = 0; i < newInstances.length; i++) {
        if (newInstances[i].url != _instances[i].url) {
          changed = true;
          break;
        }
      }
    }

    if (changed) {
      _instances.clear();
      _instances.addAll(newInstances);
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    if (_discovery != null) {
      await stopDiscovery(_discovery!);
      _discovery = null;
    }
    _isScanning = false;
    notifyListeners();
  }
}
