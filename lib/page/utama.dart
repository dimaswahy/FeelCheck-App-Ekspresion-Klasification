// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:hive/hive.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../widget/disclaimer_text.dart';
import '../../utils/history_model.dart';
import '../../utils/tflite_helper.dart';

class UtamaPage extends StatefulWidget {
  const UtamaPage({super.key});

  @override
  State<UtamaPage> createState() => _UtamaPageState();
}

class _UtamaPageState extends State<UtamaPage> with WidgetsBindingObserver {
  // Core properties
  File? _capturedImage;
  File? _faceOnlyImage;
  final ImagePicker _picker = ImagePicker();
  late final FaceDetector _faceDetector;

  // State management
  bool _isProcessing = false;
  bool _disclaimerShown = false;
  bool _pageVisible = false;

  // Detection results
  String _expressionLabel = "N/A";
  double _confidenceScore = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  // INITIALIZATION METHODS
  void _initializeComponents() {
    WidgetsBinding.instance.addObserver(this);

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableClassification: false,
        enableLandmarks: false,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animatePageEntry();
    });
  }

  void _animatePageEntry() {
    setState(() {
      _pageVisible = true;
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _showDisclaimer();
    });
  }

  void _cleanupResources() {
    WidgetsBinding.instance.removeObserver(this);
    _faceDetector.close();
  }

  // DIALOG METHODS
  Future<void> _showDisclaimer() async {
    if (_disclaimerShown) return;
    
    _disclaimerShown = true;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DisclaimerDialog(),
    );
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
                _buildModalHandle(),
                const SizedBox(height: 20),
                const Text(
                  'Pilih Sumber Gambar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _buildImageSourceTile(
                  icon: Icons.photo_library,
                  color: Colors.blue,
                  title: 'Galeri',
                  source: ImageSource.gallery,
                ),
                _buildImageSourceTile(
                  icon: Icons.photo_camera,
                  color: Colors.green,
                  title: 'Kamera',
                  source: ImageSource.camera,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showConfirmationDialog(
    String detectedExpression,
    String imagePath,
  ) async {
    final box = Hive.box<HistoryModel>('historyBox');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 20,
              right: 20,
            ),
            child: Material(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              elevation: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Konfirmasi Ekspresi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ekspresi terdeteksi:\n"$detectedExpression"',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildConfirmationButton(
                          text: 'Ya, Benar',
                          color: Colors.green,
                          onPressed: () => _handleCorrectDetection(
                            box,
                            detectedExpression,
                            imagePath,
                          ),
                        ),
                        _buildConfirmationButton(
                          text: 'Coba Lagi',
                          color: Colors.red,
                          onPressed: () => _handleIncorrectDetection(
                            box,
                            detectedExpression,
                            imagePath,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // IMAGE PROCESSING METHODS
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

  Future<void> _processImage() async {
    if (_capturedImage == null) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final result = await _detectAndProcessFace();
      await _classifyExpression(result);
    } catch (e) {
      _handleProcessingError(e);
    }
  }

  Future<File?> _detectAndProcessFace() async {
    final inputImage = InputImage.fromFile(_capturedImage!);
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      _updateStateNoFace();
      return null;
    }

    final face = faces.first;
    final croppedImage = await decodeAndCrop(_capturedImage!, face.boundingBox);

    if (croppedImage == null) {
      _updateStateImageError();
      return null;
    }

    return await _saveCroppedImage(croppedImage);
  }

  Future<File> _saveCroppedImage(img.Image croppedImage) async {
    final appDir = await getApplicationDocumentsDirectory();
    final croppedFile = File(
      '${appDir.path}/face_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await croppedFile.writeAsBytes(img.encodePng(croppedImage));
    return croppedFile;
  }

  Future<void> _classifyExpression(File? croppedFile) async {
    if (croppedFile == null) return;

    final tfliteHelper = TFLiteHelper();
    await tfliteHelper.loadModel();

    final result = await tfliteHelper.classifyImage(croppedFile);

    String detectedResult = "Tidak terdeteksi";
    double confidence = 0.0;

    if (result.isNotEmpty) {
      final best = result.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      detectedResult = best.key;
      confidence = best.value;
    }

    _updateStateWithResult(croppedFile, detectedResult, confidence);
    
    await Future.delayed(const Duration(seconds: 1));
    await _showConfirmationDialog(detectedResult, croppedFile.path);
  }

  // STATE UPDATE METHODS
  void _updateStateNoFace() {
    setState(() {
      _faceOnlyImage = null;
      _expressionLabel = "Wajah tidak ditemukan";
      _confidenceScore = 0.0;
      _isProcessing = false;
    });
  }

  void _updateStateImageError() {
    setState(() {
      _expressionLabel = "Gagal membaca gambar";
      _confidenceScore = 0.0;
      _isProcessing = false;
    });
  }

  void _updateStateWithResult(
    File croppedFile,
    String detectedResult,
    double confidence,
  ) {
    setState(() {
      _faceOnlyImage = croppedFile;
      _expressionLabel = detectedResult;
      _confidenceScore = confidence;
      _isProcessing = false;
    });
  }

  void _handleProcessingError(dynamic e) {
    setState(() {
      _expressionLabel = "Error: $e";
      _confidenceScore = 0.0;
      _isProcessing = false;
    });
  }

  // CONFIRMATION HANDLERS
  Future<void> _handleCorrectDetection(
    Box<HistoryModel> box,
    String detectedExpression,
    String imagePath,
  ) async {
    await box.add(HistoryModel(
      expression: detectedExpression,
      imagePath: imagePath,
      dateTime: DateTime.now(),
      isCorrect: true,
      confidence: _confidenceScore,
    ));
    Navigator.of(context).pop();
  }

  Future<void> _handleIncorrectDetection(
    Box<HistoryModel> box,
    String detectedExpression,
    String imagePath,
  ) async {
    await box.add(HistoryModel(
      expression: detectedExpression,
      imagePath: imagePath,
      dateTime: DateTime.now(),
      isCorrect: false,
      confidence: _confidenceScore,
    ));
    Navigator.of(context).pop();
    _showImagePickerOptions();
  }

  // UI BUILDER METHODS
  Widget _buildModalHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildImageSourceTile({
    required IconData icon,
    required Color color,
    required String title,
    required ImageSource source,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop();
        _pickImage(source);
      },
    );
  }

  Widget _buildConfirmationButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildImagePreviewContainer() {
    return Container(
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
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: _buildImagePreviewContent(),
      ),
    );
  }

  Widget _buildImagePreviewContent() {
    if (_isProcessing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_faceOnlyImage != null) {
      return Image.file(_faceOnlyImage!, fit: BoxFit.cover);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          _capturedImage == null
              ? 'assets/illustration/empty_picture.svg'
              : 'assets/illustration/empty_face.svg',
          width: 100,
        ),
        const SizedBox(height: 12),
        Text(
          _capturedImage == null ? 'Belum ada gambar' : 'Tidak ada wajah',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildExpressionDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Ekspresi:',
            style: TextStyle(color: Colors.grey),
          ),
          _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  _buildExpressionText(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ],
      ),
    );
  }

  String _buildExpressionText() {
    if (_confidenceScore > 0) {
      return '$_expressionLabel (${(_confidenceScore * 100).toStringAsFixed(1)}%)';
    }
    return _expressionLabel;
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _showImagePickerOptions,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
            child: _buildButtonContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (_isProcessing) {
      return Row(
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
      );
    }

    return Row(
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
    );
  }

  Widget _buildGuideButton() {
    return Material(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/example'),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.lightbulb_outline, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Petunjuk Penggunaan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Image.asset('assets/logo/logo edit.png', width: 100)
                    .animate()
                    .fadeIn()
                    .scale(),
                const SizedBox(height: 12),
                const Text(
                  "Selamat Datang Di FeelCheck",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  "Kenali dan pahami emosimu hari ini",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 35),
                _buildImagePreviewContainer(),
                const SizedBox(height: 32),
                _buildExpressionDisplay(),
                const SizedBox(height: 32),
                _buildUploadButton(),
                const SizedBox(height: 20),
                _buildGuideButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// HELPER CLASSES AND FUNCTIONS
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