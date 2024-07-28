import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class GirisEkrani extends StatefulWidget {
  const GirisEkrani({Key? key}) : super(key: key);

  @override
  _GirisEkraniState createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giriş Ekranı"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink),
                ),
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.purple),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10.0),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink),
                ),
                labelText: "Şifre",
                labelStyle: TextStyle(color: Colors.purple),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            MaterialButton(
              color: Colors.purple,
              textColor: Colors.white,
              child: const Text('Giriş Yap'),
              onPressed: _signIn,
            ),
          ],
        ),
      ),
    );
  }

  void _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (userCredential.user != null) {
        Navigator.pushReplacementNamed(context, '/oyunekrani');
      }
    } catch (e) {
      print('Giriş hatası: $e');
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Giriş Hatası'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Tamam'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}


