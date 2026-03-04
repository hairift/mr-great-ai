import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;

import 'package:mr_great_ai/asisten_pintar_page2.dart';
import 'package:mr_great_ai/info_kampus_page.dart';
import 'package:mr_great_ai/lokasi_dan_kontak_ucic_page.dart';
import 'package:mr_great_ai/api_config.dart';
import 'package:mr_great_ai/tts_utils.dart';
import 'package:mr_great_ai/server_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Auto-start Python backend server (desktop only, no-op on web)
  await ServerManager.startServer();
  runApp(const MrGreatApp());
}

class MrGreatApp extends StatelessWidget {
  const MrGreatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mr. Great - UCIC AI Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      home: const GetStartedPage(),
    );
  }
}

// ====================== GET STARTED PAGE ======================
class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'logo',
                child: Image.asset('assets/mr_great.png', height: 200),
              ),
              const SizedBox(height: 30),
              Text(
                'Mr. Great',
                style: GoogleFonts.outfit(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Asisten Cerdas Universitas Catur Insan Cendekia',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 18,
                  ),
                  elevation: 10,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeaturePage()),
                  );
                },
                child: Text(
                  'Mulai Sekarang',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================== FEATURE PAGE ======================
class FeaturePage extends StatefulWidget {
  const FeaturePage({super.key});

  @override
  State<FeaturePage> createState() => _FeaturePageState();
}

class _FeaturePageState extends State<FeaturePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeFeatureSection(),
    const ChatPage(),
    const ProfileSection(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.indigo, Colors.indigoAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: "Beranda",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.mic_rounded),
                label: "Chat",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: "Profil",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================== HOME FEATURE SECTION ======================
class HomeFeatureSection extends StatelessWidget {
  const HomeFeatureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text("Fitur Unggulan"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        elevation: 6,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Hero(
              tag: 'logo',
              child: Image.asset('assets/home.png', height: 120),
            ),
          ),

          const SizedBox(height: 20),

          featureCard(
            title: "💬 Tanya Mr. Great",
            desc: "AI cerdas untuk tanya apa pun tentang kebutuhanmu.",
            onTap: () => Navigator.push(context, _fadeRoute(const ChatPage())),
          ),

          featureCard(
            title: "🏫 Informasi Kampus UCIC",
            desc: "Fakultas, prodi, layanan, event, & semua info resmi UCIC.",
            onTap: () =>
                Navigator.push(context, _fadeRoute(const InfoKampusPage())),
          ),

          featureCard(
            title: "🤖 Asisten Pintar",
            desc: "Bantu memahami materi kuliah, tugas, & ide kreatif.",
            onTap: () =>
                Navigator.push(context, _fadeRoute(const AsistenPintarPage())),
          ),

          featureCard(
            title: "📍 Lokasi & Kontak UCIC",
            desc: "Alamat lengkap, map, kontak fakultas, & layanan UCIC.",
            onTap: () =>
                Navigator.push(context, _fadeRoute(const LokasiKontakPage())),
          ),
        ],
      ),
    );
  }

  // ================== FEATURE CARD WITH CLICK ===================
  Widget featureCard({
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(1, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ANIMASI HALUS (Fade Transition) ====================
  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, a, b) => FadeTransition(opacity: a, child: page),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}

// =============== ANIMASI NAVIGASI =============
Route createPremiumRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, animation, secondaryAnimation) => page,
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      // Masuk: Slide dari kanan
      final slideIn = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      // Keluar: Fade-out
      final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutQuad),
      );

      return SlideTransition(
        position: slideIn,
        child: FadeTransition(opacity: fadeOut, child: child),
      );
    },
  );
}

// =============== HALAMAN DETAIL FAKULTAS ===============
class FacultyDetailPage extends StatelessWidget {
  final String facultyName;
  final List<Map<String, String>> prodiList;

