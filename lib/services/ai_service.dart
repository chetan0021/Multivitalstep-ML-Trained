import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:vital_step/app/app.logger.dart';

/// Result returned by the ML prediction model.
class MlPrediction {
  final double average;
  final String predictedCategory;
  final double confidence;
  final double percentile;
  final List<String> recommendations;
  final double? expectedLowerKg;
  final double? expectedMedianKg;
  final double? expectedUpperKg;
  final String modelSource;

  const MlPrediction({
    required this.average,
    required this.predictedCategory,
    required this.confidence,
    required this.percentile,
    required this.recommendations,
    this.expectedLowerKg,
    this.expectedMedianKg,
    this.expectedUpperKg,
    this.modelSource = '',
  });

  factory MlPrediction.fromJson(Map<String, dynamic> json) {
    return MlPrediction(
      average: (json['average'] as num?)?.toDouble() ?? 0.0,
      predictedCategory: json['predicted_category'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      percentile: (json['percentile'] as num?)?.toDouble() ?? 0.0,
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      expectedLowerKg: (json['expected_lower_kg'] as num?)?.toDouble(),
      expectedMedianKg: (json['expected_median_kg'] as num?)?.toDouble(),
      expectedUpperKg: (json['expected_upper_kg'] as num?)?.toDouble(),
      modelSource: json['model_source'] as String? ?? '',
    );
  }
}

/// Full AI insight combining ML prediction + Groq LLM narrative.
class AiInsight {
  final MlPrediction mlPrediction;
  final String groqNarrative;
  final List<String> recommendations;

  const AiInsight({
    required this.mlPrediction,
    required this.groqNarrative,
    required this.recommendations,
  });
}

/// Service that:
///  1. Calls the VitalStep ML model on Render — sends all available patient
///     fields (age, gender, dominant_hand, palm measurements) for best accuracy.
///  2. Feeds ML output into Groq to generate a friendly patient-facing narrative.
///  3. Caches results by data fingerprint — Groq is only called when the
///     underlying data actually changes, saving tokens.
class AiService {
  final _logger = getLogger('AiService');
  final _box = GetStorage();

  // ── Cache keys ────────────────────────────────────────────────────────────
  static const _kTestInsightText = 'ai_cache_test_insight_text';
  static const _kTestInsightHash = 'ai_cache_test_insight_hash';
  static const _kHomeInsightText = 'ai_cache_home_insight_text';
  static const _kHomeInsightHash = 'ai_cache_home_insight_hash';
  static const _kCompareInsightText = 'ai_cache_compare_insight_text';
  static const _kCompareInsightHash = 'ai_cache_compare_insight_hash';

  static const String _mlBaseUrl = 'https://vitalstep.onrender.com/api/v1/ml';
  static const String _groqUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _groqApiKey =
      String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
  static const String _groqModel = 'llama-3.3-70b-versatile';

  // ─────────────────────────────────────────────────────────────────────────
  // PUBLIC API
  // ─────────────────────────────────────────────────────────────────────────

