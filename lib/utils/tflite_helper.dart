import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

/// Helper class untuk memproses gambar dan melakukan inferensi (klasifikasi)
/// menggunakan model TensorFlow Lite (.tflite).
class TFLiteHelper {
  Interpreter? _interpreter; // Objek interpreter untuk menjalankan model TFLite
  List<String>? _labels; // Daftar label hasil klasifikasi

  /// Memuat model TFLite dan file label dari folder assets.
  Future<void> loadModel() async {
    try {
      // Memuat model dari folder assets
      _interpreter = await Interpreter.fromAsset('assets/emosi.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }

    // Membaca file label (label_klasifikasi.txt)
    final labelsData = await rootBundle.loadString('assets/label_klasifikasi.txt');

    // Memisahkan label per baris dan menghapus baris kosong
    _labels = labelsData
        .split('\n')
        .where((element) => element.trim().isNotEmpty)
        .toList();
  }

  /// Melakukan klasifikasi pada gambar dan mengembalikan hasil berupa
  /// Map<String, double> di mana key = nama ekspresi, value = nilai confidence.
  Future<Map<String, double>> classifyImage(File image) async {
    // Jika model atau label belum dimuat, muat dulu
    if (_interpreter == null || _labels == null) {
      await loadModel();
    }

    // Ubah gambar menjadi tensor input (List 4D)
    var input = _processRawImage(image); // Bentuk: [1, 244, 244, 3]

    // Siapkan output array sesuai jumlah label
    var output = List.generate(1, (_) => List.filled(_labels!.length, 0.0));

    // Jalankan model dengan input dan output
    _interpreter!.run(input, output);

    print("Output values: ${output[0]}");

    // Gabungkan hasil ke dalam Map: label → confidence
    Map<String, double> results = {};
    for (int i = 0; i < _labels!.length; i++) {
      results[_labels![i]] = output[0][i];
    }

    return results;
  }

  /// Fungsi untuk memproses gambar mentah agar sesuai dengan input model TFLite.
  ///
  /// Proses yang dilakukan:
  /// 1. Membaca file gambar
  /// 2. Decode ke format image (pakai package `image`)
  /// 3. Ubah ukuran ke [244 x 244]
  /// 4. Normalisasi pixel ke rentang [0, 1]
  /// 5. Hasil akhir berbentuk [1, 244, 244, 3] (batch size = 1)
  List<List<List<List<double>>>> _processRawImage(File imageFile) {
    // Baca file menjadi bytes
    final raw = imageFile.readAsBytesSync();

    // Decode gambar menjadi objek img.Image
    final image = img.decodeImage(raw)!;

    // Ubah ukuran gambar menjadi 244x244 (sesuai model)
    final resizedImage = img.copyResize(image, width: 244, height: 244);

    // Konversi gambar ke array 4D: [batch, height, width, channels]
    List<List<List<List<double>>>> input = List.generate(
      1, // batch size = 1
      (_) => List.generate(
        244, // tinggi
        (y) => List.generate(
          244, // lebar
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r / 255.0, // normalisasi channel R
              pixel.g / 255.0, // normalisasi channel G
              pixel.b / 255.0, // normalisasi channel B
            ];
          },
        ),
      ),
    );

    return input;
  }
}
