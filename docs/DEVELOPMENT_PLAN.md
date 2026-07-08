# 💡 PELITA SYSTEM DEVELOPMENT PLAN (KMIPN INTEGRATED EDITION)

Dokumen ini bertindak sebagai berkas instruksi arsitektur utama (Cetak Biru) untuk AI Engine generator (Antigravity/Copilot) dalam mengimplementasikan, merombak, dan memperluas basis kode sistem PELITA secara tertutup dan presisi.

---

## 🎨 1. SPESIFIKASI PALET WARNA ABSOLUT (SINKRONISASI GRAFIS)
Setiap komponen antarmuka wajib merujuk secara tegas pada konstanta warna berikut:
*   `PelitaTheme.background`    : `0xFFFCF6EA` (Warm Cream - Latar Belakang Utama)
*   `PelitaTheme.darkTeal`      : `0xFF123C3A` (Rich Deep Teal - Header, Tombol Utama)
*   `PelitaTheme.orangeHighlight`: `0xFFF5A623` (Vibrant Lamp Orange - Status Terang)
*   `PelitaTheme.softYellow`    : `0xFFFCD98A` (Soft Yellow Accent - Label & Sub-teks Aktif)
*   `PelitaTheme.sageGreen`     : `0xFF7FB69B` (Calm Sage Green - Status Stabil / Tombol BK)
*   `PelitaTheme.coralRed`      : `0xFFF16A50` (Alert Emergency Coral - SOS & Distress Tinggi)
*   `PelitaTheme.honeyTint`     : `0xFFFFF3DC` (Soft Honey Tint - Kartu Sorot Aktif)
*   `PelitaTheme.textDark`      : `0xFF1C2C2B` (Deep Dark Ink - Tipografi Teks Utama)

---

## 🔒 2. SUBSISTEM LOGIN PAGE & AUTHENTICATION TRIAGE
AI harus membangun halaman masuk tunggal (`PelitaLoginScreen`) yang bertindak sebagai gerbang pembagi peran (*Multi-role Routing Engine*) tanpa menggunakan otentikasi server eksternal pada fase prototipe:

### A. Aturan Form & Input
*   Menerapkan widget `TextFormField` dengan pembatas `BoxConstraints(maxWidth: 420)` agar tampilan berbentuk HP proporsional di web Chrome.
*   Dekorasi input wajib menggunakan sudut melengkung `BorderRadius.circular(16)` dengan warna dasar `Colors.white`.

### B. Logika Alur Pengalihan (*Role Navigation Logic*)
Ketika pengguna menekan tombol utama "Masuk ke Sistem", validasikan input teks (*case-insensitive*):
1.  **Username: `siswa` / `murid`** ➔ Alihkan ke `PelitaShellScreen` (Modul Siswa - Gambar 1).
2.  **Username: `bk` / `guru`** ➔ Alihkan ke `BKDashboardScreen` (Modul Guru BK Desktop - Gambar 3).
3.  **Username: `ortu` / `parent`** ➔ Alihkan ke `ParentHomeTab` (Modul Orang Tua - Gambar 2).

### C. Inisialisasi Database Lokal Otomatis
* Sebelum menampilkan halaman login, pastikan fungsi `SharedPreferences.getInstance()` dipicu untuk menyiapkan wadah penyimpanan cerita siswa secara lokal.
* Buatkan fungsi utilitas internal `saveDataLocal(String key, String value)` dan `readDataLocal(String key)` di dalam `main.dart` untuk menyembunyikan kompleksitas pembacaan data sinkronisasi antar-role (Siswa, BK, Ortu).

---

## 👦 3. MODUL SISWA: GAMIFIED INTERACTION & CAHAYA METER (GAMBAR 1)
Modul ini diimplementasikan di dalam kelas `BerandaTab` dan `ChatMessage`.

### A. Komponen Header Atas (Teal Rounded Banner)
*   Warna Container: `PelitaTheme.darkTeal`.
*   Pojok Bawah Kiri & Kanan: `BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32))`.
*   Teks Sapaan: *"Selamat sore, Raka ✨"* (FontWeight.w900, ukuran 16, warna putih).
*   Kartu Streak: Menampilkan *"🔥 12 hari"* dengan warna latar belakang `PelitaTheme.orangeHighlight`.
*   Level Bar Widget: Menampilkan progress bar horizontal (`650/1000 EXP`). Sisi aktif berwarna `PelitaTheme.orangeHighlight`, sisi sisa berwarna `Colors.white24`.

### B. Fitur Cahaya Minggu Ini (The Interactive Mood Meter)
*   **Logika Penentuan Cahaya:** Tingkat kecerahan pendaran lingkaran diatur secara dinamis berdasarkan kalkulasi teks cerita hari ini (*Misi Swa-Bantu*) atau status intervensi manual dari Guru BK.
*   **Skala Pendaran Cahaya (Triage Visual State):**
    *   **Terang • STABIL:** Pendaran melingkar besar (`PelitaTheme.orangeHighlight` dengan opasitas bertingkat). Menandakan kondisi emosional anak baik.
    *   **Redup • CEMAS:** Pendaran menyusut tipis, warna berubah menjadi kuning pudar. Menandakan anak terindikasi lelah.
    *   **Badai • DISTRESS:** Lingkaran berubah menjadi merah koral (`PelitaTheme.coralRed`) pudar. Mematikan fitur gamifikasi sementara dan memicu peringatan darurat.
*   **Interaksi Mikro:** Ketika lingkaran wajah `^ u ^` diketuk oleh anak, munculkan modal dialog *Tactical Box Breathing* (Latihan pernapasan 4-7-8) sebagai aksi swa-bantu instan.

