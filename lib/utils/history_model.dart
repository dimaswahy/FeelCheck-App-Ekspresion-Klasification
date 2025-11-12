import 'package:hive/hive.dart';

/// Model data untuk menyimpan riwayat hasil deteksi ekspresi wajah.
/// 
/// Kelas ini menggunakan anotasi `@HiveType` dan `@HiveField`
/// agar bisa disimpan secara lokal menggunakan database Hive.
@HiveType(typeId: 0) // ID unik adapter, harus sama dengan yang ada di HistoryModelAdapter
class HistoryModel extends HiveObject {
  /// Jenis ekspresi wajah (misalnya: senang, sedih, marah, dll)
  @HiveField(0)
  String expression;

  /// Lokasi (path) file gambar yang digunakan untuk deteksi
  @HiveField(1)
  String imagePath;

  /// Waktu dan tanggal saat data ini disimpan
  @HiveField(2)
  DateTime dateTime;

  /// Menyimpan apakah hasil deteksi benar (true) atau salah (false)
  @HiveField(3)
  bool isCorrect;

  /// Konstruktor utama untuk membuat objek [HistoryModel].
  /// Semua field wajib diisi saat membuat objek baru.
  HistoryModel({
    required this.expression,
    required this.imagePath,
    required this.dateTime,
    required this.isCorrect,
  });
}
