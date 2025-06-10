import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Ganti import Maps_flutter
import 'package:latlong2/latlong.dart'; // Gunakan LatLng dari latlong2
import 'package:location/location.dart' as loc;
import 'package:fe/pages/plant_list_page.dart';
import 'package:fe/pages/schedule_plant_page.dart';
import 'package:fe/pages/profile_page.dart';

class NearestStorePage extends StatefulWidget {
  final String token;
  final int userId;

  const NearestStorePage({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<NearestStorePage> createState() => _NearestStorePageState();
}

class _NearestStorePageState extends State<NearestStorePage> {
  final int _selectedIndex = 2;
  // Controller untuk flutter_map
  final MapController _mapController = MapController();
  final loc.Location _locationService = loc.Location();

  LatLng? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;

  // Daftar marker untuk flutter_map
  final List<Marker> _markers = [];

  // Daftar toko terdekat (koordinat statis)
  final List<Map<String, dynamic>> _nearbyStores = [
    {
      'id': 'store_1',
      'name': 'Toko Tani Makmur',
      'latlng': LatLng(-7.782, 110.367)
    },
    {
      'id': 'store_2',
      'name': 'Kios Pupuk Hijau',
      'latlng': LatLng(-7.785, 110.370)
    },
    {
      'id': 'store_3',
      'name': 'Garden Center Jogja',
      'latlng': LatLng(-7.779, 110.375)
    },
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      // Logika untuk izin dan mendapatkan lokasi tetap sama
      bool serviceEnabled = await _locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationService.requestService();
        if (!serviceEnabled) {
          throw Exception('Layanan lokasi tidak diaktifkan.');
        }
      }

      loc.PermissionStatus permissionGranted =
          await _locationService.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _locationService.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          throw Exception('Izin lokasi ditolak oleh pengguna.');
        }
      }

      final locationData = await _locationService.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        if (!mounted) return;
        setState(() {
          _currentPosition =
              LatLng(locationData.latitude!, locationData.longitude!);
          _addMarkers(); // Panggil fungsi untuk menambahkan semua marker
          _isLoading = false;
        });
        _goToCurrentLocation();
      } else {
        throw Exception('Gagal mendapatkan data lokasi.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        // Set lokasi default jika gagal
        _currentPosition = LatLng(-7.7828, 110.3671);
        _addMarkers(); // Tetap tambahkan marker toko meskipun lokasi gagal
      });
    }
  }

  void _addMarkers() {
    _markers.clear(); // Bersihkan marker sebelum menambahkan yang baru

    // Tambahkan marker lokasi pengguna
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          point: _currentPosition!,
          width: 80,
          height: 80,
          child:
              const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
        ),
      );
    }

    // Tambahkan marker toko
    for (var store in _nearbyStores) {
      _markers.add(
        Marker(
          point: store['latlng'],
          width: 80,
          height: 80,
          child: Tooltip(
            // Tooltip sebagai pengganti InfoWindow sederhana
            message: store['name'],
            child: const Icon(Icons.store, color: Colors.green, size: 40),
          ),
        ),
      );
    }
  }

  void _goToCurrentLocation() {
    if (_currentPosition == null) return;
    // Menggerakkan kamera ke lokasi saat ini
    _mapController.move(_currentPosition!, 15.0);
  }

  void _onItemTapped(int index) {
    // Logika navigasi BottomNavigationBar tetap sama
    if (_selectedIndex == index) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PlantListPage(token: widget.token, userId: widget.userId),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SchedulePlantPage(token: widget.token, userId: widget.userId),
          ),
        );
        break;
      case 2:
        // Halaman saat ini, tidak perlu navigasi
        break;
      case 3:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProfilePage(token: widget.token, userId: widget.userId)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Toko Terdekat", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _currentPosition == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: $_errorMessage\n\nTidak dapat menampilkan peta.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : FlutterMap(
                  // Ganti GoogleMap dengan FlutterMap
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        _currentPosition ?? LatLng(-7.7828, 110.3671),
                    initialZoom: 14.0,
                  ),
                  children: [
                    // Layer untuk Tile Peta (wajib ada)
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    // Layer untuk Marker
                    MarkerLayer(
                      markers: _markers,
                    ),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
        // Widget BottomNavigationBar tetap sama
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
}
