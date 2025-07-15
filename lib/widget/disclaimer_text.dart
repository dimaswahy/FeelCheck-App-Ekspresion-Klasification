import 'package:flutter/material.dart';

class DisclaimerDialog extends StatelessWidget {
  const DisclaimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.info_outline, size: 32, color: Colors.blue[700]),
          const SizedBox(width: 30),
          const Text('Pemberitahuan'),
        ],
      ),
      content: const SingleChildScrollView(
        child: Text(
          '• Aplikasi ini hanya untuk keperluan pemantauan ekspresi wajah.\n'
          '• Dapat mendeteksi 5 ekspresi: Senang, Sedih, Marah, Terkejut, Bosan.\n'
          '• FeelCheck menjaga privasi Anda, Hasil gambar hanya tersimpan di perangkat anda dan tidak menyimpan gambar di server manapun.\n\n'
          'Dengan melanjutkan, Anda menyetujui ketentuan penggunaan fitur ini.',
          style: TextStyle(fontSize: 15, height: 1.4),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Saya Mengerti'),
        ),
      ],
    );
  }
}
