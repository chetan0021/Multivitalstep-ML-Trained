import 'package:flutter/material.dart';
import 'package:vital_step/Model/test.dart';

/// Structured result from a hand-comparison analysis.
class CompareResult {
  final double balanceScore;   // 0–100, where 100 = perfect symmetry
  final double percentDiff;    // % difference between hands
  final String weakerHand;     // "Left", "Right", or "None"
  final String strongerHand;
  final String severity;       // "Balanced", "Mild Imbalance", "Moderate Imbalance", "Significant Imbalance"
  final Color severityColor;
  final String headline;       // Short bold statement (e.g. "Right hand is 21% stronger")
  final String explanation;    // Plain-English explanation
  final List<String> recommendations;

  const CompareResult({
    required this.balanceScore,
    required this.percentDiff,
    required this.weakerHand,
    required this.strongerHand,
    required this.severity,
    required this.severityColor,
    required this.headline,
    required this.explanation,
    required this.recommendations,
  });
}

class AnalysisService {
  /// Analyzes a set of trials and returns an insight string.
  String analyzeTrials(Test test) {
    try {
      final t1 = double.parse(test.trial1);
      final t2 = double.parse(test.trial2);
      final t3 = double.parse(test.trial3);
      final avg = (t1 + t2 + t3) / 3;

      // Calculate variation
      final values = [t1, t2, t3];
      final maxVal = values.reduce((a, b) => a > b ? a : b);
      final minVal = values.reduce((a, b) => a < b ? a : b);
      final variation = (maxVal - minVal) / avg;

      String insight = "";

      if (variation > 0.2) {
        insight = "High variation detected between trials (${(variation * 100).toStringAsFixed(1)}%). Consider a re-test for more consistent data.";
      } else if (avg < 5) {
        insight = "Low grip strength measured. Regular exercise and follow-up are recommended.";
      } else {
        insight = "Strong and consistent effort detected across all trials. Keep it up!";
      }

      return insight;
    } catch (e) {
      return "Analysis unavailable: Invalid test data.";
    }
  }

  /// Returns a structured comparison result for Left vs Right hand.
  CompareResult compareHandsStructured(double leftAvg, double rightAvg, String dominantHand) {
    if (leftAvg == 0 && rightAvg == 0) {
      return const CompareResult(
        balanceScore: 0,
        percentDiff: 0,
        weakerHand: 'None',
        strongerHand: 'None',
        severity: 'No Data',
        severityColor: Color(0xFF9E9E9E),
        headline: 'Not enough data yet',
        explanation: 'Take tests with both hands to see your comparison.',
        recommendations: ['Test your Left hand', 'Test your Right hand'],
      );
    }

    if (leftAvg == 0) {
      return const CompareResult(
        balanceScore: 0,
        percentDiff: 100,
        weakerHand: 'Left',
        strongerHand: 'Right',
        severity: 'No Left Data',
        severityColor: Color(0xFFFF9800),
        headline: 'No Left hand data recorded',
        explanation: 'You have only tested your Right hand. Test your Left hand too to see how they compare.',
        recommendations: ['Take a Left hand test from the Assessments tab.'],
      );
    }

    if (rightAvg == 0) {
      return const CompareResult(
        balanceScore: 0,
        percentDiff: 100,
        weakerHand: 'Right',
        strongerHand: 'Left',
        severity: 'No Right Data',
        severityColor: Color(0xFFFF9800),
        headline: 'No Right hand data recorded',
        explanation: 'You have only tested your Left hand. Test your Right hand too to see how they compare.',
        recommendations: ['Take a Right hand test from the Assessments tab.'],
      );
    }

    final diff = (leftAvg - rightAvg).abs();
    final mid = (leftAvg + rightAvg) / 2;
    final percentDiff = (diff / mid) * 100;
    // Balance score: 100 = perfect, decreases with imbalance (floors at 0)
    final balanceScore = (100 - percentDiff).clamp(0.0, 100.0);

    final weakerHand = leftAvg < rightAvg ? 'Left' : 'Right';
    final strongerHand = leftAvg >= rightAvg ? 'Left' : 'Right';
    final weakerAvg = leftAvg < rightAvg ? leftAvg : rightAvg;
    final strongerAvg = leftAvg >= rightAvg ? leftAvg : rightAvg;

    String severity;
    Color severityColor;
    String headline;
    String explanation;
    final List<String> recs = [];

    if (percentDiff <= 10) {
      severity = 'Balanced ✓';
      severityColor = const Color(0xFF4CAF50);
      headline = 'Excellent hand balance!';
      explanation = 'Your hands differ by only ${percentDiff.toStringAsFixed(1)}%, which is within the healthy range (≤10%). Both hands are working well together.';
      recs.add('Keep up the consistent bilateral training.');
      recs.add('Continue monitoring weekly to maintain this balance.');
    } else if (percentDiff <= 20) {
      severity = 'Mild Imbalance';
      severityColor = const Color(0xFFFF9800);
      headline = '$strongerHand hand is ${percentDiff.toStringAsFixed(0)}% stronger';
      explanation = 'There is a mild difference of ${percentDiff.toStringAsFixed(1)}% between your hands. A difference up to 10% is normal; yours is slightly above that. This can often improve with targeted exercises.';
      recs.add('Add 2 extra sets of $weakerHand hand exercises per session.');
      recs.add('Avoid overloading the $strongerHand hand — let the $weakerHand hand catch up.');
      recs.add('Light grip exercises with a stress ball for the $weakerHand hand, 3× daily.');
    } else if (percentDiff <= 30) {
      severity = 'Moderate Imbalance';
      severityColor = const Color(0xFFFF5722);
      headline = '$weakerHand hand is notably weaker (${percentDiff.toStringAsFixed(0)}%)';
      explanation = 'Your $weakerHand hand (${weakerAvg.toStringAsFixed(1)} Kg) is ${percentDiff.toStringAsFixed(1)}% weaker than your $strongerHand hand (${strongerAvg.toStringAsFixed(1)} Kg). This level of imbalance may affect daily activities and should be addressed with a physiotherapist.';
      recs.add('Consult a physiotherapist for a targeted $weakerHand hand strengthening plan.');
      recs.add('Practice unilateral exercises focusing only on the $weakerHand hand.');
      recs.add('Wrist and forearm stretches daily — hold each stretch for 30 seconds.');
      recs.add('Re-test every 2 weeks to track improvement.');
    } else {
      severity = 'Significant Imbalance';
      severityColor = const Color(0xFFF44336);
      headline = 'Significant weakness in $weakerHand hand (${percentDiff.toStringAsFixed(0)}%)';
      explanation = 'Your $weakerHand hand (${weakerAvg.toStringAsFixed(1)} Kg) is ${percentDiff.toStringAsFixed(1)}% weaker than your $strongerHand hand (${strongerAvg.toStringAsFixed(1)} Kg). This is a significant difference that may indicate muscle weakness, injury, or nerve issues. Medical evaluation is recommended.';
      recs.add('See a doctor or physiotherapist — this level of imbalance needs professional assessment.');
      recs.add('Do not overcompensate with the $strongerHand hand to avoid overuse injury.');
      recs.add('Begin very gentle $weakerHand hand exercises only after professional clearance.');
      recs.add('Retest weekly and log your progress carefully.');
    }

    return CompareResult(
      balanceScore: balanceScore,
      percentDiff: percentDiff,
      weakerHand: weakerHand,
      strongerHand: strongerHand,
      severity: severity,
      severityColor: severityColor,
      headline: headline,
      explanation: explanation,
      recommendations: recs,
    );
  }

