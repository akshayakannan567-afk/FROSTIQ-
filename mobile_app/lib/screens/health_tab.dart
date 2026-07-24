import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import '../theme/colors.dart';
import '../services/predictive_service.dart';

class HealthTab extends StatefulWidget {
  final String deviceId;
  const HealthTab({super.key, required this.deviceId});

  @override
  State<HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends State<HealthTab> {
  Map<String, dynamic>? analysis;
  bool isAnalyzing = false;
  bool isFetchingData = true;
  String aiReport = "";

  @override
  void initState() {
    super.initState();
    _fetchAndAnalyze();
  }

  Future<void> _fetchAndAnalyze() async {
    setState(() => isFetchingData = true);
    
    try {
      final ref = FirebaseDatabase.instance.ref("devices/${widget.deviceId}/history");
      final snapshot = await ref.orderByKey().limitToLast(100).get();
      
      final List<dynamic> realData = [];
      if (snapshot.exists && snapshot.value != null) {
        final rawData = Map<String, dynamic>.from(snapshot.value as Map);
        realData.addAll(rawData.values);
      }

      // Stitch real data with demo data for a full 30-day view
      final hybridData = PredictiveService.getHybridHistory(realData);
      
      setState(() {
        analysis = PredictiveService.analyzeHealth(hybridData);
        isFetchingData = false;
      });
    } catch (e) {
      // Fallback to pure demo if something goes wrong
      final demoData = PredictiveService.generate30DayDemoData();
      setState(() {
        analysis = PredictiveService.analyzeHealth(demoData);
        isFetchingData = false;
      });
    }
  }

  Future<void> _generateAIReport() async {
    if (analysis == null) return;
    
    setState(() {
      isAnalyzing = true;
    });
    
    // Standard Gemini API Key starts with AIza...
    const String geminiKey = "AIzaSyD-TEST-KEY-PLEASE-REPLACE";
    
    final report = await PredictiveService.getAILongTermReport(geminiKey, analysis!);
    
    setState(() {
      aiReport = report;
      isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isFetchingData || analysis == null) {
      return const Center(child: CircularProgressIndicator(color: FrostiqColors.cyan));
    }

    final score = analysis!['score'] as int;
    final color = score > 85 ? FrostiqColors.green : (score > 70 ? FrostiqColors.orange : FrostiqColors.red);

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
                  Text('AI Health',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  Text('Predictive failure analysis',
                      style: GoogleFonts.inter(color: FrostiqColors.textMuted, fontSize: 14)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: FrostiqColors.textSecondary, size: 20),
                onPressed: _fetchAndAnalyze,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Health Score Gauge
          Center(
            child: Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: FrostiqColors.border, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 12,
                      backgroundColor: FrostiqColors.cardBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$score%', 
                        style: GoogleFonts.inter(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('HEALTHY', 
                        style: GoogleFonts.inter(fontSize: 12, letterSpacing: 1.5, color: FrostiqColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Risk Card
          _infoCard(
            title: 'Failure Risk',
            value: analysis!['risk'],
            icon: Icons.warning_amber_rounded,
            color: color,
          ),
          const SizedBox(height: 16),

          // Recommendation Card
          _infoCard(
            title: 'AI Recommendation',
            value: analysis!['recommendation'],
            icon: Icons.auto_awesome,
            color: FrostiqColors.cyan,
          ),
          const SizedBox(height: 32),

          // Gemini Report Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FrostiqColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: FrostiqColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: FrostiqColors.cyan),
                    const SizedBox(width: 10),
                    Text('Gemini AI Report', 
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                if (aiReport.isEmpty)
                  Text('Get a detailed analysis generated by Google Gemini AI.', 
                    style: GoogleFonts.inter(color: FrostiqColors.textSecondary, fontSize: 14))
                else
                  Text(aiReport, 
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14, height: 1.5)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isAnalyzing ? null : _generateAIReport,
                    icon: isAnalyzing 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.bolt),
                    label: Text(isAnalyzing ? 'Analyzing...' : 'Generate AI Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FrostiqColors.cyan,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _infoCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FrostiqColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FrostiqColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: FrostiqColors.textMuted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
