import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widget/disclaimer_text.dart';
import '../../utils/tflite_helper.dart';
import '../../utils/history_model.dart';

class UtamaPage extends StatefulWidget {
  const UtamaPage({super.key});

  @override
  State<UtamaPage> createState() => _UtamaPageState();
}

class _UtamaPageState extends State<UtamaPage> with WidgetsBindingObserver {
  File? _capturedImage;
  File? _faceOnlyImage;
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String _resultText = "N/A";

  late final FaceDetector _faceDetector;
  bool _disclaimerShown = false;
  bool _pageVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableClassification: false,
        enableLandmarks: false,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _pageVisible = true;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        _showDisclaimer();
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _showDisclaimer() async {
    if (_disclaimerShown) return;
    _disclaimerShown = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DisclaimerDialog(),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      _isProcessing = true;
      _capturedImage = File(image.path);
      _faceOnlyImage = null;
    });

    await _processImage();
  }

  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pilih Sumber Gambar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.blue),
                  title: const Text('Galeri'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: Colors.green),
                  title: const Text('Kamera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _processImage() async {
    if (_capturedImage == null) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 50)); // memastikan spinner muncul

    try {
      final inputImage = InputImage.fromFile(_capturedImage!);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        setState(() {
          _faceOnlyImage = null;
          _resultText = "Wajah tidak ditemukan";
          _isProcessing = false;
        });
        return;
      }

      final face = faces.first;
      final croppedImage = await decodeAndCrop(_capturedImage!, face.boundingBox);

      if (croppedImage == null) {
        setState(() {
          _resultText = "Gagal membaca gambar";
          _isProcessing = false;
        });
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final croppedFile = File('${appDir.path}/face_${DateTime.now().millisecondsSinceEpoch}.png');
      await croppedFile.writeAsBytes(img.encodePng(croppedImage));

      final tfliteHelper = TFLiteHelper();
      await tfliteHelper.loadModel();

      final result = await tfliteHelper.classifyImage(croppedFile);
      String detectedResult = "Tidak terdeteksi";

      if (result.isNotEmpty) {
        final best = result.entries.reduce((a, b) => a.value > b.value ? a : b);
        detectedResult = best.key;

        final box = Hive.box<HistoryModel>('historyBox');
        final historyItem = HistoryModel(
          expression: best.key,
          imagePath: croppedFile.path,
          dateTime: DateTime.now(),
        );
        await box.add(historyItem);
      }

      // Delay minimal untuk smooth fade-in
      await Future.delayed(const Duration(milliseconds: 200));

      setState(() {
        _faceOnlyImage = croppedFile;
        _resultText = detectedResult;
        _isProcessing = false;
      });

    } catch (e) {
      setState(() {
        _resultText = "Error: $e";
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "FeelCheck",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cursive',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Riwayat',
            onPressed: () => Navigator.pushNamed(context, '/riwayat'),
          ),
        ],
      ),
      body: AnimatedOpacity(
        opacity: _pageVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, left: 24, right: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/logo/logo edit.png', width: 100)
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .scale(),
                      const SizedBox(height: 12),
                      const Text(
                        "Selamat Datang Di FeelCheck",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Kenali dan pahami emosimu hari ini",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _isProcessing
                        ? const Center(child: CircularProgressIndicator())
                        : (_faceOnlyImage != null
                            ? Image.file(
                                _faceOnlyImage!,
                                key: ValueKey<String>(_faceOnlyImage!.path),
                                fit: BoxFit.cover,
                              ).animate().fadeIn(duration: 800.ms)
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      _resultText == "Wajah tidak ditemukan"
                                          ? 'assets/illustration/empty_face.svg'
                                          : 'assets/illustration/empty_picture.svg',
                                      width: 100,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _resultText == "Wajah tidak ditemukan"
                                          ? 'Tidak ada wajah terdeteksi'
                                          : 'Gambar Belum Diunggah',
                                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                  ],
                                ),
                              )),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ekspresi:', style: TextStyle(color: Colors.grey)),
                      _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: Text(
                                _resultText,
                                key: ValueKey<String>(_resultText),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _showImagePickerOptions,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _isProcessing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Memproses...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.camera_alt_outlined, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Unggah Gambar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/example'),
                  child: const Text(
                    'Lihat Contoh Gambar Yang Disarankan?',
                    style: TextStyle(
                      color: Color(0xFF02243D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper isolate decode crop
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

  return img.copyCrop(decoded, x: cropX, y: cropY, width: cropW, height: cropH);
}
