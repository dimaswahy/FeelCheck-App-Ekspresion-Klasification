import 'package:hive/hive.dart';
import 'history_model.dart';

class HistoryModelAdapter extends TypeAdapter<HistoryModel> {
  @override
  final int typeId = 0;

  @override
  HistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    final rawDate = fields[2];
    DateTime dateTime;
    if (rawDate is String) {
      dateTime = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is DateTime) {
      dateTime = rawDate;
    } else {
      throw Exception("Unsupported date type in Hive data for dateTime field");
    }

    return HistoryModel(
      expression: fields[0] as String,
      imagePath: fields[1] as String,
      dateTime: dateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.expression)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.dateTime);
  }
}
