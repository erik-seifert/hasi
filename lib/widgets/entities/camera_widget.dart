import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '../../services/auth_service.dart';
import '../../services/hass_websocket_service.dart';
import '../../models/dashboard.dart';

class CameraWidget extends StatefulWidget {
  final String entityId;
  final EntityConfig? config;

  const CameraWidget({super.key, required this.entityId, this.config});

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late String _snapshotUrl;
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    _updateUrl();
  }

  void _updateUrl() {
    final auth = context.read<AuthService>();
    _snapshotUrl =
        '${auth.baseUrl}/api/camera_proxy/${widget.entityId}?v=$_refreshCounter';
  }

  void _refresh() {
    setState(() {
      _refreshCounter++;
      _updateUrl();
    });
  }

  @override
  Widget build(BuildContext context) {
    final entity = context.select<HassWebSocketService, Map<String, dynamic>?>(
      (ws) => ws.entitiesMap[widget.entityId],
    );

    if (entity == null) return const SizedBox.shrink();

    final auth = context.read<AuthService>();
    final attributes = entity['attributes'] ?? {};
    final friendlyName =
        widget.config?.nameOverride ??
        attributes['friendly_name'] ??
        widget.entityId;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  _snapshotUrl,
                  headers: {'Authorization': 'Bearer ${auth.token}'},
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_off, size: 48, color: Colors.grey),
                        Text(
                          'Camera unavailable',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      friendlyName,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton.small(
                    onPressed: _refresh,
                    child: const Icon(Icons.refresh),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(name: 'Default', type: CameraWidget)
Widget buildCameraWidgetUseCase(BuildContext context) {
  return const CameraWidget(entityId: 'camera.front_door');
}
