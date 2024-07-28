import 'package:flutter/material.dart';

// 'Dance' adında bir StatefulWidget tanımlanıyor.
class Dance extends StatefulWidget {
  // 'child', 'animate' ve 'delay' adında üç parametre alıyor.
  // 'child' parametresi, bu widget içinde gösterilecek olan widget'ı temsil ediyor.
  // 'animate' parametresi, animasyonun tetiklenip tetiklenmeyeceğini belirliyor.
  // 'delay' parametresi ise animasyonun başlama gecikmesini milisaniye cinsinden belirliyor.
  const Dance(
      {required this.child,
      required this.animate,
      required this.delay,
      super.key});

  final Widget child; // Gösterilecek widget.
  final bool animate; // Animasyon durumu.
  final int delay; // Animasyon gecikmesi.

  @override
  State<Dance> createState() =>
      _DanceState(); // Widget'ın state'ini oluşturuyor.
}

// '_DanceState' sınıfı, 'Dance' widget'ının durumunu yönetir.
class _DanceState extends State<Dance> with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Animasyon kontrolcüsü.
  late Animation<Offset> _animation; // Animasyonun offset değerleri.

  @override
  void initState() {
    super.initState();
    // AnimationController, animasyonun süresini ve vsync'i (dikey senkronizasyonu) ayarlar.
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    // TweenSequence, birden fazla Tween'in bir araya geldiği bir animasyon dizisidir.
    // Bu örnekte, widget önce yukarı kaydırılıyor, sonra eski pozisyonuna dönüyor, daha az bir yüksekliğe tekrar kaydırılıyor ve son olarak eski pozisyonuna dönüyor.
    _animation = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0, 0), end: const Offset(0, -0.80)),
          weight: 15),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0, -0.80), end: const Offset(0, 0)),
          weight: 10),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0, 0), end: const Offset(0, -0.30)),
          weight: 12),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0, -0.30), end: const Offset(0, 0)),
          weight: 8),
    ]).animate(CurvedAnimation(
        parent: _controller, curve: Curves.easeInOutSine)); // Animasyon eğrisi.
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Widget yok edildiğinde AnimationController'ı da yok eder.
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Dance oldWidget) {
    // Eğer 'animate' true ise ve belirlenen gecikme süresi geçtiyse animasyon başlatılır.
    if (widget.animate) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) {
          // Widget hala ekran üzerindeyse animasyonu başlat.
          _controller.forward(); // Animasyonu başlat.
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // SlideTransition, çocuk widget'ın kayma hareketiyle animasyonunu sağlar.
    return SlideTransition(
      position: _animation, // Animasyonun uygulanacağı özellik.
      child: widget.child, // Gösterilecek widget.
    );
  }
}
