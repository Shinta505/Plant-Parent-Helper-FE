import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fe/pages/login_page.dart';
import 'package:fe/pages/plant_list_page.dart';
import 'package:fe/pages/schedule_plant_page.dart';
import 'package:fe/pages/nearest_store_page.dart';

class ProfilePage extends StatefulWidget {
  final String token;
  final int userId;

  const ProfilePage({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final int _selectedIndex = 3; // Indeks untuk halaman 'Profil'
  final String baseUrl =
      'https://plant-parent-helper-be-103949415038.us-central1.run.app';
  late Future<int> _totalCostFuture;

  // Nilai tukar mata uang (sebaiknya diambil dari API jika memungkinkan)
  final Map<String, double> conversionRates = {
    'USD': 0.000061, // Contoh rate
    'EUR': 0.000057,
    'JPY': 0.0095,
  };

  @override
  void initState() {
    super.initState();
    _totalCostFuture = _fetchTotalCost();
  }

  // --- FUNGSI YANG DIPERBAIKI ---
  // Fungsi ini sekarang langsung menggunakan logika yang benar tanpa memanggil endpoint yang tidak ada.
  Future<int> _fetchTotalCost() async {
    try {
      // 1. Ambil semua data tanaman milik pengguna.
      // Pastikan endpoint backend Anda mendukung filter `userId` seperti ini.
      final plantsResponse = await http.get(
        Uri.parse('$baseUrl/plants?userId=${widget.userId}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (plantsResponse.statusCode != 200) {
        throw Exception('Gagal memuat data tanaman.');
      }

      final plants = jsonDecode(plantsResponse.body) as List;
      int totalCost = 0;

      // 2. Iterasi setiap tanaman untuk mendapatkan biayanya.
      for (var plant in plants) {
        final costsResponse = await http.get(
          Uri.parse('$baseUrl/plants/${plant['id']}/costs'),
          headers: {'Authorization': 'Bearer ${widget.token}'},
        );
        if (costsResponse.statusCode == 200) {
          final costs = jsonDecode(costsResponse.body) as List;
          // 3. Akumulasikan total biaya dari semua tanaman.
          totalCost +=
              costs.fold<int>(0, (sum, item) => sum + (item['amount'] as int));
        }
      }
      return totalCost;
    } catch (e) {
      // Melempar error agar bisa ditangkap oleh FutureBuilder dan ditampilkan di UI.
      throw Exception('Gagal menghitung total biaya: ${e.toString()}');
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PlantListPage(token: widget.token, userId: widget.userId)),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SchedulePlantPage(
                  token: widget.token, userId: widget.userId)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  NearestStorePage(token: widget.token, userId: widget.userId)),
        );
        break;
      case 3:
        // Halaman saat ini
        break;
    }
  }

  void showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Yakin ingin logout dari aplikasi?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Pengguna",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
            onPressed: showLogoutConfirmation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Informasi Pengguna ---
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                        'assets/images/profile_picture.jpg'), // Pastikan path gambar benar
                  ),
                  const SizedBox(height: 12),
                  const Text("Shinta Nursobah Chairani",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("123220074 | IF-B",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),

            // --- Rekap Biaya Perawatan ---
            _buildSectionTitle("Rekap Biaya Perawatan"),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<int>(
                  future: _totalCostFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.hasData) {
                      final totalCost = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total Biaya",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                          Text(
                            currencyFormatter.format(totalCost),
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          const Text("Konversi:",
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          ...conversionRates.entries.map((entry) {
                            final converted =
                                (totalCost * entry.value).toStringAsFixed(2);
                            return Text("≈ $converted ${entry.key}",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey));
                            // ignore: unnecessary_to_list_in_spreads
                          }).toList(),
                        ],
                      );
                    }
                    return const Center(child: Text("Tidak ada data biaya."));
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Saran & Kesan ---
            _buildSectionTitle("Saran & Kesan"),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: TextField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText:
                        "Tuliskan saran dan kesan Anda untuk mata kuliah TPM...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Tombol Logout ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Logout",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: showLogoutConfirmation,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Tanamanku'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Jadwal'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Toko'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightGreen,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
