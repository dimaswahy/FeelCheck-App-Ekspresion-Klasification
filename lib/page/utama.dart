import 'dart:io';
import 'package:feelcheck/page/example.dart';
import 'package:feelcheck/utils/image_cropper.dart';
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
  // ============================
  // VARIABEL INTI
  // ============================
  File? _capturedImage; // Gambar yang diambil dari kamera/galeri
  File? _faceOnlyImage; // Gambar hasil crop wajah
  final ImagePicker _picker = ImagePicker(); // Untuk mengambil gambar
  late final FaceDetector _faceDetector; // Detektor wajah Google ML Kit

  // ============================
  // VARIABEL STATUS
  // ============================
  bool _isProcessing = false; // Apakah sedang memproses gambar
  bool _disclaimerShown = false; // Apakah disclaimer sudah tampil
  bool _pageVisible = false; // Untuk animasi masuk halaman

  // ============================
  // HASIL DETEKSI
  // ============================
  String _expressionLabel = "N/A"; // Label ekspresi wajah
  double _confidenceScore = 0.0; // Tingkat kepercayaan model

  // ============================
  // KONSTANTA DURASI
  // ============================
  static const Duration _animationDuration = Duration(milliseconds: 600);
  static const Duration _processingDelay = Duration(milliseconds: 50);
  static const Duration _disclaimerDelay = Duration(milliseconds: 300);
  static const Duration _resultDelay = Duration(seconds: 1);

  // ============================
  // INISIALISASI AWAL
  // ============================
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

  // Inisialisasi seluruh komponen awal
  void _initializeComponents() {
    WidgetsBinding.instance.addObserver(this);
    _initializeFaceDetector(); // Siapkan detektor wajah
    _schedulePageAnimation(); // Jalankan animasi halaman
  }

  // Inisialisasi detektor wajah ML Kit
  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableClassification: false,
        enableLandmarks: false,
      ),
    );
  }

  // Menjadwalkan animasi halaman
  void _schedulePageAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animatePageEntry();
    });
  }

  // Animasi transisi masuk halaman
  void _animatePageEntry() {
    setState(() => _pageVisible = true);
    Future.delayed(_disclaimerDelay, _showDisclaimer);
  }

  // Membersihkan resource sebelum keluar
  void _cleanupResources() {
    WidgetsBinding.instance.removeObserver(this);
    _faceDetector.close();
  }

  // ============================
  // DIALOG DISCLAIMER
  // ============================
  Future<void> _showDisclaimer() async {
    if (_disclaimerShown) return;
    _disclaimerShown = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DisclaimerDialog(),
    );
  }

  // ============================
  // PILIH SUMBER GAMBAR
  // ============================
  Future<void> _showImagePickerOptions() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => _buildImagePickerBottomSheet(),
    );
  }

  // Bottom sheet untuk memilih kamera/galeri
  Widget _buildImagePickerBottomSheet() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModalHandle(),
            const SizedBox(height: 20),
            _buildModalTitle(),
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
            _buildGuideTile(),
          ],
        ),
      ),
    );
  }

  // Judul bottom sheet
  Widget _buildModalTitle() {
    return const Text(
      'Pilih Sumber Gambar',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  // Tombol petunjuk pengambilan gambar
  Widget _buildGuideTile() {
    return ListTile(
      leading: const Icon(Icons.lightbulb_outline, color: Colors.yellow),
      title: const Text('Petunjuk Penggambilan Gambar'),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.pushNamed(context, '/example');
      },
    );
  }

  // ============================
  // DIALOG KONFIRMASI EKSPRESI
  // ============================
  Future<void> _showConfirmationDialog(
    String detectedExpression,
    String imagePath,
  ) async {
    final box = Hive.box<HistoryModel>('historyBox');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildConfirmationDialog(
        detectedExpression,
        imagePath,
        box,
      ),
    );
  }

  // Tampilan dialog konfirmasi hasil deteksi
  Widget _buildConfirmationDialog(
    String detectedExpression,
    String imagePath,
    Box<HistoryModel> box,
  ) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Konfirmasi Ekspresi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
  }

  // ============================
  // PEMROSESAN GAMBAR
  // ============================
  // Fungsi untuk mengambil gambar dari kamera/galeri
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

  // Proses deteksi wajah dan klasifikasi ekspresi
  Future<void> _processImage() async {
    if (_capturedImage == null) return;

    await Future.delayed(_processingDelay);

    try {
      // Deteksi wajah menggunakan ML Kit
      final inputImage = InputImage.fromFile(_capturedImage!);
      final faces = await _faceDetector.processImage(inputImage);

      // Jika wajah tidak ditemukan
      if (faces.isEmpty) {
        setState(() {
          _faceOnlyImage = null;
          _expressionLabel = "Wajah tidak ditemukan";
          _confidenceScore = 0.0;
          _isProcessing = false;
        });
        return;
      }

      // Potong area wajah
      final croppedImage =
          await decodeAndCrop(_capturedImage!, faces.first.boundingBox);
      if (croppedImage == null) return;

      // Simpan wajah hasil crop ke direktori aplikasi
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'face_${DateTime.now().millisecondsSinceEpoch}.png';
      final croppedFile = File('${appDir.path}/$fileName');
      await croppedFile.writeAsBytes(img.encodePng(croppedImage));

      // Jalankan model TFLite untuk klasifikasi ekspresi
      final tfliteHelper = TFLiteHelper();
      await tfliteHelper.loadModel();
      final result = await tfliteHelper.classifyImage(croppedFile);

      if (result.isEmpty) return;

      // Ambil hasil dengan confidence tertinggi
      final best = result.entries.reduce((a, b) => a.value > b.value ? a : b);

      setState(() {
        _faceOnlyImage = croppedFile;
        _expressionLabel = best.key;
        _confidenceScore = best.value;
        _isProcessing = false;
      });

      // Tampilkan dialog konfirmasi
      await Future.delayed(_resultDelay);
      await _showConfirmationDialog(best.key, croppedFile.path);
    } catch (e) {
      // Tangani error
      setState(() {
        _expressionLabel = "Error: $e";
        _confidenceScore = 0.0;
        _isProcessing = false;
      });
    }
  }

  // Simpan hasil yang benar ke riwayat
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

  // Jika hasil tidak benar → simpan dan minta ulang gambar
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

  // ============================
  // BAGIAN UI
  // ============================
  Widget _buildModalHandle() => Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      );

  // Tombol pilih kamera/galeri
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

  // Tombol konfirmasi (Ya / Coba lagi)
  Widget _buildConfirmationButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  // Seksi sambutan di halaman utama
  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD).withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Text(
            "Selamat Datang Di FeelCheck",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 2),
          Text(
            "Kenali dan pahami emosimu hari ini",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ============================
  // STRUKTUR HALAMAN UTAMA
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // AppBar dengan gradasi biru
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  // Isi utama halaman
  Widget _buildBody() {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Pola latar belakang SVG
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/illustration/background_pattern.svg',
            fit: BoxFit.cover,
            colorFilter:
                ColorFilter.mode(Colors.white.withOpacity(0.15), BlendMode.srcATop),
          ),
        ),
        // Konten utama dengan animasi
        AnimatedOpacity(
          opacity: _pageVisible ? 1.0 : 0.0,
          duration: _animationDuration,
          curve: Curves.easeInOut,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 2),
                  Image.asset('assets/logo/logo edit new.png', width: 100)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(),
                  const SizedBox(height: 10),
                  _buildWelcomeSection(),
                  const SizedBox(height: 27),
                  _buildImagePreviewContainer()
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .slideY(begin: 0.2),
                  const SizedBox(height: 32),
                  _buildExpressionDisplay()
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideY(begin: 0.2),
                  const SizedBox(height: 32),
                  _buildUploadButton()
                      .animate()
                      .fadeIn(delay: 700.ms)
                      .slideY(begin: 0.2),
                  const SizedBox(height: 20),
                  _buildHistoryButton()
                      .animate()
                      .fadeIn(delay: 900.ms)
                      .slideY(begin: 0.2),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================
  // WIDGET TAMBAHAN
  // ============================

  // Menampilkan gambar hasil deteksi
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
        child: _isProcessing
            ? const Center(child: CircularProgressIndicator())
            : _faceOnlyImage != null
                ? Image.file(_faceOnlyImage!, fit: BoxFit.cover)
                : _buildEmptyImageContent(),
      ),
    );
  }

  // Tampilan ketika belum ada gambar/wajah
  Widget _buildEmptyImageContent() {
    final isImageCaptured = _capturedImage != null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          isImageCaptured
              ? 'assets/illustration/empty_face.svg'
              : 'assets/illustration/empty_picture.svg',
          width: 100,
        ),
        const SizedBox(height: 10),
        Text(
          isImageCaptured ? 'Tidak ada wajah' : 'Belum ada gambar',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // Menampilkan hasil ekspresi & confidence
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
          const Text('Ekspresi:', style: TextStyle(color: Colors.black)),
          _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  _confidenceScore > 0
                      ? '$_expressionLabel (${(_confidenceScore * 100).toStringAsFixed(1)}%)'
                      : _expressionLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ],
      ),
    );
  }

  // Tombol unggah gambar
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
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, color: Colors.white),
                      SizedBox(width: 6),
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
    );
  }

  // Tombol menuju halaman riwayat
  Widget _buildHistoryButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/riwayat'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Lihat Riwayat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
