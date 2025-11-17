import 'package:flutter/material.dart';
import 'package:readpulse_id/features/models/reading_response.dart';
import 'package:readpulse_id/features/services/ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final _formKey = GlobalKey<FormState>();

  // Semua variabel nullable agar bisa dicek apakah sudah diisi
  int? _frequencyPerWeek;
  int? _minutesPerDay;
  int? _enjoymentScale;
  int? _hasPersonalBooks;
  int? _formatPreference;
  int? _genreVariety;
  int? _purpose;
  int? _readingHabitDuration;
  int? _discussionHabit; // NEW
  int? _readingCommunity; // NEW

  // add name controller
  final TextEditingController _nameController = TextEditingController();

  bool _isProcessing = false;
  final _aiService = AiService();

  Future<void> _process() async {
    if ((_nameController.text.trim().isEmpty) ||
        _frequencyPerWeek == null ||
        _minutesPerDay == null ||
        _enjoymentScale == null ||
        _hasPersonalBooks == null ||
        _formatPreference == null ||
        _genreVariety == null ||
        _purpose == null ||
        _readingHabitDuration == null ||
        _discussionHabit == null ||
        _readingCommunity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap diisi semua (termasuk nama assessment)'),
        ),
      );
      return;
    }

    final response = ReadingResponse(
      frequencyPerWeek: _frequencyPerWeek!, // 0..4
      minutesPerDay: _minutesPerDay!, // 0..4
      enjoymentScale: _enjoymentScale!, // 0..4
      hasPersonalBooks: _hasPersonalBooks!, // 0..1
      formatPreference: _formatPreference!, // 0..3
      genreVariety: _genreVariety!, // 0..4
      purpose: _purpose!, // 0..3
      readingHabitDuration: _readingHabitDuration!, //0..4
      discussionHabit: _discussionHabit!, //0..3
      readingCommunity: _readingCommunity!, //0..3
    );

    setState(() => _isProcessing = true);

    try {
      final result = await _aiService.predictReadingInterest(response);

      // Simpan ke history (simpan semua nilai raw)
      final prefs = await SharedPreferences.getInstance();
      final historyString = prefs.getString('reading_history');
      List<dynamic> history = [];
      if (historyString != null) history = jsonDecode(historyString);

      // build title with duplicate counting
      final rawName = _nameController.text.trim();
      final baseTitle = '$rawName Assessment';
      int sameCount = 0;
      for (final e in history) {
        final t = (e['title'] ?? '') as String;
        if (t.startsWith(baseTitle)) sameCount++;
      }
      final title = sameCount == 0 ? baseTitle : '$baseTitle ${sameCount + 1}';

      final now = DateTime.now();
      final isoNow = now.toIso8601String();
      final shortDate = isoNow.substring(0, 10);

      history.add({
        'title': title,
        'date': shortDate,
        'created_at': isoNow,
        'score': result.score, // 0..10
        'frequencyPerWeek': _frequencyPerWeek,
        'minutesPerDay': _minutesPerDay,
        'enjoymentScale': _enjoymentScale,
        'hasPersonalBooks': _hasPersonalBooks,
        'formatPreference': _formatPreference,
        'genreVariety': _genreVariety,
        'purpose': _purpose,
        'readingHabitDuration': _readingHabitDuration,
        'discussionHabit': _discussionHabit,
        'readingCommunity': _readingCommunity,
        'raw_name': rawName, // optional, useful for searching exact name
      });

      await prefs.setString('reading_history', jsonEncode(history));

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
              // NEW: input nama assessment di atas (judul terpisah)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nama Assessment',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan nama assessment',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nama assessment wajib diisi'
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'Jawab pertanyaan berikut untuk mengukur minat bacamu:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // 1. Frekuensi membaca per minggu
              const Text(
                '1. Dalam 1 minggu, berapa kali kamu membaca (buku/artikel/ebook/dsb)?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              // opsi disesuaikan: 0 kali, 1-3, 4-6, 7-10, >10 (nilai tetap 0..4)
              RadioListTile<int>(
                title: const Text('0 kali'),
                value: 0,
                groupValue: _frequencyPerWeek,
                onChanged: (v) => setState(() => _frequencyPerWeek = v),
              ),
              RadioListTile<int>(
                title: const Text('1-3 kali'),
                value: 1,
                groupValue: _frequencyPerWeek,
                onChanged: (v) => setState(() => _frequencyPerWeek = v),
              ),
              RadioListTile<int>(
                title: const Text('4-6 kali'),
                value: 2,
                groupValue: _frequencyPerWeek,
                onChanged: (v) => setState(() => _frequencyPerWeek = v),
              ),
              RadioListTile<int>(
                title: const Text('7-10 kali'),
                value: 3,
                groupValue: _frequencyPerWeek,
                onChanged: (v) => setState(() => _frequencyPerWeek = v),
              ),
              RadioListTile<int>(
                title: const Text('Lebih dari 10 kali'),
                value: 4,
                groupValue: _frequencyPerWeek,
                onChanged: (v) => setState(() => _frequencyPerWeek = v),
              ),
              const SizedBox(height: 16),

              // 2. Menit membaca per hari
              const Text(
                '2. Rata-rata berapa menit per hari kamu membaca?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              // opsi disesuaikan: 0, 1-15, 16-30, 31-60, >60 (nilai tetap 0..4)
              RadioListTile<int>(
                title: const Text('0 menit'),
                value: 0,
                groupValue: _minutesPerDay,
                onChanged: (val) => setState(() => _minutesPerDay = val),
              ),
              RadioListTile<int>(
                title: const Text('1-15 menit'),
                value: 1,
                groupValue: _minutesPerDay,
                onChanged: (val) => setState(() => _minutesPerDay = val),
              ),
              RadioListTile<int>(
                title: const Text('16-30 menit'),
                value: 2,
                groupValue: _minutesPerDay,
                onChanged: (val) => setState(() => _minutesPerDay = val),
              ),
              RadioListTile<int>(
                title: const Text('31-60 menit'),
                value: 3,
                groupValue: _minutesPerDay,
                onChanged: (val) => setState(() => _minutesPerDay = val),
              ),
              RadioListTile<int>(
                title: const Text('Lebih dari 60 menit'),
                value: 4,
                groupValue: _minutesPerDay,
                onChanged: (val) => setState(() => _minutesPerDay = val),
              ),
              const SizedBox(height: 16),

              // 3. Seberapa menikmati membaca
              const Text(
                '3. Seberapa kamu menikmati aktivitas membaca?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              ...List.generate(
                5,
                (i) => RadioListTile<int>(
                  title: Text('${i + 1} (${_enjoymentLabel(i + 1)})'),
                  value: i + 1,
                  groupValue: _enjoymentScale,
                  onChanged: (v) => setState(() => _enjoymentScale = v),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Punya koleksi buku?
              const Text(
                '4. Apakah kamu punya koleksi buku sendiri di rumah?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              RadioListTile<int>(
                title: const Text('Tidak'),
                value: 0,
                groupValue: _hasPersonalBooks,
                onChanged: (v) => setState(() => _hasPersonalBooks = v),
              ),
              RadioListTile<int>(
                title: const Text('Ya'),
                value: 1,
                groupValue: _hasPersonalBooks,
                onChanged: (v) => setState(() => _hasPersonalBooks = v),
              ),
              const SizedBox(height: 16),

              // 5. Preferensi format
              const Text(
                '5. Kamu lebih suka membaca format apa?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              RadioListTile<int>(
                title: const Text('Digital (HP/Tablet/Komputer)'),
                value: 1,
                groupValue: _formatPreference,
                onChanged: (v) => setState(() => _formatPreference = v),
              ),
              RadioListTile<int>(
                title: const Text('Cetak (buku/majalah fisik/koran)'),
                value: 2,
                groupValue: _formatPreference,
                onChanged: (v) => setState(() => _formatPreference = v),
              ),
              RadioListTile<int>(
                title: const Text('Keduanya sama-sama suka'),
                value: 3,
                groupValue: _formatPreference,
                onChanged: (v) => setState(() => _formatPreference = v),
              ),
              RadioListTile<int>(
                title: const Text('Tidak suka keduanya'),
                value: 0,
                groupValue: _formatPreference,
                onChanged: (v) => setState(() => _formatPreference = v),
              ),
              const SizedBox(height: 16),

              // 6. Variasi jenis bacaan
              const Text(
                '6. Kira-kira ada berapa banyak variasi jenis bacaan yang biasa kamu baca? (misal: komik, novel, non-fiksi, berita, artikel, dsb.)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              // opsi: 0 jenis, 1 jenis, 2 jenis, 3 jenis, lebih dari 3 jenis
              RadioListTile<int>(
                title: const Text('0 jenis bacaan'),
                value: 0,
                groupValue: _genreVariety,
                onChanged: (v) => setState(() => _genreVariety = v),
              ),
              RadioListTile<int>(
                title: const Text('1 jenis bacaan'),
                value: 1,
                groupValue: _genreVariety,
                onChanged: (v) => setState(() => _genreVariety = v),
              ),
              RadioListTile<int>(
                title: const Text('2 jenis bacaan'),
                value: 2,
                groupValue: _genreVariety,
                onChanged: (v) => setState(() => _genreVariety = v),
              ),
              RadioListTile<int>(
                title: const Text('3 jenis bacaan'),
                value: 3,
                groupValue: _genreVariety,
                onChanged: (v) => setState(() => _genreVariety = v),
              ),
              RadioListTile<int>(
                title: const Text('Lebih dari 3 jenis bacaan'),
                value: 4,
                groupValue: _genreVariety,
                onChanged: (v) => setState(() => _genreVariety = v),
              ),
              const SizedBox(height: 16),

              // 7. Tujuan utama membaca
              const Text(
                '7. Kamu lebih sering membaca untuk keperluan apa?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              RadioListTile<int>(
                title: const Text('Tugas/sekolah/kuliah/kerja'),
                value: 1,
                groupValue: _purpose,
                onChanged: (v) => setState(() => _purpose = v),
              ),
              RadioListTile<int>(
                title: const Text('Hobi & minat pribadi'),
                value: 2,
                groupValue: _purpose,
                onChanged: (v) => setState(() => _purpose = v),
              ),
              RadioListTile<int>(
                title: const Text('Keduanya (tugas dan hobi)'),
                value: 3,
                groupValue: _purpose,
                onChanged: (v) => setState(() => _purpose = v),
              ),
              RadioListTile<int>(
                title: const Text(
                  'Hanya sekedar membaca/tidak ada tujuan khusus',
                ),
                value: 0,
                groupValue: _purpose,
                onChanged: (v) => setState(() => _purpose = v),
              ),
              const SizedBox(height: 16),

              // 8. Lama kebiasaan membaca
              const Text(
                '8. Sudah berapa lama kamu punya kebiasaan membaca rutin?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              RadioListTile<int>(
                title: const Text('0-1 bulan'),
                value: 0,
                groupValue: _readingHabitDuration,
                onChanged: (v) => setState(() => _readingHabitDuration = v),
              ),
              RadioListTile<int>(
                title: const Text('1-3 bulan'),
                value: 1,
                groupValue: _readingHabitDuration,
                onChanged: (v) => setState(() => _readingHabitDuration = v),
              ),
              RadioListTile<int>(
                title: const Text('3-6 bulan'),
                value: 2,
                groupValue: _readingHabitDuration,
                onChanged: (v) => setState(() => _readingHabitDuration = v),
              ),
              RadioListTile<int>(
                title: const Text('6-12 bulan'),
                value: 3,
                groupValue: _readingHabitDuration,
                onChanged: (v) => setState(() => _readingHabitDuration = v),
              ),
              RadioListTile<int>(
                title: const Text('Lebih dari 1 tahun'),
                value: 4,
                groupValue: _readingHabitDuration,
                onChanged: (v) => setState(() => _readingHabitDuration = v),
              ),
              const SizedBox(height: 16),

              // 9. Kebiasaan diskusi bacaan
              const Text(
                '9. Seberapa sering kamu berdiskusi tentang bacaan dengan orang lain?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              RadioListTile<int>(
                title: const Text('Tidak Pernah'),
                value: 0,
                groupValue: _discussionHabit,
                onChanged: (v) => setState(() => _discussionHabit = v),
              ),
              RadioListTile<int>(
                title: const Text('Jarang'),
                value: 1,
                groupValue: _discussionHabit,
                onChanged: (v) => setState(() => _discussionHabit = v),
              ),
              RadioListTile<int>(
                title: const Text('Sering'),
                value: 2,
                groupValue: _discussionHabit,
                onChanged: (v) => setState(() => _discussionHabit = v),
              ),
              const SizedBox(height: 16),

              // 10. Keaktifan di komunitas membaca
              const Text(
                '10. Apakah kamu aktif mengikuti komunitas membaca (online/offline)?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              RadioListTile<int>(
                title: const Text('Tidak mengikuti komunitas'),
                value: 0,
                groupValue: _readingCommunity,
                onChanged: (v) => setState(() => _readingCommunity = v),
              ),
              RadioListTile<int>(
                title: const Text('Hanya mengikuti tetapi tidak aktif'),
                value: 1,
                groupValue: _readingCommunity,
                onChanged: (v) => setState(() => _readingCommunity = v),
              ),
              RadioListTile<int>(
                title: const Text('Jarang aktif'),
                value: 2,
                groupValue: _readingCommunity,
                onChanged: (v) => setState(() => _readingCommunity = v),
              ),
              RadioListTile<int>(
                title: const Text('Sangat aktif'),
                value: 3,
                groupValue: _readingCommunity,
                onChanged: (v) => setState(() => _readingCommunity = v),
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

  String _enjoymentLabel(int value) {
    switch (value) {
      case 1:
        return 'Tidak suka';
      case 2:
        return 'Kurang suka';
      case 3:
        return 'Biasa saja';
      case 4:
        return 'Suka';
      case 5:
        return 'Sangat suka';
      default:
        return '';
    }
  }
}
