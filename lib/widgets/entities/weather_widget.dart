import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/hass_websocket_service.dart';
import 'package:intl/intl.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '../../models/dashboard.dart';

class WeatherWidget extends StatefulWidget {
  final String entityId;
  final EntityConfig? config;

  const WeatherWidget({super.key, required this.entityId, this.config});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  List<dynamic>? _forecast;
  bool _isLoadingForecast = false;

  @override
  void initState() {
    super.initState();
    _fetchForecast();
  }

  @override
  void didUpdateWidget(WeatherWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entityId != widget.entityId ||
        oldWidget.config?.options['forecast_type'] !=
            widget.config?.options['forecast_type']) {
      _fetchForecast();
    }
  }

  Future<void> _fetchForecast() async {
    final ws = context.read<HassWebSocketService>();
    final entity = ws.entitiesMap[widget.entityId];
    if (entity == null) return;

    final attributes = entity['attributes'] ?? {};
    // Check if legacy forecast attribute exists
    if (attributes['forecast'] != null) {
      if (mounted) {
        setState(() {
          _forecast = attributes['forecast'];
        });
      }
      return;
    }

    // Try modern service call
    if (mounted) {
      setState(() {
        _isLoadingForecast = true;
      });
    }

    try {
      final ws = context.read<HassWebSocketService>();
      final forecastType = widget.config?.options['forecast_type'] ?? 'daily';

      final result = await ws.callService(
        'weather',
        'get_forecasts',
        serviceData: {'entity_id': widget.entityId, 'type': forecastType},
        returnResponse: true,
      );

      if (mounted) {
        setState(() {
          final entityId = widget.entityId;
          debugPrint('Forecast service result: $result for $entityId');

          // The service response is wrapped in a 'response' object
          final response = result?['response'];
          if (response != null && response[entityId] != null) {
            _forecast = response[entityId]['forecast'];
          } else {
            debugPrint('Forecast key not found in service response');
          }
          _isLoadingForecast = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching forecast for ${widget.entityId}: $e');
      if (mounted) {
        setState(() {
          _isLoadingForecast = false;
          _forecast = null; // Clear if error
        });
      }
    }
  }

  IconData _getWeatherIcon(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'cloudy':
        return Icons.cloud;
      case 'fog':
        return Icons.cloud_queue;
      case 'hail':
        return Icons.ac_unit;
      case 'lightning':
      case 'lightning-rainy':
        return Icons.thunderstorm;
      case 'partlycloudy':
        return Icons.cloud_queue;
      case 'pouring':
        return Icons.umbrella;
      case 'rainy':
        return Icons.water_drop;
      case 'snowy':
      case 'snowy-rainy':
        return Icons.ac_unit;
      case 'sunny':
      case 'clear-night':
        return condition == 'sunny' ? Icons.wb_sunny : Icons.nightlight_round;
      case 'windy':
      case 'windy-variant':
        return Icons.air;
      case 'exceptional':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entity = context.select<HassWebSocketService, Map<String, dynamic>?>(
      (ws) => ws.entitiesMap[widget.entityId],
    );

    if (entity == null) return const SizedBox.shrink();

    final attributes = entity['attributes'] ?? {};
    final state = entity['state'] ?? 'unknown';
    final friendlyName =
        widget.config?.nameOverride ??
        attributes['friendly_name'] ??
        widget.entityId;
    final temperature = attributes['temperature'];
    final unit = attributes['temperature_unit'] ?? '°C';
    final humidity = attributes['humidity'];

    final showForecast = widget.config?.options['show_forecast'] ?? true;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friendlyName,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        state.toString().toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _getWeatherIcon(state),
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$temperature',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                  child: Text(
                    unit,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Spacer(),
                if (humidity != null)
                  Column(
                    children: [
                      const Icon(
                        Icons.water_drop,
                        size: 16,
                        color: Colors.blue,
                      ),
                      Text(
                        '$humidity%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
              ],
            ),
            if (showForecast && _forecast != null && _forecast!.isNotEmpty) ...[
              const Divider(height: 32),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: () {
                    final maxCount =
                        widget.config?.options['forecast_count'] ?? 5;
                    return _forecast!.length > maxCount
                        ? maxCount
                        : _forecast!.length;
                  }(),
                  itemBuilder: (context, index) {
                    final day = _forecast![index];
                    final dateTime = DateTime.parse(day['datetime']);
                    final dayName = DateFormat('E').format(dateTime);
                    final temp =
                        day['temperature'] ?? day['native_temperature'];
                    final tempLow = day['templow'] ?? day['native_templow'];
                    final condition = day['condition'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Icon(_getWeatherIcon(condition), size: 24),
                          const SizedBox(height: 4),
                          Text(
                            tempLow != null
                                ? '$temp° / $tempLow°'
                                : '$temp$unit',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else if (_isLoadingForecast)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (showForecast && (_forecast == null || _forecast!.isEmpty))
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Forecast unavailable',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

@widgetbook.UseCase(name: 'Sunny Weather', type: WeatherWidget)
Widget buildSunnyWeatherUseCase(BuildContext context) {
  return const WeatherWidget(entityId: 'weather.home');
}
