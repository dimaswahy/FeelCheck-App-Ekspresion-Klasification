import 'package:hive/hive.dart';



@HiveType(typeId: 0)
class HistoryModel extends HiveObject {
  @HiveField(0)
  String expression;

  @HiveField(1)
  String imagePath;

  @HiveField(2)
  DateTime dateTime;

  @HiveField(3)
  bool isCorrect;

  @HiveField(4)
  double confidence; // Tambahan baru

  HistoryModel({
    required this.expression,
    required this.imagePath,
    required this.dateTime,
    required this.isCorrect,
    required this.confidence, // tambahkan juga di constructor
  });
}
