class ReadingResponse {
  final int frequencyPerWeek;
  final int minutesPerDay;
  final int enjoymentScale;
  final int hasPersonalBooks; // 0 atau 1
  final int formatPreference; // 0=digital, 1=cetak, 2=keduanya, 3=tidak suka keduanya
  final int genreVariety; // 0-5
  final int purpose; // 0=tugas, 1=hobi, 2=keduanya, 3=tidak keduanya
  final int readingHabitDuration; // 0=0-1bln, 1=1-3bln, 2=3-6bln, 3=6-12bln, 4=>1th
  final int discussionHabit; // 0=tidak pernah, 1=jarang, 2=sering
  final int readingCommunity; // 0=tidak ikut, 1=ikut tidak aktif, 2=jarang aktif, 3=sangat aktif

  ReadingResponse({
    required this.frequencyPerWeek,
    required this.minutesPerDay,
    required this.enjoymentScale,
    required this.hasPersonalBooks,
    required this.formatPreference,
    required this.genreVariety,
    required this.purpose,
    required this.readingHabitDuration,
    required this.discussionHabit,
    required this.readingCommunity,
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
      'discussion_habit': discussionHabit,
      'reading_community': readingCommunity,
    };
  }
}
