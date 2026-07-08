// ============================================================
//  PELITA · lib/screens/bk_teacher/dashboard_screen.dart
//  BK Teacher portal: 3-panel desktop layout, student queue,
//  intervention form, authority reset, counseling log
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../login_screen.dart';

class BKDashboardScreen extends StatefulWidget {
  const BKDashboardScreen({super.key});

  @override
  State<BKDashboardScreen> createState() => _BKDashboardScreenState();
}

class _BKDashboardScreenState extends State<BKDashboardScreen> {
  int _selectedMenu = 0;
  String _selectedStudent = 'rifqi';
  String _selectedStatus = 'Stabil';
  final _noteCtrl = TextEditingController();

  final List<Map<String, dynamic>> _studentQueue = [
    {
      'name': 'Rifqi Pratama',
      'username': 'rifqi',
      'class': 'IX-A',
      'priority': 'high',
      'tag': '⚠️ Prioritas Utama',
    },
    {
      'name': 'Siti Nurhaliza',
      'username': 'siti',
      'class': 'VIII-B',
      'priority': 'medium',
      'tag': '🟡 Perlu Pantau',
    },
    {
      'name': 'Ahmad Fauzi',
      'username': 'ahmad',
      'class': 'VII-C',
      'priority': 'low',
      'tag': '🟢 Stabil',
    },
    {
      'name': 'Dita Ayu',
      'username': 'dita',
      'class': 'IX-B',
      'priority': 'medium',
      'tag': '🟡 Perlu Pantau',
    },
  ];

  final List<String> _menuItems = [
    'Prioritas Siswa',
    'Riwayat Kasus',
    'Konfigurasi Rujukan',
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _saveCounselingNote() {
    if (_noteCtrl.text.trim().isEmpty) return;
    final note = _noteCtrl.text.trim();

    CahayaState newState;
    switch (_selectedStatus) {
      case 'Cemas':
        newState = CahayaState.cemas;
        break;
      case 'Distress':
        newState = CahayaState.distress;
        break;
      default:
        newState = CahayaState.stabil;
    }

    appState.setCahayaState(newState);
    appState.addCounselingLog(note, _selectedStatus);
    _noteCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('✅ Catatan disimpan — Status: $_selectedStatus'),
        backgroundColor: PelitaTheme.darkTeal,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {});
  }

