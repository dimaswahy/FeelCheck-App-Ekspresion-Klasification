import 'dart:async';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:feelcheck/page/utama.dart';
import 'package:flutter/material.dart';

class Landingpage extends StatefulWidget {
  const Landingpage({super.key});

  @override
  _LandingpageState createState() => _LandingpageState();
}

class _LandingpageState extends State<Landingpage> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Start fade-in animation
    Timer(const Duration(milliseconds: 200), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Fade out before navigating
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _opacity = 0.0;
      });

      // Delay for fade-out animation before navigating
      Timer(const Duration(milliseconds: 500), () {
        Navigator.of(context).pushReplacement(_createRoute());
      });
    });
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const UtamaPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut));

        return FadeTransition(
          opacity: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 248, 248, 248)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 500),
              child: const LoadingAnimation(),
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/logo/logo edit.png',
          width: 200,
          height: 200,
        ),
        const SizedBox(height: 20),
        Image.asset(
          'assets/logo/logo text.png',
          width: 250,
        ),
        const SizedBox(height: 40),
        const Text(
  'Kenali Emosi Dirimu Lebih Baik',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 22,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 0, 0, 0),
    letterSpacing: 1.2,
  ),
),

        const SizedBox(height: 50),
        LoadingAnimationWidget.horizontalRotatingDots(
          color: const Color.fromARGB(255, 107, 181, 241),
          size: 70,
        ),
      ],
    );
  }
}
