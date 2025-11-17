import 'package:flutter/material.dart';
import 'package:readpulse_id/features/models/reading_response.dart';
import 'package:readpulse_id/features/services/ai_service.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final _formKey = GlobalKey<FormState>();

  // Variabel jawaban user
  double _frequencyPerWeek = 3;    // 0–7 kali/minggu
  double _minutesPerDay = 30;      // 0–180 menit/hari
  double _enjoymentScale = 3;      // 1–5
  int _hasPersonalBooks = 0;       // 0 = tidak, 1 = ya
  int _formatPreference = 0;       // 0 = digital, 1 = cetak, 2 = keduanya
  double _genreVariety = 2;        // 1–5
  int _purpose = 0;                // 0 = tugas, 1 = hobi, 2 = keduanya
  int _readingHabitDuration = 0;   // 0 = <6 bln, 1 = 6–12 bln, 2 = >1 tahun

  bool _isProcessing = false;
  final _aiService = AiService();

  Future<void> _process() async {
    // kalau nanti ada TextFormField, ini bisa dipakai
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    // Bentuk objek response untuk dikirim ke AI
    final response = ReadingResponse(
      frequencyPerWeek: _frequencyPerWeek.toInt(),
      minutesPerDay: _minutesPerDay.toInt(),
      enjoymentScale: _enjoymentScale.toInt(),
      hasPersonalBooks: _hasPersonalBooks,
      formatPreference: _formatPreference,
      genreVariety: _genreVariety.toInt(),
      purpose: _purpose,
      readingHabitDuration: _readingHabitDuration,
    );

    try {
      final result = await _aiService.predictReadingInterest(response);

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/result',
        arguments: {
          'level': result.level,
          'score': result.score,
          'recommendation': result.recommendation,
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kuesioner Minat Baca')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Jawab pertanyaan berikut untuk mengukur minat bacamu:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // 1. Berapa kali membaca per minggu
              const Text(
                '1. Dalam 1 minggu, berapa kali kamu membaca (buku/artikel/ebook)?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Slider(
                value: _frequencyPerWeek,
                min: 0,
                max: 7,
                divisions: 7,
                label: '${_frequencyPerWeek.toInt()} kali/minggu',
                onChanged: (v) => setState(() => _frequencyPerWeek = v),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_frequencyPerWeek.toInt()} kali/minggu',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Menit membaca per hari
              const Text(
                '2. Rata-rata berapa menit per hari kamu membaca?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Slider(
                value: _minutesPerDay,
                min: 0,
                max: 180,
                divisions: 18,
                label: '${_minutesPerDay.toInt()} menit/hari',
                onChanged: (v) => setState(() => _minutesPerDay = v),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_minutesPerDay.toInt()} menit/hari',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Seberapa menikmati membaca
              const Text(
                '3. Seberapa kamu menikmati aktivitas membaca? (1 = tidak suka, 5 = sangat suka)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Slider(
                value: _enjoymentScale,
                min: 1,
                max: 5,
                divisions: 4,
                label: _enjoymentScale.toInt().toString(),
                onChanged: (v) => setState(() => _enjoymentScale = v),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Skor: ${_enjoymentScale.toInt()}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Punya koleksi buku?
              const Text(
                '4. Apakah kamu punya koleksi buku sendiri di rumah?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<int>(
                      title: const Text('Tidak'),
                      value: 0,
                      groupValue: _hasPersonalBooks,
                      onChanged: (v) =>
                          setState(() => _hasPersonalBooks = v ?? 0),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<int>(
                      title: const Text('Ya'),
                      value: 1,
                      groupValue: _hasPersonalBooks,
                      onChanged: (v) =>
                          setState(() => _hasPersonalBooks = v ?? 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Preferensi format
              const Text(
                '5. Kamu lebih suka membaca format apa?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _formatPreference,
                items: const [
                  DropdownMenuItem(
                    value: 0,
                    child: Text('Digital (HP/Tablet/Komputer)'),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Cetak (buku/majalah fisik)'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Keduanya sama-sama suka'),
                  ),
                ],
                onChanged: (v) => setState(() => _formatPreference = v ?? 0),
              ),
              const SizedBox(height: 16),

              // 6. Variasi jenis bacaan
              const Text(
                '6. Kira-kira ada berapa banyak variasi jenis bacaan yang biasa kamu baca? '
                '(misalnya: komik, novel, non-fiksi, berita, artikel, dsb.)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Slider(
                value: _genreVariety,
                min: 1,
                max: 5,
                divisions: 4,
                label: _genreVariety.toInt().toString(),
                onChanged: (v) => setState(() => _genreVariety = v),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_genreVariety.toInt()} jenis bacaan',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // 7. Tujuan utama membaca
              const Text(
                '7. Kamu lebih sering membaca untuk apa?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _purpose,
                items: const [
                  DropdownMenuItem(
                    value: 0,
                    child: Text('Tugas/sekolah/kuliah/kerja'),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Hobi & minat pribadi'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Keduanya (tugas dan hobi)'),
                  ),
                ],
                onChanged: (v) => setState(() => _purpose = v ?? 0),
              ),
              const SizedBox(height: 16),

              // 8. Lama kebiasaan membaca
              const Text(
                '8. Sudah berapa lama kamu punya kebiasaan membaca rutin?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _readingHabitDuration,
                items: const [
                  DropdownMenuItem(
                    value: 0,
                    child: Text('Kurang dari 6 bulan'),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text('6–12 bulan'),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Lebih dari 1 tahun'),
                  ),
                ],
                onChanged: (v) =>
                    setState(() => _readingHabitDuration = v ?? 0),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _process,
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Proses dengan AI'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
