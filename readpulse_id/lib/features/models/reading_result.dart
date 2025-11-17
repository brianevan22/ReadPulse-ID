class ReadingResult {
  final String level; // 'Rendah', 'Sedang', 'Tinggi'
  final double score; // 0.0 - 1.0

  final String recommendation; // teks saran singkat

  ReadingResult({
    required this.level,
    required this.score,
    required this.recommendation,
  });
}
