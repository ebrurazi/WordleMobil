// ignore_for_file: sort_child_properties_last

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yazlab22/firestore/firestore_data.dart';
import 'package:yazlab22/girisekrani.dart';

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  String? username;
  String? email;
  String? password;
  
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreData _firestoreData = FirestoreData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                  labelText: "Kullanıcı Adı",
                  labelStyle: TextStyle(color: Colors.purple),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Kullanıcı adını giriniz";
                  }
                  return null;
                },
                onSaved: (value) {
                  username = value;
                },
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                  labelText: "email",
                  labelStyle: TextStyle(color: Colors.purple),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "email giriniz";
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value;
                },
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                  labelText: "Şifre",
                  labelStyle: TextStyle(color: Colors.purple),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Şifreyi giriniz";
                  }
                  return null;
                },
                onSaved: (value) {
                  password = value;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  MaterialButton(
                    color: Colors.purple,
                    textColor: Colors.white,
                    child: const Text("Kaydol"),
                    onPressed: () {
                      _registerUser();
                    },
                  ),
                  MaterialButton(
                    color: Colors.purple,
                    textColor: Colors.white,
                    child: const Text("Giriş yap "),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GirisEkrani()),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
/*void registerAndAddUser(String email, String password, String email) async {
  User? user = await registerWithEmailPassword(email, password);
  if (user != null) {
    await addUserToFirestore(user, email);
  }
}*/

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email!,
          password: password!,
        );
        await _firestoreData.registerUser(
          name: username.toString(),
          email: email.toString(),
          password: password.toString(),
          id: _auth.currentUser!.uid,
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GirisEkrani()),
        );
        debugPrint("Kullanıcı kaydı başarılı: ${userCredential.user!.uid}");
        //  Navigator.pushReplacement(
        /* context,
          MaterialPageRoute(builder: (context) => GirisEkrani()),
        );*/
      } catch (e) {
        debugPrint("Firebase kayıt hatası: $e");
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Kayıt Hatası"),
              content: Text(e.toString()),
              actions: <Widget>[
                MaterialButton(
                  child: const Text("Geri Dön"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  //registerWithEmailPassword(String email, String password) {}
}