  Future<AiInsight?> getTestInsight({
    required double trial1,
    required double trial2,
    required double trial3,
    required String hand,
    required String posture,
    int? age,
    int? weight,
    int? height,
    String? gender,
    String? dominantHand,
    double? palmLength,
    double? palmWidth,
    double? knuckleLength,
    String? condition,
  }) async {
    try {
      // Include all patient-specific fields in fingerprint so different patients
      // with same trial values still get their own correct ML recommendations
      final hash = _fingerprint([
        trial1.toStringAsFixed(2),
        trial2.toStringAsFixed(2),
        trial3.toStringAsFixed(2),
        hand,
        posture,
        age?.toString() ?? '',
        gender ?? '',
        dominantHand ?? '',
        condition ?? '',
      ]);

      // Cache hit — reuse Groq narrative, still call ML for fresh recommendations
      if (_cacheHit(_kTestInsightHash, hash)) {
        final cached = _cachedText(_kTestInsightText);
        if (cached != null && cached.isNotEmpty) {
          _logger.i('Test insight: cache hit');
          final ml = await _callMlPredict(
            trial1: trial1,
            trial2: trial2,
            trial3: trial3,
            hand: hand,
            posture: posture,
            age: age,
            weight: weight,
            height: height,
            gender: gender,
            dominantHand: dominantHand,
            palmLength: palmLength,
            palmWidth: palmWidth,
            knuckleLength: knuckleLength,
          );
          if (ml == null) return null;
          return AiInsight(
            mlPrediction: ml,
            groqNarrative: cached,
            recommendations: ml.recommendations,
          );
        }
      }

      final ml = await _callMlPredict(
        trial1: trial1,
        trial2: trial2,
        trial3: trial3,
        hand: hand,
        posture: posture,
        age: age,
        weight: weight,
        height: height,
        gender: gender,
        dominantHand: dominantHand,
        palmLength: palmLength,
        palmWidth: palmWidth,
        knuckleLength: knuckleLength,
      );
      if (ml == null) return null;

      final bmi = _calcBmi(weight, height);
      final narrative = await _callGroqForTestInsight(
        ml: ml,
        hand: hand,
        posture: posture,
        age: age,
        bmi: bmi,
        condition: condition,
      );

      if (narrative.isNotEmpty) {
        _writeCache(_kTestInsightHash, _kTestInsightText, hash, narrative);
      }

      return AiInsight(
        mlPrediction: ml,
        groqNarrative: narrative,
        recommendations: ml.recommendations,
      );
    } catch (e) {
      _logger.e('getTestInsight failed: $e');
      return null;
    }
  }

  Future<AiInsight?> getCompareInsight({
    required double leftAvg,
    required double rightAvg,
    required String dominantHand,
    int? age,
    int? weight,
    int? height,
    String? condition,
  }) async {
    try {
      final hash = _fingerprint([
        leftAvg.toStringAsFixed(2),
        rightAvg.toStringAsFixed(2),
        dominantHand,
        age?.toString() ?? '',
        condition ?? '',
      ]);

      final primaryAvg = dominantHand == 'Left' ? leftAvg : rightAvg;

      if (_cacheHit(_kCompareInsightHash, hash)) {
        final cached = _cachedText(_kCompareInsightText);
        if (cached != null && cached.isNotEmpty) {
          _logger.i('Compare insight: cache hit');
          final ml = await _callMlPredict(
            trial1: primaryAvg,
            trial2: primaryAvg,
            trial3: primaryAvg,
            hand: dominantHand,
            posture: 'standing',
            age: age,
            weight: weight,
            height: height,
          );
          if (ml == null) return null;
          return AiInsight(
            mlPrediction: ml,
            groqNarrative: cached,
            recommendations: ml.recommendations,
          );
        }
      }

      final ml = await _callMlPredict(
        trial1: primaryAvg,
        trial2: primaryAvg,
        trial3: primaryAvg,
        hand: dominantHand,
        posture: 'standing',
        age: age,
        weight: weight,
        height: height,
      );
      if (ml == null) return null;

      final bmi = _calcBmi(weight, height);
      final narrative = await _callGroqForCompareInsight(
        ml: ml,
        leftAvg: leftAvg,
        rightAvg: rightAvg,
        dominantHand: dominantHand,
        age: age,
        bmi: bmi,
        condition: condition,
      );

      if (narrative.isNotEmpty) {
        _writeCache(
            _kCompareInsightHash, _kCompareInsightText, hash, narrative);
      }

      return AiInsight(
        mlPrediction: ml,
        groqNarrative: narrative,
        recommendations: ml.recommendations,
      );
    } catch (e) {
      _logger.e('getCompareInsight failed: $e');
      return null;
    }
  }

