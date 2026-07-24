import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../widgets/shimmer_loading.dart';

class AlertsTab extends StatelessWidget {
  final String deviceId;
  const AlertsTab({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance
        .ref("devices/$deviceId/alerts")
        .orderByChild('timestamp')
        .limitToLast(50);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alerts',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  Text('Recent notifications',
                      style: GoogleFonts.inter(color: FrostiqColors.textMuted, fontSize: 14)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: FrostiqColors.textSecondary),
                onPressed: () => clearAllAlerts(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: ref.onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 4,
                  itemBuilder: (context, index) => buildShimmerAlertCard(),
                );
              }
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return emptyState();
              }
              
              final value = snapshot.data!.snapshot.value;
              final List<MapEntry<String, dynamic>> alerts = [];
              
              if (value is Map) {
                alerts.addAll(value.entries.map((e) => MapEntry(e.key.toString(), e.value)));
              } else if (value is List) {
                for (int i = 0; i < value.length; i++) {
                  if (value[i] != null) {
                    alerts.add(MapEntry(i.toString(), value[i]));
                  }
                }
              }

              alerts.sort((a, b) {
                final aData = a.value is Map ? Map<String, dynamic>.from(a.value as Map) : {};
                final bData = b.value is Map ? Map<String, dynamic>.from(b.value as Map) : {};
                final aTime = aData['timestamp'] ?? 0;
                final bTime = bData['timestamp'] ?? 0;
                return (bTime as int).compareTo(aTime as int);
              });

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alertData = alerts[index].value is Map 
                      ? Map<String, dynamic>.from(alerts[index].value as Map)
                      : <String, dynamic>{};
                  return alertCard(context, alerts[index].key, alertData);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget alertCard(BuildContext context, String alertId, Map<String, dynamic> data) {
    final title = data['title'] ?? 'Alert';
    final body = data['body'] ?? '';
    final type = data['type'] ?? 'info';
    final timestamp = data['timestamp'] ?? 0;

    Color typeColor;
    IconData typeIcon;
    switch (type) {
      case 'critical': typeColor = FrostiqColors.red; typeIcon = Icons.error; break;
      case 'warning': typeColor = FrostiqColors.orange; typeIcon = Icons.warning; break;
      default: typeColor = FrostiqColors.cyan; typeIcon = Icons.info;
    }

    return Dismissible(
      key: Key(alertId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: FrostiqColors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        FirebaseDatabase.instance.ref("devices/$deviceId/alerts/$alertId").remove();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: FrostiqColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: typeColor.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(typeIcon, color: typeColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(body, style: GoogleFonts.inter(color: FrostiqColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 10),
                  Text(_formatTime(timestamp),
                      style: GoogleFonts.inter(color: FrostiqColors.textMuted, fontSize: 12)),
                ],
              ),
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
          Icon(Icons.notifications_off_outlined, size: 80, color: FrostiqColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('No alerts yet',
              style: GoogleFonts.inter(color: FrostiqColors.textSecondary, fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('You\'ll see important notifications here',
              style: GoogleFonts.inter(color: FrostiqColors.textMuted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget buildShimmerAlertCard() {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: FrostiqColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: FrostiqColors.border.withValues(alpha: 0.6)),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 48, height: 48, radius: 14),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: double.infinity, height: 16, radius: 4),
                  SizedBox(height: 10),
                  ShimmerBox(width: 260, height: 14, radius: 4),
                  SizedBox(height: 14),
                  ShimmerBox(width: 90, height: 13, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int timestamp) {
    if (timestamp == 0) return 'Just now';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('MMM d, y • h:mm a').format(date);
  }

  void clearAllAlerts(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FrostiqColors.cardBackground,
        title: const Text('Clear All Alerts?', style: TextStyle(color: Colors.white)),
        content: const Text('This action cannot be undone.',
            style: TextStyle(color: FrostiqColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              FirebaseDatabase.instance.ref("devices/$deviceId/alerts").remove();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: FrostiqColors.red)),
          ),
        ],
      ),
    );
  }
}