# 🌐 PELITA SYSTEM CONTEXT DOCUMENT (KMIPN COMPETITION EDITION)

Dokumen ini menyediakan konteks domain bisnis, arsitektur data lintas-peran, dan spesifikasi state management lokal untuk membantu AI Engine memahami logika di balik pengembangan aplikasi PELITA.

---

## 📋 1. LATAR BELAKANG PROYEK & MATRIKS PENGGUNA
PELITA (Sistem Pendampingan Elektronika Lintas-Instansi Berbasis Gamifikasi) dirancang sebagai lapisan penanganan pasca-skrining massal Program Cek Kesehatan Gratis (CKG) Kementerian Kesehatan RI di lingkungan sekolah untuk mendeteksi dini kecemasan dan depresi pada anak[cite: 8].

Aplikasi ini beroperasi dalam sebuah ekosistem lingkaran tertutup (*closed-loop*) yang melibatkan tiga aktor utama dengan kebutuhan antarmuka yang berbeda[cite: 8]:

| Peran Pengguna (Role) | Kebutuhan Utama & Domain Interaksi | Alur Data Sistem |
| :--- | :--- | :--- |
| **Siswa / Anak** | Mengisi jurnal harian via Metafora Cuaca, berinteraksi dengan karakter Bintang, memantau *Cahaya Meter*, dan memicu SOS krisis[cite: 8]. | Pengirim data mood harian & Penerima intervensi/perubahan status Cahaya dari Guru BK[cite: 8]. |
| **Guru BK** | Memantau daftar antrean siswa berisiko, melihat grafik emosi pekaaan, menulis rekam medis, dan menentukan status Cahaya anak secara manual[cite: 8]. | Penerima *flagging alert* otomatis dari chat/jurnal siswa & Pengendali penuh status *Cahaya Meter* siswa[cite: 8]. |
| **Orang Tua / Wali** | Menerima sinkronisasi status anak (*Live Sync*) dan mengonfirmasi rujukan darurat jika status anak masuk kategori "Distress Berat"[cite: 8]. | Penerima eskalasi krisis dari sistem jika dipicu oleh tombol SOS siswa atau kata kunci kritis[cite: 8]. |

---

## 🔄 2. LOGIKA STATE MANAGEMENT LOKAL (CROSS-ROLE INTERACTION)
Karena prototipe ini belum menggunakan database server eksternal, AI generator wajib menyimulasikan aliran data antarhalaman menggunakan manajemen status lokal berbasis memori yang reaktif (*reactive local memory state*).

### A. Variabel Global Objek Data (Mock Database Structure)
AI harus menyediakan sebuah struktur data global yang bisa diakses dan dimutasi oleh ketiga modul peran tersebut:
*   `currentCahayaState`: Menyimpan status emosional Raka saat ini (`"Stabil"` / `"Cemas"` / `"Distress"`). Default awal diatur ke `"Stabil"`.
*   `counselingLogs`: Sebuah `List<Map<String, String>>` yang menampung riwayat catatan privat yang ditulis oleh Guru BK.
*   `isSosTriggeredGlobal`: Variabel penanda (`bool`) apakah siswa sedang menekan tombol krisis SOS.

### B. Mekanisme Reaktivitas Fitur Intervensi (Siswa ↔ Guru BK)
1.  **Aksi di Halaman BK (`BKDashboardScreen`):** ketika Guru BK mengetik catatan di panel kanan dan memilih status emosi baru (misal: menurunkan status Raka menjadi `"Cemas"`), variabel `currentCahayaState` global harus diperbarui.
2.  **Dampak di Halaman Siswa (`BerandaTab`):** Begitu user login kembali sebagai "Siswa", komponen *Cahaya Minggu Ini* harus secara otomatis membaca nilai `currentCahayaState` terbaru, mengubah warna pendaran lingkaran wajah, dan memperbarui teks deskripsinya secara instan tanpa perlu merestart aplikasi.
3.  **Dampak di Halaman Orang Tua (`ParentHomeTab`):** Banner *Live Sync* pada halaman orang tua harus ikut berubah warna menjadi kuning/merah koral secara sinkron mengikuti nilai variabel global tersebut.

