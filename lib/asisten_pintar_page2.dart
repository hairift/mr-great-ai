import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mr_great_ai/api_config.dart';
import 'package:mr_great_ai/tts_utils.dart';

class AsistenPintarPage extends StatefulWidget {
  const AsistenPintarPage({super.key});

  @override
  State<AsistenPintarPage> createState() => _AsistenPintarPageState();
}

class _AsistenPintarPageState extends State<AsistenPintarPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  final FlutterTts flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  
  // TTS Control features
  bool _isTTSEnabled = true;
  bool _isSpeaking = false;
  bool _isPaused = false;
  String _currentSpeechText = '';
  String _lastAIResponse = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initChat();
  }

  void _initChat() {
    messages.add({
      'text':
          'Halo 👋 Saya Mr. Great — Asisten Pintar Anda. Ada yang bisa saya bantu hari ini?',
      'isBot': true,
      'hasCode': false,
      'hasMath': false,
    });

    // Setup TTS callbacks
    flutterTts.setLanguage("id-ID");
    flutterTts.setSpeechRate(0.85);
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
      setState(() => _isPaused = true);
    });
    flutterTts.setContinueHandler(() {
      if (!mounted) return;
      setState(() => _isPaused = false);
    });
    
    if (_isTTSEnabled) {
      flutterTts.speak(
        'Halo, silakan tanyakan apa saja kepada Asisten Pintar UCIC.',
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String cleanTextForSpeech(String text) {
    return cleanTextForTTS(text);
  }

  bool hasCodeBlock(String text) {
    return text.contains(RegExp(r'```[\s\S]*?```')) ||
        text.contains(RegExp(r'`[^`]+`'));
  }

  bool hasMathExpression(String text) {
    return text.contains(RegExp(r'\$\$[\s\S]*?\$\$')) ||
        text.contains(RegExp(r'\$[^\$]+\$'));
  }

  Future<String> _getAIResponse(String input) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.chatGeneralUrl),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'message': input,
          'system_prompt':
              '''Anda adalah asisten pintar yang membantu mahasiswa dalam berbagai mata kuliah.

PENTING - Format Penulisan:
1. Untuk kode program: Gunakan ```bahasa
kode
```

2. Untuk matematika: WAJIB gunakan LaTeX dengan \$ atau \$\$
 - Inline math: \$rumus\$
 - Display math (centered): \$\$rumus\$\$
 
 Contoh LaTeX yang BENAR:
 - Persamaan: \$ax^2 + bx + c = 0\$
 - Pecahan: \$\\frac{a}{b}\$
 - Akar: \$\\sqrt{x}\$
 - Pangkat: \$x^2\$ atau \$x^{10}\$
 - Subscript: \$x_1\$ atau \$x_{10}\$
 - Matriks: \$\$\\begin{bmatrix} a & b \\\\ c & d \\end{bmatrix}\$\$
 - Integral: \$\\int_{0}^{1} x dx\$
 - Sigma: \$\\sum_{i=1}^{n} i\$
 - Limit: \$\\lim_{x \\to \\infty} f(x)\$
 - Greek letters: \$\\alpha, \\beta, \\theta, \\pi\$

3. Berikan penjelasan yang jelas dan terstruktur dengan bullet points atau numbering jika perlu.''',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiText = data['response'] ?? '';
        return aiText;
      } else if (response.statusCode == 401) {
        return 'API Key tidak valid. Periksa konfigurasi.';
      } else if (response.statusCode == 429) {
        return 'Terlalu banyak permintaan. Coba lagi nanti.';
      } else {
        return 'Maaf, terjadi kesalahan saat mengambil jawaban dari server. Status: ${response.statusCode}';
      }
    } catch (e) {
      return 'Maaf, terjadi kesalahan koneksi: $e';
    }
  }

  Future<void> sendMessage({String? text}) async {
    final input = text ?? _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      messages.add({
        'text': input,
        'isBot': false,
        'hasCode': false,
        'hasMath': false,
      });
      _controller.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    final response = await _getAIResponse(input);
    final hasCode = hasCodeBlock(response);
    final hasMath = hasMathExpression(response);
    final cleanResponse = cleanTextForSpeech(response);

    setState(() {
      _isLoading = false;
      messages.add({
        'text': response,
        'isBot': true,
        'hasCode': hasCode,
        'hasMath': hasMath,
      });
    });

    _scrollToBottom();

    // Prepare speech text
    String speechText;
    if (!hasCode && !hasMath) {
      speechText = cleanResponse;
    } else if (hasCode && !hasMath) {
      speechText = 'Saya telah memberikan kode program untuk Anda. Silakan lihat di layar.';
    } else if (hasMath && !hasCode) {
      speechText = 'Saya telah memberikan solusi matematika untuk Anda. Silakan lihat di layar.';
    } else {
      speechText = 'Saya telah memberikan jawaban lengkap. Silakan lihat di layar.';
    }
    
    _lastAIResponse = speechText;
    
    // Speak response if TTS is enabled
    if (_isTTSEnabled) {
      await _speakText(speechText);
    }
  }

  Future<void> _speakText(String text) async {
    if (!_isTTSEnabled || text.isEmpty) return;
    _currentSpeechText = text;
    await flutterTts.speak(text);
  }

  Future<void> _pauseTTS() async {
    if (_isSpeaking && !_isPaused) {
      await flutterTts.pause();
      setState(() => _isPaused = true);
    }
  }

  Future<void> _resumeTTS() async {
    if (_isPaused && _currentSpeechText.isNotEmpty) {
      setState(() => _isPaused = false);
      // Flutter TTS handles resume internally after pause
    }
  }

  Future<void> _stopTTS() async {
    await flutterTts.stop();
    setState(() {
      _isSpeaking = false;
      _isPaused = false;
      _currentSpeechText = '';
    });
  }

  void _onTTSToggle() {
    setState(() {
      _isTTSEnabled = !_isTTSEnabled;
    });
    
    if (!_isTTSEnabled) {
      // Stop speaking when disabled
      flutterTts.stop();
      setState(() {
        _isSpeaking = false;
        _isPaused = false;
      });
    } else {
      // When re-enabled, speak the last AI response if available
      if (_lastAIResponse.isNotEmpty) {
        _speakText(_lastAIResponse);
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isTTSEnabled
              ? 'Text-to-Speech diaktifkan'
              : 'Text-to-Speech dinonaktifkan',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
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
    setState(() {
      messages.clear();
      _initChat();
    });
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Teks telah dicopy ke clipboard!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text("Asisten Pintar"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          // TTS Enable/Disable toggle
          IconButton(
            icon: Icon(
              _isTTSEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
            ),
            tooltip: _isTTSEnabled ? 'Matikan TTS' : 'Aktifkan TTS',
            onPressed: _onTTSToggle,
          ),
          // Pause/Resume TTS when speaking
          if (_isSpeaking || _isPaused)
            IconButton(
              icon: Icon(
                _isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
              ),
              tooltip: _isPaused ? 'Lanjutkan' : 'Pause',
              onPressed: () async {
                if (_isPaused) {
                  await _resumeTTS();
                } else {
                  await _pauseTTS();
                }
              },
            ),
          // Stop TTS when speaking
          if (_isSpeaking || _isPaused)
            IconButton(
              icon: const Icon(Icons.stop, color: Colors.white),
              tooltip: 'Stop',
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
                if (_isLoading && index == messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text("Mr. Great sedang berpikir..."),
                        ],
                      ),
                    ),
                  );
                }
                final msg = messages[index];
                final isBot = msg['isBot'] as bool;
                final hasCode = msg['hasCode'] as bool? ?? false;
                final hasMath = msg['hasMath'] as bool? ?? false;

                return Align(
                  alignment: isBot
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: isBot
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isBot)
                        const CircleAvatar(
                          backgroundImage: AssetImage('assets/asistent_ai.png'),
                          radius: 18,
                        ),
                      if (isBot) const SizedBox(width: 8),
                      Flexible(
                        child: GestureDetector(
                          onLongPress: isBot
                              ? () => copyToClipboard(msg['text'])
                              : null,
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
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: (hasCode || hasMath) && isBot
                                ? MathMarkdownBody(data: msg['text'])
                                : Text(
                                    msg['text'],
                                    style: TextStyle(
                                      color: isBot
                                          ? Colors.black87
                                          : Colors.white,
                                      fontSize: 15,
                                    ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
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
                    decoration: const InputDecoration(
                      hintText: 'Ketik atau ucapkan pertanyaan...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
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

// Custom Widget untuk Markdown dengan Math Support dan Rich Text
class MathMarkdownBody extends StatelessWidget {
  final String data;

  const MathMarkdownBody({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _parseContent(data),
    );
  }

  List<Widget> _parseContent(String text) {
    final List<Widget> widgets = [];
    final lines = text.split('\n');
    
    int i = 0;
    while (i < lines.length) {
      final line = lines[i];
      
      // Check for code block start
      if (line.trim().startsWith('```')) {
        final languageMatch = RegExp(r'^```(\w*)').firstMatch(line.trim());
        final language = languageMatch?.group(1) ?? '';
        final codeLines = <String>[];
        i++;
        
        // Collect code until closing ```
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          codeLines.add(lines[i]);
          i++;
        }
        i++; // Skip closing ```
        
        widgets.add(_buildCodeBlock(codeLines.join('\n'), language));
        continue;
      }
      
      // Check for math block $$...$$
      if (line.trim().startsWith(r'$$')) {
        final mathLines = <String>[];
        String currentLine = line.trim().substring(2); // Remove $$
        
        if (currentLine.endsWith(r'$$')) {
          // Single line math block
          mathLines.add(currentLine.substring(0, currentLine.length - 2));
        } else {
          if (currentLine.isNotEmpty) mathLines.add(currentLine);
          i++;
          
          while (i < lines.length && !lines[i].trim().endsWith(r'$$')) {
            mathLines.add(lines[i]);
            i++;
          }
          if (i < lines.length) {
            final lastLine = lines[i].trim();
            if (lastLine != r'$$') {
              mathLines.add(lastLine.substring(0, lastLine.length - 2));
            }
          }
        }
        i++;
        
        widgets.add(_buildMathBlock(mathLines.join('\n')));
        continue;
      }
      
      // Parse regular line with inline formatting
      widgets.add(_buildFormattedLine(line));
      i++;
    }
    
    return widgets.isEmpty ? [const SizedBox.shrink()] : widgets;
  }

  Widget _buildFormattedLine(String line) {
    if (line.trim().isEmpty) {
      return const SizedBox(height: 8);
    }
    
    // Check for headings
    final headingMatch = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(line);
    if (headingMatch != null) {
      final level = headingMatch.group(1)!.length;
      final content = headingMatch.group(2)!;
      return _buildHeading(content, level);
    }
    
    // Check for blockquote
    if (line.trim().startsWith('>')) {
      final content = line.trim().substring(1).trim();
      return _buildBlockquote(content);
    }
    
    // Check for bullet points
    final bulletMatch = RegExp(r'^(\s*)[-*+]\s+(.*)$').firstMatch(line);
    if (bulletMatch != null) {
      final indent = bulletMatch.group(1)!.length;
      final content = bulletMatch.group(2)!;
      return _buildBulletPoint(content, indent);
    }
    
    // Check for numbered lists
    final numberedMatch = RegExp(r'^(\s*)(\d+)[.)]\s+(.*)$').firstMatch(line);
    if (numberedMatch != null) {
      final indent = numberedMatch.group(1)!.length;
      final number = numberedMatch.group(2)!;
      final content = numberedMatch.group(3)!;
      return _buildNumberedItem(content, number, indent);
    }
    
    // Regular text with inline formatting
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: _buildRichText(line),
    );
  }

  Widget _buildHeading(String text, int level) {
    final double fontSize;
    final FontWeight fontWeight;
    final Color color;
    
    switch (level) {
      case 1:
        fontSize = 24;
        fontWeight = FontWeight.w800;
        color = Colors.indigo.shade800;
        break;
      case 2:
        fontSize = 20;
        fontWeight = FontWeight.w700;
        color = Colors.indigo.shade700;
        break;
      case 3:
        fontSize = 18;
        fontWeight = FontWeight.w600;
        color = Colors.indigo.shade600;
        break;
      case 4:
        fontSize = 16;
        fontWeight = FontWeight.w600;
        color = Colors.black87;
        break;
      case 5:
        fontSize = 15;
        fontWeight = FontWeight.w500;
        color = Colors.black87;
        break;
      default:
        fontSize = 14;
        fontWeight = FontWeight.w500;
        color = Colors.black87;
    }
    
    return Padding(
      padding: EdgeInsets.only(top: level <= 2 ? 12 : 8, bottom: 4),
      child: _buildRichText(
        text,
        baseStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
    );
  }

  Widget _buildBlockquote(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.indigo.shade300, width: 4),
        ),
        color: Colors.indigo.shade50,
      ),
      child: _buildRichText(
        text,
        baseStyle: TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, int indent) {
    return Padding(
      padding: EdgeInsets.only(left: 8.0 + (indent * 8), top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7, right: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.indigo.shade400,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(child: _buildRichText(text)),
        ],
      ),
    );
  }

  Widget _buildNumberedItem(String text, String number, int indent) {
    return Padding(
      padding: EdgeInsets.only(left: 8.0 + (indent * 8), top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$number.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.indigo.shade600,
              ),
            ),
          ),
          Expanded(child: _buildRichText(text)),
        ],
      ),
    );
  }

  Widget _buildRichText(String text, {TextStyle? baseStyle}) {
    final spans = _parseInlineFormatting(text, baseStyle ?? const TextStyle(fontSize: 15, color: Colors.black87));
    
    return RichText(
      text: TextSpan(children: spans),
    );
  }

  List<InlineSpan> _parseInlineFormatting(String text, TextStyle baseStyle) {
    final List<InlineSpan> spans = [];
    
    // Regex patterns for inline formatting
    final patterns = <_InlinePattern>[
      // Bold + Italic: ***text*** or ___text___
      _InlinePattern(
        RegExp(r'\*\*\*(.+?)\*\*\*|___(.+?)___'),
        (match) => TextSpan(
          text: match.group(1) ?? match.group(2),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
      ),
      // Bold: **text** or __text__
      _InlinePattern(
        RegExp(r'\*\*(.+?)\*\*|__(.+?)__'),
        (match) => TextSpan(
          text: match.group(1) ?? match.group(2),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      // Italic: *text* or _text_
      _InlinePattern(
        RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)|(?<!_)_([^_]+)_(?!_)'),
        (match) => TextSpan(
          text: match.group(1) ?? match.group(2),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ),
      ),
      // Strikethrough: ~~text~~
      _InlinePattern(
        RegExp(r'~~(.+?)~~'),
        (match) => TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(decoration: TextDecoration.lineThrough),
        ),
      ),
      // Inline code: `code`
      _InlinePattern(
        RegExp(r'`([^`]+)`'),
        (match) => TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(
            fontFamily: 'monospace',
            backgroundColor: Colors.grey.shade200,
            color: Colors.pink.shade700,
          ),
        ),
      ),
      // Inline math: $formula$
      _InlinePattern(
        RegExp(r'\$([^\$]+)\$'),
        (match) => WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _buildInlineMath(match.group(1) ?? ''),
        ),
      ),
    ];
    
    // Process text with all patterns
    int processedUntil = 0;
    List<_MatchInfo> allMatches = [];
    
    // Find all matches
    for (var pattern in patterns) {
      for (var match in pattern.regex.allMatches(text)) {
        allMatches.add(_MatchInfo(match, pattern.builder));
      }
    }
    
    // Sort by start position
    allMatches.sort((a, b) => a.match.start.compareTo(b.match.start));
    
    // Remove overlapping matches (keep first one)
    final filteredMatches = <_MatchInfo>[];
    int lastEnd = 0;
    for (var m in allMatches) {
      if (m.match.start >= lastEnd) {
        filteredMatches.add(m);
        lastEnd = m.match.end;
      }
    }
    
    // Build spans
    processedUntil = 0;
    for (var matchInfo in filteredMatches) {
      // Add plain text before this match
      if (matchInfo.match.start > processedUntil) {
        spans.add(TextSpan(
          text: text.substring(processedUntil, matchInfo.match.start),
          style: baseStyle,
        ));
      }
      
      // Add formatted span
      spans.add(matchInfo.builder(matchInfo.match));
      processedUntil = matchInfo.match.end;
    }
    
    // Add remaining plain text
    if (processedUntil < text.length) {
      spans.add(TextSpan(
        text: text.substring(processedUntil),
        style: baseStyle,
      ));
    }
    
    return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
  }

  Widget _buildInlineMath(String latex) {
    try {
      return Math.tex(
        latex,
        textStyle: const TextStyle(fontSize: 15),
        mathStyle: MathStyle.text,
      );
    } catch (e) {
      return Text(
        '\$$latex\$',
        style: const TextStyle(
          fontSize: 15,
          color: Colors.red,
          fontFamily: 'monospace',
        ),
      );
    }
  }

  Widget _buildMathBlock(String latex) {
    try {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Math.tex(
            latex.trim(),
            textStyle: const TextStyle(fontSize: 18),
            mathStyle: MathStyle.display,
          ),
        ),
      );
    } catch (e) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Text(
          'Error rendering math: \$\$$latex\$\$',
          style: const TextStyle(
            fontSize: 13,
            color: Colors.red,
            fontFamily: 'monospace',
          ),
        ),
      );
    }
  }

  Widget _buildCodeBlock(String code, String language) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language.isEmpty ? 'code' : language,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                  },
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: HighlightView(
              code,
              language: language.isEmpty ? 'plaintext' : language,
              theme: githubTheme,
              padding: const EdgeInsets.all(12),
              textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper classes for inline pattern matching
class _InlinePattern {
  final RegExp regex;
  final InlineSpan Function(RegExpMatch match) builder;
  
  _InlinePattern(this.regex, this.builder);
}

class _MatchInfo {
  final RegExpMatch match;
  final InlineSpan Function(RegExpMatch match) builder;
  
  _MatchInfo(this.match, this.builder);
}

