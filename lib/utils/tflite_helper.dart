import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteHelper {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/emosi.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }

    final labelsData = await rootBundle.loadString('assets/label_klasifikasi.txt');
    _labels = labelsData
        .split('\n')
        .where((element) => element.trim().isNotEmpty)
        .toList();
  }

  Future<Map<String, double>> classifyImage(File image) async {
    if (_interpreter == null || _labels == null) {
      await loadModel();
    }

    var input = _processRawImage(image); // List<List<List<List<float>>>>

    var output = List.generate(1, (_) => List.filled(_labels!.length, 0.0));

    _interpreter!.run(input, output);

    print("Output values: ${output[0]}");

    Map<String, double> results = {};
    for (int i = 0; i < _labels!.length; i++) {
      results[_labels![i]] = output[0][i];
    }

    return results;
  }

  /// Proses gambar dan hasilkan input tensor berbentuk [1, 244, 244, 3]
  List<List<List<List<double>>>> _processRawImage(File imageFile) {
    final raw = imageFile.readAsBytesSync();
    final image = img.decodeImage(raw)!;
    final resizedImage = img.copyResize(image, width: 244, height: 244);

    List<List<List<List<double>>>> input = List.generate(
      1,
      (_) => List.generate(
        244,
        (y) => List.generate(
          244,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    return input;
  }
}