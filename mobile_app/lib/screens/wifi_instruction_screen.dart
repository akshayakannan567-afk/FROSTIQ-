import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../theme/colors.dart';
import 'already_configured_screen.dart';
import 'name_device_screen.dart';

class WiFiInstructionScreen extends StatelessWidget {
  final String deviceId;

  const WiFiInstructionScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final hotspotName = "Frostiq_${deviceId.substring(8)}";

    return Scaffold(
      backgroundColor: FrostiqColors.background,
      appBar: AppBar(
        title: const Text('Connect to Device'),
        backgroundColor: FrostiqColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.wifi, size: 70, color: FrostiqColors.cyan),
            const SizedBox(height: 24),
            const Text(
              'Connect to your FrostIQ device',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'The device is now in setup mode.',
              style: TextStyle(color: FrostiqColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: FrostiqColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: FrostiqColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Steps:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _stepItem(1, 'Go to your phone\'s WiFi settings'),
                  const SizedBox(height: 12),
                  _stepItem(2, 'Connect to this network:'),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      hotspotName,
                      style: const TextStyle(
                        color: FrostiqColors.cyan,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _stepItem(3, 'Come back to this app'),
                ],
              ),
            ),

            const Spacer(),

            // Button 1: Set up the device
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Add actual WiFi setup logic here
                  // For now, just go to Name Device screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NameDeviceScreen(deviceId: deviceId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FrostiqColors.cyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'I want to set up this device',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Button 2: Device is already working
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () async {
                  // Add device to user's account in Firebase
                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  final db = FirebaseDatabase.instance;

                  await db.ref("users/$uid/devices/$deviceId").set(true);
                  await db.ref("devices/$deviceId/metadata").update({
                    'owner_uid': uid,
                    'claimed_at': ServerValue.timestamp,
                  });

                  // Navigate to Already Configured screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AlreadyConfiguredScreen(deviceId: deviceId),
                    ),
                        (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: FrostiqColors.textMuted,
                  side: BorderSide(color: FrostiqColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'This device is already working',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: FrostiqColors.textMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepItem(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: FrostiqColors.cyan,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ],
    );
  }
}