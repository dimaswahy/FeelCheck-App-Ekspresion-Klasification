import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class CropParams {
  final Uint8List bytes;
  final Rect rect;

  CropParams(this.bytes, this.rect);
}

Future<img.Image?> decodeAndCrop(File file, Rect rect) async {
  final bytes = await file.readAsBytes();
  return compute(_decodeAndCropIsolate, CropParams(bytes, rect));
}

img.Image? _decodeAndCropIsolate(CropParams params) {
  final decoded = img.decodeImage(params.bytes);
  if (decoded == null) return null;

  final cropX = params.rect.left.toInt().clamp(0, decoded.width - 1);
  final cropY = params.rect.top.toInt().clamp(0, decoded.height - 1);
  final cropW = params.rect.width.toInt().clamp(1, decoded.width - cropX);
  final cropH = params.rect.height.toInt().clamp(1, decoded.height - cropY);

  return img.copyCrop(
    decoded,
    x: cropX,
    y: cropY,
    width: cropW,
    height: cropH,
  );
}
