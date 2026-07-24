import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AlreadyConfiguredScreen extends StatelessWidget {
  final String deviceId;

  const AlreadyConfiguredScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FrostiqColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: FrostiqColors.green,
              ),
              const SizedBox(height: 24),
              Text(
                'Device Already Configured',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'This FrostIQ device is already connected to a WiFi network and is online.',
                style: GoogleFonts.inter(
                  color: FrostiqColors.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FrostiqColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: FrostiqColors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      'Device ID',
                      style: GoogleFonts.inter(
                        color: FrostiqColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deviceId,
                      style: GoogleFonts.inter(
                        color: FrostiqColors.cyan,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FrostiqColors.cyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}