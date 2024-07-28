import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  // Kullanıcının tema tercihini kaydeder (koyu tema için true, ışık tema için false).
  static saveTheme({required bool isDark}) async {
    final prefs = await SharedPreferences
        .getInstance(); // SharedPreferences örneğini alır.
    prefs.setBool('isDark',
        isDark); // Koyu tema tercihini 'isDark' anahtar kelimesi ile kaydeder.
  }

  // Kaydedilmiş tema tercihini alır. Tercih kaydedilmemişse varsayılan olarak false döner.
  static Future<bool> getTheme() async {
    final prefs = await SharedPreferences
        .getInstance(); // SharedPreferences örneğini alır.
    return prefs.getBool('isDark') ??
        false; // 'isDark' anahtar kelimesi ile kaydedilmiş tercihi alır. Kayıt yoksa false döner.
  }
}