  /// Legacy simple string compare (still used by existing callers)
  String compareHands(double leftAvg, double rightAvg, String dominantHand) {
    return compareHandsStructured(leftAvg, rightAvg, dominantHand).headline;
  }

  /// Calculates the current health streak based on test dates.
  int calculateStreak(List<Test> tests) {
    if (tests.isEmpty) return 0;
    
    // Sort tests by date descending
    final sortedTests = List<Test>.from(tests)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    int streak = 0;
    DateTime lastDate = DateTime.now();
    
    for (var test in sortedTests) {
      final testDate = DateTime(test.createdAt.year, test.createdAt.month, test.createdAt.day);
      final compareDate = DateTime(lastDate.year, lastDate.month, lastDate.day);
      
      final difference = compareDate.difference(testDate).inDays;
      
      if (difference == 0) {
        if (streak == 0) streak = 1;
        continue;
      } else if (difference == 1) {
        streak++;
        lastDate = testDate;
      } else {
        break;
      }
    }
    
    return streak;
  }

  /// Generates a proactive health nudge based on recent trends.
  String getNudgeMessage(List<Test> tests) {
    if (tests.length < 5) return "Keep testing to get personalized health nudges!";
    
    final recent = tests.last;
    final previous = tests[tests.length - 2];
    
    final recentAvg = (double.parse(recent.trial1) + double.parse(recent.trial2) + double.parse(recent.trial3)) / 3;
    final prevAvg = (double.parse(previous.trial1) + double.parse(previous.trial2) + double.parse(previous.trial3)) / 3;
    
    if (recentAvg < prevAvg * 0.9) {
      return "Noticeable drop in strength detected. Consider a rest day or consult your specialist.";
    } else if (recentAvg > prevAvg * 1.1) {
      return "Great progress! Your strength is improving. Keep up the consistency!";
    }
    
    return "Your strength is stable. Consistency is key to long-term health.";
  }

  /// Provides AI-generated recovery tips based on test results.
  List<String> getRecoveryTips(Test test) {
    final t1 = double.parse(test.trial1);
    final t2 = double.parse(test.trial2);
    final t3 = double.parse(test.trial3);
    final avg = (t1 + t2 + t3) / 3;

    List<String> tips = [];

    if (avg < 20) {
      tips.add("Focus on light squeezing exercises using a soft ball.");
      tips.add("Heat therapy for 10 minutes before exercises may help flexibility.");
    } else if (avg < 40) {
      tips.add("Try rubber band finger extensions to balance your grip strength.");
      tips.add("Incorporate wrist curls using light weights (1-2 kg).");
    } else {
      tips.add("Maintain current strength with regular maintenance sessions.");
      tips.add("Consider advanced dexterity drills like 'piano finger' tapping.");
    }

    final variance = [t1, t2, t3].reduce((a, b) => a > b ? a : b) - [t1, t2, t3].reduce((a, b) => a < b ? a : b);
    if (variance > (avg * 0.2)) {
      tips.add("High trial variance detected. Focus on consistent, slow squeezes.");
    }

    return tips;
  }
}
