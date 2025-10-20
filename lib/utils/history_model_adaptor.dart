import 'package:hive/hive.dart';
import 'history_model.dart';

/// Adapter untuk menyimpan dan membaca data [HistoryModel] di Hive.
/// 
/// TypeAdapter ini berfungsi sebagai penghubung antara model Dart (`HistoryModel`)
/// dan format biner Hive (agar data bisa disimpan secara lokal di perangkat).
class HistoryModelAdapter extends TypeAdapter<HistoryModel> {
  @override
  final int typeId = 0; // ID unik adapter ini di Hive (tidak boleh sama dengan adapter lain)

  @override
  HistoryModel read(BinaryReader reader) {
    // Membaca jumlah field (kolom) yang disimpan di dalam satu objek Hive
    final numOfFields = reader.readByte();

    // Membaca semua pasangan key-value dari field
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Ambil data dari field ke-2 (index 2) yang seharusnya berisi tanggal
    final rawDate = fields[2];
    DateTime dateTime;

    // Pastikan data tanggal dalam format yang benar (String atau DateTime)
    if (rawDate is String) {
      // Jika disimpan sebagai String, coba ubah ke DateTime
      dateTime = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is DateTime) {
      // Jika sudah dalam bentuk DateTime, langsung gunakan
      dateTime = rawDate;
    } else {
      // Jika tipe data tidak dikenali, lempar error
      throw Exception("Unsupported date type in Hive data for dateTime field");
    }

    // Mengembalikan objek HistoryModel dari data yang sudah dibaca
    return HistoryModel(
      expression: fields[0] as String,          // Nama ekspresi (senang, sedih, dll)
      imagePath: fields[1] as String,           // Path gambar hasil deteksi
      dateTime: dateTime,                       // Waktu penyimpanan data
      isCorrect: fields[3] as bool? ?? false,   // Status benar/salah (default: false)
      confidence: fields[4] as double? ?? 0.0,  // Tingkat kepercayaan (default: 0.0)
    );
  }

  @override
  void write(BinaryWriter writer, HistoryModel obj) {
    // Menulis data dari objek HistoryModel ke format biner Hive
    writer
      ..writeByte(5) // jumlah total field = 5 (harus sesuai dengan field di bawah)
      ..writeByte(0)
      ..write(obj.expression) // Simpan ekspresi
      ..writeByte(1)
      ..write(obj.imagePath)  // Simpan path gambar
      ..writeByte(2)
      ..write(obj.dateTime)   // Simpan tanggal/waktu
      ..writeByte(3)
      ..write(obj.isCorrect)  // Simpan status benar/salah
      ..writeByte(4)
      ..write(obj.confidence); // Simpan nilai confidence
  }
}
