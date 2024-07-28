import 'package:flutter/material.dart';
import 'package:yazlab22/oda.dart'; // Oda sınıfını doğru bir şekilde import ettiğinizden emin olun.

class RastgeleSayfa extends StatelessWidget {
  const RastgeleSayfa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sabit Kelime Uzunluğu Seç')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (int i = 4; i <= 7; i++) // 4, 5, 6 ve 7 harfli oda seçenekleri
              ElevatedButton(
                onPressed: () {
                  // Oda sınıfına seçilen kelime uzunluğunu ve oda türünü parametre olarak gönderiyoruz.
                  // Burada `roomNumber` parametresi olarak kelime uzunluğunu ve `roomType` olarak 2'yi kullanıyoruz.
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Oda(roomNumber: i, roomType: 1)));
                },
                child: Text('$i Harf'),
              ),
          ],
        ),
      ),
    );
  }
}
