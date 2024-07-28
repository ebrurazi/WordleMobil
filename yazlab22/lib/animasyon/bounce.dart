import 'package:flutter/material.dart';

// 'Bounce' adında bir StatefulWidget tanımlanıyor.
class Bounce extends StatefulWidget {
  // 'child' ve 'animate' adında iki parametre alıyor.
  // 'child' parametresi, bu widget içinde gösterilecek olan widget'ı temsil ediyor.
  // 'animate' parametresi, animasyonun tetiklenip tetiklenmeyeceğini belirliyor.
  const Bounce({required this.child, required this.animate, super.key});

  final Widget child; // Gösterilecek widget.
  final bool animate; // Animasyon durumu.

  @override
  State<Bounce> createState() =>
      _BounceState(); // Widget'ın state'ini oluşturuyor.
}

// '_BounceState' sınıfı, 'Bounce' widget'ının durumunu yönetir.
class _BounceState extends State<Bounce> with SingleTickerProviderStateMixin {
  late AnimationController _animationController; // Animasyon kontrolcüsü.
  late Animation<double> _animation; // Animasyon değerleri.

  @override
  void initState() {
    super.initState();
    // AnimationController, animasyonun süresini ve vsync'i (dikey senkronizasyonu) ayarlar.
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);

    // TweenSequence, birden fazla Tween'in bir araya geldiği bir animasyon dizisidir.
    // Bu örnekte, widget önce büyütülüyor sonra eski boyutuna dönüyor.
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.30), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.30, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.bounceInOut)); // Animasyon eğrisi.
  }

  @override
  void dispose() {
    _animationController
        .dispose(); // Widget yok edildiğinde AnimationController'ı da yok eder.
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Bounce oldWidget) {
    // Eğer 'animate' true ise animasyon başlatılır.
    if (widget.animate) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) {
          // Widget hala ekran üzerindeyse animasyonu başlat.
          _animationController.reset(); // Animasyonu sıfırla.
          _animationController.forward(); // Animasyonu başlat.
        }
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // ScaleTransition, çocuk widget'ın ölçeklenmesini sağlayan bir animasyon widget'ıdır.
    return ScaleTransition(
      scale: _animation, // Animasyonun uygulanacağı özellik.
      child: widget.child, // Gösterilecek widget.
    );
  }
}
