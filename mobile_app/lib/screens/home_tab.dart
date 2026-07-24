import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/shimmer_loading.dart';

class HomeTab extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const HomeTab({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<HomeTab> createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  List<FlSpot> energyData = [];
  List<DateTime> timeStamps = [];
  static const int maxPoints = 60; // Last 60 minutes (1 point per minute)
  late Stream<DatabaseEvent> _telemetryStream;

  @override
  void initState() {
    super.initState();
    _telemetryStream = FirebaseDatabase.instance
        .ref("devices/${widget.deviceId}/telemetry")
        .onValue;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: _telemetryStream,
      builder: (context, snapshot) {
        double temp = 0.0;
        bool doorOpen = false;
        int gas = 0;
        double power = 0.0;
        bool hasRealData = false;

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final value = snapshot.data!.snapshot.value;
          if (value is Map) {
            final data = Map<String, dynamic>.from(value);
            temp = (data['temp'] ?? 0.0).toDouble();
            doorOpen = data['door_open'] ?? false;
            gas = (data['gas'] ?? 0).toInt();
            power = (data['power'] ?? 0.0).toDouble();
            
            // We can't call setState here, so we use a post-frame callback
            // or better, we listen to the stream in initState.
            // For now, let's just trigger the update if needed.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) updateEnergyData(power);
            });
            
            hasRealData = true;
          }
        }

        bool isLoading = snapshot.connectionState == ConnectionState.waiting;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader(),
              const SizedBox(height: 24),

              // Shimmer loading for sensor cards
              if (isLoading)
                Row(children: [
                  Expanded(child: buildShimmerSensorCard()),
                  const SizedBox(width: 16),
                  Expanded(child: buildShimmerSensorCard()),
                ])
              else
                Row(children: [
                  Expanded(child: buildTemperatureCard(temp)),
                  const SizedBox(width: 16),
                  Expanded(child: buildDoorStatusCard(doorOpen)),
                ]),

              const SizedBox(height: 16),

              if (isLoading)
                Row(children: [
                  Expanded(child: buildShimmerSensorCard()),
                  const SizedBox(width: 16),
                  Expanded(child: buildShimmerSensorCard()),
                ])
              else
                Row(children: [
                  Expanded(child: buildAirQualityCard(gas)),
                  const SizedBox(width: 16),
                  Expanded(child: buildPowerCard(power)),
                ]),

              const SizedBox(height: 24),

              if (isLoading)
                buildShimmerEnergyCard()
              else if (!hasRealData)
                buildNoDataCard()
              else
                buildEnergyGraphCard(power),
            ],
          ),
        );
      },
    );
  }

  Widget buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FrostIQ',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            )),
        Text('Live Status',
            style: GoogleFonts.inter(color: FrostiqColors.textMuted, fontSize: 14)),
      ],
    );
  }

  // Shimmer placeholders
  Widget buildShimmerSensorCard() {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: FrostiqColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: FrostiqColors.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 90, height: 14, radius: 4),
            SizedBox(height: 14),
            ShimmerBox(width: 110, height: 30, radius: 6),
            SizedBox(height: 10),
            ShimmerBox(width: 70, height: 14, radius: 4),
          ],
        ),
      ),
    );
  }

  Widget buildShimmerEnergyCard() {
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 95, height: 14, radius: 4),
                    SizedBox(height: 6),
                    ShimmerBox(width: 130, height: 24, radius: 6),
                  ],
                ),
                ShimmerBox(width: 24, height: 24, radius: 12),
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

  Widget buildTemperatureCard(double temp) {
    String status;
    Color color;
    if (temp < 2) { status = 'Too Cold'; color = Colors.blue; }
    else if (temp <= 8) { status = 'Normal'; color = FrostiqColors.green; }
    else { status = 'Too Warm'; color = Colors.orange; }

    return sensorCard(
      title: 'Temperature',
      value: '${temp.toStringAsFixed(1)}°C',
      status: status,
      valueColor: FrostiqColors.cyan,
      statusColor: color,
    );
  }

  Widget buildDoorStatusCard(bool isOpen) {
    return sensorCard(
      title: 'Door Status',
      value: isOpen ? 'Open' : 'Closed',
      status: isOpen ? 'Alert' : 'Secure',
      valueColor: isOpen ? Colors.orange : FrostiqColors.green,
      statusColor: isOpen ? Colors.orange : FrostiqColors.green,
    );
  }

  Widget buildAirQualityCard(int gas) {
    String quality, status;
    Color color;
    if (gas < 300) { quality = 'Good'; status = 'Safe'; color = FrostiqColors.green; }
    else if (gas < 600) { quality = 'Fair'; status = 'Monitor'; color = Colors.orange; }
    else { quality = 'Poor'; status = 'Warning'; color = Colors.red; }

    return sensorCard(
      title: 'Air Quality',
      value: quality,
      status: status,
      valueColor: color,
      statusColor: color,
    );
  }

  Widget buildPowerCard(double power) {
    String status;
    Color color;
    if (power < 150) { status = 'Normal'; color = FrostiqColors.green; }
    else if (power < 250) { status = 'High'; color = Colors.orange; }
    else { status = 'Very High'; color = Colors.red; }

    return sensorCard(
      title: 'Power Usage',
      value: '${power.toStringAsFixed(0)}W',
      status: status,
      valueColor: FrostiqColors.cyan,
      statusColor: color,
    );
  }

  Widget sensorCard({
    required String title,
    required String value,
    required String status,
    required Color valueColor,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FrostiqColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FrostiqColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.inter(
                color: FrostiqColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.inter(
                color: valueColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 6),
          Text(status,
              style: GoogleFonts.inter(
                color: statusColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  Widget buildEnergyGraphCard(double currentPower) {
    double kwhToday = energyData.isEmpty
        ? 0.0
        : energyData.map((e) => e.y).reduce((a, b) => a + b) / 1000 * 0.1;

    // Dynamic Y-axis
    double dynamicMaxY = 100;
    if (energyData.isNotEmpty) {
      double maxValue = energyData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
      dynamicMaxY = maxValue * 1.35;
      if (dynamicMaxY < 100) dynamicMaxY = 100;
    }

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
                  Text('Energy Today',
                      style: GoogleFonts.inter(color: FrostiqColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('${kwhToday.toStringAsFixed(2)} kWh',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
              Icon(Icons.close, color: Colors.grey.shade600, size: 20),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            'Last 60 minutes',
            style: GoogleFonts.inter(
              color: FrostiqColors.textMuted,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 180,
            child: energyData.isEmpty
                ? const Center(
                child: Text('Waiting for data...',
                    style: TextStyle(color: Colors.grey)))
                : LineChart(
              LineChartData(
                minY: 0,
                maxY: dynamicMaxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: dynamicMaxY / 3,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: FrostiqColors.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: dynamicMaxY / 3,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(
                            color: FrostiqColors.textMuted, fontSize: 11),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        if (timeStamps.isEmpty || value.toInt() >= timeStamps.length) {
                          return const SizedBox();
                        }

                        final time = timeStamps[value.toInt()];
                        String label;

                        if (value == energyData.length - 1) {
                          label = "Now";
                        } else {
                          label =
                          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: FrostiqColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: energyData,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: FrostiqColors.cyan,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          FrostiqColors.cyan.withValues(alpha: 0.3),
                          FrostiqColors.cyan.withValues(alpha: 0.0),
                        ],
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

  void updateEnergyData(double power) {
    final now = DateTime.now();

    setState(() {
      energyData.add(FlSpot(energyData.length.toDouble(), power));
      timeStamps.add(now);

      // Keep only last 60 points (rolling window)
      if (energyData.length > maxPoints) {
        energyData.removeAt(0);
        timeStamps.removeAt(0);

        // Re-index the spots
        for (int i = 0; i < energyData.length; i++) {
          energyData[i] = FlSpot(i.toDouble(), energyData[i].y);
        }
      }
    });
  }

  Widget buildNoDataCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FrostiqColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FrostiqColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.sensors_off_outlined, size: 48, color: FrostiqColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'No data yet',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Waiting for your FrostIQ device to send data...',
            style: GoogleFonts.inter(color: FrostiqColors.textMuted, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}