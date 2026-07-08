// ============================================================
//  PELITA · lib/screens/child/profile_tab.dart
//  Student profile: avatar, stats, badges, logout
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Avatar card ──────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: PelitaTheme.darkTeal,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: PelitaTheme.orangeHighlight
                            .withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                          child: Text('👦',
                              style: TextStyle(fontSize: 38))),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Rifqi Pratama',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelas IX-A  •  SMP Nusantara',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statChip('${appState.exp}', 'EXP'),
                        _statChip('12', 'Streak'),
                        _statChip('Lv 4', 'Level'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _sectionTitle('🌡️ Kondisi Emosi Sekarang'),
              const SizedBox(height: 12),
              _cahayaStatusCard(),
              const SizedBox(height: 20),
              _sectionTitle('🏅 Lencana Pencapaian'),
              const SizedBox(height: 12),
              _badgesRow(),
              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PelitaLoginScreen()),
                  );
                },
                icon: const Icon(Icons.logout_rounded,
                    color: PelitaTheme.coralRed),
                label: const Text('Keluar Akun',
                    style: TextStyle(color: PelitaTheme.coralRed)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: PelitaTheme.coralRed),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statChip(String value, String label) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12)),
        ],
      );

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 15,
          color: PelitaTheme.textDark));

  Widget _cahayaStatusCard() {
    final state = appState.cahayaState;
    final Color bg;
    final String label;
    final String emoji;

    switch (state) {
      case CahayaState.stabil:
        bg = PelitaTheme.sageGreen.withValues(alpha: 0.12);
        label = 'Stabil — Semua baik-baik saja';
        emoji = '✅';
        break;
      case CahayaState.cemas:
        bg = PelitaTheme.softYellow.withValues(alpha: 0.4);
        label = 'Cemas — Perlu perhatian ringan';
        emoji = '⚠️';
        break;
      case CahayaState.distress:
        bg = PelitaTheme.coralRed.withValues(alpha: 0.12);
        label = 'Distress — Intervensi aktif';
        emoji = '🚨';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: PelitaTheme.textDark)),
        ],
      ),
    );
  }

  Widget _badgesRow() {
    final badges = [
      ('🔆', 'Pejuang\nCahaya'),
      ('🌱', 'Tumbuh\nBersama'),
      ('💬', 'Pembuka\nCerita'),
      ('🎯', 'Fokus\nHarian'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: badges
          .map((b) => Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: PelitaTheme.honeyTint,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: PelitaTheme.orangeHighlight
                              .withValues(alpha: 0.4),
                          width: 2),
                    ),
                    child: Center(
                        child: Text(b.$1,
                            style: const TextStyle(fontSize: 26))),
                  ),
                  const SizedBox(height: 6),
                  Text(b.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          color: PelitaTheme.textDark
                              .withValues(alpha: 0.65))),
                ],
              ))
          .toList(),
    );
  }
}
