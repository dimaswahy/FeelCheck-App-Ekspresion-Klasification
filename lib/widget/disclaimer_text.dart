import 'package:flutter/material.dart';

class DisclaimerDialog extends StatelessWidget {
  const DisclaimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 15, height: 1.5, color: Colors.grey[800]);
    final boldStyle = textStyle.copyWith(fontWeight: FontWeight.bold);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.info_outline, size: 32, color: Colors.blue[700]),
          const SizedBox(width: 16),
          Text(
            'Pemberitahuan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBulletPoint(
              icon: Icons.remove_red_eye_outlined,
              text: 'Aplikasi ini hanya untuk keperluan pemantauan ekspresi wajah.',
              style: textStyle,
            ),
            _buildBulletPoint(
              icon: Icons.emoji_emotions_outlined,
              text: 'Dapat mendeteksi 5 ekspresi: '
                  '${["Senang", "Sedih", "Marah", "Terkejut", "Bosan"].join(", ")}.',
              style: textStyle,
            ),
            _buildBulletPoint(
              icon: Icons.lock_outline,
              text: 'FeelCheck menjaga privasi Anda.\n'
                  'Hasil gambar hanya tersimpan di perangkat Anda dan tidak '
                  'disimpan di server manapun.',
              style: textStyle,
            ),
            const SizedBox(height: 12),
            Text(
              'Dengan melanjutkan, Anda menyetujui ketentuan penggunaan fitur ini.',
              style: boldStyle,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Saya Mengerti', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildBulletPoint({required IconData icon, required String text, required TextStyle style}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}
