import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'notification_service.dart';

class AlertMonitor {
  final String deviceId;
  final String deviceName;
  StreamSubscription? subscription;

  bool lastDoorOpen = false;
  bool lastTempAlert = false;
  bool lastGasAlert = false;
  bool lastPowerAlert = false;

  AlertMonitor({required this.deviceId, required this.deviceName});

  void startMonitoring() {
    final ref = FirebaseDatabase.instance.ref("devices/$deviceId/telemetry");

    subscription = ref.onValue.listen((event) {
      if (event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final double temp = (data['temp'] ?? 0.0).toDouble();
      final int gas = (data['gas'] ?? 0).toInt();
      final bool doorAlarm = data['alarm'] ?? false;
      final double power = (data['power'] ?? 0.0).toDouble();

      if (doorAlarm && !lastDoorOpen) {
        sendAlert(
          title: '🚪 Door Left Open!',
          body: '$deviceName door has been open for 30+ seconds. Please close it.',
          type: AlertType.critical,
        );
        lastDoorOpen = true;
      } else if (!doorAlarm) {
        lastDoorOpen = false;
      }

      if (temp > 10 && !lastTempAlert) {
        sendAlert(
          title: '🌡️ High Temperature!',
          body: '$deviceName temperature reached ${temp.toStringAsFixed(1)}°C. Food may spoil!',
          type: AlertType.critical,
        );
        lastTempAlert = true;
      } else if (temp <= 8) {
        lastTempAlert = false;
      }

      if (gas > 700 && !lastGasAlert) {
        sendAlert(
          title: '⚠️ Poor Air Quality!',
          body: '$deviceName detected high gas levels. Check for spoiled food.',
          type: AlertType.warning,
        );
        lastGasAlert = true;
      } else if (gas <= 500) {
        lastGasAlert = false;
      }

      if (power > 300 && !lastPowerAlert) {
        sendAlert(
          title: '⚡ High Power Usage!',
          body: '$deviceName is using ${power.toStringAsFixed(0)}W. Check compressor.',
          type: AlertType.warning,
        );
        lastPowerAlert = true;
      } else if (power <= 250) {
        lastPowerAlert = false;
      }
    });
  }

  Future<void> sendAlert({
    required String title,
    required String body,
    required AlertType type,
  }) async {
    await NotificationService.showNotification(
      title: title,
      body: body,
      type: type,
    );

    final alertsRef = FirebaseDatabase.instance
        .ref("devices/$deviceId/alerts")
        .push();

    await alertsRef.set({
      'title': title,
      'body': body,
      'type': type.name,
      'timestamp': ServerValue.timestamp,
      'read': false,
    });
  }

  void stopMonitoring() {
    subscription?.cancel();
  }
}