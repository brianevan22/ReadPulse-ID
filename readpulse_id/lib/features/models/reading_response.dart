class ReadingResponse {
  final int frequencyPerWeek;
  final int minutesPerDay;
  final int enjoymentScale;
  final int hasPersonalBooks; // 0 atau 1
  final int formatPreference; // 0=digital, 1=cetak, 2=keduanya
  final int genreVariety; // 1-5
  final int purpose; // 0=tugas, 1=hobi, 2=keduanya
  final int readingHabitDuration; // 0=<6bln, 1=6-12bln, 2=>1th

  ReadingResponse({
    required this.frequencyPerWeek,
    required this.minutesPerDay,
    required this.enjoymentScale,
    required this.hasPersonalBooks,
    required this.formatPreference,
    required this.genreVariety,
    required this.purpose,
    required this.readingHabitDuration,
  });

  // kalau nanti kirim ke API
  Map<String, dynamic> toJson() {
    return {
      'frequency_per_week': frequencyPerWeek,
      'minutes_per_day': minutesPerDay,
      'enjoyment_scale': enjoymentScale,
      'has_personal_books': hasPersonalBooks,
      'format_preference': formatPreference,
      'genre_variety': genreVariety,
      'purpose': purpose,
      'reading_habit_duration': readingHabitDuration,
    };
  }
}
