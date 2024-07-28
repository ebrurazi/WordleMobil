import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:yazlab22/home_page.dart';
import 'package:yazlab22/saglayıcılar/controller.dart';

class WordEntryPage extends StatefulWidget {
  final int wordLength;
  final int roomNumber;
  final int roomType;
  final String rakipid;

  WordEntryPage({
    required this.wordLength,
    required this.roomNumber,
    required this.roomType,
    required this.rakipid,
});

  @override
  _WordEntryPageState createState() => _WordEntryPageState();
}

class _WordEntryPageState extends State<WordEntryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final DatabaseReference _dbRef;
  final TextEditingController _controller = TextEditingController();
  late Set<String> _wordSet;
  
  get roomNumber_ =>widget.roomNumber;

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase(
        databaseURL:
            'https://flutter-firebase-6ce5a-default-rtdb.europe-west1.firebasedatabase.app/');
    _dbRef = database.ref().child('odalar');
    loadWordList();
  }

  Future<void> loadWordList() async {
    var tmp = widget.wordLength;
    final wordList = await rootBundle.loadString('assets/${tmp}harf.txt');
    setState(() {
      _wordSet = Set.from(wordList.split('\n'));
    });
  }


void listenForOpponentWord(int roomNumber, String myUserId) {
  // Rakibin kelimesini dinlemek için Query referansı oluşturma
  Query opponentWordQuery = _dbRef.child('kelimeler').orderByChild('roomNumber').equalTo(roomNumber);

  // Dinleme işlemi başlatma
  opponentWordQuery.onValue.listen((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;
    if (data != null) {
      data.forEach((key, value) {
        if (value['userId'] != myUserId && value['roomNumber'] == roomNumber) {
          // Rakibinizin kelimesini aldığınızda yapılacak işlemler
          String opponentWord = value['word'];
          print("Rakibinizin kelimesi: $opponentWord");
          // Burada rakibinizin kelimesine göre işlemler gerçekleştirebilirsiniz
        }
      });
    }
  }).onError((error) {
    print('Rakibinizin kelimesini dinlerken hata oluştu: $error');
  });
}
  void saveWord(String word, int roomNumber, int roomType, String rakipid) {
  String roomKey = '$roomNumber_$roomType';
  _dbRef.child('odalar').child(roomKey).child(rakipid).set(word).then((_) {
    print("Kelime başarıyla kaydedildi.");
  }).catchError((error) {
    print("Kelime kaydederken hata oluştu: $error");
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.wordLength}-Harf Kelime Gir'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Kelime',
                hintText: 'Kelime giriniz',
              ),
              maxLength: widget.wordLength > 0
                  ? widget.wordLength
                  : null, // Eğer wordLength 0 veya daha küçükse null kullan
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp("[a-zA-Z]")), // Sadece harf girişine izin verir.
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.length == widget.wordLength &&
                    _wordSet.contains(_controller.text.toUpperCase())) {
                  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                  if (userId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Kullanıcı girişi yapılmamış.'),
                    ));
                    return;
                  }

                  // Firebase veritabanına kelimeyi kaydet
                  _dbRef.child('kelimeler').push().set({
                    'word': _controller.text.toUpperCase(),
                    'userId': userId,
                    'roomNumber': widget.roomNumber,
                    'roomType': widget.roomType,
                    'timestamp': DateTime.now().millisecondsSinceEpoch,
                  }).then((_) {
                    // İşlem başarılı olduğunda yapılacak işlemler
                    Provider.of<Controller>(context, listen: false)
                        .setCorrectWord(word: _controller.text.toUpperCase());
                    // Kullanıcının ID'sini

                    // Rakip kelimeyi dinlemeye başla


                    // Navigasyon işlemi
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => HomePage(
                        letterCount: widget.wordLength,
                      ),
                    ));
                  }).catchError((error) {
                    // Hata durumunda yapılacak işlemler
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Veritabanına kelime kaydedilirken bir hata oluştu: $error'),
                    ));
                  });
                } else {
                  // Geçersiz giriş durumunda yapılacak işlemler
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Böyle bir kelime bulunamadı veya uygun uzunlukta değil!'),
                  ));
                }
              },
              child: Text('Onayla'),
              
            ),
            
          ],
        ),
      ),
    );
  }
}
