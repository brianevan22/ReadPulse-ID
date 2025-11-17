class ReadingResult {
  final String
  level; // 'Sangat Rendah', 'Rendah', 'Sedang', 'Tinggi', 'Sangat Tinggi'
  final double score; // 0.0 - 10.0 (sesuai perhitungan manual/backend)

  final String recommendation; // teks saran singkat

  ReadingResult({
    required this.level,
    required this.score,
    required this.recommendation,
  });
}
