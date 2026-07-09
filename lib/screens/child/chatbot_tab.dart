// ============================================================
//  PELITA · lib/screens/child/chatbot_tab.dart
//  Nyala AI chatbot with sentiment triage and typing indicator
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/theme.dart';

// ─────────────────────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────────────────────

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  ChatMessage(
      {required this.text,
      required this.isUser,
      required this.time});
}

// ─────────────────────────────────────────────────────────────
//  CHATBOT TAB
// ─────────────────────────────────────────────────────────────

class ChatBotTab extends StatefulWidget {
  const ChatBotTab({super.key});

  @override
  State<ChatBotTab> createState() => _ChatBotTabState();
}

class _ChatBotTabState extends State<ChatBotTab> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Halo Rifqi! Aku Nyala 🌟, teman AI-mu. Ceritakan apa yang kamu rasakan hari ini. Semua aman di sini ya 💛',
      isUser: false,
      time: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];
  final _chatCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isBotTyping = false;

  @override
  void dispose() {
    _chatCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
          ChatMessage(text: text, isUser: true, time: DateTime.now()));
      _chatCtrl.clear();
      _isBotTyping = true;
    });
    _scrollToBottom();

    final username =
        appState.loggedInUser.isEmpty ? 'siswa' : appState.loggedInUser;

    // AI Triage source #2 — ChatBot input
    final isDistress = detectDistress(text);
    await AppState.saveChat(username, text);

    if (isDistress) {
      appState.setCahayaState(CahayaState.distress);
    }

    await Future.delayed(const Duration(milliseconds: 1200));

    String botReply;
    if (isDistress) {
      botReply =
          '💛 Aku dengar kamu... Itu pasti berat. Aku sudah memberi tahu Guru BK agar bisa mendampingimu lebih cepat. Kamu tidak sendirian, Rifqi 🌈\n\n⚠️ Status darurat aktif — Guru BK diprioritaskan.';
    } else {
      botReply = _generateNormalReply(text);
    }

    if (!mounted) return;
    setState(() {
      _isBotTyping = false;
      _messages.add(ChatMessage(
          text: botReply, isUser: false, time: DateTime.now()));
    });
    _scrollToBottom();
  }

  String _generateNormalReply(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('bosan') || lower.contains('males')) {
      return 'Bosan itu wajar! Coba istirahat sejenak, dengarkan musik favorit, atau jalan-jalan sebentar 🎵';
    }
    if (lower.contains('senang') ||
        lower.contains('baik') ||
        lower.contains('oke')) {
      return 'Wah, senang mendengarnya! Pertahankan energi positif itu ya Rifqi ✨ Kamu keren!';
    }
    if (lower.contains('tugas') ||
        lower.contains('pr') ||
        lower.contains('ujian')) {
      return 'Tugas memang kadang terasa banyak. Coba bagi menjadi bagian kecil-kecil dulu, satu per satu pasti bisa! 💪';
    }
    return 'Terima kasih sudah berbagi cerita 💛 Setiap perasaan itu valid. Kamu sudah berani menceritakannya, itu langkah hebat!';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Selamat pagi';
    if (hour >= 11 && hour < 15) return 'Selamat siang';
    if (hour >= 15 && hour < 19) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header ──────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [PelitaTheme.darkTeal, Color(0xFF1E5C58)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 18),
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
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: PelitaTheme.orangeHighlight,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: PelitaTheme.orangeHighlight
                                    .withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                              child: Text('🌟',
                                  style: TextStyle(fontSize: 22))),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Teman Cerita',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16),
                            ),
                            Text(
                              'Asisten Mental Empati • Selalu Ada',
                              style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ListenableBuilder(
                          listenable: appState,
                          builder: (_, __) {
                            if (appState.cahayaState ==
                                CahayaState.distress) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: PelitaTheme.coralRed,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: PelitaTheme.coralRed
                                          .withValues(alpha: 0.4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '⚠️ DISTRESS',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Chat messages ─────────────────────────────
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isBotTyping ? 1 : 0),
            itemBuilder: (context, i) {
              if (_isBotTyping && i == _messages.length) {
                return _buildTypingIndicator();
              }
              return _buildBubble(_messages[i]);
            },
          ),
        ),

        // ── Input bar ────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: PelitaTheme.textDark.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cerita sesuatu ke Nyala...',
                    hintStyle: TextStyle(
                        color: PelitaTheme.textDark
                            .withValues(alpha: 0.35),
                        fontSize: 14),
                    filled: true,
                    fillColor: PelitaTheme.background,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: PelitaTheme.darkTeal,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: PelitaTheme.orangeHighlight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                  child:
                      Text('🌟', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? PelitaTheme.darkTeal : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft:
                      Radius.circular(isUser ? 18 : 4),
                  bottomRight:
                      Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: PelitaTheme.textDark.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isUser
                      ? Colors.white
                      : PelitaTheme.textDark.withValues(alpha: 0.85),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: PelitaTheme.orangeHighlight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
                child:
                    Text('🌟', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color:
                      PelitaTheme.textDark.withValues(alpha: 0.06),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TYPING DOTS ANIMATION
// ─────────────────────────────────────────────────────────────

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final offset = ((_ctrl.value - i * 0.2) % 1.0);
            final opacity = (offset < 0.5)
                ? (offset * 2).clamp(0.3, 1.0)
                : ((1.0 - offset) * 2).clamp(0.3, 1.0);
            return Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PelitaTheme.darkTeal.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}
