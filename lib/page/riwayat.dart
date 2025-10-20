import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/history_model.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Membuka box Hive yang menyimpan data riwayat
    final historyBox = Hive.box<HistoryModel>('historyBox');

    // Format tanggal dan waktu untuk ditampilkan di list
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      // === BAGIAN APPBAR ===
      appBar: AppBar(
        // Background gradient untuk AppBar
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Riwayat",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        // Tombol kembali di kiri atas
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        // Tombol hapus semua riwayat di kanan atas
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            tooltip: 'Hapus Semua',
            onPressed: () async {
              // Menampilkan dialog konfirmasi sebelum menghapus semua data
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Konfirmasi"),
                  content: const Text(
                    "Hapus semua riwayat? Tindakan ini tidak dapat dibatalkan.",
                  ),
                  actions: [
                    // Tombol batal
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Batal"),
                    ),
                    // Tombol hapus
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Hapus"),
                    ),
                  ],
                ),
              );

              // Jika pengguna menekan "Hapus", bersihkan semua isi box
              if (confirm == true) {
                await historyBox.clear();
              }
            },
          ),
        ],
      ),

      // === BAGIAN BODY ===
      body: SizedBox.expand( // agar background menutupi seluruh layar
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

            // === BACKGROUND PATTERN SVG ===
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/illustration/background_pattern.svg',
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.15),
                  BlendMode.srcATop,
                ),
              ),
            ),

            // === KONTEN UTAMA (DAFTAR RIWAYAT) ===
            ValueListenableBuilder(
              // Dengarkan perubahan pada box Hive secara real-time
              valueListenable: historyBox.listenable(),
              builder: (context, Box<HistoryModel> box, _) {
                // Jika belum ada data riwayat
                if (box.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Ilustrasi kosong
                          SvgPicture.asset(
                            'assets/illustration/empty_history.svg',
                            width: 150,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Belum ada riwayat.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Balik urutan list agar data terbaru tampil di atas
                final reversedItems = box.values.toList().reversed.toList();

                // Tampilkan daftar riwayat
                return ListView.builder(
                  itemCount: reversedItems.length + 1, // +1 untuk teks "Batas Akhir"
                  itemBuilder: (context, index) {
                    // Bagian bawah daftar: teks "Batas Akhir"
                    if (index == reversedItems.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            "Batas Akhir.",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ),
                      );
                    }

                    // Ambil item riwayat berdasarkan index
                    final item = reversedItems[index];

                    // Format teks confidence
                    final confidenceText = item.confidence == 0.0
                        ? "kepercayaan: N/A"
                        : "kepercayaan: ${(item.confidence * 100).toStringAsFixed(1)}%";

                    // Kartu berisi data ekspresi wajah
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),

                        // Gambar hasil deteksi wajah
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(item.imagePath),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Teks utama: ekspresi dan confidence
                        title: Text(
                          "Ekspresi: ${item.expression}\n"
                          "$confidenceText",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        // Subjudul: waktu dan status benar/salah
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              children: [
                                // Waktu prediksi
                                TextSpan(
                                  text: "${dateFormat.format(item.dateTime)}\n",
                                ),
                                // Status validasi hasil ekspresi
                                TextSpan(
                                  text: item.isCorrect ? "Benar" : "Salah",
                                  style: TextStyle(
                                    color: item.isCorrect
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        isThreeLine: true, // agar teks tidak terpotong

                        // Tombol hapus satu riwayat
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            await item.delete(); // hapus item dari Hive
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
