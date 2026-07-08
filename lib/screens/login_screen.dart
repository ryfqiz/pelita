// ============================================================
//  PELITA · lib/screens/login_screen.dart
//  Multi-role login with animated branding and demo shortcuts
// ============================================================

import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../core/theme.dart';
import 'child/shell_screen.dart';
import 'bk_teacher/dashboard_screen.dart';
import 'parent/parent_home_tab.dart';

class PelitaLoginScreen extends StatefulWidget {
  const PelitaLoginScreen({super.key});

  @override
  State<PelitaLoginScreen> createState() => _PelitaLoginScreenState();
}

class _PelitaLoginScreenState extends State<PelitaLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;
  late AnimationController _logoAnim;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _logoAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _logoScale =
        CurvedAnimation(parent: _logoAnim, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _logoAnim.dispose();
    _usernameCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);

    final uname = _usernameCtrl.text.trim().toLowerCase();
    appState.setLoggedInUser(uname);

    Widget dest;
    if (uname == 'siswa' || uname == 'murid' || uname == 'rifqi') {
      dest = const PelitaShellScreen();
    } else if (uname == 'bk' || uname == 'guru') {
      dest = const BKDashboardScreen();
    } else if (uname == 'ortu' || uname == 'parent') {
      dest = const ParentHomeTab();
    } else {
      dest = const PelitaShellScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => dest,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _quickLogin(String role) {
    _usernameCtrl.text = role;
    _passCtrl.text = '1234';
    _handleLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PelitaTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo / branding ──────────────────────
                  ScaleTransition(
                    scale: _logoScale,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Image.asset(
                            'assets/images/pelita_logo.png',
                            height: 360,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback jika asset belum ter-load sempurna atau error
                              return Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: PelitaTheme.darkTeal,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: const Center(
                                  child: Text(
                                    '🔆',
                                    style: TextStyle(fontSize: 54),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 0),

                  // ── Username field ────────────────────────
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: _inputDecoration(
                      label: 'Username',
                      hint: 'siswa / bk / ortu',
                      icon: Icons.person_outline_rounded,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Isi username' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Password field ────────────────────────
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscurePass,
                    decoration: _inputDecoration(
                      label: 'Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePass
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: PelitaTheme.darkTeal.withValues(alpha: 0.6),
                        ),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Isi password' : null,
                  ),
                  const SizedBox(height: 28),

                  // ── Login button ──────────────────────────
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PelitaTheme.darkTeal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : const Text(
                              'Masuk ke Sistem',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Quick demo shortcuts ───────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: PelitaTheme.honeyTint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: PelitaTheme.orangeHighlight
                              .withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚡ Pintasan Demo KMIPN',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color:
                                PelitaTheme.darkTeal.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _demoChip(
                                '👦 Siswa', () => _quickLogin('siswa')),
                            const SizedBox(width: 8),
                            _demoChip(
                                '🛡️ Guru BK', () => _quickLogin('bk')),
                            const SizedBox(width: 8),
                            _demoChip(
                                '👨‍👩‍👦 Ortu',
                                () => _quickLogin('ortu')),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      'KMIPN 2025 · Prototipe Sistem Skrining Mental',
                      style: TextStyle(
                        fontSize: 11,
                        color: PelitaTheme.textDark.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
          {required String label,
          required String hint,
          required IconData icon}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            Icon(icon, color: PelitaTheme.darkTeal.withValues(alpha: 0.6)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: PelitaTheme.textDark.withValues(alpha: 0.1),
              width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: PelitaTheme.darkTeal, width: 2),
        ),
        labelStyle: TextStyle(
            color: PelitaTheme.textDark.withValues(alpha: 0.7)),
      );

  Widget _demoChip(String label, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: PelitaTheme.darkTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
}