### C. Misi Swa-Bantu Harian (Input Cerita Harian)
*   Menyediakan form teks jurnal bebas bagi siswa untuk mencatat emosinya.
*   Ketika tombol "Kirim Catatan" ditekan, jalankan simulasi pencatatan lokal. Tambahkan point EXP (+50 EXP) dan ubah kondisi state `isMissionCompleted = true`.

---

## 🛡️ 4. MODUL ORANG TUA: PARENTAL LINK PORTAL (GAMBAR 2)
Modul ini diimplementasikan di dalam kelas `ParentHomeTab` untuk mensimulasikan pemantauan satu arah dari sisi wali murid.

### A. Banner Pemantauan Real-Time (*Live Sync Banner*)
*   Jika kondisi siswa di database lokal bernilai "Stabil", render kartu hijau `PelitaTheme.sageGreen.withValues(alpha: 0.1)`. Tampilkan teks: *"Lentera Raka terpantau Stabil. Tidak ada anomali atau sinyal distress parah dalam obrolan 7 hari terakhir."*
*   Jika kondisi siswa berubah menjadi "Distress/Krisis" akibat kata kunci di chat bot, ubah banner secara reaktif menjadi warna merah `PelitaTheme.coralRed.withValues(alpha: 0.15)` dan tampilkan tombol darurat rujukan 1-klik ke Puskesmas terdekat.

### B. Feed Edukasi Adaptif
*   Menampilkan daftar kartu artikel psikologi perkembangan anak (seperti *"Mengenali Gejala Burnout Akademik Pada Remaja"*).
*   Setiap kartu memiliki detil nama penulis medis profesional dan estimasi waktu baca (`4 mnt baca`) menggunakan aksen warna hijau `PelitaTheme.sageGreen`.

---

## 💡 5. MODUL GURU BK: DASHBOARD PRIORITAS & INTERVENSI CAHAYA (GAMBAR 3)
Modul ini dirancang dengan layout horizontal (*Row*) untuk simulasi Web Desktop Dashboard khusus Guru BK.

### A. Panel Kiri: Navigasi Menu (*Sidebar*)
*   Lebar tetap: 240, warna dasar `PelitaTheme.darkTeal`.
*   Menampilkan menu: `Prioritas Siswa` (Status Aktif), `Riwayat Kasus`, dan `Konfigurasi Rujukan`.

### B. Panel Tengah: Daftar Antrean Prioritas Konseling
*   Menampilkan daftar siswa berisiko hasil penyaringan AI (*Triage System*).
*   Siswa bernama **Raka (Simulasi Siswa)** diletakkan di prioritas utama dengan sorot kartu berwarna `PelitaTheme.honeyTint` dan garis tepi `PelitaTheme.orangeHighlight`.

### C. Panel Kanan: Rekam Medis & Fitur Intervensi Penentu Cahaya (FITUR INTI)
*   **Grafik Emosi Harian:** AI harus menggambar 5 batang grafik vertikal (`H-5` sampai `H-1`) berdasarkan riwayat skor mood anak skala 1-5.
*   **Buku Catatan Sesi Privat:** Menampilkan daftar riwayat konseling tatap muka yang dilakukan secara kronologis terbalik (Sesi terbaru paling atas).
*   **Fitur Input Intervensi Penentu Cahaya:**
    *   Menyediakan `TextField` bagi Guru BK untuk mengetik rekam perkembangan kasus baru.
    *   Menyediakan drop-down menu atau tombol seleksi di mana Guru BK bisa **menentukan secara manual status Cahaya batin anak** (apakah mau dikembalikan ke "Terang", diturunkan ke "Redup", atau diset ke "Badai").
    *   Ketika tombol "Simpan Catatan" diklik, simpan teks tersebut ke daftar rekam medis lokal, dan perbarui *Cahaya Meter* di modul siswa secara lintas-halaman (*reactive state override*).
    *   **Komponen AI Ringkasan Tren (AI Summary Box):** Buat sebuah widget Container berwarna `PelitaTheme.honeyTint` dengan sudut melengkung 16 di panel kanan. Tampilkan teks rangkuman otomatis berbasis state lokal (Contoh: "AI Insights: Berdasarkan analisis jurnal 7 hari terakhir, Raka mengalami penurunan energi batin akibat beban tugas, namun interaksi sosialnya stabil.").
    *   **Fitur Instan Bypass Triage (Real-Time Escalation):** Jika form cerita harian siswa atau input chat mengandung kata-kata krisis yang sangat buruk, sistem harus langsung mem-bypass sistem mingguan, mengubah `currentCahayaState` menjadi "Distress", dan memunculkan indikator status berkedip merah "⚠️ PERLU TINDAKAN INSTAN HARI INI" di dashboard Guru BK.
    *   **Tombol Reset Otoritas (Authority Reset Button):** Tambahkan tombol `TextButton` atau `IconButton` berlambang putar balik (refresh) di sebelah nama Raka pada panel kanan Guru BK dengan teks "Reset Keadaan Hari Ini (Iseng/False Alarm)". Jika tombol ini diklik oleh Guru BK, bersihkan status krisis hari itu, kembalikan `currentCahayaState` ke "Stabil", dan sinkronisasikan ulang ke halaman Siswa dan Orang Tua secara real-time via SharedPreferences.

---

## 🏗️ 6. PETUNJUK INSTALASI AGAR AI TIDAK ERROR
Saat melakukan instalasi kode otomatis, pastikan AI menambahkan dependensi ini pada berkas `pubspec.yaml` agar tidak terjadi kegagalan pencarian pustaka (*library references*):
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  shared_preferences: ^2.2.0