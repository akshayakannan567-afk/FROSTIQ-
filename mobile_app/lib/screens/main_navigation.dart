import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../services/alert_monitor.dart';
import 'home_tab.dart';
import 'history_tab.dart';
import 'alerts_tab.dart';
import 'settings_tab.dart';

class MainNavigation extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const MainNavigation({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;
  late AlertMonitor alertMonitor;

  @override
  void initState() {
    super.initState();
    alertMonitor = AlertMonitor(
      deviceId: widget.deviceId,
      deviceName: widget.deviceName,
    );
    alertMonitor.startMonitoring();
  }

  @override
  void dispose() {
    alertMonitor.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeTab(deviceId: widget.deviceId, deviceName: widget.deviceName),
      HistoryTab(deviceId: widget.deviceId),
      AlertsTab(deviceId: widget.deviceId),
      SettingsTab(deviceId: widget.deviceId, deviceName: widget.deviceName),
    ];

    return Scaffold(
      backgroundColor: FrostiqColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Go back to device list
                    },
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new,
                            color: FrostiqColors.textMuted, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Back to Devices',
                          style: GoogleFonts.inter(
                            color: FrostiqColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: tabs[selectedIndex],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: FrostiqColors.background,
          border: Border(top: BorderSide(color: FrostiqColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => setState(() => selectedIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: FrostiqColors.cyan,
          unselectedItemColor: FrostiqColors.textMuted,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Alerts'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}