  const FacultyDetailPage({
    super.key,
    required this.facultyName,
    required this.prodiList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: Text(facultyName),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: prodiList.length,
        itemBuilder: (context, index) {
          final item = prodiList[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item["image"] != null && item["image"]!.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: Image.asset(
                      item["image"]!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["title"] ?? "",
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item["desc"] ?? "",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ====================== PROFILE PAGE ===================
class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text("Profil Universitas"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        elevation: 6,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(80),
              child: Image.asset('assets/profile.png', height: 150),
            ),
            const SizedBox(height: 20),
            Text(
              "Universitas Catur Insan Cendekia (UCIC)",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.indigo),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Jl. Kesambi No. 202, Drajat, Kesambi, Kota Cirebon, Jawa Barat 45133",
                    style: GoogleFonts.poppins(fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Icon(Icons.email, color: Colors.indigo),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "info@ucic.ac.id",
                    style: GoogleFonts.poppins(fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.indigo),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "+6289512314188",
                    style: GoogleFonts.poppins(fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Fakultas:",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ========== FAKULTAS TEKNOLOGI INFORMASI ============
            facultyCard("Fakultas Teknologi Informasi", Icons.computer, () {
              Navigator.push(
                context,
                createPremiumRoute(
                  FacultyDetailPage(
                    facultyName: "Fakultas Teknologi Informasi",
                    prodiList: [
                      {
                        "title": "S1 Teknik Informatika",
                        "image": "assets/TI/TI.png",
                        "desc":
                            "Fokus pada software engineering, AI, data science, dan teknologi modern.",
                      },
                      {
                        "title": "S1 Sistem Informasi",
                        "image": "assets/TI/SI.png",
                        "desc":
                            "Berfokus pada analisis sistem, basis data, bisnis digital, dan integrasi IT.",
                      },
                      {
                        "title": "S1 Desain Komunikasi Visual (DKV)",
                        "image": "assets/TI/DKV.png",
                        "desc":
                            "Mempelajari desain visual, animasi, ilustrasi, dan branding modern.",
                      },
                      {
                        "title": "D3 Manajemen Informatika",
                        "image": "assets/TI/MI.png",
                        "desc":
                            "Fokus implementasi teknologi, jaringan, dan sistem berbasis komputer.",
                      },
                      {
                        "title": "D3 Komputerisasi Akuntansi",
                        "image": "assets/TI/KA.png",
                        "desc":
                            "Menggabungkan teknologi informasi dengan dunia akuntansi modern.",
                      },
                    ],
                  ),
                ),
              );
            }),

            // ========== FAKULTAS EKONOMI & BISNIS ============
            facultyCard("Fakultas Ekonomi dan Bisnis", Icons.business_center, () {
              Navigator.push(
                context,
                createPremiumRoute(
                  FacultyDetailPage(
                    facultyName: "Fakultas Ekonomi dan Bisnis",
                    prodiList: [
                      {
                        "title": "S1 Akuntansi",
                        "image": "assets/FEB/AK.png",
                        "desc":
                            "Fokus pada akuntansi keuangan, audit, perpajakan, dan sistem informasi akuntansi.",
                      },
                      {
                        "title": "S1 Manajemen",
                        "image": "assets/FEB/MJN.png",
                        "desc":
                            "Mempelajari keuangan, pemasaran, SDM, strategi, dan pengembangan bisnis.",
                      },
                      {
                        "title": "S1 Bisnis Digital",
                        "image": "assets/FEB/BISDI.png",
                        "desc":
                            "Berfokus pada digital marketing, e-commerce, dan transformasi digital.",
                      },
                      {
                        "title": "D3 Manajemen Bisnis",
                        "image": "assets/FEB/MB.png",
                        "desc":
                            "Menyiapkan profesional operasional dan administrasi bisnis.",
                      },
                    ],
                  ),
                ),
              );
            }),

            // ========== FAKULTAS PENDIDIKAN & SAINS ============
            facultyCard("Fakultas Pendidikan dan Sains", Icons.school, () {
              Navigator.push(
                context,
                createPremiumRoute(
                  FacultyDetailPage(
                    facultyName: "Fakultas Pendidikan dan Sains",
                    prodiList: [
                      {
                        "title": "S1 Pendidikan Kepelatihan Olahraga",
                        "image": "assets/PIKOR/PIKOR.png",
                        "desc":
                            "Fokus pada ilmu kepelatihan, biomekanika, fisiologi olahraga, dan manajemen pelatihan.",
                      },
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET CARD FAKULTAS ===============
  Widget facultyCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.indigo, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.indigo),
          ],
        ),
      ),
    );
  }
}

// ====================== CHAT PAGE ======================
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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
          'Halo 👋 Saya Mr. Great — Asisten AI UCIC. Ada yang bisa saya bantu hari ini?',
      'isBot': true,
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
        "Halo, saya Mister Great. Ada yang bisa saya bantu hari ini?",
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

  // ====================== CLEAN CHAT TEXTAI ======================
  String cleanText(String text) {
    if (text.trim().isEmpty) return '';

    String t = text;

    // =========================
    // 1. Basic Cleaning
    // =========================
    t = t.replaceAll(
      RegExp(r'^\s*#+\s*', multiLine: true),
      '',
    ); // Remove markdown titles
    t = t.replaceAll(RegExp(r'https?:\/\/\S+'), ''); // Remove hyperlinks

    // Convert markdown links -> text only
    t = t.replaceAllMapped(
      RegExp(r'\[(.*?)\]\((.*?)\)'),
      (m) => m.group(1) ?? '',
    );

    // Quote formatting
    t = t.replaceAllMapped(
      RegExp(r'^\s*>\s*(.*)', multiLine: true),
      (m) => '❝ ${m.group(1)?.trim() ?? ""} ❞',
    );

    // Code block formatting
    t = t.replaceAllMapped(
      RegExp(r'```([\s\S]*?)```'),
      (m) => '\n──── CODE ────\n${m.group(1)!.trim()}\n───────────────\n',
    );

    // Inline code formatting
    t = t.replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => '⟦${m.group(1)}⟧');

    // =========================
    // 2. Normal Formatting
    // =========================
    final cleaned = <String>[];

    for (var raw in t.split('\n')) {
      String line = raw.trim();

      if (line.isEmpty) {
        cleaned.add('');
        continue;
      }

      // Bullet / numbered list
      if (RegExp(r'^[-*]\s+').hasMatch(line) ||
          RegExp(r'^\d+[\.\)]\s+').hasMatch(line)) {
        final item = line
            .replaceFirst(RegExp(r'^([-*]|\d+[\.\)])\s+'), '')
            .trim();
        cleaned.add('- ${item[0].toUpperCase()}${item.substring(1)}');
        continue;
      }

      // Normal sentence capitalization
      cleaned.add(line[0].toUpperCase() + line.substring(1));
    }

    t = cleaned.join('\n');

    // =========================
    // Final Cleanup
    // =========================
    t = t.replaceAll(
      RegExp(r'(\*\*|__|~~)'),
      '',
    ); // remove markdown bold/underline
    t = t.replaceAll(RegExp(r'\n\s*\n+'), '\n\n'); // tidy empty lines

    return t.trim();
  }

  // ====================== API ======================
  Future<String> _getAIResponse(String input) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.chatGeneralUrl),
        headers: ApiConfig.headers,
        body: jsonEncode({
          "message": input,
          "system_prompt": "Anda adalah asisten AI bernama Mr. Great dari UCIC. "
              "Berikan jawaban yang SINGKAT, PADAT, dan JELAS. "
              "Gunakan maksimal 2-3 paragraf pendek. "
              "Gunakan format markdown untuk heading (#), bold (**), italic (*), "
              "bullet points (-), dan numbered list (1.) jika diperlukan untuk kejelasan.",
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['response'];
        if (content == null || content.toString().trim().isEmpty) {
          return "⚠️ Konten jawaban AI kosong.";
        }
        return content.toString().trim();
      } else if (response.statusCode == 401) {
        return "⚠️ API Key tidak valid. Periksa konfigurasi.";
      } else if (response.statusCode == 429) {
        return "⚠️ Terlalu banyak permintaan. Coba lagi nanti.";
      } else {
        return "⚠️ Gagal menghubungi server AI (${response.statusCode}).";
      }
    } catch (e) {
      return "❌ Terjadi kesalahan koneksi: $e";
    }
  }

  // ====================== SEND MESSAGE ======================
  Future<void> sendMessage({String? text}) async {
    final input = text ?? _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      messages.add({'text': input, 'isBot': false});
      _controller.clear();
      _isLoading = true;
    });

    final response = await _getAIResponse(input);

    setState(() {
      _isLoading = false;
      messages.add({'text': response, 'isBot': true});
    });

    _scrollToBottom();

    // Speak response if TTS is enabled
    if (_isTTSEnabled) {
      final cleanResponse = cleanTextForTTS(response);
      await _speakText(cleanResponse);
    } else {
      // Store for later if user enables TTS
      _lastAIResponse = cleanTextForTTS(response);
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
      try {
        await flutterTts.speak(_currentSpeechText);
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

  Future<void> _speakText(String text) async {
    if (!_isTTSEnabled || text.isEmpty) return;
    _currentSpeechText = text;
    _lastAIResponse = text;
    try {
      await flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  void _onTTSToggle() {
    if (!mounted) return;
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

  // ====================== VOICE ======================
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

  @override
  void dispose() {
    _speech.stop();
    flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  // ====================== UI ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text("Chat Virtual Assistant UCIC"),
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
                          backgroundImage: AssetImage('assets/tanya_ai.png'),
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
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isBot
                              ? ChatMarkdownBody(data: msg['text'])
                              : Text(
                                  msg['text'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
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
            decoration: const BoxDecoration(color: Colors.white),
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
                      hintText: 'Ketik atau ucapkan pesan...',
                      border: InputBorder.none,
                    ),
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

// ====================== CHAT MARKDOWN BODY ======================
class ChatMarkdownBody extends StatelessWidget {
  final String data;

  const ChatMarkdownBody({super.key, required this.data});

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
        
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          codeLines.add(lines[i]);
          i++;
        }
        i++;
        
        widgets.add(_buildCodeBlock(codeLines.join('\n'), language));
        continue;
      }
      
      widgets.add(_buildFormattedLine(line));
      i++;
    }
    
    return widgets.isEmpty ? [const SizedBox.shrink()] : widgets;
  }

  Widget _buildFormattedLine(String line) {
    if (line.trim().isEmpty) {
      return const SizedBox(height: 6);
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
        fontSize = 22;
        fontWeight = FontWeight.w800;
        color = Colors.indigo.shade800;
        break;
      case 2:
        fontSize = 18;
        fontWeight = FontWeight.w700;
        color = Colors.indigo.shade700;
        break;
      case 3:
        fontSize = 16;
        fontWeight = FontWeight.w600;
        color = Colors.indigo.shade600;
        break;
      default:
        fontSize = 15;
        fontWeight = FontWeight.w600;
        color = Colors.black87;
    }
    
    return Padding(
      padding: EdgeInsets.only(top: level <= 2 ? 10 : 6, bottom: 4),
      child: _buildRichText(
        text,
        baseStyle: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color),
      ),
    );
  }

  Widget _buildBlockquote(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.indigo.shade300, width: 3)),
        color: Colors.indigo.shade50,
      ),
      child: _buildRichText(
        text,
        baseStyle: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildBulletPoint(String text, int indent) {
    return Padding(
      padding: EdgeInsets.only(left: 6.0 + (indent * 6), top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 6),
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: Colors.indigo.shade400, shape: BoxShape.circle),
          ),
          Expanded(child: _buildRichText(text)),
        ],
      ),
    );
  }

