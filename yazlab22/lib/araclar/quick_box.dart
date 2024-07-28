import 'package:flutter/material.dart';

// Belirli bir mesajı gösteren kısa süreli bir diyalog kutusu çalıştırır.
runQuickBox({required BuildContext context, required String message}) {
  // Çerçeve işlemi bittikten sonra bir işlem yapmak için bir geri çağırım ekler.
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    // Diyalog kutusunu gösterir.
    showDialog(
        barrierDismissible: false, // Diyalog dışına dokunulduğunda kapatılamaz.
        barrierColor: Colors.transparent, // Diyalog dışı arka plan rengi.
        context: context,
        builder: (context) {
          // Diyalog gösterildikten 1 saniye sonra otomatik kapanmasını sağlar.
          Future.delayed(const Duration(milliseconds: 1000), () {
            Navigator.maybePop(context); // Diyalogu kapatır.
          });
          // AlertDialog widget'ını döndürür.
          return AlertDialog(
            title: Text(
              message,
              textAlign: TextAlign.center, // Mesaj metni ortalanmıştır.
            ),
          );
        });
  });
}
