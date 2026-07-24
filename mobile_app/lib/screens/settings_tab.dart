import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/shimmer_loading.dart';

class SettingsTab extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const SettingsTab({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<SettingsTab> createState() => SettingsTabState();
}

class SettingsTabState extends State<SettingsTab> {
  bool notificationsEnabled = true;
  bool doorAlertEnabled = true;
  bool tempAlertEnabled = true;
  bool powerAlertEnabled = true;
  double tempThreshold = 8.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading (like YouTube)
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          Text('Manage your Frostiq device',
              style: GoogleFonts.inter(color: FrostiqColors.textMuted, fontSize: 14)),
          const SizedBox(height: 24),
          sectionTitle('DEVICE'),
          if (isLoading)
            buildShimmerSettingsSection(3)
          else
            card(children: [
              infoRow(Icons.kitchen, 'Name', widget.deviceName, onTap: renameDevice),
              divider(),
              infoRow(Icons.qr_code, 'Device ID', '${widget.deviceId.substring(0, 8)}...'),
              divider(),
              infoRow(Icons.wifi, 'WiFi', 'Connected'),
            ]),
          const SizedBox(height: 24),
          sectionTitle('NOTIFICATIONS'),
          if (isLoading)
            buildShimmerSettingsSection(4)
          else
            card(children: [
              switchRow('Enable Notifications', notificationsEnabled, (v) => setState(() => notificationsEnabled = v)),
              divider(),
              switchRow('Door Alerts', doorAlertEnabled, (v) => setState(() => doorAlertEnabled = v)),
              divider(),
              switchRow('Temperature Alerts', tempAlertEnabled, (v) => setState(() => tempAlertEnabled = v)),
              divider(),
              switchRow('Power Alerts', powerAlertEnabled, (v) => setState(() => powerAlertEnabled = v)),
            ]),
          const SizedBox(height: 24),
          sectionTitle('ALERT THRESHOLDS'),
          if (isLoading)
            buildShimmerSliderSection()
          else
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Max Temperature', style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
                      Text('${tempThreshold.toStringAsFixed(1)}°C',
                          style: GoogleFonts.inter(color: FrostiqColors.cyan, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: tempThreshold,
                    min: 4,
                    max: 15,
                    divisions: 22,
                    activeColor: FrostiqColors.cyan,
                    inactiveColor: FrostiqColors.border,
                    onChanged: (v) => setState(() => tempThreshold = v),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          sectionTitle('DANGER ZONE'),
          if (isLoading)
            buildShimmerSettingsSection(2)
          else
            card(children: [
              actionRow(Icons.refresh, 'Reset Device WiFi', color: FrostiqColors.orange, onTap: resetWifi),
              divider(),
              actionRow(Icons.delete, 'Remove Device', color: FrostiqColors.red, onTap: removeDevice),
            ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: FrostiqColors.textSecondary,
                side: const BorderSide(color: FrostiqColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => _showSignOutConfirmation(context),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('FrostIQ v1.0.0',
                style: GoogleFonts.inter(color: FrostiqColors.textMuted, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(text,
        style: GoogleFonts.inter(
          color: FrostiqColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        )),
  );

  Widget card({required List<Widget> children}) => Material(
    color: FrostiqColors.cardBackground,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: FrostiqColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    ),
  );

  Widget divider() => const Divider(color: FrostiqColors.border, height: 1);

  Widget infoRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: FrostiqColors.cyan, size: 20),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 15))),
            Text(value, style: GoogleFonts.inter(color: FrostiqColors.textSecondary, fontSize: 14)),
            if (onTap != null) const Icon(Icons.chevron_right, color: FrostiqColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: SwitchListTile(
          title: Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
          value: value,
          onChanged: onChanged,
          activeThumbColor: FrostiqColors.cyan,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget actionRow(IconData icon, String label, {VoidCallback? onTap, Color color = Colors.white}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: GoogleFonts.inter(color: color, fontSize: 14))),
            Icon(Icons.chevron_right, color: color.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }

  void renameDevice() {
    final controller = TextEditingController(text: widget.deviceName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FrostiqColors.cardBackground,
        title: const Text('Rename Device', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Device name',
            hintStyle: TextStyle(color: FrostiqColors.textMuted),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await FirebaseDatabase.instance
                  .ref("devices/${widget.deviceId}/metadata/name")
                  .set(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: FrostiqColors.cyan)),
          ),
        ],
      ),
    );
  }

  void resetWifi() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FrostiqColors.cardBackground,
        title: const Text('Reset WiFi?', style: TextStyle(color: Colors.white)),
        content: const Text('The device will go into setup mode. You will need to reconfigure the WiFi.',
            style: TextStyle(color: FrostiqColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await FirebaseDatabase.instance
                  .ref("devices/${widget.deviceId}/commands/reset_wifi")
                  .set(true);
              Navigator.pop(context);
            },
            child: const Text('Reset', style: TextStyle(color: FrostiqColors.orange)),
          ),
        ],
      ),
    );
  }

  void removeDevice() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FrostiqColors.cardBackground,
        title: const Text('Remove Device?', style: TextStyle(color: Colors.white)),
        content: const Text('This will unlink the device from your account. You can add it back anytime by scanning the QR code.',
            style: TextStyle(color: FrostiqColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser!.uid;
              await FirebaseDatabase.instance
                  .ref("users/$uid/devices/${widget.deviceId}")
                  .remove();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Remove', style: TextStyle(color: FrostiqColors.red)),
          ),
        ],
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context) {
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

  // Shimmer helpers
  Widget buildShimmerSettingsSection(int rows) {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        decoration: BoxDecoration(
          color: FrostiqColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: FrostiqColors.border),
        ),
        child: Column(
          children: List.generate(rows, (index) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Row(
                children: [
                  ShimmerBox(width: 20, height: 20, radius: 4),
                  SizedBox(width: 16),
                  Expanded(child: ShimmerBox(width: double.infinity, height: 16, radius: 4)),
                  SizedBox(width: 12),
                  ShimmerBox(width: 80, height: 16, radius: 4),
                ],
              ),
            );
          }).expand((widget) => [
            widget,
            if (widget != List.generate(rows, (index) => widget).last)
              const Divider(color: FrostiqColors.border, height: 1),
          ]).toList(),
        ),
      ),
    );
  }

  Widget buildShimmerSliderSection() {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FrostiqColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FrostiqColors.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 130, height: 14, radius: 4),
                ShimmerBox(width: 65, height: 14, radius: 4),
              ],
            ),
            SizedBox(height: 18),
            ShimmerBox(width: double.infinity, height: 8, radius: 4),
          ],
        ),
      ),
    );
  }
}