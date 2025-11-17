import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final level = args?['level'] ?? 'Belum Ada Data';
    final score = (args?['score'] ?? 0.0) as double;
    final recommendation = args?['recommendation'] ??
        'Belum ada rekomendasi. Silakan isi kuesioner terlebih dahulu.';

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Assessment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Level Minat Baca:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '$level (skor: ${(score * 100).toStringAsFixed(1)}%)',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rekomendasi:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              recommendation,
              style: const TextStyle(fontSize: 14),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/home'));
                },
                child: const Text('Kembali ke Beranda'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