  void _authorityReset() {
    appState.resetToStabil();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            '🔄 Authority Reset — Status dikembalikan ke Stabil (False Alarm)'),
        backgroundColor: PelitaTheme.sageGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final isWide = MediaQuery.of(context).size.width > 900;
        return Scaffold(
          backgroundColor: PelitaTheme.background,
          body: isWide
              ? _buildDesktopLayout(context)
              : _buildMobileLayout(context),
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        _buildSidebar(),
        SizedBox(
          width: 280,
          child: _buildStudentQueuePanel(),
        ),
        Expanded(child: _buildDetailPanel(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: PelitaTheme.darkTeal,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        const Text(
                          '🛡️ Dashboard BK',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded,
                              color: Colors.white54),
                          onPressed: () =>
                              Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const PelitaLoginScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    indicatorColor: PelitaTheme.orangeHighlight,
                    tabs: [
                      Tab(text: 'Antrean Siswa'),
                      Tab(text: 'Panel Intervensi'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildStudentQueuePanel(),
                _buildDetailPanel(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: PelitaTheme.darkTeal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🛡️ PELITA BK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Portal Guru BK',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _menuItems.length,
              itemBuilder: (context, i) {
                final active = _selectedMenu == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMenu = i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: active
                          ? Border.all(
                              color:
                                  Colors.white.withValues(alpha: 0.15))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          [
                            Icons.priority_high_rounded,
                            Icons.history_rounded,
                            Icons.settings_rounded,
                          ][i],
                          color: active
                              ? PelitaTheme.orangeHighlight
                              : Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _menuItems[i],
                          style: TextStyle(
                            color: active
                                ? Colors.white
                                : Colors.white60,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const PelitaLoginScreen()),
              ),
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded,
                      color: Colors.white38, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Keluar',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentQueuePanel() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Antrean Prioritas',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: PelitaTheme.textDark),
                ),
                Text(
                  '${_studentQueue.length} siswa terdaftar',
                  style: TextStyle(
                      fontSize: 12,
                      color: PelitaTheme.textDark
                          .withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
          if (appState.cahayaState == CahayaState.distress)
            _buildDistressFlashBanner(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _studentQueue.length,
              itemBuilder: (context, i) {
                final sortedQueue =
                    List<Map<String, dynamic>>.from(_studentQueue);
                if (appState.cahayaState == CahayaState.distress) {
                  sortedQueue.sort((a, b) {
                    if (a['username'] == 'rifqi') return -1;
                    if (b['username'] == 'rifqi') return 1;
                    return 0;
                  });
                }
                return _buildStudentCard(sortedQueue[i]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistressFlashBanner() {
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: PelitaTheme.coralRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: PelitaTheme.coralRed.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: PelitaTheme.coralRed, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '⚠️ PERLU TINDAKAN INSTAN HARI INI',
              style: TextStyle(
                  color: PelitaTheme.coralRed,
                  fontWeight: FontWeight.w800,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final isSelected = _selectedStudent == student['username'];
    final isRaka = student['username'] == 'rifqi';
    final isDistressActive =
        isRaka && appState.cahayaState == CahayaState.distress;

    return GestureDetector(
      onTap: () =>
          setState(() => _selectedStudent = student['username']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDistressActive
              ? PelitaTheme.coralRed.withValues(alpha: 0.07)
              : isSelected
                  ? PelitaTheme.honeyTint
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDistressActive
                ? PelitaTheme.coralRed.withValues(alpha: 0.4)
                : isSelected
                    ? PelitaTheme.orangeHighlight
                    : PelitaTheme.textDark.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isRaka
                    ? PelitaTheme.orangeHighlight
                        .withValues(alpha: 0.2)
                    : PelitaTheme.sageGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  student['name'].toString()[0],
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isRaka
                        ? PelitaTheme.orangeHighlight
                        : PelitaTheme.sageGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: PelitaTheme.textDark),
                  ),
                  Text(
                    '${student['class']} · ${student['tag']}',
                    style: TextStyle(
                        fontSize: 11,
                        color: PelitaTheme.textDark
                            .withValues(alpha: 0.55)),
                  ),
                ],
              ),
            ),
            if (isDistressActive)
              const Icon(Icons.flash_on_rounded,
                  color: PelitaTheme.coralRed, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPanel(BuildContext context) {
    final studentName = _studentQueue.firstWhere(
        (s) => s['username'] == _selectedStudent,
        orElse: () => _studentQueue[0])['name'];

    final studentJournal =
        AppState.readJournal(_selectedStudent) ?? '';
    final studentChat = AppState.readChat(_selectedStudent) ?? '';

    return Container(
      color: PelitaTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top bar ──────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rekam Medis — $studentName',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: PelitaTheme.textDark,
                        ),
                      ),
                      _cahayaStatusChip(appState.cahayaState),
                    ],
                  ),
                ),

                // ── Authority Reset Button ──────────
                if (appState.cahayaState != CahayaState.stabil)
                  Tooltip(
                    message: 'Reset status — False Alarm / Iseng',
                    child: OutlinedButton.icon(
                      onPressed: _authorityReset,
                      icon: const Icon(Icons.refresh_rounded,
                          color: PelitaTheme.sageGreen, size: 18),
                      label: const Text(
                        'Reset Keadaan Hari Ini\n(Iseng/False Alarm)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PelitaTheme.sageGreen,
                            fontSize: 12,
                            height: 1.3),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: PelitaTheme.sageGreen),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMoodGraph(),
                  const SizedBox(height: 20),
                  _buildAISummaryBox(),
                  const SizedBox(height: 20),
                  if (studentJournal.isNotEmpty ||
                      studentChat.isNotEmpty)
                    _buildStudentDataCard(
                        studentName, studentJournal, studentChat),
                  const SizedBox(height: 20),
                  _buildInterventionForm(),
                  const SizedBox(height: 20),
                  _buildCounselingLog(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cahayaStatusChip(CahayaState state) {
    final Color bg;
    final String label;

    switch (state) {
      case CahayaState.stabil:
        bg = PelitaTheme.sageGreen;
        label = '🟢 Stabil';
        break;
      case CahayaState.cemas:
        bg = PelitaTheme.softYellow;
        label = '🟡 Cemas';
        break;
      case CahayaState.distress:
        bg = PelitaTheme.coralRed;
        label = '🔴 Distress';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: state == CahayaState.cemas
                ? const Color(0xFF8A6500)
                : bg),
      ),
    );
  }

  Widget _buildMoodGraph() {
    final lastScore = appState.cahayaState == CahayaState.distress
        ? 1
        : appState.cahayaState == CahayaState.cemas
            ? 2
            : 4;
    final scores = [3, 4, 2, 3, lastScore];
    final labels = ['H-5', 'H-4', 'H-3', 'H-2', 'H-1'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PelitaTheme.textDark.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Grafik Emosi 5 Hari Terakhir',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: PelitaTheme.textDark),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(5, (i) {
                final score = scores[i];
                final color = score >= 4
                    ? PelitaTheme.sageGreen
                    : score >= 3
                        ? PelitaTheme.orangeHighlight
                        : PelitaTheme.coralRed;
                return Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$score',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w700,
                              fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 600),
                          width: double.infinity,
                          height: score * 20.0,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          labels[i],
                          style: TextStyle(
                              fontSize: 11,
                              color: PelitaTheme.textDark
                                  .withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISummaryBox() {
    final state = appState.cahayaState;
    String summary;

    if (state == CahayaState.distress) {
      summary =
          'AI Insights ⚠️: Terdeteksi kata kunci krisis dalam jurnal/chat hari ini. Rifqi membutuhkan perhatian segera. Antrean konseling telah diprioritaskan ke urutan teratas. Disarankan untuk melakukan wawancara tatap muka dalam waktu 24 jam.';
    } else if (state == CahayaState.cemas) {
      summary =
          'AI Insights 🟡: Berdasarkan analisis jurnal 7 hari terakhir, Rifqi mengalami sedikit kecemasan. Interaksi sosialnya masih positif namun beban akademik mulai terasa. Pantau perkembangan dalam 2-3 hari ke depan.';
    } else {
      summary =
          'AI Insights ✅: Berdasarkan analisis jurnal 7 hari terakhir, Rifqi mengalami penurunan energi batin akibat beban tugas, namun interaksi sosialnya stabil. Tidak ada tanda-tanda krisis yang signifikan. Lanjutkan pemantauan rutin.';
    }

    return Container(
      padding: const EdgeInsets.all(18),
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
          const Row(
            children: [
              Text('🤖', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                'Ringkasan AI Triage',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: PelitaTheme.darkTeal),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary,
            style: TextStyle(
                fontSize: 13,
                color:
                    PelitaTheme.textDark.withValues(alpha: 0.75),
                height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentDataCard(
      String name, String journal, String chat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: PelitaTheme.sageGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 Data Real-Time dari $name',
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: PelitaTheme.textDark),
          ),
          const SizedBox(height: 12),
          if (journal.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.edit_note_rounded,
                    color: PelitaTheme.sageGreen, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'Jurnal Harian:',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: PelitaTheme.darkTeal),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PelitaTheme.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                journal,
                style: TextStyle(
                    fontSize: 13,
                    color: PelitaTheme.textDark
                        .withValues(alpha: 0.75)),
              ),
            ),
          ],
          if (chat.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded,
                    color: PelitaTheme.orangeHighlight, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'Pesan Chat Terakhir:',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: PelitaTheme.darkTeal),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PelitaTheme.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chat,
                style: TextStyle(
                    fontSize: 13,
                    color: PelitaTheme.textDark
                        .withValues(alpha: 0.75)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInterventionForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PelitaTheme.textDark.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✏️ Intervensi Penentu Cahaya',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: PelitaTheme.textDark),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Tulis catatan perkembangan kasus...',
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
          const SizedBox(height: 14),
          const Text(
            'Tentukan Status Cahaya Batin:',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: PelitaTheme.textDark),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _statusChip('Stabil', PelitaTheme.sageGreen),
              const SizedBox(width: 8),
              _statusChip('Cemas', PelitaTheme.softYellow),
              const SizedBox(width: 8),
              _statusChip('Distress', PelitaTheme.coralRed),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveCounselingNote,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text(
                  'Simpan Catatan & Perbarui Status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PelitaTheme.darkTeal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    final selected = _selectedStatus == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStatus = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? color
                  : PelitaTheme.textDark.withValues(alpha: 0.15),
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight:
                  selected ? FontWeight.w800 : FontWeight.w500,
              color: selected
                  ? (label == 'Cemas'
                      ? const Color(0xFF8A6500)
                      : color)
                  : PelitaTheme.textDark.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounselingLog() {
    final logs = appState.counselingLogs;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📚 Buku Catatan Sesi',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: PelitaTheme.textDark),
          ),
          const SizedBox(height: 12),
          if (logs.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Belum ada catatan sesi. Isi form di atas untuk memulai.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: PelitaTheme.textDark
                          .withValues(alpha: 0.4),
                      fontSize: 13),
                ),
              ),
            )
          else
            ...logs.map(_buildLogEntry),
        ],
      ),
    );
  }

  Widget _buildLogEntry(Map<String, String> log) {
    final Color statusColor;
    switch (log['status']) {
      case 'Distress':
        statusColor = PelitaTheme.coralRed;
        break;
      case 'Cemas':
        statusColor = PelitaTheme.orangeHighlight;
        break;
      default:
        statusColor = PelitaTheme.sageGreen;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PelitaTheme.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                log['status'] ?? 'Stabil',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: statusColor),
              ),
              const Spacer(),
              Text(
                log['date'] ?? '',
                style: TextStyle(
                    fontSize: 11,
                    color: PelitaTheme.textDark
                        .withValues(alpha: 0.45)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            log['note'] ?? '',
            style: TextStyle(
                fontSize: 13,
                color:
                    PelitaTheme.textDark.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}
