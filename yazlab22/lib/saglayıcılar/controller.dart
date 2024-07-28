import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yazlab22/modeller/tile_model.dart';
import 'package:yazlab22/sabitler/answer_stages.dart';
import '../araclar/calculate_stats.dart';
import '../klavyeVeri/keys_map.dart';
import 'package:firebase_database/firebase_database.dart';

class Controller extends ChangeNotifier {
  // Oyun durumuyla ilgili değişkenler
  bool checkLine = false, // Bir satırın kontrol edilip edilmediğini belirtir
      backOrEnterTapped =
          false, // Geri veya Enter tuşuna basılıp basılmadığını belirtir
      gameWon = false, // Oyunun kazanılıp kazanılmadığını belirtir
      gameCompleted = false, // Oyunun tamamlandığını belirtir
      notEnoughLetters = false; // Yeterli harf girilip girilmediğini belirtir
  int letterCount = 7; // Varsayılan harf sayısı
  String correctWord = ""; // Doğru kelime
  int currentTile = 0, // Mevcut kutu
      currentRow = 0, // Mevcut satır
      maxTiles =
          7; // Maksimum kutu sayısı, varsayılan olarak 7 (Dinamik olarak ayarlanır)
  List<TileModel> tilesEntered = []; // Girilen harfler
  Random _random = Random();
  Map<int, bool> revealedIndexes = {}; // Açık harflerin indexlerini tutar
  String selectedWord = "";

  get answer => null;

  get clueIndex => null;

  // Rastgele bir kelime seçmek için fonksiyon
  Future<void> selectRandomWord(int wordLength) async {
    final wordListString =
        await rootBundle.loadString('assets/${wordLength}harf.txt');
    List<String> wordList =
        wordListString.split('\n').where((word) => word.isNotEmpty).toList();
    selectedWord = (wordList..shuffle()).first;
    setCorrectWord(
        word: selectedWord); // Seçilen kelimeyi doğru kelime olarak ayarla
  }

  setForwardButtonPressed({required int roomNumber}) {
    // Oda numarasına göre harf sayısını belirle
    if (roomNumber == 4) {
      letterCount = 4;
    } else if (roomNumber == 6) {
      letterCount = 6;
    } else if (roomNumber == 7) {
      letterCount = 7;
    } else {
      letterCount = 5; // Varsayılan olarak 5
    }
    notifyListeners();
  }

// Harf sayısını ayarlar
  void setLetterCount(int count) {
    letterCount = count;
    notifyListeners();
  }

  // Doğru kelimeyi ayarlar ve rastgele bir harfi açığa çıkarır
  void setCorrectWord({required String word}) {
    correctWord = word.toUpperCase(); // Kelimeyi büyük harfe çevir
    maxTiles = correctWord.length; // Maksimum kutu sayısını ayarla
    revealRandomLetter(); // Rastgele bir harfi açığa çıkar
    notifyListeners(); // UI katmanında değişiklikleri bildir
  }

  // Tuşa basıldığında çalışır
  setKeyTapped({required String value}) {
    if (value == 'ENTER') {
      if (currentTile == maxTiles * (currentRow + 1)) {
        checkWord();
        notEnoughLetters = false;
      } else {
        notEnoughLetters = true;
        notifyListeners(); // Kullanıcıya yeterli harf girilmediğini bildir
      }
    } else if (value == 'BACK' && currentTile > maxTiles * currentRow) {
      // Geri tuşuna basıldığında
      if (currentTile == 0) {
        // Eğer geri tuşuna basıldığında herhangi bir harf girilmemişse
        resetGame(); // Oyunu sıfırla ve baştan başlat
      } else {
        currentTile--;
        tilesEntered.removeLast();
        notifyListeners();
      }
    } else if (currentTile < maxTiles * (currentRow + 1)) {
      tilesEntered
          .add(TileModel(letter: value, answerStage: AnswerStage.notAnswered));
      currentTile++;
      notifyListeners();
    }
  }

// Oyunu sıfırla ve baştan başlat
  void resetGame() {
    checkLine = false;
    backOrEnterTapped = false;
    gameWon = false;
    gameCompleted = false;
    notEnoughLetters = false;
    currentTile = 0;
    currentRow = 0;
    tilesEntered.clear();
    revealedIndexes.clear();
    notifyListeners();
  }

