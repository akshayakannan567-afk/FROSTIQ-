import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';

class PredictiveService {
  // Demo Data Model
  static List<Map<String, dynamic>> generate30DayDemoData({DateTime? until}) {
    final List<Map<String, dynamic>> data = [];
    final end = until ?? DateTime.now();
    final random = Random();

    for (int i = 0; i < 30; i++) {
      final date = end.subtract(Duration(days: 30 - i));
      // Simulate a degrading refrigerator: 
      // Temp starts at 4.0 and rises to 6.5
      // Power starts at 120W and rises to 180W
      double avgTemp = 4.0 + (i * 0.08) + (random.nextDouble() * 0.5);
      double avgPower = 120.0 + (i * 2.0) + (random.nextDouble() * 10);
      
      data.add({
        'timestamp': date.millisecondsSinceEpoch,
        'temp': avgTemp,
        'power': avgPower,
        'door_open_count': 5 + random.nextInt(5),
        'gas_avg': 200 + random.nextInt(100),
      });
    }
    return data;
  }

  /// Merges real historical data with demo data to ensure a full 30-day view.
  static List<Map<String, dynamic>> getHybridHistory(List<dynamic> realData) {
    if (realData.isEmpty) return generate30DayDemoData();

    // Sort real data by timestamp
    final List<Map<String, dynamic>> sortedReal = realData
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList()
      ..sort((a, b) => (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0));

    final firstRealTimestamp = sortedReal.first['timestamp'] as int;
    final firstRealDate = DateTime.fromMillisecondsSinceEpoch(firstRealTimestamp);
    
    final now = DateTime.now();
    final totalDaysCoveredByReal = now.difference(firstRealDate).inDays;

    if (totalDaysCoveredByReal >= 30) {
      return sortedReal;
    }

    // Generate demo data up until the first real data point
    final daysToFill = 30 - totalDaysCoveredByReal;
    final List<Map<String, dynamic>> demoToFill = [];
    final random = Random();

    for (int i = 0; i < daysToFill; i++) {
      final date = firstRealDate.subtract(Duration(days: daysToFill - i));
      
      // Keep it healthy in the past
      double avgTemp = 3.8 + (random.nextDouble() * 0.4);
      double avgPower = 115.0 + (random.nextDouble() * 8);

      demoToFill.add({
        'timestamp': date.millisecondsSinceEpoch,
        'temp': avgTemp,
        'power': avgPower,
        'door_open_count': 4 + random.nextInt(3),
        'gas_avg': 180 + random.nextInt(50),
      });
    }

    return [...demoToFill, ...sortedReal];
  }

  // Heuristic Analysis
  static Map<String, dynamic> analyzeHealth(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return {'score': 100, 'status': 'Healthy'};

    final start = data.first;
    final end = data.last;

    double tempIncrease = ((end['temp'] - start['temp']) / start['temp']) * 100;
    double powerIncrease = ((end['power'] - start['power']) / start['power']) * 100;
    
    // Average door activity
    double avgDoorOpenings = data.map((e) => e['door_open_count'] as int).reduce((a, b) => a + b) / data.length;
    double avgGas = data.map((e) => e['gas_avg'] as int).reduce((a, b) => a + b) / data.length;

    double healthScore = 100 - (tempIncrease + (powerIncrease / 2));
    if (avgDoorOpenings > 10) healthScore -= 5; // Excessive usage penalty
    healthScore = healthScore.clamp(0, 100);

    String recommendation = "System is performing within normal parameters.";
    String risk = "Low";

    if (healthScore < 85) {
      risk = "Moderate";
      recommendation = "Compressor efficiency is dropping. Consider cleaning the condenser coils.";
    }
    if (healthScore < 70) {
      risk = "High";
      recommendation = "Significant efficiency loss detected. Maintenance check recommended within 7 days.";
    }

    return {
      'score': healthScore.toInt(),
      'risk': risk,
      'recommendation': recommendation,
      'temp_trend': tempIncrease > 0 ? "Increasing" : "Stable",
      'power_trend': powerIncrease > 0 ? "Increasing" : "Stable",
      'avg_door_activity': avgDoorOpenings.toStringAsFixed(1),
      'avg_air_quality': avgGas.toStringAsFixed(0),
    };
  }

  // Google Gemini AI Integration
  static Future<String> getAILongTermReport(String apiKey, Map<String, dynamic> analysis) async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      
      final prompt = """
        ROLE: Act as a Master Refrigerator Service Technician with 20 years of experience.
        TASK: Provide a technical yet easy-to-understand health report for a consumer refrigerator based on the following diagnostic data.
        
        DIAGNOSTIC DATA:
        - System Health Score: ${analysis['score']}/100
        - Failure Risk Assessment: ${analysis['risk']}
        - Temperature Trend: ${analysis['temp_trend']} (Last 30 days)
        - Power Consumption: ${analysis['power_trend']} (Last 30 days)
        - Door Activity: ${analysis['avg_door_activity']} openings per day (average)
        - Internal Air Quality: ${analysis['avg_air_quality']} units (gas levels)
        
        INSTRUCTIONS:
        1. Explain what these trends mean for the appliance's lifespan.
        2. Identify the most likely culprit (e.g., dirty coils, failing seal, or compressor wear).
        3. Provide exactly two actionable steps: one for the user (DIY) and one for a professional.
        4. Keep the tone professional, reassuring, and concise.
      """;
      
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "Unable to generate AI report.";
    } catch (e) {
      return "AI analysis unavailable. ${analysis['recommendation']}";
    }
  }
}
