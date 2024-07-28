import 'dart:math';
import 'package:flutter/material.dart';
import 'package:yazlab22/home_page.dart';
import 'package:yazlab22/sabit_sayfa.dart';

class OyunEkrani extends StatelessWidget {
  const OyunEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wordle Ana Menü')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                int randomLetterCount = Random().nextInt(4) +
                    4; // 4 ile 7 arasında rastgele bir sayı üretir.
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SabitSayfa()));
              },
              child: const Text('Rastgele'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SabitSayfa()));
              },
              child: const Text('Sabit'),
            ),
          ],
        ),
      ),
    );
  }
}
