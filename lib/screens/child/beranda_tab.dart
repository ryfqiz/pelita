// ============================================================
//  PELITA · lib/screens/child/beranda_tab.dart
//  Cahaya Meter, Daily Journal Mission, Box Breathing Dialog
// ============================================================

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';

// ─────────────────────────────────────────────────────────────
//  BERANDA TAB
// ─────────────────────────────────────────────────────────────

class BerandaTab extends StatefulWidget {
  const BerandaTab({super.key});

  @override
  State<BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab>
    with SingleTickerProviderStateMixin {
  final _misiCtrl = TextEditingController();
  bool _isMissionCompleted = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  String? _savedJournal;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.92, end: 1.08).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _savedJournal = AppState.readJournal(appState.loggedInUser);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _misiCtrl.dispose();
    super.dispose();
  }

  void _submitMission(BuildContext context) async {
    final text = _misiCtrl.text.trim();
    if (text.isEmpty) return;

    final username =
        appState.loggedInUser.isEmpty ? 'siswa' : appState.loggedInUser;
    await AppState.saveJournal(username, text);

    // AI Triage source #1 — Daily journal form
    if (detectDistress(text)) {
      appState.setCahayaState(CahayaState.distress);
      if (mounted) {
        _showDistressAlert(context);
      }
    } else {
      appState.addExp(50);
    }

    setState(() {
      _isMissionCompleted = true;
      _savedJournal = text;
    });
  }

  void _showDistressAlert(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('⚠️ Perhatian Sistem',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: PelitaTheme.coralRed)),
        content: const Text(
          'Catatan harianmu terdeteksi mengandung sinyal yang perlu perhatian. Guru BK sudah kami beritahu. Kamu tidak sendirian 💛',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Oke, Terima Kasih'),
          ),
        ],
      ),
    );
  }

  void _showBreathingDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => const _BreathingDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCahayaMeter(context),
                    const SizedBox(height: 24),
                    _buildMisiCard(context),
                    if (_savedJournal != null &&
                        _savedJournal!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildJournalSavedCard(),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Selamat pagi';
    if (hour >= 11 && hour < 15) return 'Selamat siang';
    if (hour >= 15 && hour < 19) return 'Selamat sore';
    return 'Selamat malam';
  }

  Widget _buildHeader() {
    final loggedIn = appState.loggedInUser;
    final username = (loggedIn.isEmpty || loggedIn.toLowerCase() == 'siswa')
        ? 'Rifqi'
        : loggedIn[0].toUpperCase() + loggedIn.substring(1);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PelitaTheme.darkTeal, Color(0xFF1E5C58)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PelitaTheme.sageGreen.withValues(alpha: 0.85),
                  PelitaTheme.darkTeal.withValues(alpha: 0.15),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()}, $username ✨',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bagaimana perasaanmu hari ini?',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: PelitaTheme.orangeHighlight,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: PelitaTheme.orangeHighlight
                                .withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        '🔥 12 hari',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      'Level 4 · ${appState.exp}/1000 EXP',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: appState.exp / 1000,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(
                        PelitaTheme.orangeHighlight),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCahayaMeter(BuildContext context) {
    final state = appState.cahayaState;
    final Color glowColor;
    final Color faceColor;
    final String stateLabel;
    final String stateDesc;
    final String face;

    switch (state) {
      case CahayaState.stabil:
        glowColor = PelitaTheme.orangeHighlight;
        faceColor = PelitaTheme.softYellow;
        stateLabel = 'Terang • STABIL';
        stateDesc = 'Cahaya batinmu bersinar cerah hari ini!';
        face = '^ u ^';
        break;
      case CahayaState.cemas:
        glowColor = PelitaTheme.softYellow;
        faceColor = const Color(0xFFFDE68A);
        stateLabel = 'Redup • CEMAS';
        stateDesc =
            'Terdeteksi kelelahan ringan. Istirahat sejenak ya.';
        face = '·  ·  ·';
        break;
      case CahayaState.distress:
        glowColor = PelitaTheme.coralRed;
        faceColor = PelitaTheme.coralRed.withValues(alpha: 0.25);
        stateLabel = 'Badai • DISTRESS';
        stateDesc =
            'Sinyal krisis terdeteksi. Guru BK sudah diberitahu.';
        face = 'T_T';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.18),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🔆 Cahaya Minggu Ini',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: PelitaTheme.textDark.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _showBreathingDialog(context),
            child: ScaleTransition(
              scale: _pulse,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: glowColor.withValues(alpha: 0.12),
                    ),
                  ),
                  Container(
                    width: 105,
                    height: 105,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: glowColor.withValues(alpha: 0.22),
                    ),
                  ),
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: faceColor,
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withValues(alpha: 0.4),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        face,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color:
                              state == CahayaState.distress
                                  ? PelitaTheme.coralRed
                                  : PelitaTheme.darkTeal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: glowColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              stateLabel,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: glowColor == PelitaTheme.softYellow
                    ? const Color(0xFFB07D00)
                    : (state == CahayaState.distress
                        ? PelitaTheme.coralRed
                        : PelitaTheme.orangeHighlight),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stateDesc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: PelitaTheme.textDark.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ketuk wajah untuk latihan pernapasan 🌬️',
            style: TextStyle(
              fontSize: 11,
              color: PelitaTheme.darkTeal.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMisiCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: PelitaTheme.sageGreen.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PelitaTheme.sageGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_note_rounded,
                    color: PelitaTheme.sageGreen, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cerita Harian',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: PelitaTheme.textDark),
                  ),
                  Text(
                    'Yuk, luapkan perasaanmu!',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_isMissionCompleted) ...[
            TextField(
              controller: _misiCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Tulis cerita atau perasaanmu hari ini... Tidak ada yang salah di sini.',
                hintStyle: TextStyle(
                    color: PelitaTheme.textDark.withValues(alpha: 0.35),
                    fontSize: 13),
                filled: true,
                fillColor: PelitaTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _submitMission(context),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Kirim Catatan  (+50 EXP)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PelitaTheme.sageGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PelitaTheme.sageGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: PelitaTheme.sageGreen),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Misi hari ini selesai! Kamu luar biasa 💚\n+50 EXP dikreditkan',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: PelitaTheme.sageGreen),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJournalSavedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PelitaTheme.honeyTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: PelitaTheme.orangeHighlight.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📖 Catatan Tersimpan',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: PelitaTheme.darkTeal),
          ),
          const SizedBox(height: 8),
          Text(
            _savedJournal!,
            style: TextStyle(
                fontSize: 13,
                color:
                    PelitaTheme.textDark.withValues(alpha: 0.75)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  BOX BREATHING DIALOG
// ─────────────────────────────────────────────────────────────

class _BreathingDialog extends StatefulWidget {
  const _BreathingDialog();

  @override
  State<_BreathingDialog> createState() => _BreathingDialogState();
}

class _BreathingDialogState extends State<_BreathingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _phase = 0;
  final List<String> _phaseLabels = [
    'Tarik Nafas\n4 detik',
    'Tahan\n7 detik',
    'Hembuskan\n8 detik',
    'Istirahat\n4 detik',
  ];
  late Timer _timer;
  int _countdown = 4;
  final List<int> _phaseDurations = [4, 7, 8, 4];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
    _startPhase();
  }

  void _startPhase() {
    _countdown = _phaseDurations[_phase];
    
    // Configure animation direction/duration based on the phase
    if (_phase == 0) {
      // Tarik nafas: Membesar (from 0.0 to 1.0)
      _ctrl.duration = Duration(seconds: _phaseDurations[0]);
      _ctrl.forward(from: 0.0);
    } else if (_phase == 1) {
      // Tahan: Diam di posisi maksimal (1.0)
      _ctrl.value = 1.0;
    } else if (_phase == 2) {
      // Hembuskan: Mengecil (from 1.0 to 0.0)
      _ctrl.duration = Duration(seconds: _phaseDurations[2]);
      _ctrl.reverse(from: 1.0);
    } else if (_phase == 3) {
      // Istirahat: Diam di posisi minimal (0.0)
      _ctrl.value = 0.0;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          t.cancel();
          _phase = (_phase + 1) % 4;
          _startPhase();
        }
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24)),
      backgroundColor: PelitaTheme.darkTeal,
      title: const Text(
        '🌬️ Latihan Pernapasan 4-7-8',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              // Map animation value (0.0 to 1.0) to Scale range (0.85 to 1.15)
              final scaleVal = 0.85 + (_ctrl.value * 0.30);
              return Transform.scale(
                scale: scaleVal,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PelitaTheme.orangeHighlight
                        .withValues(alpha: 0.2),
                    border: Border.all(
                        color: PelitaTheme.orangeHighlight, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      '$_countdown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            _phaseLabels[_phase],
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Teknik 4-7-8 membantu menenangkan sistem saraf',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Selesai',
                style: TextStyle(
                    color: PelitaTheme.softYellow,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
