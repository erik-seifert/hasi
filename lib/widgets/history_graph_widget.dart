import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class HistoryGraphWidget extends StatefulWidget {
  final String entityId;
  final String friendlyName;
  final double height;
  final int historyHours;

  const HistoryGraphWidget({
    super.key,
    required this.entityId,
    required this.friendlyName,
    this.height = 150,
    this.historyHours = 24,
  });

  @override
  State<HistoryGraphWidget> createState() => _HistoryGraphWidgetState();
}

class _HistoryGraphWidgetState extends State<HistoryGraphWidget> {
  List<FlSpot> _spots = [];
  bool _isLoading = true;
  double _minY = 0;
  double _maxY = 0;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final auth = context.read<AuthService>();
    final now = DateTime.now().toUtc();
    final startTime = now.subtract(Duration(hours: widget.historyHours));

    // REST API call to fetch history
    final url =
        '${auth.baseUrl}/api/history/period/${startTime.toIso8601String()}?filter_entity_id=${widget.entityId}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${auth.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty && data[0] is List) {
          final List<dynamic> history = data[0];
          final Map<int, double> uniquePoints = {};

          for (var entry in history) {
            final state = double.tryParse(entry['state'] ?? '');
            final lastChanged = DateTime.tryParse(entry['last_changed'] ?? '');

            if (state != null && lastChanged != null) {
              final x = lastChanged.difference(startTime).inSeconds;
              uniquePoints[x] = state;
            }
          }

          final List<FlSpot> spots = uniquePoints.entries
              .map((e) => FlSpot(e.key.toDouble(), e.value))
              .toList();

          // Sort spots by time (x-axis)
          spots.sort((a, b) => a.x.compareTo(b.x));

          double currentMin = double.infinity;
          double currentMax = double.negativeInfinity;
          for (var spot in spots) {
            if (spot.y < currentMin) currentMin = spot.y;
            if (spot.y > currentMax) currentMax = spot.y;
          }

          if (mounted) {
            setState(() {
              _spots = spots;
              if (currentMax == currentMin) {
                _minY = currentMin - 1;
                _maxY = currentMax + 1;
              } else {
                _minY = currentMin - (currentMax - currentMin) * 0.1;
                _maxY = currentMax + (currentMax - currentMin) * 0.1;
              }
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_spots.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Text('No history data')),
      );
    }

    return Container(
      height: widget.height,
      padding: const EdgeInsets.only(top: 10, right: 10, left: 0),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(1)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minY: _minY,
          maxY: _maxY,
          lineBarsData: [
            LineChartBarData(
              spots: _spots,
              isCurved: true,
              curveSmoothness: 0.35,
              preventCurveOverShooting: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    Theme.of(context).colorScheme.primary.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeInOutCubic,
      ),
    );
  }
}
