import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';

// TAMBAHKAN: Import untuk service notifikasi yang telah dibuat.
import '../services/notification_service.dart';

class CreatePlantPage extends StatefulWidget {
  final String token;
  final int userId;

  const CreatePlantPage({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<CreatePlantPage> createState() => _CreatePlantPageState();
}

class _CreatePlantPageState extends State<CreatePlantPage> {
  final String baseUrl =
      'https://plant-parent-helper-be-103949415038.us-central1.run.app';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _taskNoteController = TextEditingController();

  // TAMBAHKAN: Inisialisasi instance dari NotificationService.
  final NotificationService _notificationService = NotificationService();

  String _taskType = 'watering';
  String _repeatInterval = 'none';
  DateTime? _scheduleTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // TAMBAHKAN: Panggil metode init dari service notifikasi saat state diinisialisasi.
    _notificationService.init();
  }

  Future<void> _getCurrentLocation() async {
    loc.Location location = loc.Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        if (!mounted) return;
        _showSnackBar('Layanan lokasi tidak tersedia.');
        return;
      }
    }

    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        if (!mounted) return;
        _showSnackBar('Izin lokasi ditolak.');
        return;
      }
    }

    final locData = await location.getLocation();
    if (locData.latitude != null && locData.longitude != null) {
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          locData.latitude!,
          locData.longitude!,
        );
        Placemark place = placemarks.first;
        if (!mounted) return;
        setState(() {
          _locationController.text =
              "${place.street}, ${place.locality}, ${place.country}";
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _locationController.text =
              "${locData.latitude}, ${locData.longitude}";
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_scheduleTime == null) {
      _showSnackBar("Jadwal tugas awal wajib dipilih.");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final plantResp = await http.post(
        Uri.parse('$baseUrl/plants'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'location': _locationController.text.isNotEmpty
              ? _locationController.text
              : null,
          'note': _noteController.text.isNotEmpty ? _noteController.text : null,
          'imageUrl': _imageUrlController.text.isNotEmpty
              ? _imageUrlController.text
              : null,
          'userId': widget.userId,
        }),
      );

      if (plantResp.statusCode != 201) {
        throw Exception(jsonDecode(plantResp.body)['msg']);
      }

      final plantId = jsonDecode(plantResp.body)['data']['id'];

      final costValue = int.tryParse(_costController.text);
      if (costValue != null && costValue > 0) {
        await http.post(
          Uri.parse('$baseUrl/plants/$plantId/costs'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
          body: jsonEncode({'amount': costValue}),
        );
      }

      final taskResp = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'type': _taskType,
          'note': _taskNoteController.text.isNotEmpty
              ? _taskNoteController.text
              : null,
          'schedule_time': _scheduleTime!.toUtc().toIso8601String(),
          'status': 'pending',
          'repeatInterval': _repeatInterval,
          'plantId': plantId,
        }),
      );

      if (taskResp.statusCode != 201) {
        throw Exception(jsonDecode(taskResp.body)['msg']);
      }

      // TAMBAHKAN: Blok untuk menjadwalkan notifikasi setelah tugas berhasil dibuat.
      final taskData = jsonDecode(taskResp.body)['data'];
      final String plantName = _nameController.text;
      String taskTypeName =
          _taskType == 'watering' ? 'menyiram' : 'memberi pupuk';

      await _notificationService.scheduleTaskNotification(
        id: taskData['id'],
        title: 'Waktunya Merawat Tanaman!',
        body: 'Saatnya $taskTypeName tanaman "$plantName".',
        scheduledTime: _scheduleTime!,
        repeatInterval: _repeatInterval,
      );
      // AKHIR BLOK TAMBAHAN

      if (!mounted) return;
      _showSnackBar("Tanaman berhasil ditambahkan 🌿");
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    _imageUrlController.dispose();
    _costController.dispose();
    _taskNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Tanaman Baru",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Informasi Tanaman",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Tanaman'),
              validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
            ),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Lokasi (Opsional)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: _getCurrentLocation,
                ),
              ),
            ),
            TextFormField(
              controller: _noteController,
              decoration:
                  const InputDecoration(labelText: 'Catatan (Opsional)'),
            ),
            TextFormField(
              controller: _imageUrlController,
              decoration:
                  const InputDecoration(labelText: 'URL Gambar (Opsional)'),
            ),
            const SizedBox(height: 20),
            const Text("Biaya Tanaman (Opsional)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(labelText: 'Biaya (Rp)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const Text("Tugas Pertama",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            DropdownButtonFormField<String>(
              value: _taskType,
              items: const [
                DropdownMenuItem(value: 'watering', child: Text('Penyiraman')),
                DropdownMenuItem(
                    value: 'fertilizing', child: Text('Pemupukan')),
              ],
              onChanged: (v) => setState(() => _taskType = v!),
              decoration: const InputDecoration(labelText: 'Jenis Tugas'),
            ),
            TextFormField(
              controller: _taskNoteController,
              decoration: const InputDecoration(labelText: 'Catatan Tugas'),
            ),
            DropdownButtonFormField<String>(
              value: _repeatInterval,
              items: const [
                DropdownMenuItem(value: 'none', child: Text('Tidak Berulang')),
                DropdownMenuItem(value: 'daily', child: Text('Harian')),
                DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
              ],
              onChanged: (v) => setState(() => _repeatInterval = v!),
              decoration: const InputDecoration(labelText: 'Interval Tugas'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _scheduleTime == null
                        ? 'Waktu belum dipilih'
                        : 'Jadwal: ${DateFormat('dd MMM yyyy, HH:mm').format(_scheduleTime!.toLocal())}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: DateTime(now.year + 2),
                    );

                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        // ignore: use_build_context_synchronously
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (pickedTime != null) {
                        setState(() {
                          _scheduleTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  child: const Text("Pilih Jadwal"),
                )
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitData,
                child: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan Tanaman'),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
