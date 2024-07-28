import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:yazlab22/home_page.dart';
import 'package:yazlab22/saglayıcılar/controller.dart';
import 'package:yazlab22/wordEntryPage.dart';

class Oda extends StatefulWidget {
  final int roomNumber; // Oda numarası
  final int roomType; // Oda türü

  Oda({required this.roomNumber, required this.roomType});

  @override
  _OdaState createState() => _OdaState();
}

class _OdaState extends State<Oda> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final DatabaseReference _dbRef;
  Timer? _responseTimer;
  String? opponentWord; // Define opponentWord here

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase(
        databaseURL:
            '**********');
    _dbRef = database.ref().child('odalar');
    addUserToRoomFromFirestore();
    getGameRequest();
  }

  void addUserToRoomFromFirestore() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      var firestoreInstance = FirebaseFirestore.instance;
      var userDoc = await firestoreInstance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      String userName = userDoc.data()?['name'] ?? '?';
      String roomPath =
          '${widget.roomType}/${widget.roomNumber}/oyuncular/${currentUser.uid}';
      await _dbRef.child(roomPath).set({'name': userName, 'online': true});
      _dbRef.child(roomPath).onDisconnect().update({'online': false});
    }
  }

  void getGameRequest() {
    String userId = _auth.currentUser?.uid ?? '';
    String incomingRequestPath =
        'game_requests/${widget.roomType}/${widget.roomNumber}/$userId';

    _dbRef.child(incomingRequestPath).onValue.listen((DatabaseEvent event) {
      var value = event.snapshot.value as Map<dynamic, dynamic>?;
      if (value != null && value['status'] == 'pending') {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text("Game Request"),
              content: Text(value['message']),
              actions: <Widget>[
                TextButton(
                  child: Text("Accept"),
                  onPressed: () {
                    _dbRef
                        .child(incomingRequestPath)
                        .update({'status': 'accepted'});
                    Navigator.of(dialogContext).pop();
                    startGame(widget.roomNumber, widget.roomType, userId,
                        value['requesterId'],context);
                  },
                ),
                TextButton(
                  child: Text("Decline"),
                  onPressed: () {
                    _dbRef.child(incomingRequestPath).remove();
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  void sendGameRequest(
      String userId, int roomNumber, int roomType, BuildContext context) {
    String requestPath = 'game_requests/$roomType/$roomNumber/$userId';
    String message =
        '${_auth.currentUser?.displayName ?? "Someone"} wants to play with you. Play?';

    _dbRef.child(requestPath).set({
      'requesterId': _auth.currentUser?.uid,
      'status': 'pending',
      'message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Oyun İsteği"),
          content: Text("Oyun isteği gönderildi. Cevap bekleniyor..."),
          actions: <Widget>[
            TextButton(
              child: Text("İptal"),
              onPressed: () {
                _dbRef.child(requestPath).remove();
                Navigator.of(dialogContext).pop();
                _responseTimer?.cancel();
              },
            ),
          ],
        );
      },
    );

    _responseTimer = Timer(Duration(seconds: 10), () {
      Navigator.of(context, rootNavigator: true).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("İstek zaman aşımına uğradı veya reddedildi.")));
      _dbRef.child(requestPath).remove();
    });

    _dbRef.child(requestPath).onValue.listen((event) {
      var value = event.snapshot.value as Map<dynamic, dynamic>?;
      if (value != null && value['status'] == 'accepted') {
        _responseTimer?.cancel();
        Navigator.of(context, rootNavigator: true).pop(); // Close the dialog
        startGame(roomNumber, roomType, userId, value['requesterId'],context);
      }
    });
  }

void startGame(int roomNumber, int roomType, String userId, String rakipid,
      BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => WordEntryPage(
              wordLength:
                  roomNumber, // wordLength yerine roomNumber parametresini kullanıyoruz
              roomNumber:
                  roomNumber, // WordEntryPage'de kullanılabilirse, roomNumber parametresini geçiyoruz
              roomType: roomType,
              rakipid: rakipid,
              // WordEntryPage'de kullanılabilirse, roomType parametresini geçiyoruz
    )));
}

  @override
  Widget build(BuildContext context) {
    Stream<DatabaseEvent> roomStream = _dbRef
        .child('${widget.roomType}/${widget.roomNumber}/oyuncular')
        .onValue;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Oda ${widget.roomNumber} Kullanıcıları'),
          actions: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop(); // Geri gitme işlemi
              },
            ),

          ],
        ),
        body: StreamBuilder<DatabaseEvent>(
          stream: roomStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Hata: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            Map<dynamic, dynamic> players = {};
            if (snapshot.data?.snapshot.value != null) {
              players = Map<dynamic, dynamic>.from(
                  snapshot.data!.snapshot.value as Map);
            }

            return ListView(
              children: players.entries.map((entry) {
                return ListTile(
                  title: Text(entry.value['name']),
                  trailing: Wrap(
                    spacing: 12, // space between two icons
                    children: <Widget>[
                      Icon(Icons.circle,
                          color: entry.value['online']
                              ? Colors.green
                              : Colors.grey),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.pink, // Text color
                          ),
                          onPressed: () {
                            if (_responseTimer == null ||
                                !_responseTimer!.isActive) {
                              sendGameRequest(entry.key, widget.roomNumber,
                                  widget.roomType, context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      "Zaten bir istekte bulunulmuş. Lütfen cevap bekleyin.")));
                            }
                          },
                          child: Text('Oyna')),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
