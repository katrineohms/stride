// ===============================
// Plugins
// ===============================
import 'dart:math';

// ===============================
// Packages
// ===============================
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// ===============================
// Files
// ===============================
import '../model/_models.dart';

// ===============================
// SessionGraphCard Widget
// ===============================

/// Session graph card - displays heart rate data from a completed session
class SessionGraphCard extends StatelessWidget {
  // ====== Fields ======
  final Session session;
  final VoidCallback? onDelete;

  // ====== Constructor ======
  const SessionGraphCard({
    super.key,
    required this.session,
    this.onDelete,
  });

  // ====== Build Method ======
  @override
  Widget build(BuildContext context) {
    final actualStart = DateTime.fromMillisecondsSinceEpoch(
      (session.actualStartTime ?? session.startTime) * 1000,
    );
    final endTime = session.endTime != null
        ? DateTime.fromMillisecondsSinceEpoch(session.endTime! * 1000)
        : DateTime.now();
    final duration = session.duration;
    final startCity = session.startLocationCity;

    // ====== Heart Rate Stats ======
    // Calculate stats
    final hrValues = session.hrReadings.map((r) => r.heartRate).toList();
    final avgHr = hrValues.isEmpty
        ? 0
        : hrValues.reduce((a, b) => a + b) ~/ hrValues.length;
    final maxHr = hrValues.isEmpty ? 0 : hrValues.reduce(max);
    final minHr = hrValues.isEmpty ? 0 : hrValues.reduce(min);

    // Prepare chart data and capture last X for tight bounds
    final spots = <FlSpot>[];
    double maxDataX = 0;
    if (session.hrReadings.isNotEmpty) {
      final baseTime = session.actualStartTime ?? session.startTime;
      for (final reading in session.hrReadings) {
        final minutesElapsed = (reading.timestamp - baseTime) / 60.0;
        spots.add(FlSpot(minutesElapsed, reading.heartRate.toDouble()));
        if (minutesElapsed > maxDataX) maxDataX = minutesElapsed;
      }
    }

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Session',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onDelete,
                    tooltip: 'Delete session',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${actualStart.hour.toString().padLeft(2, '0')}:'
              '${actualStart.minute.toString().padLeft(2, '0')} - '
              '${endTime.hour.toString().padLeft(2, '0')}:'
              '${endTime.minute.toString().padLeft(2, '0')} '
              '(${duration.inMinutes} min)',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (startCity != null) ...[
              const SizedBox(height: 6),
              Text(
                'Location: $startCity',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 12),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Avg', '$avgHr', 'bpm'),
                _buildStatItem('Max', '$maxHr', 'bpm'),
                _buildStatItem('Min', '$minHr', 'bpm'),
              ],
            ),
            const SizedBox(height: 16),
            // Chart
            if (spots.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  // right-only padding to add 20px breathing room
                  child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 20,
                      verticalInterval: 5, // TODO make dynamic based on duration? 
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 5,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}m',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 25,
                          interval: 20,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    minX: 0,
                    // Snap X range to last data point to avoid trailing gap
                    maxX: spots.isNotEmpty ? maxDataX : 5,
                    minY: max(minHr - 10, 40).toDouble(),
                    maxY: (maxHr + 10).toDouble(),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Theme.of(context).primaryColor,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              )
            else
              const Center(
                child: Text('No heart rate data recorded'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
