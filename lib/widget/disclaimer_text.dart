import 'package:flutter/material.dart';

/// Widget dialog pemberitahuan (disclaimer) yang muncul sebelum
/// pengguna menggunakan fitur deteksi ekspresi wajah.
class DisclaimerDialog extends StatelessWidget {
  const DisclaimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // === Deklarasi gaya teks umum ===
    final textStyle = TextStyle(
      fontSize: 15,
      height: 1.5,
      color: Colors.grey[800],
    );

    // Gaya teks tebal (untuk bagian penting)
    final boldStyle = textStyle.copyWith(fontWeight: FontWeight.bold);

    return AlertDialog(
      // === Bentuk dialog dengan sudut melengkung ===
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      // === Judul dialog dengan ikon dan teks ===
      title: Row(
        children: [
          Icon(Icons.info_outline, size: 32, color: Colors.blue[700]),
          const SizedBox(width: 16),
          Text(
            'Pemberitahuan',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),

      // === Isi dialog ===
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Poin 1: Tujuan aplikasi
            _buildBulletPoint(
              icon: Icons.remove_red_eye_outlined,
              text: 'Aplikasi ini hanya untuk keperluan pemantauan ekspresi wajah.',
              style: textStyle,
            ),

            // 🔹 Poin 2: Jenis ekspresi yang dapat dideteksi
            _buildBulletPoint(
              icon: Icons.emoji_emotions_outlined,
              text: 'Dapat mendeteksi 5 ekspresi: '
                  '${["Senang", "Sedih", "Marah", "Terkejut", "Bosan"].join(", ")}.',
              style: textStyle,
            ),

            // 🔹 Poin 3: Privasi pengguna
            _buildBulletPoint(
              icon: Icons.lock_outline,
              text: 'FeelCheck menjaga privasi Anda.\n'
                  'Hasil gambar hanya tersimpan di perangkat Anda dan tidak '
                  'disimpan di server manapun.',
              style: textStyle,
            ),

            const SizedBox(height: 12),

            // 🔹 Teks tambahan penegasan
            Text(
              'Dengan melanjutkan, Anda menyetujui ketentuan penggunaan fitur ini.',
              style: boldStyle,
            ),
          ],
        ),
      ),

      // === Tombol aksi di bagian bawah dialog ===
      actions: [
        ElevatedButton(
          // Menutup dialog saat ditekan
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Saya Mengerti',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// Widget pembantu untuk membuat poin dengan ikon di depan teks.
  ///
  /// Digunakan untuk menampilkan daftar poin seperti privasi, fungsi, dll.
  Widget _buildBulletPoint({
    required IconData icon,
    required String text,
    required TextStyle style,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