### C. Sinkronisasi Database Lokal & Akun Dummy Berpasangan (Siswa -> BK -> Ortu)
1. **Mekanisme Penyimpanan Cerita Multi-User (Siswa ➔ Guru BK):** 
   Setiap kali Siswa mengirimkan teks cerita di form "Misi Hari Ini" atau melakukan chat dengan Nyala AI, AI Generator wajib menyimpan teks tersebut ke dalam database lokal `shared_preferences` menggunakan Key Dinamis berbasis username: `pref_jurnal_${username}` dan `pref_chat_${username}`. Saat Guru BK membuka `BKDashboardScreen` dan memilih salah satu nama siswa dari daftar antrean, dashboard harus membaca Key sesuai username siswa yang diklik sehingga Guru BK bisa memantau dan membaca semua isi cerita spesifik dari siswa tersebut secara nyata.
2. **Keterhubungan Akun Berpasangan (Siswa ➔ Orang Tua):**
   Sistem login diatur agar mengenali hubungan relasi keluarga terikat secara otomatis via prefix username. Akun siswa (misal: 'raka') terhubung langsung dengan akun orang tua jika orang tua masuk menggunakan kredensial verifikasi (misal: mengetik nama siswa yang ingin dipantau). Modul Orang Tua (`ParentHomeTab`) wajib membaca data cerita harian dari Key dinamis `pref_jurnal_${usernameSiswa}` yang sama, sehingga Orang Tua juga bisa ikut memantau perkembangan dan membaca tulisan cerita anaknya secara *live*.
3. **Persistensi Data Tanpa Server:**
   Seluruh fungsi mutasi status Cahaya Meter (`currentCahayaState`) dan log konseling harus langsung di-commit ke `SharedPreferences` lokal seketika itu juga agar data pengujian dari responden aman terarsip meskipun browser di-refresh.

---

## 🛠️ 3. REKAYASA KATA KUNCI SENTIMEN BOT (MOCK AI TRIAGE ENGINE)
Pada Modul Chatbot Siswa (`ChatBotTab`), implementasikan sebuah fungsi pemindai teks sederhana untuk menyimulasikan *AI Sentiment Analysis*:
*   **Kata Kunci Distress:** `sedih`, `lelah`, `sendiri`, `takut`, `bully`.
*   **Logika Sistem & Bypass Antrean (Instant Emergency Trigger):**
    1. Sistem tidak boleh menunggu kalkulasi tren pekanan selesai jika anak mendeteksi kata kunci krisis yang bersifat destruktif secara mendadak hari ini.
    2. Begitu kata kunci terdeteksi, trigger mekanisme Bypass: ubah `currentCahayaState` menjadi "Distress", simpan riwayat chat ke `shared_preferences`, kirim alarm otomatis ke portal Orang Tua, dan naikkan status Raka di antrean Guru BK menjadi urutan teratas tanpa syarat.
    3. Jika Guru BK menilai bahwa input anak tersebut hanyalah sebuah ketidaksengajaan atau keisengan setelah melakukan wawancara langsung, Guru BK dapat mengeklik *Authority Reset Button*. Tindakan ini akan mengesampingkan deteksi AI, mereset status memori lokal kembali ke "Stabil", dan menghapus penanda bahaya merah di seluruh aplikasi.
    4. **Cakupan Pemindaian AI Triage (Multi-Source Intake):**
    Fungsi pemindaian kata kunci distress harus diterapkan secara universal pada dua gerbang input: (1) Form pengisian teks "Misi Hari Ini" di BerandaTab, dan (2) Kolom input percakapan di ChatBotTab. Jika salah satu atau kedua tempat tersebut mendeteksi kata kunci kritis, sistem harus langsung memicu status "Distress" secara instan.

---

## 🎯 4. ARSITEKTUR LAYOUT CODE YANG DIHARAPKAN
AI harus menyusun kode di dalam `lib/main.dart` dengan pembagian struktur class widget yang rapi sebagai berikut:
1.  `void main()` & `class PelitaApp` (Akar konfigurasi tema dan pencarian halaman)[cite: 9]
2.  `class PelitaLoginScreen` (Form Login Multi-Role & Tombol Pintasan Demo)
3.  `class PelitaShellScreen` (Navigasi BottomBar, Frame Aplikasi Siswa, dan Overlay SOS)[cite: 9]
4.  `class BerandaTab` (Widget pengolah Cahaya Meter harian dan Misi Swa-bantu)[cite: 8, 9]
5.  `class ChatBotTab` (Simulasi analisis sentimen chat asisten Nyala AI)[cite: 8, 9]
6.  `class ProfileTab` (Kondisi emosi mikro dan milestone lencana)[cite: 8, 9]