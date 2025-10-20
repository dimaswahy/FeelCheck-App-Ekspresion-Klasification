import 'dart:async';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:feelcheck/page/utama.dart';
import 'package:flutter/material.dart';

/// Halaman awal (Splash Screen) yang menampilkan logo, teks, dan animasi loading
/// Sebelum masuk ke halaman utama (UtamaPage)
class Landingpage extends StatefulWidget {
  const Landingpage({super.key});

  @override
  _LandingpageState createState() => _LandingpageState();
}

class _LandingpageState extends State<Landingpage> with SingleTickerProviderStateMixin {
  // Variabel untuk mengatur transparansi (fade in/out)
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // === MULAI ANIMASI FADE-IN SETELAH 200ms ===
    Timer(const Duration(milliseconds: 200), () {
      setState(() {
        _opacity = 1.0; // tampil perlahan
      });
    });

    // === SETELAH 2 DETIK, MULAI FADE-OUT DAN LANJUT KE HALAMAN UTAMA ===
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _opacity = 0.0; // mulai menghilang
      });

      // Tunggu 0.5 detik (untuk animasi fade-out selesai) baru pindah halaman
      Timer(const Duration(milliseconds: 500), () {
        Navigator.of(context).pushReplacement(_createRoute());
      });
    });
  }

  /// Fungsi untuk membuat transisi halaman ke UtamaPage dengan efek Fade
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const UtamaPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Tween untuk animasi opacity (transparansi)
        var tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut));

        return FadeTransition(
          opacity: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 500), // durasi animasi transisi
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // === LATAR BELAKANG DENGAN GRADIENT PUTIH KE ABU MUDA ===
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 248, 248, 248)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          // AnimatedOpacity digunakan agar tampilan muncul dan menghilang dengan halus
          child: Center(
            child: AnimatedOpacity(
              opacity: _opacity, // nilai opacity dikontrol oleh variabel _opacity
              duration: const Duration(milliseconds: 500), // durasi efek fade
              child: const LoadingAnimation(), // isi tampilan splash
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget yang menampilkan isi dari splash screen:
/// Logo aplikasi, teks motivasi, dan animasi loading
class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // posisi di tengah layar
      children: [
        // === LOGO UTAMA (ikon aplikasi) ===
        Image.asset(
          'assets/logo/logo edit.png',
          width: 200,
          height: 200,
        ),
        const SizedBox(height: 20),

        // === LOGO TEKS (nama aplikasi) ===
        Image.asset(
          'assets/logo/logo text.png',
          width: 250,
        ),
        const SizedBox(height: 40),

        // === TEKS SLOGAN / TAGLINE ===
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

        // === ANIMASI LOADING (titik berputar horizontal) ===
        LoadingAnimationWidget.horizontalRotatingDots(
          color: const Color.fromARGB(255, 107, 181, 241), // warna biru muda
          size: 70, // ukuran animasi
        ),
      ],
    );
  }
}
