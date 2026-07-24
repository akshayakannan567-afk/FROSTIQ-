import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/shimmer_loading.dart';
import '../services/predictive_service.dart';

class HistoryTab extends StatefulWidget {
  final String deviceId;
  const HistoryTab({super.key, required this.deviceId});

  @override
  State<HistoryTab> createState() => HistoryTabState();
}

class HistoryTabState extends State<HistoryTab> {
  String selectedRange = '24H';
  final List<String> ranges = ['24H', '7D', '30D'];

  List<FlSpot> tempHistory = [];
  List<FlSpot> powerHistory = [];
  List<String> xLabels = [];

  bool isLoading = true;
  bool hasError = false;
  bool isHybridData = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadHistoryData();
  }

  Future<void> loadHistoryData() async {
    setState(() {
      isLoading = true;
      hasError = false;
      isHybridData = false;
    });

    try {
      final ref = FirebaseDatabase.instance.ref("devices/${widget.deviceId}/history");
      final snapshot = await ref.orderByKey().limitToLast(500).get();

      final List<dynamic> entries = [];
      if (snapshot.exists && snapshot.value != null) {
        final rawData = Map<String, dynamic>.from(snapshot.value as Map);
        entries.addAll(rawData.values);
      }

      // Use Hybrid Data (Merge real with demo)
      final hybridData = PredictiveService.getHybridHistory(entries);
      _processRawEntries(hybridData);
      
      setState(() {
        // If we merged demo data, mark it as hybrid
        isHybridData = true; 
        isLoading = false;
      });
    } catch (e) {
      // FALLBACK ON ERROR
      final demoData = PredictiveService.generate30DayDemoData();
      _processRawEntries(demoData);
      setState(() {
        isHybridData = true;
        isLoading = false;
      });
    }
  }

  void _processRawEntries(List<dynamic> entries) {
    // Sort by timestamp
    entries.sort((a, b) => (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0));

    List<FlSpot> tempSpots = [];
    List<FlSpot> powerSpots = [];
    List<String> labels = [];

    final now = DateTime.now();
    int interval;

    // Determine grouping interval based on range
    switch (selectedRange) {
      case '24H':
        interval = 60; // minutes
        break;
      case '7D':
        interval = 360; // 6 hours
        break;
      case '30D':
        interval = 1440; // 1 day
        break;
      default:
        interval = 60;
    }

    // Group data into buckets
    Map<int, List<double>> tempBuckets = {};
    Map<int, List<double>> powerBuckets = {};

    for (var entry in entries) {
      final timestamp = entry['timestamp'] ?? 0;
      final temp = (entry['temp'] ?? 0.0).toDouble();
      final power = (entry['power'] ?? 0.0).toDouble();

      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final minutesSinceEpoch = dateTime.difference(now.subtract(const Duration(days: 30))).inMinutes;

      int bucketKey = (minutesSinceEpoch / interval).floor();

      tempBuckets.putIfAbsent(bucketKey, () => []).add(temp);
      powerBuckets.putIfAbsent(bucketKey, () => []).add(power);
    }

    // Calculate averages
    int index = 0;
    tempBuckets.forEach((key, values) {
      final avgTemp = values.reduce((a, b) => a + b) / values.length;
      final avgPower = powerBuckets[key]!.reduce((a, b) => a + b) / powerBuckets[key]!.length;

      tempSpots.add(FlSpot(index.toDouble(), avgTemp));
      powerSpots.add(FlSpot(index.toDouble(), avgPower));

      // Create labels
      if (selectedRange == '24H') {
        final hour = now.subtract(Duration(minutes: (tempBuckets.length - 1 - index) * interval));
        labels.add("${hour.hour.toString().padLeft(2, '0')}:00");
      } else {
        final day = now.subtract(Duration(days: (tempBuckets.length - 1 - index)));
        labels.add("${day.day}/${day.month}");
      }
      index++;
    });

    tempHistory = tempSpots;
    powerHistory = powerSpots;
    xLabels = labels;
  }

  void onRangeChanged(String newRange) {
    if (newRange == selectedRange) return;
    setState(() {
      selectedRange = newRange;
    });
    loadHistoryData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('History',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  Text('Past performance data',
                      style: GoogleFonts.inter(color: FrostiqColors.textMuted, fontSize: 14)),
                ],
              ),
              if (isHybridData)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: FrostiqColors.cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: FrostiqColors.cyan.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'HYBRID DATA',
                    style: GoogleFonts.inter(
                      color: FrostiqColors.cyan,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Time Range Selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: FrostiqColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: ranges.map((range) {
                bool isSelected = range == selectedRange;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onRangeChanged(range),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? FrostiqColors.cyan : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(range,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          if (isLoading)
            buildShimmerHistoryChart()
          else if (hasError)
            buildErrorState()
          else ...[
              buildHistoryChart(
                title: 'Temperature History',
                unit: '°C',
                data: tempHistory,
                color: FrostiqColors.cyan,
              ),
              const SizedBox(height: 20),
              buildHistoryChart(
                title: 'Power Consumption',
                unit: 'W',
                data: powerHistory,
                color: FrostiqColors.green,
              ),
              const SizedBox(height: 24),
              buildStatsSummary(),
            ],
        ],
      ),
    );
  }

  Widget buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: FrostiqColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FrostiqColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 64, color: FrostiqColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'Unable to load data',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: FrostiqColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: loadHistoryData,
            style: ElevatedButton.styleFrom(
              backgroundColor: FrostiqColors.cyan,
              foregroundColor: Colors.black,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget buildShimmerHistoryChart() {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FrostiqColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: FrostiqColors.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 150, height: 14, radius: 4),
                ShimmerBox(width: 80, height: 14, radius: 4),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: ShimmerBox(width: double.infinity, height: 180, radius: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHistoryChart({
    required String title,
    required String unit,
    required List<FlSpot> data,
    required Color color,
  }) {
    if (data.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
            color: FrostiqColors.cardBackground,
            borderRadius: BorderRadius.circular(20)),
        child: const Center(child: CircularProgressIndicator(color: FrostiqColors.cyan)),
      );
    }

    double maxY = data.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.25;
    double avg = data.map((e) => e.y).reduce((a, b) => a + b) / data.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FrostiqColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FrostiqColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(color: FrostiqColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(_getSubtitle(),
                      style: GoogleFonts.inter(color: FrostiqColors.textMuted, fontSize: 12)),
                ],
              ),
              Text('Avg: ${avg.toStringAsFixed(1)}$unit',
                  style: GoogleFonts.inter(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 3,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: FrostiqColors.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: maxY / 3,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(color: FrostiqColors.textMuted, fontSize: 11),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: data.length / 5,
                      getTitlesWidget: (value, meta) {
                        if (xLabels.isEmpty || value.toInt() >= xLabels.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            xLabels[value.toInt()],
                            style: const TextStyle(color: FrostiqColors.textMuted, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: color,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSubtitle() {
    switch (selectedRange) {
      case '24H': return 'Last 24 hours';
      case '7D': return 'Last 7 days';
      case '30D': return 'Last 30 days';
      default: return 'Last 24 hours';
    }
  }

  Widget buildStatsSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FrostiqColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FrostiqColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Summary ($selectedRange)',
              style: GoogleFonts.inter(color: FrostiqColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              statItem('Door Openings', '24', FrostiqColors.cyan),
              statItem('Alerts', '3', FrostiqColors.orange),
              statItem('Uptime', '99.2%', FrostiqColors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget statItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: GoogleFonts.inter(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: GoogleFonts.inter(color: FrostiqColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}