  Widget _buildNumberedItem(String text, String number, int indent) {
    return Padding(
      padding: EdgeInsets.only(left: 6.0 + (indent * 6), top: 2, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$number.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.indigo.shade600),
            ),
          ),
          Expanded(child: _buildRichText(text)),
        ],
      ),
    );
  }

  Widget _buildRichText(String text, {TextStyle? baseStyle}) {
    final spans = _parseInlineFormatting(text, baseStyle ?? const TextStyle(fontSize: 14, color: Colors.black87));
    return RichText(text: TextSpan(children: spans));
  }

  List<InlineSpan> _parseInlineFormatting(String text, TextStyle baseStyle) {
    final List<InlineSpan> spans = [];
    
    final patterns = <_ChatInlinePattern>[
      _ChatInlinePattern(
        RegExp(r'\*\*\*(.+?)\*\*\*|___(.+?)___'),
        (match) => TextSpan(text: match.group(1) ?? match.group(2), style: baseStyle.copyWith(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
      ),
      _ChatInlinePattern(
        RegExp(r'\*\*(.+?)\*\*|__(.+?)__'),
        (match) => TextSpan(text: match.group(1) ?? match.group(2), style: baseStyle.copyWith(fontWeight: FontWeight.bold)),
      ),
      _ChatInlinePattern(
        RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)|(?<!_)_([^_]+)_(?!_)'),
        (match) => TextSpan(text: match.group(1) ?? match.group(2), style: baseStyle.copyWith(fontStyle: FontStyle.italic)),
      ),
      _ChatInlinePattern(
        RegExp(r'~~(.+?)~~'),
        (match) => TextSpan(text: match.group(1), style: baseStyle.copyWith(decoration: TextDecoration.lineThrough)),
      ),
      _ChatInlinePattern(
        RegExp(r'`([^`]+)`'),
        (match) => TextSpan(text: match.group(1), style: baseStyle.copyWith(fontFamily: 'monospace', backgroundColor: Colors.grey.shade200, color: Colors.pink.shade700)),
      ),
    ];
    
    List<_ChatMatchInfo> allMatches = [];
    for (var pattern in patterns) {
      for (var match in pattern.regex.allMatches(text)) {
        allMatches.add(_ChatMatchInfo(match, pattern.builder));
      }
    }
    
    allMatches.sort((a, b) => a.match.start.compareTo(b.match.start));
    
    final filteredMatches = <_ChatMatchInfo>[];
    int lastEnd = 0;
    for (var m in allMatches) {
      if (m.match.start >= lastEnd) {
        filteredMatches.add(m);
        lastEnd = m.match.end;
      }
    }
    
    int processedUntil = 0;
    for (var matchInfo in filteredMatches) {
      if (matchInfo.match.start > processedUntil) {
        spans.add(TextSpan(text: text.substring(processedUntil, matchInfo.match.start), style: baseStyle));
      }
      spans.add(matchInfo.builder(matchInfo.match));
      processedUntil = matchInfo.match.end;
    }
    
    if (processedUntil < text.length) {
      spans.add(TextSpan(text: text.substring(processedUntil), style: baseStyle));
    }
    
    return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
  }

  Widget _buildCodeBlock(String code, String language) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          code,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.black87),
        ),
      ),
    );
  }
}

class _ChatInlinePattern {
  final RegExp regex;
  final InlineSpan Function(RegExpMatch match) builder;
  _ChatInlinePattern(this.regex, this.builder);
}

class _ChatMatchInfo {
  final RegExpMatch match;
  final InlineSpan Function(RegExpMatch match) builder;
  _ChatMatchInfo(this.match, this.builder);
}
