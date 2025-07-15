import 'package:feelcheck/page/example.dart';
import 'package:feelcheck/page/landingpage.dart';
import 'package:feelcheck/page/riwayat.dart';
import 'package:feelcheck/utils/history_model.dart';
import 'package:feelcheck/utils/history_model_adaptor.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
 // Import model adapter

/// Global RouteObserver untuk kebutuhan observer navigasi di halaman lain
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(HistoryModelAdapter());

  await Hive.openBox<HistoryModel>('historyBox');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FeelCheck',
      debugShowCheckedModeBanner: false,

      /// Konfigurasi tema global
      theme: ThemeData(
        useMaterial3: true,
      ),

      /// Tambahkan observer global
      navigatorObservers: [routeObserver],

      /// Set initial route
      initialRoute: '/',

      /// Define semua route
      routes: {
        '/': (context) =>  const Landingpage(),
        '/example': (context) => const ExamplePage(),
        '/riwayat': (context) => const RiwayatPage(),
      },
    );
  }
}
