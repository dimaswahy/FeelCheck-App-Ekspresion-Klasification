<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>FeelCheck - Dokumentasi</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background-color: #fafafa;
      color: #333;
      line-height: 1.6;
      margin: 0;
      padding: 0;
    }
    header {
      background: linear-gradient(90deg, #4A90E2, #007AFF);
      color: white;
      padding: 20px;
      text-align: center;
    }
    header h1 {
      margin: 0;
      font-size: 2rem;
    }
    header p {
      margin-top: 5px;
      font-size: 1.1rem;
    }
    main {
      max-width: 900px;
      margin: auto;
      padding: 20px;
    }
    h2 {
      border-left: 5px solid #007AFF;
      padding-left: 10px;
      color: #007AFF;
    }
    code {
      background-color: #eee;
      padding: 3px 6px;
      border-radius: 4px;
      font-family: Consolas, monospace;
    }
    pre {
      background-color: #272822;
      color: #f8f8f2;
      padding: 10px;
      border-radius: 6px;
      overflow-x: auto;
    }
    ul, ol {
      padding-left: 20px;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin: 15px 0;
    }
    table, th, td {
      border: 1px solid #ccc;
    }
    th, td {
      padding: 8px;
      text-align: center;
    }
    img {
      max-width: 100%;
      border-radius: 6px;
    }
    footer {
      text-align: center;
      font-size: 0.9rem;
      color: #555;
      padding: 15px;
      border-top: 1px solid #ddd;
      margin-top: 30px;
    }
  </style>
</head>
<body>
  <header>
    <h1>📱 FeelCheck</h1>
    <p>Aplikasi Klasifikasi Ekspresi Wajah Berbasis Flutter & TensorFlow Lite</p>
  </header>

  <main>
    <section>
      <p>
        FeelCheck adalah aplikasi <strong>klasifikasi ekspresi wajah</strong> berbasis Flutter dengan model <strong>TensorFlow Lite</strong>.
        Aplikasi ini menggunakan dataset <strong>USK FEMO</strong> yang berisi 5 kelas ekspresi wajah:
      </p>
      <ul>
        <li>😀 Senang</li>
        <li>😢 Sedih</li>
        <li>😠 Marah</li>
        <li>😲 Terkejut</li>
        <li>😐 Bosan</li>
      </ul>
    </section>

    <h2>✨ Fitur Utama</h2>
    <ul>
      <li>📷 Deteksi wajah real-time melalui kamera</li>
      <li>🤖 Klasifikasi ekspresi menjadi 5 kelas</li>
      <li>🖼️ Deteksi wajah dari gambar yang diunggah</li>
      <li>📊 Menampilkan nilai confidence hasil prediksi</li>
      <li>🗂️ Riwayat deteksi ekspresi wajah</li>
      <li>🎨 Antarmuka modern & ringan</li>
    </ul>

    <h2>🛠️ Teknologi yang Digunakan</h2>
    <ul>
      <li><strong>Flutter</strong> – Framework UI</li>
      <li><strong>TensorFlow Lite</strong> – Model deep learning</li>
      <li><strong>tflite_flutter</strong> – Plugin inferensi TFLite di Flutter</li>
      <li><strong>camera</strong> – Streaming kamera</li>
      <li><strong>permission_handler</strong> – Izin kamera & penyimpanan</li>
      <li><strong>path_provider</strong> – Akses direktori lokal</li>
      <li><strong>flutter_svg</strong> – Menampilkan ilustrasi SVG</li>
    </ul>

    <h2>📦 Instalasi</h2>
    <ol>
      <li>Clone repositori:
        <pre><code>git clone https://github.com/dimaswahy/FeelCheck-App-Ekspresion-Klasification.git
cd FeelCheck-App-Ekspresion-Klasification</code></pre>
      </li>
      <li>Install dependencies:
        <pre><code>flutter pub get</code></pre>
      </li>
      <li>Jalankan aplikasi:
        <pre><code>flutter run</code></pre>
      </li>
    </ol>
    <p><em>Catatan: Pastikan perangkat sudah mengizinkan akses kamera.</em></p>

    <h2>📸 Cuplikan Layar</h2>
    <table>
      <tr>
        <td><img src="assets/gambar/Untitled.png" 
      </tr>
    </table>

    <h2>🧠 Model AI</h2>
    <p>Model deep learning yang digunakan dilatih dengan dataset <strong>USK FEMO</strong>:</p>
    <ul>
      <li><strong>Arsitektur:</strong> CNN (Convolutional Neural Network)</li>
      <li><strong>Format:</strong> .tflite</li>
      <li><strong>Kelas Output:</strong>
        <ol>
          <li>Senang</li>
          <li>Sedih</li>
          <li>Marah</li>
          <li>Terkejut</li>
          <li>Bosan</li>
        </ol>
      </li>
    </ul>
    <p><em>Model diekspor ke TensorFlow Lite untuk performa tinggi di perangkat mobile.</em></p>

    <h2>📂 Struktur Proyek</h2>
    <pre><code>lib/
 ├── main.dart                # Entry point aplikasi
 ├── pages/                   # Halaman utama, hasil, dan riwayat
 ├── utils/                   # Fungsi popup konfirmasi, helper
 ├── models/                  # Model data dan fungsi parsing
 └── assets/                  # Gambar & ilustrasi SVG
</code></pre>

    <h2>👨‍💻 Pengembang</h2>
    <p><strong>Dimas Wahyu Nugraha</strong> – <a href="https://github.com/dimaswahy" target="_blank">GitHub</a></p>
  </main>

  <footer>
    📜 Lisensi: -
  </footer>
</body>
</html>
