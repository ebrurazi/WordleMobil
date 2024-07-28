import 'package:shared_preferences/shared_preferences.dart';

// Oyunun kazanılıp kazanılmadığını belirten bir flag (gameWon) alır ve buna bağlı olarak istatistikleri günceller.
calculateStats({required bool gameWon}) async {
  // İstatistikler için başlangıç değerleri atanır.
  int gamesPlayed = 0,
      gamesWon = 0,
      winPercentage = 0,
      currentStreak = 0,
      maxStreak = 0;

  final stats = await getStats(); // Kaydedilmiş istatistikleri çeker.

  // Eğer kaydedilmiş istatistikler varsa, bunlar atanır.
  if (stats != null) {
    gamesPlayed = int.parse(stats[0]);
    gamesWon = int.parse(stats[1]);
    winPercentage = int.parse(stats[2]);
    currentStreak = int.parse(stats[3]);
    maxStreak = int.parse(stats[4]);
  }

  gamesPlayed++; // Oynanan oyun sayısını artırır.

  if (gameWon) {
    gamesWon++; // Eğer oyun kazanıldıysa, kazanılan oyun sayısını artırır.
    currentStreak++; // Mevcut seri sayısını artırır.
  } else {
    currentStreak = 0; // Eğer oyun kazanılmadıysa, mevcut seri sıfırlanır.
  }

  // Eğer mevcut seri, maksimum seri sayısından büyükse, maksimum seri güncellenir.
  if (currentStreak > maxStreak) {
    maxStreak = currentStreak;
  }

  // Kazanma yüzdesi hesaplanır.
  winPercentage = ((gamesWon / gamesPlayed) * 100).toInt();

  final prefs =
      await SharedPreferences.getInstance(); // SharedPreferences örneği alınır.
  // Güncellenen istatistikler kaydedilir.
  prefs.setStringList('stats', [
    gamesPlayed.toString(),
    gamesWon.toString(),
    winPercentage.toString(),
    currentStreak.toString(),
    maxStreak.toString()
  ]);
}

// Kaydedilmiş istatistikleri çeken fonksiyon.
Future<List<String>?> getStats() async {
  final prefs =
      await SharedPreferences.getInstance(); // SharedPreferences örneği alınır.
  final stats = prefs.getStringList(
      'stats'); // 'stats' anahtarı kullanılarak kaydedilmiş istatistikler çekilir.
  if (stats != null) {
    return stats; // İstatistikler varsa döndürülür.
  } else {
    return null; // İstatistikler yoksa null döndürülür.
  }
}
