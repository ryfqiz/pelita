// ============================================================
//  PELITA · lib/screens/child/shell_screen.dart
//  Student app shell: BottomBar + SOS overlay + blinking banner
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import 'beranda_tab.dart';
import 'chatbot_tab.dart';
import 'profile_tab.dart';


// ─────────────────────────────────────────────────────────────
//  SHELL SCREEN
// ─────────────────────────────────────────────────────────────

class PelitaShellScreen extends StatefulWidget {
  const PelitaShellScreen({super.key});

  @override
  State<PelitaShellScreen> createState() => _PelitaShellScreenState();
}

class _PelitaShellScreenState extends State<PelitaShellScreen> {
  int _tabIndex = 0;

  final List<Widget> _tabs = const [
    BerandaTab(),
    ChatBotTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          body: Stack(
            children: [
              _tabs[_tabIndex],
              // ── SOS global overlay ────────────────────
              if (appState.isSosTriggeredGlobal)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _SOSBanner(),
                ),
            ],
          ),

          // ── Bottom Nav ───────────────────────────────
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: PelitaTheme.textDark.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _tabIndex,
              onTap: (i) => setState(() => _tabIndex = i),
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: PelitaTheme.darkTeal,
              unselectedItemColor:
                  PelitaTheme.textDark.withValues(alpha: 0.35),
              selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 12),
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded), label: 'Beranda'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_rounded),
                    label: 'Teman Cerita'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_rounded), label: 'Profil'),
              ],
            ),
          ),

          // ── Floating SOS button ──────────────────────
          floatingActionButton: _tabIndex == 1
              ? null
              : FloatingActionButton.extended(
                  heroTag: 'sos_fab',
                  onPressed: () => _showSOSDialog(context),
                  backgroundColor: PelitaTheme.coralRed,
                  icon: const Icon(Icons.warning_amber_rounded,
                      color: Colors.white),
                  label: const Text('SOS',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800)),
                ),
        );
      },
    );
  }

  void _showSOSDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: PelitaTheme.coralRed, size: 28),
            SizedBox(width: 8),
            Text('Sinyal Darurat SOS',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: PelitaTheme.textDark)),
          ],
        ),
        content: const Text(
          'Kamu akan mengirimkan sinyal darurat ke Guru BK dan Orang Tua sekarang. Status kamu akan berubah ke Distress.\n\nApakah kamu yakin?',
          style: TextStyle(color: PelitaTheme.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              appState.triggerSOS();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      '🚨 Sinyal SOS dikirim ke BK & Orang Tua'),
                  backgroundColor: PelitaTheme.coralRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: PelitaTheme.coralRed),
            child: const Text('Kirim SOS'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SOS BANNER  (blinking overlay)
// ─────────────────────────────────────────────────────────────

class _SOSBanner extends StatefulWidget {
  @override
  State<_SOSBanner> createState() => _SOSBannerState();
}

class _SOSBannerState extends State<_SOSBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.6, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: PelitaTheme.coralRed.withValues(alpha: 0.92),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '⚠️ Status DISTRESS aktif — Guru BK & Orang Tua sudah diberitahu',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ProfileTab lives in profile_tab.dart

