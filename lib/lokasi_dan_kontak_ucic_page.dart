import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LokasiKontakPage extends StatelessWidget {
  const LokasiKontakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text("Lokasi & Kontak UCIC"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white, // warna teks dan ikon jadi putih
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), // melengkung di bawah
          ),
        ),
        elevation: 6,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kampus UCIC",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade900,
              ),
            ),
            const SizedBox(height: 16),
            campusCard(
              title: "Kampus 1",
              address: "Jalan Kesambi No. 202, Kota Cirebon",
              imageAsset: "assets/kampus1.png",
            ),
            campusCard(
              title: "Kampus 2",
              address: "Jalan Kesambi No. 58 A, Kota Cirebon",
              imageAsset: "assets/kampus2.png",
            ),
            const SizedBox(height: 24),
            Text(
              "Kontak UCIC",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade900,
              ),
            ),
            const SizedBox(height: 12),
            contactCard(
              icon: Icons.location_city,
              label: "Alamat",
              info: "Jl. Kesambi No. 202, Cirebon",
            ),
            contactCard(
              icon: Icons.email,
              label: "Email",
              info: "info@ucic.ac.id",
            ),
            contactCard(
              icon: Icons.phone,
              label: "Telepon",
              info: "+62 895-1231-4188",
            ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET CAMPUS CARD =================
  Widget campusCard({
    required String title,
    required String address,
    required String imageAsset,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              imageAsset,
              height: 200,
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
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= WIDGET CONTACT CARD =================
  Widget contactCard({
    required IconData icon,
    required String label,
    required String info,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.indigo, size: 28),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
