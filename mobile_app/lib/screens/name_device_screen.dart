import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/colors.dart';
import 'main_navigation.dart';

class NameDeviceScreen extends StatefulWidget {
  final String deviceId;
  const NameDeviceScreen({super.key, required this.deviceId});

  @override
  State<NameDeviceScreen> createState() => NameDeviceScreenState();
}

class NameDeviceScreenState extends State<NameDeviceScreen> {
  final nameController = TextEditingController();
  bool isSaving = false;

  final List<String> suggestions = [
    'Kitchen Fridge',
    'Garage Cooler',
    'Office Fridge',
    'Bedroom Mini Fridge',
    'Basement Freezer',
  ];

  Future<void> saveDevice() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give your Frostiq a name')),
      );
      return;
    }

    setState(() => isSaving = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseDatabase.instance;
    final deviceName = nameController.text.trim();

    await db.ref("users/$uid/devices/${widget.deviceId}").set(true);
    await db.ref("devices/${widget.deviceId}/metadata").set({
      'name': deviceName,
      'owner_uid': uid,
      'model': 'Frostiq-V1',
      'claimed_at': ServerValue.timestamp,
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainNavigation(deviceId: widget.deviceId, deviceName: deviceName),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FrostiqColors.background,
      appBar: AppBar(
        title: const Text('Name Your Frostiq'),
        backgroundColor: FrostiqColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: FrostiqColors.green, size: 60),
            const SizedBox(height: 16),
            const Text('Device Connected!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const Text('Give your Frostiq a name so you can identify it later.',
                style: TextStyle(color: FrostiqColors.textSecondary)),
            const SizedBox(height: 32),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Device Name (e.g. Kitchen Fridge)',
                labelStyle: const TextStyle(color: FrostiqColors.textMuted),
                prefixIcon: const Icon(Icons.kitchen, color: FrostiqColors.cyan),
                filled: true,
                fillColor: FrostiqColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Suggestions:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: suggestions.map((name) => ActionChip(
                label: Text(name),
                backgroundColor: FrostiqColors.cardBackground,
                labelStyle: const TextStyle(color: FrostiqColors.textSecondary),
                onPressed: () => setState(() => nameController.text = name),
              )).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: isSaving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: const Text('Start Monitoring', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FrostiqColors.cyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isSaving ? null : saveDevice,
              ),
            ),
          ],
        ),
      ),
    );
  }
}