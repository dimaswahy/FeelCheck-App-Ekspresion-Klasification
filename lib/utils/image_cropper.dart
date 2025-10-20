import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Kelas untuk menampung data yang akan dikirim ke isolate (proses terpisah)
/// 
/// [bytes] → data gambar dalam bentuk byte (Uint8List)
/// [rect]  → area persegi panjang yang ingin di-crop (dipotong)
class CropParams {
  final Uint8List bytes;
  final Rect rect;

  CropParams(this.bytes, this.rect);
}

/// Fungsi utama untuk membaca file gambar dari penyimpanan dan melakukan cropping.
/// 
/// Fungsi ini:
/// - Membaca gambar dari file
/// - Menjalankan proses cropping di isolate terpisah agar tidak mengganggu UI
/// 
/// [file] → file gambar yang akan diolah
/// [rect] → area yang ingin di-crop (koordinat x, y, lebar, tinggi)
Future<img.Image?> decodeAndCrop(File file, Rect rect) async {
  // Baca file menjadi bytes
  final bytes = await file.readAsBytes();

  // Jalankan proses decoding dan cropping di isolate terpisah
  // dengan fungsi `_decodeAndCropIsolate`
  return compute(_decodeAndCropIsolate, CropParams(bytes, rect));
}

/// Fungsi yang dijalankan di isolate untuk decoding dan cropping gambar.
/// 
/// Fungsi ini dipisahkan dari thread utama agar proses berat
/// seperti decoding gambar tidak menyebabkan UI menjadi lag.
/// 
/// [params] → berisi data gambar (bytes) dan area crop (rect)
img.Image? _decodeAndCropIsolate(CropParams params) {
  // Decode gambar dari bytes menjadi objek img.Image
  final decoded = img.decodeImage(params.bytes);
  if (decoded == null) return null; // Jika gagal decode, kembalikan null

  // Pastikan nilai koordinat crop tidak keluar dari batas gambar
  final cropX = params.rect.left.toInt().clamp(0, decoded.width - 1);
  final cropY = params.rect.top.toInt().clamp(0, decoded.height - 1);
  final cropW = params.rect.width.toInt().clamp(1, decoded.width - cropX);
  final cropH = params.rect.height.toInt().clamp(1, decoded.height - cropY);

  // Lakukan pemotongan (cropping) gambar sesuai area yang diberikan
  return img.copyCrop(
    decoded,
    x: cropX,
    y: cropY,
    width: cropW,
    height: cropH,
  );
}
