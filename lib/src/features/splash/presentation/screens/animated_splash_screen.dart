import 'dart:async';
import 'package:nai/src/imports/core_imports.dart';
import 'package:nai/src/imports/packages_imports.dart';

/// Custom animated splash shown right after Flutter's engine starts —
/// native splash (flutter_native_splash) can't animate, this can.
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.15).chain(CurveTween(curve: Curves.easeOutBack)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
    ]).animate(_controller);

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 2000), widget.onComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: child,
              ),
            );
          },
          child: Image.asset(
            'assets/icons/nai_logo.png',
            width: 140,
            height: 140,
          ),
        ),
      ),
    );
  }
}
