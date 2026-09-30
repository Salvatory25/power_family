import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';

// -----------------------------------------------------------------------------
// 1. DATA MODEL
// -----------------------------------------------------------------------------
class ChatMessage {
  final ValueNotifier<String> textNotifier;
  final bool isUser;
  final DateTime timestamp;
  bool isStreaming;

  ChatMessage({
    required String text,
    required this.isUser,
    required this.timestamp,
    this.isStreaming = false,
  }) : textNotifier = ValueNotifier(text);
}

// -----------------------------------------------------------------------------
// 2. MAIN SCREEN
// -----------------------------------------------------------------------------
class AIMarketingCenterScreen extends StatefulWidget {
  const AIMarketingCenterScreen({super.key});

  @override
  _AIMarketingCenterScreenState createState() => _AIMarketingCenterScreenState();
}

class _AIMarketingCenterScreenState extends State<AIMarketingCenterScreen> with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isLoading = false;
  bool _isDarkMode = false;

  StreamSubscription? _streamSubscription;
  http.Client? _httpClient;

  final String _ollamaUrl = 'https://traducianistic-unmagnanimously-summer.ngrok-free.dev/api/generate';

  @override
  void initState() {
    super.initState();
    _addInitialMessage();
  }

  void _addInitialMessage() {
    _messages.add(ChatMessage(
      text: "Habari! Mimi ni **AI Marketing Assistant wa Power Family**. Naweza kukusaidia kutengeneza matangazo ya viwanja na nyumba, chambuzi za soko, na kuvutia wateja. Nianze na nini?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _stopStreaming();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _stopStreaming() {
    _streamSubscription?.cancel();
    _httpClient?.close();
    if (mounted && _isLoading) {
      setState(() {
        _isLoading = false;
        if (_messages.isNotEmpty && _messages.last.isStreaming) {
          _messages.last.isStreaming = false;
          _messages.last.textNotifier.value += " *(Stopped)*";
        }
      });
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<String> _buildContextualPrompt(String userText) async {
    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('properties')
          .select('property_code, type, size_sqm, price, status')
          .eq('status', 'AVAILABLE')
          .limit(10);
      
      String inventoryData = "Available Properties in Database:\n";
      for (var prop in res as List) {
        inventoryData += "- Code: ${prop['property_code']}, Type: ${prop['type']}, Size: ${prop['size_sqm']} sqm, Price: ${prop['price']} TZS\n";
      }

      return "Role: You are a Professional AI Marketing Assistant for 'Power Family' (a Real Estate Company in Tanzania).\nCRITICAL INSTRUCTIONS:\n1. You MUST reply in ENGLISH ONLY.\n2. Be extremely concise, factual, and direct (word-to-word).\n3. Do NOT write long paragraphs or unnecessary fluff.\n4. You MUST strictly use the following real inventory data. Do not invent properties, prices, or codes that are not listed here.\n\n$inventoryData\n\nUser: $userText\nAssistant:";
    } catch (e) {
      // Fallback if DB fails
      return "Role: You are a Professional AI Marketing Assistant for 'Power Family' (a Real Estate Company in Tanzania).\nCRITICAL INSTRUCTIONS:\n1. You MUST reply in ENGLISH ONLY.\n2. Be extremely concise and factual.\n3. Do NOT write long paragraphs.\n\nUser: $userText\nAssistant:";
    }
  }

  Future<void> _handleSendMessage() async {
    String userText = _inputController.text.trim();
    if (userText.isEmpty || _isLoading) return;

    _inputController.clear();
    setState(() {
      _messages.add(ChatMessage(text: userText, isUser: true, timestamp: DateTime.now()));
      _isLoading = true;
      _messages.add(ChatMessage(text: "", isUser: false, timestamp: DateTime.now(), isStreaming: true));
    });
    _scrollToBottom();

    try {
      final contextualPrompt = await _buildContextualPrompt(userText);

      _httpClient = http.Client();
      var request = http.Request('POST', Uri.parse(_ollamaUrl));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        "model": "phi3",
        "prompt": contextualPrompt,
        "stream": true,
      });

      var response = await _httpClient!.send(request);

      _streamSubscription = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
          if (line.trim().isEmpty) return;
          try {
            final json = jsonDecode(line);
            final String chunk = json['response'] ?? "";
            _messages.last.textNotifier.value += chunk;
            _scrollToBottom();
            if (json['done'] == true) _finalizeChat();
          } catch (e) {}
        },
        onError: (e) => _handleError("Stream interrupted."),
        cancelOnError: true,
      );
    } catch (e) { _handleError("Connection failed."); }
  }

  void _finalizeChat() {
    if (mounted) setState(() { _isLoading = false; _messages.last.isStreaming = false; });
    _streamSubscription?.cancel();
    _httpClient?.close();
  }

  void _handleError(String error) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _messages.add(ChatMessage(text: "**Note**: $error", isUser: false, timestamp: DateTime.now()));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: _isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFF0F2F5),
        appBar: AppBar(
          backgroundColor: _isDarkMode ? const Color(0xFF1A1A1A) : AppColors.primary,
          title: Text("AI Marketing Hub", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white), onPressed: () => setState(() => _isDarkMode = !_isDarkMode)),
            IconButton(icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white), onPressed: () => setState(() { _messages.clear(); _addInitialMessage(); })),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _ChatBubble(message: _messages[index], isDark: _isDarkMode),
              ),
            ),
            _buildInputSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: _isLoading ? "Thinking..." : "Andika hapa...",
                hintStyle: TextStyle(color: _isDarkMode ? Colors.white54 : Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: _isDarkMode ? Colors.white24 : Colors.grey.shade300),
                ),
              ),
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: _isLoading ? Colors.redAccent : AppColors.accent,
            child: IconButton(
              icon: Icon(_isLoading ? Icons.stop : Icons.send, color: Colors.white),
              onPressed: _isLoading ? _stopStreaming : _handleSendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. TYPING DOTS
// -----------------------------------------------------------------------------
class _TypingDots extends StatefulWidget {
  @override
  _TypingDotsState createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) => AnimationController(vsync: this, duration: const Duration(milliseconds: 500)));
    _animations = _controllers.map((c) => Tween<double>(begin: 0.0, end: -6.0).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut))).toList();
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () { if (mounted) _controllers[i].repeat(reverse: true); });
    }
  }

  @override
  void dispose() { for (var c in _controllers) { c.dispose(); } super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (index) => AnimatedBuilder(
      animation: _animations[index],
      builder: (context, child) => Transform.translate(offset: Offset(0, _animations[index].value), child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 5, height: 5, decoration: BoxDecoration(color: Colors.grey[500], shape: BoxShape.circle))),
    )));
  }
}

