import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:readpulse_id/features/models/reading_response.dart';
import 'package:readpulse_id/features/models/reading_result.dart';

class AiService {
  // Untuk Flutter Web di laptop yang sama:
  static const String _baseUrl = 'http://localhost:5000';
  // Kalau bermasalah, bisa coba 'http://127.0.0.1:5000'

  Future<ReadingResult> predictReadingInterest(ReadingResponse response) async {
    final url = Uri.parse('$_baseUrl/predict');
    final body = jsonEncode(response.toJson());

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

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
      // fallback kalau server error
      return ReadingResult(
        level: 'Error',
        score: 0.0,
        recommendation:
            'Gagal terhubung ke server AI (kode ${res.statusCode}). Pastikan backend berjalan.',
      );
    }
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
