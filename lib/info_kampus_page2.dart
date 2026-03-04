import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =============== CUSTOM APPBAR UCIC (NAVBAR ATAS) =================
PreferredSizeWidget customUCICAppBar(String title) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(70),
    child: AppBar(
      automaticallyImplyLeading: true,
      elevation: 0,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
    ),
  );
}

// =============== HALAMAN INFO KAMPUS UCIC ===============

class InfoKampusPage extends StatelessWidget {
  const InfoKampusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,

      // ====== NAVBAR BARU ======
      appBar: customUCICAppBar("Informasi Kampus UCIC"),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER ================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.indigo, Colors.indigoAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selamat Datang di Informasi Kampus UCIC",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Telusuri Fakultas dan Program Studi.",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ================= FAKULTAS ================
            Text(
              "Fakultas",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.indigo.shade900,
              ),
            ),
            const SizedBox(height: 12),

            // ================= FTI ======================
            facultyCard(
              context,
              image: "assets/TI/FTI.png",
              title: "Fakultas Teknologi Informasi",
              desc:
                  "Berfokus pada teknologi, software engineering, desain, dan inovasi digital.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProdiPage(
                      facultyName: "Fakultas Teknologi Informasi",
                      headerImage: "assets/TI/FTI.png",
                      prodiList: [
                        {
                          "title": "S1 Teknik Informatika",
                          "image": "assets/TI/TI.png",
                          "desc":
                              "Fokus software engineering, AI, data science, dan teknologi modern.",
                        },
                        {
                          "title": "S1 Sistem Informasi",
                          "image": "assets/TI/SI.png",
                          "desc":
                              "Analisis sistem, basis data, bisnis digital, dan integrasi teknologi.",
                        },
                        {
                          "title": "S1 Desain Komunikasi Visual (DKV)",
                          "image": "assets/TI/DKV.png",
                          "desc":
                              "Desain visual, ilustrasi, animasi, dan media kreatif modern.",
                        },
                        {
                          "title": "D3 Manajemen Informatika",
                          "image": "assets/TI/MI.png",
                          "desc":
                              "Implementasi jaringan, sistem komputer, dan dukungan teknis.",
                        },
                        {
                          "title": "D3 Komputerisasi Akuntansi",
                          "image": "assets/TI/KA.png",
                          "desc":
                              "Penggabungan teknologi informasi dengan akuntansi modern.",
                        },
                      ],
                    ),
                  ),
                );
              },
            ),

            // ================= FEB ======================
            facultyCard(
              context,
              image: "assets/FEB/FEB.png",
              title: "Fakultas Ekonomi dan Bisnis",
              desc:
                  "Fokus pada akuntansi, manajemen, dan bisnis digital modern.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProdiPage(
                      facultyName: "Fakultas Ekonomi dan Bisnis",
                      headerImage: "assets/FEB/FEB.png",
                      prodiList: [
                        {
                          "title": "S1 Akuntansi",
                          "image": "assets/FEB/AK.png",
                          "desc":
                              "Akuntansi keuangan, perpajakan, audit, dan sistem informasi akuntansi.",
                        },
                        {
                          "title": "S1 Manajemen",
                          "image": "assets/FEB/MJN.png",
                          "desc":
                              "Pemasaran, keuangan, SDM, kewirausahaan, dan strategi bisnis.",
                        },
                        {
                          "title": "S1 Bisnis Digital",
                          "image": "assets/FEB/BISDI.png",
                          "desc":
                              "Digital marketing, e-commerce, startup, dan transformasi digital.",
                        },
                        {
                          "title": "D3 Manajemen Bisnis",
                          "image": "assets/FEB/MB.png",
                          "desc":
                              "Menyiapkan profesional administrasi dan operasional bisnis.",
                        },
                      ],
                    ),
                  ),
                );
              },
            ),

            // ================= FPS ======================
            facultyCard(
              context,
              image: "assets/FEB/FEB.png",
              title: "Fakultas Pendidikan dan Sains",
              desc: "Fokus pada pendidikan olahraga dan pengembangan akademik.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProdiPage(
                      facultyName: "Fakultas Pendidikan dan Sains",
                      headerImage: "assets/FEB/FEB.png",
                      prodiList: [
                        {
                          "title": "S1 Pendidikan Kepelatihan Olahraga",
                          "image": "assets/PIKOR/PIKOR.png",
                          "desc":
                              "Kepelatihan olahraga, biomekanika, fisiologi, dan manajemen pelatihan.",
                        },
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET CARD FAKULTAS =================
  Widget facultyCard(
    BuildContext context, {
    required String image,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    final double width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: width,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: GoogleFonts.poppins(
                      fontSize: 14.5,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============== HALAMAN PRODI UCIC =====================

class ProdiPage extends StatelessWidget {
  final String facultyName;
  final String headerImage;
  final List<Map<String, dynamic>> prodiList;

  const ProdiPage({
    super.key,
    required this.facultyName,
    required this.headerImage,
    required this.prodiList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ====== NAVBAR BARU ======
      appBar: customUCICAppBar(facultyName),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            for (var prodi in prodiList) prodiCard(prodi),
          ],
        ),
      ),
    );
  }

  Widget prodiCard(Map<String, dynamic> prodi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.asset(
              prodi['image'],
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prodi['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  prodi['desc'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
