import 'package:shared_preferences/shared_preferences.dart';

// Bu fonksiyon, geçerli satır numarasına bağlı olarak çizelge istatistiklerini günceller.
setChartStats({required int currentRow}) async {
  List<int> distribution = [
    0,
    0,
    0,
    0,
    0,
    0
  ]; // Başlangıçta tüm satırlar için 0 değerinde bir dağılım listesi oluşturur.
  List<String> distributionString =
      []; // Dağılım değerlerini string olarak saklamak için boş bir liste oluşturur.

  final stats = await getStats(); // Kaydedilmiş istatistikleri çeker.

  if (stats != null) {
    distribution =
        stats; // Eğer kaydedilmiş istatistikler varsa, bunları kullanır.
  }

  // Geçerli satırı bulup, ilgili dağılım değerini 1 artırır.
  for (int i = 0; i < 6; i++) {
    if (currentRow - 1 == i) {
      distribution[i]++;
    }
  }

  // Dağılım listesindeki her elemanı string'e çevirip yeni listeye ekler.
  for (var e in distribution) {
    distributionString.add(e.toString());
  }

  final prefs =
      await SharedPreferences.getInstance(); // SharedPreferences örneğini alır.
  prefs.setInt('row', currentRow); // Geçerli satırı 'row' anahtarıyla kaydeder.
  prefs.setStringList('chart',
      distributionString); // Dağılım değerlerini 'chart' anahtarıyla kaydeder.
}

// Bu fonksiyon, kaydedilmiş çizelge istatistiklerini çeker ve integer listesi olarak döndürür.
Future<List<int>?> getStats() async {
  final prefs =
      await SharedPreferences.getInstance(); // SharedPreferences örneğini alır.
  final stats = prefs.getStringList(
      'chart'); // 'chart' anahtarını kullanarak kaydedilmiş istatistikleri çeker.
  if (stats != null) {
    List<int> result =
        []; // String formatındaki istatistikleri integer'a çevirip saklamak için boş bir liste oluşturur.
    for (var e in stats) {
      result.add(int.parse(
          e)); // Her bir string elemanını integer'a çevirir ve listeye ekler.
    }
    return result; // Çevrilen integer listesini döndürür.
  } else {
    return null; // Eğer kaydedilmiş istatistik yoksa, null döndürür.
  }
}
