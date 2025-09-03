import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:feelcheck/main.dart'; // ganti dengan path main app Anda
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Menampilkan teks 'Gambar Belum Diunggah' saat belum upload",
      (tester) async {
    await tester.pumpWidget(MyApp());

    // Pastikan teks default muncul
    expect(find.text("Gambar Belum Diunggah"), findsOneWidget);
    expect(find.text("N/A"), findsOneWidget);
  });

  testWidgets("Tombol upload bisa ditekan", (tester) async {
    await tester.pumpWidget(MyApp());

    // Cari tombol berdasarkan ValueKey
    final uploadButton = find.byKey(ValueKey("btn_upload"));

    expect(uploadButton, findsOneWidget);

    // Tap tombol upload
    await tester.tap(uploadButton);
    await tester.pumpAndSettle();

    // (di sini Anda bisa expect hasilnya, misalnya muncul dialog pilih gambar)
    // Contoh:
    // expect(find.text("Pilih Gambar"), findsOneWidget);
  });
}
