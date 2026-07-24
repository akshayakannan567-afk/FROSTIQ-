import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/shimmer_loading.dart';
import 'main_navigation.dart';
import 'qr_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FrostiqColors.cardBackground,
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: FrostiqColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FrostiqColors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FrostiqColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Devices',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          )),
                      Text('Manage all your Frostiq units',
                          style: GoogleFonts.inter(
                            color: FrostiqColors.textMuted,
                            fontSize: 14,
                          )),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.logout, color: FrostiqColors.textSecondary),
                        onPressed: () => _showLogoutDialog(context),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: FrostiqColors.cyan,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.black),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const QRScannerScreen(),
                            ));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseDatabase.instance
                    .ref("users/$uid/devices")
                    .onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 3,
                      itemBuilder: (context, index) => buildShimmerDeviceCard(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                    return emptyState();
                  }

                  final List<String> deviceIds = [];
                  final value = snapshot.data!.snapshot.value;

                  if (value is Map) {
                    deviceIds.addAll(value.keys.map((e) => e.toString()));
                  } else if (value is List) {
                    for (int i = 0; i < value.length; i++) {
                      if (value[i] != null) deviceIds.add(i.toString());
                    }
                  }

                  if (deviceIds.isEmpty) return emptyState();

                  return RefreshIndicator(
                    color: FrostiqColors.cyan,
                    onRefresh: () async => setState(() {}),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: deviceIds.length,
                      itemBuilder: (context, index) {
                        return DeviceCard(deviceId: deviceIds[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShimmerDeviceCard() {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
              children: [
                ShimmerBox(width: 48, height: 48, radius: 14),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 160, height: 18, radius: 6),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          ShimmerBox(width: 10, height: 10, radius: 5),
                          SizedBox(width: 8),
                          ShimmerBox(width: 60, height: 14, radius: 4),
                        ],
                      ),
                    ],
                  ),
                ),
                ShimmerBox(width: 20, height: 20, radius: 10),
              ],
            ),
            SizedBox(height: 18),
            Divider(color: FrostiqColors.border, height: 1),
            SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    ShimmerBox(width: 22, height: 22, radius: 4),
                    SizedBox(height: 8),
                    ShimmerBox(width: 45, height: 16, radius: 4),
                    SizedBox(height: 4),
                    ShimmerBox(width: 30, height: 12, radius: 4),
                  ],
                ),
                Column(
                  children: [
                    ShimmerBox(width: 22, height: 22, radius: 4),
                    SizedBox(height: 8),
                    ShimmerBox(width: 45, height: 16, radius: 4),
                    SizedBox(height: 4),
                    ShimmerBox(width: 30, height: 12, radius: 4),
                  ],
                ),
                Column(
                  children: [
                    ShimmerBox(width: 22, height: 22, radius: 4),
                    SizedBox(height: 8),
                    ShimmerBox(width: 45, height: 16, radius: 4),
                    SizedBox(height: 4),
                    ShimmerBox(width: 30, height: 12, radius: 4),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: FrostiqColors.cardBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.kitchen_outlined,
              size: 60,
              color: FrostiqColors.cyan,
            ),
          ),
          const SizedBox(height: 24),
          Text('No devices yet',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Text('Add your first Frostiq to get started',
              style: GoogleFonts.inter(
                color: FrostiqColors.textSecondary,
                fontSize: 14,
              )),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: FrostiqColors.cyan,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const QRScannerScreen(),
              ));
            },
          ),
        ],
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  final String deviceId;
  const DeviceCard({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref("devices/$deviceId").onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return loadingCard();
        }

        final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
        final metadata = Map<String, dynamic>.from(data['metadata'] ?? {});
        final telemetry = Map<String, dynamic>.from(data['telemetry'] ?? {});
        final status = Map<String, dynamic>.from(data['status'] ?? {});

        final name = metadata['name'] ?? 'Frostiq Device';
        final temp = (telemetry['temp'] ?? 0.0).toDouble();
        final doorOpen = telemetry['door_open'] ?? false;
        final power = (telemetry['power'] ?? 0.0).toDouble();
        final isOnline = isDeviceOnline(status['last_seen']);
        final hasAlert = telemetry['alarm'] ?? false;

        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => MainNavigation(
                deviceId: deviceId,
                deviceName: name,
              ),
            ));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FrostiqColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasAlert
                    ? FrostiqColors.red.withOpacity(0.5)
                    : FrostiqColors.border,
                width: hasAlert ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: FrostiqColors.cyan.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.kitchen,
                        color: FrostiqColors.cyan,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isOnline
                                      ? FrostiqColors.green
                                      : FrostiqColors.textMuted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isOnline ? 'Online' : 'Offline',
                                style: GoogleFonts.inter(
                                  color: isOnline
                                      ? FrostiqColors.green
                                      : FrostiqColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (hasAlert)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: FrostiqColors.red.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning,
                          color: FrostiqColors.red,
                          size: 16,
                        ),
                      ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: FrostiqColors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: FrostiqColors.border, height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    miniStat(
                      Icons.thermostat,
                      '${temp.toStringAsFixed(1)}°C',
                      'Temp',
                      temp > 8 ? FrostiqColors.red : FrostiqColors.cyan,
                    ),
                    miniStat(
                      doorOpen ? Icons.door_front_door : Icons.door_back_door,
                      doorOpen ? 'Open' : 'Closed',
                      'Door',
                      doorOpen ? FrostiqColors.orange : FrostiqColors.green,
                    ),
                    miniStat(
                      Icons.bolt,
                      '${power.toStringAsFixed(0)}W',
                      'Power',
                      FrostiqColors.cyan,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget miniStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            )),
        Text(label,
            style: GoogleFonts.inter(
              color: FrostiqColors.textMuted,
              fontSize: 11,
            )),
      ],
    );
  }

  Widget loadingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      height: 140,
      decoration: BoxDecoration(
        color: FrostiqColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FrostiqColors.border),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: FrostiqColors.cyan),
      ),
    );
  }

  bool isDeviceOnline(dynamic lastSeen) {
    if (lastSeen == null) return false;

    int? timestamp;

    if (lastSeen is int) {
      timestamp = lastSeen;
    } else if (lastSeen is String) {
      timestamp = int.tryParse(lastSeen);
    }

    if (timestamp == null) return false;

    final lastSeenTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final diff = DateTime.now().difference(lastSeenTime);
    return diff.inSeconds < 30;
  }
}