  /// Rakip kelimeyi dinlemek için metod
  void listenForOpponentWord(int roomNumber, String rakipid) {
    DatabaseReference roomRef =
        FirebaseDatabase.instance.ref('kelimeler/$roomNumber/userWords');

    roomRef.onValue.listen((event) {
      final roomData = event.snapshot.value as Map<String, dynamic>?;
      if (roomData != null) {
        roomData.forEach((userId, userData) {
          if (userId != rakipid) {
            final userWordData = userData as Map<String, dynamic>;
            setCorrectWord(
                word: userWordData['word']); // Rakip kelimenin ayarlanması
          }
        });
      }
    });
  }

  // Kelimeyi kontrol eder
  checkWord() {
    var guessedWord = tilesEntered
        .sublist(currentRow * maxTiles, (currentRow + 1) * maxTiles)
        .map((t) => t.letter)
        .join(); // Girilen kelimeyi oluştur

    var correctWordChars = List<String>.from(
        correctWord.split('')); // Doğru kelimenin harflerini ayır

    if (guessedWord == correctWord) {
      // Tahmin edilen kelime doğruysa
      gameWon = true; // Oyun kazanıldı bayrağını ayarla
      gameCompleted = true; // Oyun tamamlandı bayrağını ayarla
      for (int i = currentRow * maxTiles;
          i < (currentRow + 1) * maxTiles;
          i++) {
        tilesEntered[i].answerStage =
            AnswerStage.correct; // Doğru cevap bayrağını ayarla
        keysMap.update(tilesEntered[i].letter, (v) => AnswerStage.correct,
            ifAbsent: () => AnswerStage.correct); // Doğru harfleri güncelle
      }
    } else {
      // Tahmin edilen kelime yanlışsa
      var guessedLetters = guessedWord.split(''); // Tahmin edilen harfleri ayır

      for (int i = 0; i < guessedLetters.length; i++) {
        if (guessedLetters[i] == correctWordChars[i]) {
          // Tahmin edilen harf doğruysa
          tilesEntered[currentRow * maxTiles + i].answerStage =
              AnswerStage.correct; // Doğru cevap bayrağını ayarla
          correctWordChars[i] = ''; // Kullanıldı olarak işaretle
        }
      }

      for (int i = 0; i < guessedLetters.length; i++) {
        if (tilesEntered[currentRow * maxTiles + i].answerStage !=
                AnswerStage.correct &&
            correctWordChars.contains(guessedLetters[i])) {
          // Tahmin edilen harf yanlışsa ve doğru kelimenin harfleri içeriyorsa
          tilesEntered[currentRow * maxTiles + i].answerStage =
              AnswerStage.contains; // İçeriyor bayrağını ayarla
          correctWordChars[correctWordChars.indexOf(guessedLetters[i])] =
              ''; // Kullanıldı olarak işaretle
        } else if (tilesEntered[currentRow * maxTiles + i].answerStage ==
            AnswerStage.notAnswered) {
          tilesEntered[currentRow * maxTiles + i].answerStage =
              AnswerStage.incorrect; // Yanlış bayrağını ayarla
        }
      }
    }

    checkLine = true; // Satırı kontrol edildi bayrağını ayarla
    currentRow++; // Mevcut satırı bir arttır
    if (currentRow == maxTiles) {
      // Mevcut satır maksimum kutuya ulaştıysa
      gameCompleted = true; // Oyun tamamlandı bayrağını ayarla
    }
    if (gameCompleted) {
      calculateStats(gameWon: gameWon); // Oyun istatistiklerini hesapla
      // if (gameWon) setChartStats(currentRow: currentRow); // Grafik istatistiklerini ayarla (kullanılacaksa)
    }

    notifyListeners(); // Değişiklikleri bildir
  }

  // İndexe göre harfi al
  getLetterAt(int index) {
    return tilesEntered.length > index ? tilesEntered[index].letter : "";
  }

  void revealRandomLetter() {
    int randomIndex = _random.nextInt(correctWord.length); // Rastgele index seç
    revealedIndexes[randomIndex] = true; // Bu indexi açık olarak işaretle
}
}