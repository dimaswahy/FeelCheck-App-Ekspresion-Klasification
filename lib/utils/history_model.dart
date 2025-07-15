import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class HistoryModel extends HiveObject {
  @HiveField(0)
  String expression;

  @HiveField(1)
  String imagePath;

  @HiveField(2)
  DateTime dateTime;

  HistoryModel({
    required this.expression,
    required this.imagePath,
    required this.dateTime,
  });
}
