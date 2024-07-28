import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:yazlab22/araclar/quick_box.dart';
import 'package:yazlab22/settings.dart';
import 'package:yazlab22/saglayıcılar/controller.dart';
import 'package:yazlab22/bilesen/grid.dart';
import 'package:yazlab22/bilesen/keyboard_row.dart';
import 'package:yazlab22/bilesen/stats_box.dart';

class HomePage extends StatefulWidget {
  final int letterCount; // Kelime uzunluğunu parametre olarak alıyoruz.

  const HomePage({Key? key, required this.letterCount}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _word;
  String? opponentWord; // Karşı tarafın kelimesini tutacak
  Timer? _timer;
  int _remainingSeconds = 60;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Provider.of<Controller>(context, listen: false)
          .setCorrectWord(word: _word);
    });

    super.initState();
    super.initState();
    _loadWord();
    _startTimer();
    _getOpponentWord(); // Karşı tarafın kelimesini alma işlemi başlat
  }

  void _loadWord() async {
    final String fileName = 'assets/${widget.letterCount}harf.txt';
    try {
      final String wordsString = await rootBundle.loadString(fileName);
      List<String> words = wordsString
          .split('\n')
          .where((word) => word.isNotEmpty)
          .map((word) => word.trim().toUpperCase())
          .toList();
      final Random random = Random();
      _word = words[random
          .nextInt(words.length)]; // Kelimeler zaten büyük harfe çevrildi.

      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      String gamePath = 'game/${widget.letterCount}/$userId';

      // Firebase veritabanına kelimeyi büyük harf olarak kaydet
      DatabaseReference ref = FirebaseDatabase.instance.ref(gamePath);
      await ref.set({'word': _word, 'status': 'active'}).then(() {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Veritabanına kaydedildi.')));
        // Yükleme başarılı ise bir sonraki ekranı yükle
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomePage(letterCount: widget.letterCount)));
      } as FutureOr Function(void value)).catchError((error) {
        print("Kelime kaydedilirken bir hata oluştu: $error");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Kaydedilmedi.')));
      });
    } catch (e) {
      print("Error loading words for ${widget.letterCount} letters: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kelime yüklenirken bir hata oluştu!')));
    }
  }

  void _startTimer() {
    _timer?.cancel(); // Önceki timer varsa iptal et
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel(); // Timer'ı otomatik olarak iptal et
        // Zamanlayıcı sıfıra ulaştığında ne olacağını burada işleyin
      }
    });
  }

  void _getOpponentWord() {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    String gamePath = 'game/${widget.letterCount}';

    FirebaseDatabase.instance
        .ref(gamePath)
        .onValue
        .listen((DatabaseEvent event) {
      var data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null &&
          data.entries.any((entry) =>
              entry.key != userId && entry.value['status'] == 'waiting')) {
        var opponentEntry =
            data.entries.firstWhere((entry) => entry.key != userId);
        setState(() {
          opponentWord =
              opponentEntry.value['word']; // Karşı tarafın kelimesini al
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Null kontrolü ile timer iptal ediliyor
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.letterCount} Harf Kelime'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWord, // Yenileme işlemi
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Settings()));
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text('00:${_remainingSeconds.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 20)),
            ),
          ),
          Consumer<Controller>(
            builder: (_, notifier, __) {
              if (notifier.notEnoughLetters) {
                runQuickBox(context: context, message: 'Not Enough Letters');
              }
              if (notifier.gameCompleted) {
                if (notifier.gameWon) {
                  if (notifier.currentRow == 6) {
                    runQuickBox(context: context, message: 'Phew!');
                  } else {
                    runQuickBox(context: context, message: 'Splendid!');
                  }
                } else {
                  runQuickBox(context: context, message: notifier.correctWord);
                }
                Future.delayed(
                  const Duration(milliseconds: 4000),
                  () {
                    if (mounted) {
                      showDialog(
                          context: context, builder: (_) => const StatsBox());
                    }
                  },
                );
              }
              return IconButton(
                  onPressed: () async {
                    showDialog(
                        context: context, builder: (_) => const StatsBox());
                  },
                  icon: const Icon(Icons.bar_chart_outlined));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1, thickness: 2),
          Expanded(
            flex: 7,
            child: Grid(letterCount: widget.letterCount), // Harf gridi
          ),
          const Expanded(
            flex: 4,
            child: Column(
              children: [
                KeyboardRow(min: 1, max: 10), // Klavye satırları
                KeyboardRow(min: 11, max: 19),
                KeyboardRow(min: 20, max: 29),
              ],
            ),
          ),
        ],
     ),
);
}
}