import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yazlab22/araclar/theme_preferences.dart';
import 'package:yazlab22/girisekrani.dart';  // Giriş ekranı dosyası
import 'package:yazlab22/kayit_ekrani.dart'; // Kayıt ekranı dosyası
import 'package:yazlab22/oyun_ekrani.dart';  // Oyun ekranı dosyasını import et
import 'package:firebase_core/firebase_core.dart';
import 'package:yazlab22/sabitler/themes.dart';
import 'package:yazlab22/saglayıcılar/controller.dart';
import 'package:yazlab22/saglayıcılar/theme_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Const yapıcı. Key parametresi, widget ağacında widget'ı benzersiz kılmak için kullanılır.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Controller()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: FutureBuilder(
        initialData: false,
        future: ThemePreferences.getTheme(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Provider.of<ThemeProvider>(context, listen: false)
                  .setTheme(turnOn: snapshot.data as bool);
            });
          }
          
          return Consumer<ThemeProvider>(
            builder: (_, notifier, __) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Wordle Clone',
              theme: notifier.isDark ? darkTheme : lightTheme,
              initialRoute: '/kayitekrani',  // Başlangıç rotası olarak kayıt ekranını belirler
              routes: {
                '/kayitekrani': (context) => const KayitEkrani(),
                '/girisekrani': (context) => const GirisEkrani(),
                '/oyunekrani': (context) => const OyunEkrani(),  // Oyun ekranına rota
                '/useremails': (context) => const UserEmailScreen(), // Kullanıcı e-posta ekranına rota
              },
              home:
                  const OyunEkrani(), // Ana giriş ekranını başlatmak için değişiklik yapıldı.
            ),
          );
        },
      ),
    );
  }
}

class UserEmailScreen extends StatelessWidget {
  const UserEmailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Burada kullanıcıların e-posta adreslerini getirip göstermek için kod yazabilirsiniz.
    return Scaffold(
      appBar: AppBar(
        title: Text('Kullanıcı E-postaları'),
      ),
      body: Center(
        child: Text('Kullanıcı e-postaları burada listelenecek.'),
      ),
    );
  }
}