  Future<String?> getHomeInsight({
    required double latestAvg,
    required double previousAvg,
    required String hand,
    int? age,
    int? weight,
    int? height,
    String? condition,
  }) async {
    try {
      final hash = _fingerprint([
        latestAvg.toStringAsFixed(2),
        previousAvg.toStringAsFixed(2),
        hand,
        condition ?? '',
      ]);

      if (_cacheHit(_kHomeInsightHash, hash)) {
        final cached = _cachedText(_kHomeInsightText);
        if (cached != null && cached.isNotEmpty) {
          _logger.i('Home insight: cache hit');
          return cached;
        }
      }

      final ml = await _callMlPredict(
        trial1: latestAvg,
        trial2: latestAvg,
        trial3: latestAvg,
        hand: hand,
        posture: 'sitting',
        age: age,
        weight: weight,
        height: height,
      );
      if (ml == null) return null;

      final bmi = _calcBmi(weight, height);
      final result = await _callGroqForHomeInsight(
        ml: ml,
        latestAvg: latestAvg,
        previousAvg: previousAvg,
        age: age,
        bmi: bmi,
        condition: condition,
      );

      if (result.isNotEmpty) {
        _writeCache(_kHomeInsightHash, _kHomeInsightText, hash, result);
      }

      return result.isNotEmpty ? result : null;
    } catch (e) {
      _logger.e('getHomeInsight failed: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CACHE HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  String _fingerprint(List<dynamic> values) =>
      values.map((v) => v.toString()).join('|');

  bool _cacheHit(String hashKey, String currentHash) {
    final stored = _box.read<String>(hashKey);
    return stored != null && stored == currentHash;
  }

  String? _cachedText(String textKey) => _box.read<String>(textKey);

  void _writeCache(String hashKey, String textKey, String hash, String text) {
    _box.write(hashKey, hash);
    _box.write(textKey, text);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ML PREDICT — sends all available patient fields for best accuracy
  // ─────────────────────────────────────────────────────────────────────────

  Future<MlPrediction?> _callMlPredict({
    required double trial1,
    required double trial2,
    required double trial3,
    required String hand,
    required String posture,
    int? age,
    int? weight,
    int? height,
    String? gender,
    String? dominantHand,
    double? palmLength,
    double? palmWidth,
    double? knuckleLength,
  }) async {
    try {
      final payload = <String, dynamic>{
        'trial1': trial1,
        'trial2': trial2,
        'trial3': trial3,
        'hand': hand.toLowerCase(),
        'posture': posture,
        if (age != null) 'age': age,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
        if (weight != null && height != null)
          'bmi': _calcBmi(weight, height) ?? 0,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (dominantHand != null && dominantHand.isNotEmpty)
          'dominant_hand': dominantHand.toLowerCase(),
        if (palmLength != null) 'palm_length': palmLength,
        if (palmWidth != null) 'palm_width': palmWidth,
        if (knuckleLength != null) 'knuckle_length': knuckleLength,
      };

      _logger.i('Calling ML predict: $payload');

      final response = await http
          .post(
            Uri.parse('$_mlBaseUrl/predict'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _logger.i('ML response: $json');
        return MlPrediction.fromJson(json);
      } else {
        _logger.w('ML predict ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.e('ML predict failed: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GROQ
  // ─────────────────────────────────────────────────────────────────────────

  Future<String> _callGroq(String prompt) async {
    try {
      final response = await http
          .post(
            Uri.parse(_groqUrl),
            headers: {
              'Authorization': 'Bearer $_groqApiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _groqModel,
              'messages': [
                {
                  'role': 'system',
                  'content': 'You are a friendly health assistant for a palm pressure measurement app. '
                      'Speak directly to the patient in simple, warm, everyday language. '
                      'Never use technical terms like "ML model", "percentile", '
                      '"confidence score", "bilateral", "clinical", or any medical jargon. '
                      'Do NOT give nutrition or diet advice. '
                      'Focus only on movement, exercise, rest and daily habits. '
                      'Be encouraging, brief, and clear. Write like a supportive coach.',
                },
                {'role': 'user', 'content': prompt},
              ],
              'max_tokens': 200,
              'temperature': 0.4,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            json['choices']?[0]?['message']?['content'] as String? ?? '';
        _logger.i('Groq: $content');
        return content.trim();
      } else {
        _logger.w('Groq ${response.statusCode}: ${response.body}');
        return '';
      }
    } catch (e) {
      _logger.e('Groq failed: $e');
      return '';
    }
  }

  Future<String> _callGroqForTestInsight({
    required MlPrediction ml,
    required String hand,
    required String posture,
    int? age,
    double? bmi,
    String? condition,
  }) async {
    final ageStr = age != null ? 'The patient is $age years old.' : '';
    final conditionStr = (condition != null && condition != 'None')
        ? 'They have: $condition.'
        : '';
    final avgKg = ml.average.toStringAsFixed(1);
    final level = ml.predictedCategory.toLowerCase();

    final prompt =
        'A patient just tested their $hand hand palm pressure while $posture. '
        'Their average pressure was $avgKg kg, which is considered $level. '
        '$ageStr $conditionStr '
        'Write 2 friendly sentences telling them what this result means and one simple tip. '
        'No jargon, no technical terms, speak directly to them as "you".';

    final result = await _callGroq(prompt);
    return result.isNotEmpty ? result : _fallbackTestInsight(ml);
  }

  Future<String> _callGroqForCompareInsight({
    required MlPrediction ml,
    required double leftAvg,
    required double rightAvg,
    required String dominantHand,
    int? age,
    double? bmi,
    String? condition,
  }) async {
    final diff = (leftAvg - rightAvg).abs();
    final mid = (leftAvg + rightAvg) / 2;
    final percentDiff = mid > 0 ? ((diff / mid) * 100) : 0.0;
    final weakerHand = leftAvg < rightAvg ? 'left' : 'right';
    final conditionStr = (condition != null && condition != 'None')
        ? 'They have: $condition.'
        : '';
    final ageStr = age != null ? 'The patient is $age years old.' : '';

    final prompt = 'A patient compared their two hands. '
        'Left hand: ${leftAvg.toStringAsFixed(1)} kg, Right hand: ${rightAvg.toStringAsFixed(1)} kg. '
        'Their dominant hand is the $dominantHand hand. '
        'The difference is about ${percentDiff.toStringAsFixed(0)}%. '
        '$ageStr $conditionStr '
        'Write 2-3 friendly sentences explaining what this means. '
        'If there is a clear difference, gently suggest they work on their $weakerHand hand. '
        'Keep it simple and encouraging, speak as "you".';

    final result = await _callGroq(prompt);
    return result.isNotEmpty
        ? result
        : _fallbackCompareInsight(leftAvg, rightAvg);
  }

  Future<String> _callGroqForHomeInsight({
    required MlPrediction ml,
    required double latestAvg,
    required double previousAvg,
    int? age,
    double? bmi,
    String? condition,
  }) async {
    final trend = latestAvg > previousAvg * 1.05
        ? 'gotten stronger'
        : latestAvg < previousAvg * 0.95
            ? 'dropped a little'
            : 'stayed steady';
    final conditionStr = (condition != null && condition != 'None')
        ? 'They have: $condition.'
        : '';
    final ageStr = age != null ? 'The patient is $age years old.' : '';

    final prompt = "A patient's palm pressure has $trend recently. "
        'Their latest reading is ${latestAvg.toStringAsFixed(1)} kg, '
        'previous was ${previousAvg.toStringAsFixed(1)} kg. '
        'Their current level is ${ml.predictedCategory.toLowerCase()}. '
        '$ageStr $conditionStr '
        'Write one short, warm sentence (under 20 words) for their home screen. '
        'No jargon. Be encouraging. Speak as "your".';

    final result = await _callGroq(prompt);
    return result.isNotEmpty ? result : _fallbackHomeInsight(ml, trend);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FALLBACKS
  // ─────────────────────────────────────────────────────────────────────────

  String _fallbackTestInsight(MlPrediction ml) {
    final level = ml.predictedCategory.toLowerCase();
    final tip = ml.recommendations.isNotEmpty
        ? ml.recommendations.first
        : 'Keep up your regular exercises!';
    return 'Your palm pressure at ${ml.average.toStringAsFixed(1)} kg is $level. $tip';
  }

  String _fallbackCompareInsight(double leftAvg, double rightAvg) {
    final diff = (leftAvg - rightAvg).abs();
    final mid = (leftAvg + rightAvg) / 2;
    final pct = mid > 0 ? ((diff / mid) * 100) : 0.0;
    if (pct <= 10)
      return 'Great — your two hands are very close in strength. Keep it up!';
    final weaker = leftAvg < rightAvg ? 'left' : 'right';
    return 'Your $weaker hand is a bit weaker right now. Try giving it some extra attention in your exercises.';
  }

  String _fallbackHomeInsight(MlPrediction ml, String trend) {
    return 'Your palm pressure has $trend — currently at ${ml.average.toStringAsFixed(1)} kg. Keep going!';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  double? _calcBmi(int? weight, int? height) {
    if (weight == null || height == null || height <= 0) return null;
    final h = height / 100.0;
    return weight / (h * h);
  }
}
