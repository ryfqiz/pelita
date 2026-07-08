// ============================================================
//  PELITA · lib/core/app_state.dart
//  Global reactive state, SharedPreferences persistence,
//  and AI Triage keyword engine
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
//  EMOTIONAL STATE ENUM
// ─────────────────────────────────────────────────────────────

/// Possible emotional states for a student's Cahaya Meter.
enum CahayaState { stabil, cemas, distress }

// ─────────────────────────────────────────────────────────────
//  AI TRIAGE ENGINE — Keyword scanner (multi-source)
// ─────────────────────────────────────────────────────────────

const List<String> _kDistressKeywords = [
  'sedih',
  'lelah',
  'sendiri',
  'takut',
  'bully',
  'mati',
  'bunuh',
  'hopeless',
  'putus asa',
];

bool detectDistress(String text) {
  final lower = text.toLowerCase();
  return _kDistressKeywords.any((kw) => lower.contains(kw));
}

// ─────────────────────────────────────────────────────────────
//  APP STATE  (ChangeNotifier singleton)
// ─────────────────────────────────────────────────────────────

/// Singleton-style global state notifier. All screens listen
/// and mutate through this object so cross-role reactivity
/// works without a package like Provider or Riverpod.
class AppState extends ChangeNotifier {
  // ── Cahaya Meter ──────────────────────────────────────────
  CahayaState _cahayaState = CahayaState.stabil;
  CahayaState get cahayaState => _cahayaState;

  // ── SOS flag ──────────────────────────────────────────────
  bool _isSosTriggeredGlobal = false;
  bool get isSosTriggeredGlobal => _isSosTriggeredGlobal;

  // ── Counseling log (BK private notes) ─────────────────────
  List<Map<String, String>> _counselingLogs = [];
  List<Map<String, String>> get counselingLogs =>
      List.unmodifiable(_counselingLogs);

  // ── EXP / gamification ────────────────────────────────────
  int _exp = 650;
  int get exp => _exp;

  // ── Current logged-in username ────────────────────────────
  String _loggedInUser = '';
  String get loggedInUser => _loggedInUser;
  void setLoggedInUser(String u) {
    _loggedInUser = u;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  //  Mutators
  // ─────────────────────────────────────────────────────────

  void setCahayaState(CahayaState s) {
    _cahayaState = s;
    _isSosTriggeredGlobal = (s == CahayaState.distress);
    _persistCahayaState(s);
    notifyListeners();
  }

  void resetToStabil() {
    _cahayaState = CahayaState.stabil;
    _isSosTriggeredGlobal = false;
    _persistCahayaState(CahayaState.stabil);
    notifyListeners();
  }

  void triggerSOS() {
    _cahayaState = CahayaState.distress;
    _isSosTriggeredGlobal = true;
    _persistCahayaState(CahayaState.distress);
    notifyListeners();
  }

  void addCounselingLog(String note, String status) {
    final now = DateTime.now();
    _counselingLogs.insert(0, {
      'note': note,
      'status': status,
      'date':
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}  ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    });
    notifyListeners();
  }

  void addExp(int amount) {
    _exp = (_exp + amount).clamp(0, 1000);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  //  SharedPreferences persistence
  // ─────────────────────────────────────────────────────────

  static late SharedPreferences _prefs;

  static Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void _persistCahayaState(CahayaState s) {
    _prefs.setString('cahaya_state', s.name);
  }

  void loadPersistedState() {
    final saved = _prefs.getString('cahaya_state');
    if (saved != null) {
      _cahayaState = CahayaState.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => CahayaState.stabil,
      );
      _isSosTriggeredGlobal = (_cahayaState == CahayaState.distress);
    }
    notifyListeners();
  }

  // ── Journal / chat per-user helpers ───────────────────────

  static Future<void> saveJournal(String username, String text) async {
    await _prefs.setString('pref_jurnal_$username', text);
  }

  static String? readJournal(String username) {
    return _prefs.getString('pref_jurnal_$username');
  }

  static Future<void> saveChat(String username, String text) async {
    await _prefs.setString('pref_chat_$username', text);
  }

  static String? readChat(String username) {
    return _prefs.getString('pref_chat_$username');
  }
}

// Single global instance — all widgets access this.
final appState = AppState();
