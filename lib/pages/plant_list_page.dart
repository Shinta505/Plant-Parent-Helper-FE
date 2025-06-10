import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fe/pages/detail_plant_page.dart';
import 'package:fe/pages/create_plant_page.dart';
import 'package:fe/pages/edit_plant_page.dart';
import 'package:fe/pages/nearest_store_page.dart';
import 'package:fe/pages/profile_page.dart';
import 'package:fe/pages/schedule_plant_page.dart';
import 'package:shake/shake.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PlantListPage extends StatefulWidget {
  final String token;
  final int userId;
  const PlantListPage({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<PlantListPage> createState() => _PlantListPageState();
}

class _PlantListPageState extends State<PlantListPage> {
  final String baseUrl =
      'https://plant-parent-helper-be-103949415038.us-central1.run.app';
  List<dynamic> plantList = [];
  List<dynamic> filteredPlantList = [];
  bool isLoading = true;
  String? errorMessage;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  late ConfettiController _confettiController;
  ShakeDetector? _shakeDetector;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    fetchPlants();
    _searchController.addListener(_filterPlants);

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    // Versi shake: ^3.0.0 pakai autoStart (langsung aktif)
    _shakeDetector = ShakeDetector.autoStart(
      shakeThresholdGravity: 1.8,
      onPhoneShake: (_) {
        debugPrint("SHAKE DETECTED!");
        _confettiController.play();
      },
    );
  }

  Future<void> _requestNotificationPermission() async {
    // Cek jika platform adalah Android
    if (Platform.isAndroid) {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      // Minta izin notifikasi
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeDetector?.stopListening();
    _searchController.dispose();
    super.dispose();
  }

  void _filterPlants() {
    setState(() {
      filteredPlantList = plantList
          .where((plant) => plant['name']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> fetchPlants() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('$baseUrl/plants');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          plantList = (data as List)
              .where((plant) => plant['userId'] == widget.userId)
              .toList();
          filteredPlantList = plantList;
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = jsonDecode(response.body)['msg'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Gagal memuat data. Periksa koneksi Anda.";
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SchedulePlantPage(
              key: UniqueKey(),
              token: widget.token,
              userId: widget.userId,
            ),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => NearestStorePage(
              token: widget.token,
              userId: widget.userId,
            ),
            transitionDuration: Duration.zero,
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProfilePage(token: widget.token, userId: widget.userId),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tanamanku", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (route) => false),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari Tanaman...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Tambah Tanaman Baru",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreatePlantPage(
                            token: widget.token,
                            userId: widget.userId,
                          ),
                        ),
                      );
                      if (result == true) {
                        fetchPlants();
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(errorMessage!,
                                  textAlign: TextAlign.center),
                            ),
                          )
                        : filteredPlantList.isEmpty
                            ? const Center(
                                child: Text("Anda belum memiliki tanaman. 😢"),
                              )
                            : RefreshIndicator(
                                onRefresh: fetchPlants,
                                child: ListView.builder(
                                  itemCount: filteredPlantList.length,
                                  itemBuilder: (context, index) {
                                    final plant = filteredPlantList[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                        leading: plant['imageUrl'] != null &&
                                                plant['imageUrl']
                                                    .toString()
                                                    .isNotEmpty
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  plant['imageUrl'],
                                                  width: 56,
                                                  height: 56,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                        Icons.broken_image,
                                                        color: Colors.grey);
                                                  },
                                                ),
                                              )
                                            : CircleAvatar(
                                                backgroundColor:
                                                    Colors.lightGreen.shade100,
                                                child: const Icon(
                                                    Icons.local_florist,
                                                    color: Colors.lightGreen),
                                              ),
                                        title: Text(
                                          plant['name'],
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(plant['location'] ??
                                            'Lokasi tidak diatur'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blueAccent),
                                              onPressed: () async {
                                                final result =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditPlantPage(
                                                      token: widget.token,
                                                      plantId: plant['id'],
                                                      userId: widget.userId,
                                                    ),
                                                  ),
                                                );
                                                if (result == true) {
                                                  fetchPlants();
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.redAccent),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        "Konfirmasi Hapus"),
                                                    content: Text(
                                                        "Yakin ingin menghapus tanaman '${plant['name']}'?"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child:
                                                            const Text("Batal"),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          Navigator.pop(
                                                              context);
                                                          final url = Uri.parse(
                                                              '$baseUrl/plants/${plant['id']}');
                                                          final response =
                                                              await http.delete(
                                                            url,
                                                            headers: {
                                                              'Authorization':
                                                                  'Bearer ${widget.token}'
                                                            },
                                                          );
                                                          if (response
                                                                  .statusCode ==
                                                              200) {
                                                            fetchPlants();
                                                            ScaffoldMessenger
                                                                    // ignore: use_build_context_synchronously
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    const SnackBar(
                                                              content: Text(
                                                                  "Tanaman berhasil dihapus 🌿"),
                                                            ));
                                                          }
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                backgroundColor:
                                                                    Colors.red),
                                                        child:
                                                            const Text("Hapus"),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailPlantPage(
                                                plantId: plant['id'],
                                                token: widget.token,
                                              ),
                                            ),
                                          );
                                          if (result == true) {
                                            fetchPlants();
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
              )
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.lightGreen,
                Colors.brown,
                Colors.teal,
              ],
              numberOfParticles: 20,
              gravity: 0.3,
              emissionFrequency: 0.05,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Tanamanku',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Toko',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.lightGreen,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