// -----------------------------------------------------------------------------
// 4. CHAT BUBBLE WIDGET (With Copy Feature)
// -----------------------------------------------------------------------------
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;

  const _ChatBubble({required this.message, required this.isDark});

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: const Text("Text copied!"), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isUser ? AppColors.accent : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(15), topRight: const Radius.circular(15),
              bottomLeft: Radius.circular(message.isUser ? 15 : 0), bottomRight: Radius.circular(message.isUser ? 0 : 15),
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          ),
          child: ValueListenableBuilder<String>(
            valueListenable: message.textNotifier,
            builder: (context, currentText, _) {
              if (!message.isUser && currentText.isEmpty && message.isStreaming) {
                return Padding(padding: const EdgeInsets.all(8), child: _TypingDots());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: currentText + (message.isStreaming && !message.isUser ? " █" : ""),
                    styleSheet: MarkdownStyleSheet(
                        p: TextStyle(color: message.isUser ? Colors.white : (isDark ? Colors.white : Colors.black87), fontSize: 15)
                    ),
                  ),
                  if (!message.isUser && currentText.isNotEmpty) ...[
                    const Divider(height: 15, thickness: 0.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => _copyToClipboard(context, currentText),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                Icon(Icons.copy, size: 14, color: isDark ? Colors.white54 : Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text("Copy", style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey[600])),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
