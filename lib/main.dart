import 'package:feelcheck/page/example.dart';
import 'package:feelcheck/page/landingpage.dart';
import 'package:feelcheck/page/riwayat.dart';
import 'package:feelcheck/utils/history_model.dart';
import 'package:feelcheck/utils/history_model_adaptor.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 🔹 Import model adapter yang digunakan untuk menyimpan dan membaca data dari Hive

/// Global RouteObserver digunakan untuk memantau perubahan halaman (navigasi)
/// Misalnya: ketika berpindah halaman, bisa digunakan untuk logging atau animasi transisi.
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

void main() async {
  // 🔹 Pastikan binding Flutter sudah diinisialisasi sebelum menjalankan fungsi async
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inisialisasi Hive (database lokal berbasis key-value)
  await Hive.initFlutter();

  // 🔹 Registrasi adapter untuk model `HistoryModel`
  //    Agar Hive tahu cara menyimpan dan membaca objek `HistoryModel`
  Hive.registerAdapter(HistoryModelAdapter());

  // 🔹 Buka box (semacam tabel) untuk menyimpan data riwayat
  await Hive.openBox<HistoryModel>('historyBox');

  // 🔹 Jalankan aplikasi utama
  runApp(MyApp());
}

/// Widget utama aplikasi FeelCheck
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FeelCheck',
      debugShowCheckedModeBanner: false, // 🔹 Hilangkan label "Debug" di pojok kanan atas

      /// 🔹 Tema global aplikasi
      theme: ThemeData(
        useMaterial3: true, // Menggunakan desain Material 3 (versi terbaru)
      ),

      /// 🔹 Daftarkan Route Observer global
      ///    Digunakan untuk memantau navigasi antar halaman
      navigatorObservers: [routeObserver],

      /// 🔹 Halaman awal yang ditampilkan saat aplikasi dijalankan
      initialRoute: '/',

      /// 🔹 Daftar semua rute halaman (route map)
      ///    Mempermudah navigasi menggunakan `Navigator.pushNamed(context, '/riwayat')`
      routes: {
        '/': (context) => const Landingpage(), // Halaman pembuka (Splash / Loading)
        '/example': (context) => const ExamplePage(), // Halaman petunjuk pengambilan gambar
        '/riwayat': (context) => const RiwayatPage(), // Halaman daftar riwayat ekspresi
      },
    );
  }
}
