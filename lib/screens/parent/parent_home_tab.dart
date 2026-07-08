// ============================================================
//  PELITA · lib/screens/parent/parent_home_tab.dart
//  Parental monitoring portal: Live Sync Banner + Journal Feed
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../login_screen.dart';

class ParentHomeTab extends StatefulWidget {
  const ParentHomeTab({super.key});

  @override
  State<ParentHomeTab> createState() => _ParentHomeTabState();
}

class _ParentHomeTabState extends State<ParentHomeTab> {
  final List<Map<String, String>> _articles = [
    {
      'title': 'Mengenali Gejala Burnout Akademik Pada Remaja',
      'author': 'dr. Amelia Fitri, M.Psi.',
      'duration': '4 mnt baca',
      'icon': '📚',
    },
    {
      'title':
          'Cara Orang Tua Membangun Dialog Terbuka dengan Anak',
      'author': 'Prof. Budi Santoso, Sp.KJ.',
      'duration': '6 mnt baca',
      'icon': '💬',
    },
    {
      'title':
          'Tanda-Tanda Kecemasan Sosial yang Sering Terabaikan',
      'author': 'dr. Sari Dewi Utami, M.Psi.',
      'duration': '5 mnt baca',
      'icon': '🔍',
    },
    {
      'title':
          'Strategi Mendukung Anak Melewati Masa Ujian dengan Sehat',
      'author': 'Dr. Rizka Nurhayati, Ph.D.',
      'duration': '7 mnt baca',
      'icon': '💡',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final journalText = AppState.readJournal('siswa') ??
            AppState.readJournal('rifqi') ??
            '';

        return Scaffold(
          backgroundColor: PelitaTheme.background,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildParentHeader(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLiveSyncBanner(context),
                      if (journalText.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildJournalPreviewCard(journalText),
                      ],
                      const SizedBox(height: 24),
                      const Text(
                        '📰 Feed Edukasi Adaptif',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: PelitaTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._articles.map(_buildArticleCard),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const PelitaLoginScreen()),
                        ),
                        icon: const Icon(Icons.logout_rounded,
                            color: PelitaTheme.coralRed),
                        label: const Text('Keluar',
                            style: TextStyle(
                                color: PelitaTheme.coralRed)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: PelitaTheme.coralRed),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParentHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
      decoration: const BoxDecoration(
        color: PelitaTheme.darkTeal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
                child: Text('👨‍👩‍👦',
                    style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Portal Orang Tua',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              Text(
                'Pemantauan Rifqi Pratama',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: PelitaTheme.sageGreen.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '🔴 LIVE',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSyncBanner(BuildContext ctx) {
    final state = appState.cahayaState;
    final isDistress = state == CahayaState.distress;
    final isCemas = state == CahayaState.cemas;

    final Color bannerBg;
    final Color borderColor;
    final String icon;
    final String message;

    if (isDistress) {
      bannerBg = PelitaTheme.coralRed.withValues(alpha: 0.15);
      borderColor = PelitaTheme.coralRed.withValues(alpha: 0.4);
      icon = '🚨';
      message =
          'PERINGATAN: Sinyal distress terdeteksi dari aktivitas Rifqi. Intervensi segera diperlukan.';
    } else if (isCemas) {
      bannerBg = PelitaTheme.softYellow.withValues(alpha: 0.4);
      borderColor =
          PelitaTheme.orangeHighlight.withValues(alpha: 0.4);
      icon = '⚠️';
      message =
          'Rifqi menunjukkan sedikit kecemasan. Pantau dan berikan dukungan ringan.';
    } else {
      bannerBg = PelitaTheme.sageGreen.withValues(alpha: 0.1);
      borderColor = PelitaTheme.sageGreen.withValues(alpha: 0.35);
      icon = '✅';
      message =
          'Lentera Rifqi terpantau Stabil. Tidak ada anomali atau sinyal distress parah dalam obrolan 7 hari terakhir.';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Live Sync — Status Rifqi',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: PelitaTheme.textDark,
                      fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
                fontSize: 13,
                color: PelitaTheme.textDark.withValues(alpha: 0.75)),
          ),
          if (isDistress) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: ctx,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: const Text('Rujukan Puskesmas 📍'),
                      content: const Text(
                          'Tombol ini mensimulasikan pengiriman rujukan darurat ke Puskesmas terdekat. Dalam sistem produksi, ini terhubung ke API layanan kesehatan setempat.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Tutup')),
                        ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Kirim Rujukan')),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.local_hospital_rounded,
                    size: 18),
                label: const Text('Rujuk ke Puskesmas Terdekat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PelitaTheme.coralRed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJournalPreviewCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PelitaTheme.honeyTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                PelitaTheme.orangeHighlight.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📖 Jurnal Terbaru Rifqi',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: PelitaTheme.darkTeal),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
                fontSize: 13,
                color: PelitaTheme.textDark.withValues(alpha: 0.75)),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Map<String, String> article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: PelitaTheme.textDark.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: PelitaTheme.sageGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: Text(article['icon']!,
                    style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article['title']!,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: PelitaTheme.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  article['author']!,
                  style: TextStyle(
                      fontSize: 12,
                      color: PelitaTheme.textDark
                          .withValues(alpha: 0.55)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 13, color: PelitaTheme.sageGreen),
                    const SizedBox(width: 4),
                    Text(
                      article['duration']!,
                      style: const TextStyle(
                          fontSize: 12,
                          color: PelitaTheme.sageGreen,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
