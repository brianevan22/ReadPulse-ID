import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:readpulse_id/features/models/reading_response.dart';
import 'package:readpulse_id/features/models/reading_result.dart';

class AiService {
  // Untuk Flutter Web di laptop yang sama:
  static const String _baseUrl = 'http://127.0.0.1:5000';
  // Kalau bermasalah, bisa coba 'http://localhost:5000'

  Future<ReadingResult> predictReadingInterest(ReadingResponse response) async {
    final url = Uri.parse('$_baseUrl/predict');
    final body = jsonEncode(response.toJson());

    try {
      final res = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final level = data['level'] as String;
        final score = (data['score'] as num).toDouble();

        return ReadingResult(
          level: level,
          score: score,
          recommendation: _buildRecommendation(level),
        );
      } else {
        final localScore = _manualScoreFromResponse(response);
        final localLevel = _levelFromScore(localScore);
        return ReadingResult(
          level: localLevel,
          score: localScore,
          recommendation:
              'Gagal terhubung ke server AI (kode ${res.statusCode}). Hasil dihitung lokal: ${_buildRecommendation(localLevel)}',
        );
      }
    } catch (e) {
      final localScore = _manualScoreFromResponse(response);
      final localLevel = _levelFromScore(localScore);
      return ReadingResult(
        level: localLevel,
        score: localScore,
        recommendation:
            'Tidak dapat menghubungi server AI. Hasil dihitung lokal: ${_buildRecommendation(localLevel)}',
      );
    }
  }

  double _manualScoreFromResponse(ReadingResponse r) {
    // Normalisasi menurut max tiap pertanyaan agar setiap soal menyumbang 0..1
    final q1 = r.frequencyPerWeek; // 0..4
    final q2 = r.minutesPerDay; // 0..4
    final q3 = (r.enjoymentScale > 0)
        ? (r.enjoymentScale - 1)
        : r.enjoymentScale; // 0..4
    final q4 = r.hasPersonalBooks; // 0..1
    final q5 = r.formatPreference; // 0..3
    final q6 = r.genreVariety; // 0..4
    final q7 = r.purpose; // 0..3
    final q8 = r.readingHabitDuration; // 0..4
    final q9 = r.discussionHabit; // 0..2 (UI has 3 options)
    final q10 = r.readingCommunity; // 0..3

    final s1 = q1 / 4.0;
    final s2 = q2 / 4.0;
    final s3 = q3 / 4.0;
    final s4 = q4 / 1.0;
    final s5 = q5 / 3.0;
    final s6 = q6 / 4.0;
    final s7 = q7 / 3.0;
    final s8 = q8 / 4.0;
    final s9 = q9 / 2.0;
    final s10 = q10 / 3.0;

    final total = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10; // 0..10
    return total.toDouble();
  }

  String _levelFromScore(double manualScore) {
    if (manualScore < 2) return 'Sangat Rendah';
    if (manualScore < 4) return 'Rendah';
    if (manualScore < 6) return 'Sedang';
    if (manualScore < 8) return 'Tinggi';
    return 'Sangat Tinggi';
  }

  String _buildRecommendation(String level) {
    switch (level) {
      case 'Rendah':
        return 'Coba mulai dengan membaca 10–15 menit per hari dari bacaan yang ringan dan menarik bagimu, seperti komik atau cerita pendek.';
      case 'Sedang':
        return 'Minat bacamu cukup baik. Tingkatkan dengan menambah variasi bacaan dan membuat jadwal membaca 20–30 menit setiap hari.';
      case 'Tinggi':
        return 'Minat bacamu tinggi! Kamu bisa menantang diri dengan buku non-fiksi, berdiskusi, atau merekomendasikan bacaan ke teman.';
      default:
        return 'Terus kembangkan kebiasaan membaca dengan memilih bacaan yang kamu sukai dan konsisten setiap hari.';
    }
  }
}
