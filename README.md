📌 Deskripsi Proyek

Aplikasi Flutter yang terhubung dengan API 3awan Cafe & Resto untuk menampilkan daftar menu, melakukan pemesanan, dan menghitung total harga.
Dibangun menggunakan Flutter + Provider untuk state management.

🎯 Fitur Aplikasi

Melihat daftar menu dari API Flask

Menambah dan mengurangi jumlah pesanan

Menghitung total harga secara otomatis

Halaman ringkasan pesanan (Cart Page)

Integrasi penuh dengan API online (Railway)

Responsive UI

(Bonus) Filter/Search berdasarkan kategori

🏗️ Struktur Direktori
3awan_caferesto_app/
│
├── api/
│   └── caferesto_api.dart          # Koneksi ke endpoint API Flask
│
├── models/
│   ├── menu_model.dart             # Model data menu
│   └── transaction_model.dart      # Model data transaksi
│
├── pages/
│   ├── home_page.dart              # Menampilkan daftar menu
│   ├── cart_page.dart              # Ringkasan pesanan
│   ├── history_page.dart           # (Opsional) Riwayat pesanan
│
├── providers/
│   ├── menu_provider.dart          # Provider pengelolaan daftar menu
│   ├── cart_provider.dart          # Provider keranjang (increment/decrement)
│   └── transaction_provider.dart   # Provider transaksi
│
├── main.dart                       # Entry point Flutter app
└── pubspec.yaml                    # Dependensi Flutter

🧰 Instalasi & Menjalankan Proyek
1️⃣ Clone Repository
git clone https://github.com/herzyyy/flutter-3awan-caferesto.git
cd 3awan_caferesto_app

2️⃣ Install Dependensi
flutter pub get

3️⃣ Jalankan Aplikasi
flutter run

⚙️ Konfigurasi API

Buka file:

lib/api/caferesto_api.dart


Ubah base URL menjadi:

const String baseUrl = "https://python-flask-3awan-caferesto-production.up.railway.app";

🖥️ Tampilan Aplikasi

Home Page – Menampilkan daftar menu dari API (menggunakan ListView.builder)

Cart Page – Menampilkan pesanan yang telah dipilih, jumlah, dan total harga

History Page (opsional) – Riwayat transaksi sebelumnya

🧮 State Management

Menggunakan Provider untuk:

Menyimpan daftar menu dari API

Mengelola jumlah pesanan (increment/decrement)

Menghitung total harga secara dinamis

🧾 Penilaian Tugas
Komponen	Keterangan	Bobot
API Python + PostgreSQL	CRUD & Online	20%
Integrasi Flutter	Data tampil dari API	20%
State Management	Fungsi berjalan	15%
Tampilan UI Flutter	Layout rapi & responsif	15%
Dokumentasi & Upload GitHub	README + link Railway	10%

Bonus:
+10% fitur search/filter kategori makanan/minuman di Flutter.

🌐 Output yang Dikumpulkan

🔗 Link GitHub API Python

🔗 Link GitHub Flutter Project

🌍 URL API Railway

📱 Demo aplikasi (video/screenshare)
