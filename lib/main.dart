// ============================================================
//  PELITA — Sistem Pendampingan Elektronika Lintas-Instansi
//  KMIPN Competition Edition · lib/main.dart
//  Entry point only — all feature code lives in lib/screens/
// ============================================================

import 'package:flutter/material.dart';
import 'core/app_state.dart';
import 'core/theme.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.initPrefs();
  appState.loadPersistedState();
  runApp(const PelitaApp());
}

class PelitaApp extends StatelessWidget {
  const PelitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PELITA — Sistem Cek Kesehatan Mental Sekolah',
      debugShowCheckedModeBanner: false,
      theme: PelitaTheme.theme,
      home: const PelitaLoginScreen(),
    );
  }
}
