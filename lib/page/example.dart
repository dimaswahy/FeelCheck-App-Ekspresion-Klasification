import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Halaman ExamplePage
/// Menampilkan petunjuk dan tips pengambilan gambar wajah agar hasil deteksi lebih akurat.
class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Daftar tips yang akan ditampilkan dalam bentuk poin bernomor
    final List<String> tips = [
      'Pastikan wajah terlihat jelas dan tidak terhalang.',
      'Pencahayaan cukup (hindari cahaya belakang).',
      'Fokus dan tidak blur.',
      'Buatlah ekspresi wajah natural.',
      'Posisi kamera sejajar dengan wajah.',
    ];

    return Scaffold(
      // === BAGIAN ATAS (APPBAR) ===
      appBar: AppBar(
        flexibleSpace: Container(
          // Memberikan efek gradasi biru pada AppBar
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // Tombol kembali ke halaman sebelumnya
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Petunjuk Pengambilan Gambar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),

      // === BAGIAN UTAMA (BODY) ===
      body: SizedBox.expand( // memastikan Stack memenuhi seluruh layar
        child: Stack(
          children: [
            // === BACKGROUND GRADIENT ===
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // === BACKGROUND PATTERN DARI FILE SVG ===
            Positioned.fill(
              child: SizedBox.expand(
                child: SvgPicture.asset(
                  'assets/illustration/background_pattern.svg',
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.15), // membuat pola lebih lembut
                    BlendMode.srcATop,
                  ),
                ),
              ),
            ),

            // === ISI UTAMA HALAMAN ===
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 5),

                    // === GAMBAR CONTOH ===
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/gambar/contoh.png',
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // === KARTU YANG BERISI DAFTAR TIPS ===
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tips Pengambilan Gambar:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E88E5),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // === LOOPING UNTUK MENAMPILKAN LIST TIPS ===
                            Column(
                              children: List.generate(tips.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // === NOMOR DALAM LINGKARAN KECIL ===
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E88E5),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}', // nomor urut
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // === TEKS TIPS ===
                                      Expanded(
                                        child: Text(
                                          tips[index],
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // === TOMBOL KONFIRMASI "SAYA MENGERTI" ===
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, // agar gradien terlihat
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // Ketika ditekan, kembali ke halaman sebelumnya
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Saya Mengerti',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
