import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:mr_great_ai/api_config.dart';
import 'package:mr_great_ai/tts_utils.dart';

class InfoKampusPage extends StatefulWidget {
  const InfoKampusPage({super.key});

  @override
  State<InfoKampusPage> createState() => _InfoKampusPageState();
}

class _InfoKampusPageState extends State<InfoKampusPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> messages = [];
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isLoading = false;

  // =============== TTS CONTROLS ===============
  bool _isTTSEnabled = true;
  bool _isSpeaking = false;
  bool _isPaused = false;
  String _currentSpeechText = '';
  String _lastAIResponse = '';

  // ======================= TES MINAT BAKAT =======================
  bool isRunningTest = false;
  int testStep = 0;
  Map<String, int> interestScore = {
    'tech': 0,
    'design': 0,
    'business': 0,
    'accounting': 0,
    'sport': 0,
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initChat();
  }

  void _initChat() {
    messages.add({
      'text':
          'Halo 👋 Saya **Mr. Great** — Asisten Informasi Kampus UCIC.\n\n'
          '💡 **Fitur yang bisa kamu gunakan:**\n'
          '- Menanyakan informasi tentang UCIC (jurusan, lokasi, rektor, visi/misi, dll)\n'
          '- Meminta rekomendasi jurusan\n'
          '- Mengikuti **Tes Minat Bakat** untuk mengetahui jurusan paling cocok\n\n'
          'Coba ketik atau ucapkan pertanyaanmu sekarang!',
      'isBot': true,
    });

    // Setup TTS
    flutterTts.setLanguage("id-ID");
    flutterTts.setSpeechRate(0.85);

    // TTS event handlers
    flutterTts.setStartHandler(() {
      if (!mounted) return;
      setState(() {
        _isSpeaking = true;
        _isPaused = false;
      });
    });

    flutterTts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
        _isPaused = false;
        _currentSpeechText = '';
      });
    });

    flutterTts.setCancelHandler(() {
      if (!mounted) return;
      setState(() {
        _isSpeaking = false;
        _isPaused = false;
      });
    });

    flutterTts.setPauseHandler(() {
      if (!mounted) return;
      setState(() {
        _isPaused = true;
        _isSpeaking = false;
      });
    });

    flutterTts.setContinueHandler(() {
      if (!mounted) return;
      setState(() {
        _isPaused = false;
        _isSpeaking = true;
      });
    });

    // Speak welcome message
    if (_isTTSEnabled) {
      _speakText(
        "Halo, saya Mister Great. "
        "Kamu bisa menanyakan informasi kampus UCIC, "
        "atau mengikuti Tes Minat Bakat. "
        "Silakan mulai bertanya!",
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ======================= TTS METHODS =======================
  String _cleanTextForSpeech(String text) {
    return cleanTextForTTS(text);
  }

  Future<void> _speakText(String text) async {
    if (!_isTTSEnabled) return;
    _currentSpeechText = text;
    _lastAIResponse = text;
    String cleanedText = _cleanTextForSpeech(text);
    try {
      await flutterTts.speak(cleanedText);
    } catch (e) {
      debugPrint('TTS error: $e');
    }
  }

  Future<void> _pauseTTS() async {
    try {
      await flutterTts.pause();
    } catch (e) {
      debugPrint('TTS pause error: $e');
    }
    if (!mounted) return;
    setState(() {
      _isPaused = true;
      _isSpeaking = false;
    });
  }

  Future<void> _resumeTTS() async {
    if (_currentSpeechText.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _isPaused = false;
        _isSpeaking = true;
      });
      String cleanedText = _cleanTextForSpeech(_currentSpeechText);
      try {
        await flutterTts.speak(cleanedText);
      } catch (e) {
        debugPrint('TTS resume error: $e');
      }
    }
  }

  Future<void> _stopTTS() async {
    try {
      await flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
    if (!mounted) return;
    setState(() {
      _isSpeaking = false;
      _isPaused = false;
      _currentSpeechText = '';
    });
  }

  void _onTTSToggle() {
    if (!mounted) return;
    setState(() {
      _isTTSEnabled = !_isTTSEnabled;
    });

    if (!_isTTSEnabled) {
      // Disable → stop any speaking
      _stopTTS();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔇 Text-to-Speech dinonaktifkan'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      // Enable → speak last response if available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔊 Text-to-Speech diaktifkan'),
          duration: Duration(seconds: 1),
        ),
      );
      if (_lastAIResponse.isNotEmpty) {
        _speakText(_lastAIResponse);
      }
    }
  }

  // ======================= TES MINAT BAKAT =======================
  String _startInterestTest() {
    isRunningTest = true;
    testStep = 1;
    return """
🔍 **Tes Minat Bakat UCIC – Level Lanjut**

Jawab dengan angka **1–5**:
- 1 → Tidak suka
- 2 → Kurang suka
- 3 → Biasa saja
- 4 → Suka
- 5 → Sangat suka

---
❓ **Pertanyaan 1:**
Apakah kamu suka bekerja dengan komputer, teknologi, atau pemrograman?
""";
  }

  String _nextQuestion(int step) {
    switch (step) {
      case 2:
        return "❓ **Pertanyaan 2:**\nApakah kamu suka membuat desain, menggambar, editing, atau UI/UX?";
      case 3:
        return "❓ **Pertanyaan 3:**\nApakah kamu tertarik dengan bisnis, marketing, atau manajemen organisasi?";
      case 4:
        return "❓ **Pertanyaan 4:**\nApakah kamu suka angka, keuangan, analisis data, atau laporan akuntansi?";
      case 5:
        return "❓ **Pertanyaan 5:**\nApakah kamu suka dunia olahraga, melatih orang, atau aktivitas fisik?";
      default:
        return "";
    }
  }

  void _applyScore(int step, int value) {
    switch (step) {
      case 1:
        interestScore['tech'] = value;
        break;
      case 2:
        interestScore['design'] = value;
        break;
      case 3:
        interestScore['business'] = value;
        break;
      case 4:
        interestScore['accounting'] = value;
        break;
      case 5:
        interestScore['sport'] = value;
        break;
    }
  }

  String _finishInterestTest() {
    isRunningTest = false;

    final tech = interestScore['tech']!;
    final design = interestScore['design']!;
    final business = interestScore['business']!;
    final accounting = interestScore['accounting']!;
    final sport = interestScore['sport']!;

    String topField = "";
    int topScore = 0;

    interestScore.forEach((key, value) {
      if (value > topScore) {
        topScore = value;
        topField = key;
      }
    });

    String recommendation = "";
    switch (topField) {
      case 'tech':
        recommendation = "💻 **Teknik Informatika** atau **Manajemen Informatika**";
        break;
      case 'design':
        recommendation = "🎨 **Desain Komunikasi Visual (DKV)**";
        break;
      case 'business':
        recommendation = "📈 **Manajemen** atau **Bisnis Digital**";
        break;
      case 'accounting':
        recommendation = "📊 **Akuntansi** atau **Komputerisasi Akuntansi**";
        break;
      case 'sport':
        recommendation = "🤸 **Pendidikan Kepelatihan Olahraga**";
        break;
    }

    return """
🎉 **Tes Minat Bakat Selesai!**

📊 **Hasil Skor Kamu:**
- Teknologi: **$tech/5**
- Desain: **$design/5**
- Bisnis: **$business/5**
- Akuntansi: **$accounting/5**
- Olahraga: **$sport/5**

✨ Rekomendasi jurusan paling cocok untuk kamu:
$recommendation

Kalau mau tes ulang, ketik: *tes minat lagi*
""";
  }

  // ======================= RESPONSE HANDLING =======================

  /// Handle interest test input locally
  String? _handleLocalInput(String input) {
    final text = input.toLowerCase().trim();

    // Interest test start
    if (text.contains("tes minat") || text.contains("minat bakat")) {
      return _startInterestTest();
    }

    // Running interest test — handle score input
    if (isRunningTest) {
      if (RegExp(r'^[1-5]$').hasMatch(text)) {
        int value = int.parse(text);
        _applyScore(testStep, value);
        testStep++;
        if (testStep > 5) return _finishInterestTest();
        return _nextQuestion(testStep);
      } else {
        return "Masukkan angka **1 sampai 5** ya 😊";
      }
    }

    // Recommendation redirect to interest test
    if (text.contains("rekomendasi")) {
      return "Ayo ikuti **Tes Minat** terlebih dahulu supaya kita tahu kamu cocok di jurusan mana 😊\n\nKetik atau ucapkan: *tes minat bakat*";
    }

    return null; // Not handled locally → send to backend
  }

  /// Get AI response from the Python backend
  Future<String> _getAIResponseFromBackend(String input) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.chatRagUrl),
        headers: ApiConfig.headers,
        body: jsonEncode({'message': input}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['response'] ?? '';

        // If the backend signals interest test, handle locally
        if (aiResponse == '__INTEREST_TEST__') {
          return _startInterestTest();
        }

        return aiResponse.toString().trim();
      } else {
        return "⚠️ Gagal menghubungi server AI (${response.statusCode}).";
      }
    } catch (e) {
      // Fallback: return a helpful message when backend is unreachable
      return _offlineFallback(input);
    }
  }

  /// Offline fallback when backend is unreachable
  String _offlineFallback(String input) {
    return "⚠️ **Server AI sedang tidak tersedia.**\n\n"
        "Pastikan server Python sudah dijalankan:\n"
        "```\n"
        "cd server\n"
        "python main.py\n"
        "```\n\n"
        "Sementara itu, silakan coba fitur **Tes Minat Bakat** yang bisa digunakan offline!";
  }

  Future<String> _getAIResponse(String input) async {
    // Try local handling first (interest test, recommendations)
    final localResponse = _handleLocalInput(input);
    if (localResponse != null) {
      return localResponse;
    }

    // Send to backend API
    return _getAIResponseFromBackend(input);
  }

  Future<void> sendMessage({String? text}) async {
    final input = text ?? _controller.text.trim();
    if (input.isEmpty) return;

    if (!mounted) return;
    setState(() {
      messages.add({'text': input, 'isBot': false});
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    final response = await _getAIResponse(input);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      messages.add({'text': response, 'isBot': true});
    });
    _scrollToBottom();

    // Speak the response if TTS is enabled
    if (_isTTSEnabled) {
      await _speakText(response);
    } else {
      _lastAIResponse = response;
    }
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        localeId: "id_ID",
        onResult: (result) async {
          setState(() => _controller.text = result.recognizedWords);
          if (result.finalResult) {
            _stopListening();
            await sendMessage(text: result.recognizedWords);
          }
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void clearChat() {
    _stopTTS();
    setState(() {
      messages.clear();
      isRunningTest = false;
      testStep = 0;
      interestScore = {
        'tech': 0,
        'design': 0,
        'business': 0,
        'accounting': 0,
        'sport': 0,
      };
      _initChat();
    });
  }

  @override
  void dispose() {
    _speech.stop();
    flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  // ======================= BUILD UI =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: Text(
          "Informasi Kampus UCIC",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        elevation: 6,
        actions: [
          // TTS Toggle
          IconButton(
            icon: Icon(
              _isTTSEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
            ),
            tooltip: _isTTSEnabled ? 'Nonaktifkan TTS' : 'Aktifkan TTS',
            onPressed: _onTTSToggle,
          ),
          // TTS Pause/Resume (visible only when TTS is enabled and speaking/paused)
          if (_isTTSEnabled && (_isSpeaking || _isPaused))
            IconButton(
              icon: Icon(
                _isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
              ),
              tooltip: _isPaused ? 'Lanjutkan TTS' : 'Pause TTS',
              onPressed: () {
                if (_isPaused) {
                  _resumeTTS();
                } else {
                  _pauseTTS();
                }
              },
            ),
          // TTS Stop (visible when speaking or paused)
          if (_isTTSEnabled && (_isSpeaking || _isPaused))
            IconButton(
              icon: const Icon(Icons.stop, color: Colors.white),
              tooltip: 'Stop TTS',
              onPressed: _stopTTS,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Loading indicator
                if (_isLoading && index == messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.indigo.shade400,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Mr. Great sedang berpikir...",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final msg = messages[index];
                final isBot = msg['isBot'] as bool;

                return Align(
                  alignment:
                      isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment:
                        isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isBot)
                        const CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/informasi_kmps.png'),
                          radius: 18,
                        ),
                      if (isBot) const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isBot
                                ? Colors.white
                                : Colors.indigo.shade400,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isBot
                              ? _InfoMarkdownBody(
                                  data: msg['text'],
                                )
                              : Text(
                                  msg['text'],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                      if (!isBot) const SizedBox(width: 8),
                      if (!isBot)
                        const CircleAvatar(
                          backgroundColor: Colors.indigo,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // =============== INPUT BAR ===============
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic_off : Icons.mic,
                    color: _isListening ? Colors.red : Colors.indigo,
                  ),
                  onPressed: () {
                    if (_isListening) {
                      _stopListening();
                    } else {
                      _startListening();
                    }
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ketik atau ucapkan pertanyaan kampus...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.indigo),
                  onPressed: () => sendMessage(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: clearChat,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================== MARKDOWN RENDERER ======================
// Lightweight markdown renderer for campus info responses
class _InfoMarkdownBody extends StatelessWidget {
  final String data;

  const _InfoMarkdownBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final lines = data.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Skip empty lines (add spacing)
      if (line.trim().isEmpty) {
        if (widgets.isNotEmpty) {
          widgets.add(const SizedBox(height: 6));
        }
        continue;
      }

      // Horizontal rule
      if (line.trim() == '---' || line.trim() == '***') {
        widgets.add(Divider(color: Colors.grey.shade300, thickness: 1));
        continue;
      }

      // Code block (``` ... ```)
      if (line.trim().startsWith('```')) {
        // Collect code block lines
        List<String> codeLines = [];
        i++;
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          codeLines.add(lines[i]);
          i++;
        }
        widgets.add(
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              codeLines.join('\n'),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Color(0xFF89B4FA),
              ),
            ),
          ),
        );
        continue;
      }

      // Headings
      if (line.startsWith('######')) {
        widgets.add(_buildHeading(line.substring(6).trim(), 6));
      } else if (line.startsWith('#####')) {
        widgets.add(_buildHeading(line.substring(5).trim(), 5));
      } else if (line.startsWith('####')) {
        widgets.add(_buildHeading(line.substring(4).trim(), 4));
      } else if (line.startsWith('###')) {
        widgets.add(_buildHeading(line.substring(3).trim(), 3));
      } else if (line.startsWith('##')) {
        widgets.add(_buildHeading(line.substring(2).trim(), 2));
      } else if (line.startsWith('#')) {
        widgets.add(_buildHeading(line.substring(1).trim(), 1));
      }
      // Blockquote
      else if (line.trimLeft().startsWith('>')) {
        widgets.add(_buildBlockquote(line.replaceFirst(RegExp(r'>\s*'), '')));
      }
      // Bullet points
      else if (RegExp(r'^\s*[-*+]\s').hasMatch(line)) {
        final indent = line.indexOf(RegExp(r'[-*+]'));
        final text = line.replaceFirst(RegExp(r'^\s*[-*+]\s'), '');
        widgets.add(_buildBulletPoint(text, indent));
      }
      // Numbered list
      else if (RegExp(r'^\s*\d+[.)]\s').hasMatch(line)) {
        final match = RegExp(r'^(\s*)(\d+)[.)]\s(.*)').firstMatch(line);
        if (match != null) {
          final indent = match.group(1)!.length;
          final number = match.group(2)!;
          final text = match.group(3)!;
          widgets.add(_buildNumberedItem(text, number, indent));
        }
      }
      // Regular text with inline formatting
      else {
        widgets.add(_buildRichText(line));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildHeading(String text, int level) {
    final sizes = [22.0, 19.0, 17.0, 15.5, 14.5, 13.5];
    final colors = [
      Colors.indigo.shade900,
      Colors.indigo.shade800,
      Colors.indigo.shade700,
      Colors.indigo.shade700,
      Colors.indigo.shade600,
      Colors.indigo.shade600,
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 3),
      child: _buildRichTextWidget(
        text,
        baseStyle: GoogleFonts.poppins(
          fontSize: sizes[level - 1],
          fontWeight: FontWeight.bold,
          color: colors[level - 1],
        ),
      ),
    );
  }

  Widget _buildBlockquote(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8, right: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.indigo.shade400, width: 3),
        ),
        color: Colors.indigo.shade50,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
      ),
      child: _buildRichTextWidget(
        text,
        baseStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, int indent) {
    return Padding(
      padding: EdgeInsets.only(left: indent * 8.0 + 8, top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 8),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.indigo.shade400,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(child: _buildRichTextWidget(text)),
        ],
      ),
    );
  }

  Widget _buildNumberedItem(String text, String number, int indent) {
    return Padding(
      padding: EdgeInsets.only(left: indent * 8.0 + 8, top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$number. ",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.indigo.shade600,
            ),
          ),
          Expanded(child: _buildRichTextWidget(text)),
        ],
      ),
    );
  }

  Widget _buildRichText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: _buildRichTextWidget(text),
    );
  }

  Widget _buildRichTextWidget(String text, {TextStyle? baseStyle}) {
    final style = baseStyle ??
        GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black87,
          height: 1.5,
        );
    return RichText(text: TextSpan(children: _parseInline(text, style)));
  }

  List<InlineSpan> _parseInline(String text, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    // Pattern: bold+italic, bold, italic, strikethrough, inline code
    final regex = RegExp(
      r'(\*\*\*(.*?)\*\*\*)|(\*\*(.*?)\*\*)|(\*(.*?)\*)|(\~\~(.*?)\~\~)|(`([^`]+)`)',
    );

    int lastEnd = 0;
    for (final match in regex.allMatches(text)) {
      // Add text before match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      if (match.group(1) != null) {
        // Bold + Italic
        spans.add(TextSpan(
          text: match.group(2),
          style: baseStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ));
      } else if (match.group(3) != null) {
        // Bold
        spans.add(TextSpan(
          text: match.group(4),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(5) != null) {
        // Italic
        spans.add(TextSpan(
          text: match.group(6),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(7) != null) {
        // Strikethrough
        spans.add(TextSpan(
          text: match.group(8),
          style: baseStyle.copyWith(decoration: TextDecoration.lineThrough),
        ));
      } else if (match.group(9) != null) {
        // Inline code
        spans.add(WidgetSpan(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              match.group(10)!,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0xFFE91E63),
              ),
            ),
          ),
        ));
      }

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: baseStyle));
    }

    return spans;
  }
}
