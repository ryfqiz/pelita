// ============================================================
//  PELITA · lib/screens/child/profile_tab.dart
//  Student profile: avatar, stats, badges, logout
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Selamat pagi';
    if (hour >= 11 && hour < 15) return 'Selamat siang';
    if (hour >= 15 && hour < 19) return 'Selamat sore';
    return 'Selamat malam';
  }

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
              // ── Avatar card (glassmorphism) ────────────
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [PelitaTheme.darkTeal, Color(0xFF1E5C58)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            PelitaTheme.sageGreen.withValues(alpha: 0.85),
                            PelitaTheme.darkTeal.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getGreeting(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: PelitaTheme.orangeHighlight
                                  .withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: PelitaTheme.orangeHighlight
                                      .withValues(alpha: 0.3),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: const Center(
                                child: Text('👦',
                                    style: TextStyle(fontSize: 38))),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Rifqi Zaki',
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
                                color: Colors.white.withValues(alpha: 0.7),
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
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _sectionTitle('Kondisi Emosi Sekarang'),
              const SizedBox(height: 12),
              _cahayaStatusCard(),
              const SizedBox(height: 20),
              _sectionTitle('Badge Pencapaian'),
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
    final String label;
    final String face;
    final Color glowColor;
    final Color faceBgColor;
    final Color statusTextColor;

    switch (state) {
      case CahayaState.stabil:
        label = 'Stabil — Semua baik-baik saja';
        face = '^ u ^';
        glowColor = PelitaTheme.orangeHighlight;
        faceBgColor = PelitaTheme.softYellow;
        statusTextColor = PelitaTheme.darkTeal;
        break;
      case CahayaState.cemas:
        label = 'Cemas — Perlu perhatian ringan';
        face = '·  ·  ·';
        glowColor = PelitaTheme.softYellow;
        faceBgColor = const Color(0xFFFDE68A);
        statusTextColor = const Color(0xFFB07D00);
        break;
      case CahayaState.distress:
        label = 'Distress — Intervensi aktif';
        face = 'T_T';
        glowColor = PelitaTheme.coralRed;
        faceBgColor = PelitaTheme.coralRed.withValues(alpha: 0.25);
        statusTextColor = PelitaTheme.coralRed;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PelitaTheme.sageGreen.withValues(alpha: 0.25),
            PelitaTheme.darkTeal.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: faceBgColor,
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      face,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: state == CahayaState.distress
                            ? PelitaTheme.coralRed
                            : PelitaTheme.darkTeal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: statusTextColor,
                      fontSize: 14,
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

  Widget _badgesRow() {
    final badges = [
      ('🔆', 'Pejuang\nCahaya'),
      ('🌱', 'Tumbuh\nBersama'),
      ('💬', 'Pembuka\nCerita'),
      ('🎯', 'Fokus\nHarian'),
    ];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PelitaTheme.sageGreen.withValues(alpha: 0.25),
            PelitaTheme.darkTeal.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: badges
                  .map((b) => Column(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                b.$1,
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            b.$2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: PelitaTheme.textDark.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
