import 'package:charts_flutter/flutter.dart' as charts;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yazlab22/modeller/chart_model.dart';


// Kaydedilen skorları ve mevcut satır bilgisini kullanarak grafik için veri serileri oluşturur.
Future<List<charts.Series<ChartModel, String>>> getSeries() async {
  List<ChartModel> data =
      []; // ChartModel nesnelerini saklayacak boş bir liste oluşturur.
  final prefs =
      await SharedPreferences.getInstance(); // SharedPreferences örneğini alır.
  final scores = prefs.getStringList('chart'); // Kaydedilmiş skorları çeker.
  final row = prefs.getInt('row'); // Mevcut satır bilgisini çeker.

  // Skorları ChartModel nesnelerine dönüştürür ve 'data' listesine ekler.
  if (scores != null) {
    for (var e in scores) {
      data.add(ChartModel(score: int.parse(e), currentGame: false));
    }
  }

  // Mevcut satır bilgisi varsa, ilgili ChartModel nesnesinin 'currentGame' özelliğini true yapar.
  if (row != null) {
    data[row - 1].currentGame = true;
  }

  // Grafik için veri serilerini oluşturur. İki kez aynı seriyi oluşturduğuna dikkat edin (bu muhtemelen bir hata olabilir).
  return [
    charts.Series<ChartModel, String>(
      id: 'Stats',
      data: data,
      domainFn: (model, index) => (index! + 1)
          .toString(), // X ekseni değerlerini oluşturur (1'den başlayarak).
      measureFn: (model, _) =>
          model.score, // Y ekseni değerlerini (skor) belirler.
      colorFn: (model, _) => model.currentGame
          ? charts.MaterialPalette.green.shadeDefault
          : charts.MaterialPalette.gray
              .shadeDefault, // Mevcut oyun için farklı bir renk kullanır.
      labelAccessorFn: (model, _) =>
          model.score.toString(), // Grafikteki etiketleri oluşturur.
    ),
    // Not: Aynı seri tekrar ediliyor. İhtiyacınıza göre bu kısmı kaldırabilir veya değiştirebilirsiniz.
    charts.Series<ChartModel, String>(
      id: 'Stats',
      data: data,
      domainFn: (model, index) => (index! + 1)
          .toString(), // X ekseni değerlerini oluşturur (1'den başlayarak).
      measureFn: (model, _) =>
          model.score, // Y ekseni değerlerini (skor) belirler.
      colorFn: (model, _) => model.currentGame
          ? charts.MaterialPalette.green.shadeDefault
          : charts.MaterialPalette.gray
              .shadeDefault, // Mevcut oyun için farklı bir renk kullanır.
      labelAccessorFn: (model, _) =>
          model.score.toString(), // Grafikteki etiketleri oluşturur.
    ),
  ];
}
