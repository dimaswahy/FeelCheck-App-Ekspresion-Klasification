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

    // Ambil data dari field ke-2 (index 2) yang berisi tanggal
    final rawDate = fields[2];
    DateTime dateTime;

    // Pastikan data tanggal dalam format yang benar (String atau DateTime)
    if (rawDate is String) {
      dateTime = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is DateTime) {
      dateTime = rawDate;
    } else {
      throw Exception("Unsupported date type in Hive data for dateTime field");
    }

    // Mengembalikan objek HistoryModel dari data yang sudah dibaca
    return HistoryModel(
      expression: fields[0] as String,
      imagePath: fields[1] as String,
      dateTime: dateTime,
      isCorrect: fields[3] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryModel obj) {
    // Menulis data dari objek HistoryModel ke format biner Hive
    writer
      ..writeByte(4) // jumlah total field = 4
      ..writeByte(0)
      ..write(obj.expression)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.isCorrect);
  }
}
