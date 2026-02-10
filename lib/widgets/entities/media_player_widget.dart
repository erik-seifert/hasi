import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '../../services/auth_service.dart';
import '../../services/hass_websocket_service.dart';

import '../../models/dashboard.dart';

class MediaWidget extends StatelessWidget {
  final String entityId;
  final EntityConfig? config;

  const MediaWidget({super.key, required this.entityId, this.config});

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
    final isPlaying = state == 'playing';
    final mediaTitle = attributes['media_title'];
    final mediaArtist = attributes['media_artist'];
    final volume = attributes['volume_level'] ?? 0.0;
    final entityPicture = attributes['entity_picture'];

    final auth = context.read<AuthService>();
    final imageUrl = entityPicture != null
        ? '${auth.baseUrl}$entityPicture'
        : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            height: 140, // Increased height
            width: double.infinity,
            decoration: BoxDecoration(
              image: imageUrl != null && !imageUrl.startsWith('null')
                  ? DecorationImage(
                      image: NetworkImage(
                        imageUrl,
                        headers: {'Authorization': 'Bearer ${auth.token}'},
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: Colors.black87,
            ),
            child: Stack(
              children: [
                if (imageUrl == null || imageUrl.startsWith('null'))
                  const Center(
                    child: Icon(
                      Icons.music_note,
                      size: 50,
                      color: Colors.white24,
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black, Colors.transparent],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mediaTitle ?? friendlyName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (mediaArtist != null)
                          Text(
                            mediaArtist,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isPlaying ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      state.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: () =>
                          context.read<HassWebSocketService>().callService(
                            'media_player',
                            'media_previous_track',
                            serviceData: {'entity_id': entityId},
                          ),
                    ),
                    IconButton(
                      iconSize: 48,
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                      ),
                      onPressed: () {
                        final service = isPlaying
                            ? 'media_pause'
                            : 'media_play';
                        context.read<HassWebSocketService>().callService(
                          'media_player',
                          service,
                          serviceData: {'entity_id': entityId},
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: () =>
                          context.read<HassWebSocketService>().callService(
                            'media_player',
                            'media_next_track',
                            serviceData: {'entity_id': entityId},
                          ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.volume_down, size: 16, color: Colors.grey),
                    Expanded(
                      child: Slider(
                        value: volume.toDouble(),
                        onChanged: (val) {
                          context.read<HassWebSocketService>().callService(
                            'media_player',
                            'volume_set',
                            serviceData: {
                              'entity_id': entityId,
                              'volume_level': val,
                            },
                          );
                        },
                      ),
                    ),
                    const Icon(Icons.volume_up, size: 16, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(name: 'Playing', type: MediaWidget)
Widget buildMediaWidgetPlayingUseCase(BuildContext context) {
  return const MediaWidget(entityId: 'media_player.spotify');
}

@widgetbook.UseCase(name: 'Paused', type: MediaWidget)
Widget buildMediaWidgetPausedUseCase(BuildContext context) {
  return const MediaWidget(entityId: 'media_player.spotify');
}
