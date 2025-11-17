import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString('reading_history');
    if (historyString != null) {
      final List<dynamic> decoded = jsonDecode(historyString);
      setState(() {
        _history = decoded.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } else {
      setState(() {
        _history = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Assessment'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(child: Text('Belum ada riwayat assessment.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[_history.length - 1 - index];
                    final score = (item['score'] ?? 0.0) as num;
                    final double totalScore = score.toDouble(); // 0..10
                    String levelLabel;
                    Color levelColor;
                    if (totalScore < 2) {
                      levelLabel = 'Sangat Rendah';
                      levelColor = Colors.red;
                    } else if (totalScore < 4) {
                      levelLabel = 'Rendah';
                      levelColor = Colors.orange;
                    } else if (totalScore < 6) {
                      levelLabel = 'Sedang';
                      levelColor = Colors.amber;
                    } else if (totalScore < 8) {
                      levelLabel = 'Tinggi';
                      levelColor = Colors.green;
                    } else {
                      levelLabel = 'Sangat Tinggi';
                      levelColor = Colors.blue;
                    }
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Icon(Icons.history, color: Colors.deepPurple),
                        title: Text(item['title'] ?? 'Assessment'),
                        subtitle: Text('Tanggal: ${item['date'] ?? '-'}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              levelLabel,
                              style: TextStyle(
                                color: levelColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(totalScore / 10 * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final score = (item['score'] ?? 0.0) as num;
                              final double totalScore = score.toDouble();
                              String levelLabel;
                              if (totalScore < 2) {
                                levelLabel = 'Sangat Rendah';
                              } else if (totalScore < 4) {
                                levelLabel = 'Rendah';
                              } else if (totalScore < 6) {
                                levelLabel = 'Sedang';
                              } else if (totalScore < 8) {
                                levelLabel = 'Tinggi';
                              } else {
                                levelLabel = 'Sangat Tinggi';
                              }
                              return AlertDialog(
                                title: const Text('Detail Assessment'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Tanggal: ${item['date'] ?? '-'}'),
                                      const SizedBox(height: 8),
                                      Text('Level: $levelLabel'),
                                      Text('Skor: ${(totalScore / 10 * 100).toStringAsFixed(1)}%'),
                                      const Divider(),
                                      Text('1. Frekuensi per minggu: ${item['frequencyPerWeek'] ?? "-"}'),
                                      Text('2. Menit per hari: ${item['minutesPerDay'] ?? "-"}'),
                                      Text('3. Skala menikmati: ${item['enjoymentScale'] ?? "-"}'),
                                      Text('4. Punya koleksi buku: ${item['hasPersonalBooks'] == 1 ? "Ya" : "Tidak"}'),
                                      Text('5. Preferensi format: ${_formatPrefText(item['formatPreference'])}'),
                                      Text('6. Variasi bacaan: ${item['genreVariety'] ?? "-"}'),
                                      Text('7. Tujuan membaca: ${_purposeText(item['purpose'])}'),
                                      Text('8. Lama kebiasaan: ${_durationText(item['readingHabitDuration'])}'),
                                      Text('9. Diskusi bacaan: ${_discussionText(item['discussionHabit'])}'),
                                      Text('10. Komunitas membaca: ${_communityText(item['readingCommunity'])}'),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Tutup'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  String _formatPrefText(dynamic val) {
    switch (val) {
      case 0:
        return 'Digital';
      case 1:
        return 'Cetak';
      case 2:
        return 'Keduanya';
      default:
        return '-';
    }
  }

  String _purposeText(dynamic val) {
    switch (val) {
      case 0:
        return 'Tugas/sekolah/kuliah/kerja';
      case 1:
        return 'Hobi & minat pribadi';
      case 2:
        return 'Keduanya';
      default:
        return '-';
    }
  }

  String _durationText(dynamic val) {
    switch (val) {
      case 0:
        return '0-1 bulan';
      case 1:
        return '1-3 bulan';
      case 2:
        return '3-6 bulan';
      case 3:
        return '6-12 bulan';
      case 4:
        return 'Lebih dari 1 tahun';
      default:
        return '-';
    }
  }

  String _discussionText(dynamic val) {
    switch (val) {
      case 0:
        return 'Tidak Pernah';
      case 1:
        return 'Jarang';
      case 2:
        return 'Sering';
      default:
        return '-';
    }
  }

  String _communityText(dynamic val) {
    switch (val) {
      case 0:
        return 'Tidak mengikuti komunitas';
      case 1:
        return 'Hanya mengikuti tetapi tidak aktif';
      case 2:
        return 'Jarang aktif';
      case 3:
        return 'Sangat aktif';
      default:
        return '-';
    }
  }
}
