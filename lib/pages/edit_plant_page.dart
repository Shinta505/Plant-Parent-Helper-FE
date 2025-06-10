import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// TAMBAHKAN: Import untuk package intl, location, geocoding, dan service notifikasi
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import '../services/notification_service.dart';

class EditPlantPage extends StatefulWidget {
  final String token;
  final int plantId;
  final int userId;

  const EditPlantPage({
    super.key,
    required this.token,
    required this.plantId,
    required this.userId,
  });

  @override
  State<EditPlantPage> createState() => _EditPlantPageState();
}

class _EditPlantPageState extends State<EditPlantPage> {
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

  int? _costId;
  int? _taskId;

  String _taskType = 'watering';
  String _repeatInterval = 'none';
  DateTime? _scheduleTime;

  bool _isSubmitting = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // TAMBAHKAN: Panggil metode init dari service notifikasi.
    _notificationService.init();
    _fetchPlantDetails();
  }

  Future<void> _fetchPlantDetails() async {
    // ... (Fungsi ini tetap sama, tidak perlu diubah)
    try {
      final plantRes = await http.get(
        Uri.parse('$baseUrl/plants/${widget.plantId}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (plantRes.statusCode == 200) {
        final data = jsonDecode(plantRes.body);
        if (!mounted) return;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _locationController.text = data['location'] ?? '';
          _noteController.text = data['note'] ?? '';
          _imageUrlController.text = data['imageUrl'] ?? '';
        });
      }

      final costRes = await http.get(
        Uri.parse('$baseUrl/plants/${widget.plantId}/costs'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (costRes.statusCode == 200) {
        final costs = jsonDecode(costRes.body);
        if (costs.isNotEmpty) {
          if (!mounted) return;
          _costId = costs[0]['id'];
          _costController.text = costs[0]['amount'].toString();
        }
      }

      final taskRes = await http.get(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (taskRes.statusCode == 200) {
        final tasks = jsonDecode(taskRes.body);
        final task = tasks.firstWhere(
          (t) => t['plantId'] == widget.plantId,
          orElse: () => null,
        );
        if (task != null) {
          if (!mounted) return;
          _taskId = task['id'];
          _taskType = task['type'];
          _repeatInterval = task['repeatInterval'] ?? 'none';
          _taskNoteController.text = task['note'] ?? '';
          _scheduleTime = DateTime.tryParse(task['schedule_time'])?.toLocal();
        }
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Gagal memuat data: ${e.toString()}");
      setState(() => _isLoading = false);
    }
  }

  // TAMBAHKAN: Fungsi untuk mendapatkan lokasi saat ini
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

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // API call untuk update detail tanaman
      final updateRes = await http.put(
        Uri.parse('$baseUrl/plants/${widget.plantId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'location': _locationController.text,
          'note': _noteController.text,
          'imageUrl': _imageUrlController.text,
        }),
      );

      if (updateRes.statusCode != 200) {
        throw Exception(jsonDecode(updateRes.body)['msg']);
      }

      final costValue = int.tryParse(_costController.text);
      if (_costId != null && costValue != null && costValue > 0) {
        // API call untuk update biaya tanaman
        await http.put(
          Uri.parse('$baseUrl/plants/${widget.plantId}/costs/$_costId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
          body: jsonEncode({'amount': costValue}),
        );
      } else if (_costId == null && costValue != null && costValue > 0) {
        // Jika biaya belum ada, buat baru
        await http.post(
          Uri.parse('$baseUrl/plants/${widget.plantId}/costs'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
          body: jsonEncode({'amount': costValue}),
        );
      }

      if (_taskId != null && _scheduleTime != null) {
        // API call untuk update tugas
        await http.put(
          Uri.parse('$baseUrl/tasks/$_taskId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.token}',
          },
          body: jsonEncode({
            'type': _taskType,
            'note': _taskNoteController.text,
            'schedule_time': _scheduleTime!.toIso8601String(),
            'status': 'pending',
            'repeatInterval': _repeatInterval,
          }),
        );

        // MODIFIKASI: Jadwalkan ulang notifikasi dengan data baru
        final String plantName = _nameController.text;
        String taskTypeName =
            _taskType == 'watering' ? 'menyiram' : 'memberi pupuk';
        await _notificationService.scheduleTaskNotification(
          id: _taskId!,
          title: 'Jadwal Diperbarui!',
          body: 'Saatnya $taskTypeName tanaman "$plantName".',
          scheduledTime: _scheduleTime!,
          repeatInterval: _repeatInterval,
        );
      }

      if (!mounted) return;
      _showSnackBar("Tanaman berhasil diperbarui ✅");
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
        title:
            const Text("Edit Tanaman", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Informasi Tanaman",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    TextFormField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Tanaman'),
                      validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                    ),
                    // MODIFIKASI: Tambahkan tombol ikon lokasi
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
                      decoration: const InputDecoration(
                          labelText: 'Catatan (Opsional)'),
                    ),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration:
                          const InputDecoration(labelText: 'URL Gambar'),
                    ),
                    const SizedBox(height: 20),
                    const Text("Biaya Tanaman",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    TextFormField(
                      controller: _costController,
                      decoration:
                          const InputDecoration(labelText: 'Biaya (Rp)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    const Text("Tugas Tanaman",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    DropdownButtonFormField<String>(
                      value: _taskType,
                      items: const [
                        DropdownMenuItem(
                            value: 'watering', child: Text('Penyiraman')),
                        DropdownMenuItem(
                            value: 'fertilizing', child: Text('Pemupukan')),
                      ],
                      onChanged: (v) => setState(() => _taskType = v!),
                      decoration:
                          const InputDecoration(labelText: 'Jenis Tugas'),
                    ),
                    TextFormField(
                      controller: _taskNoteController,
                      decoration:
                          const InputDecoration(labelText: 'Catatan Tugas'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _repeatInterval,
                      items: const [
                        DropdownMenuItem(
                            value: 'none', child: Text('Tidak Berulang')),
                        DropdownMenuItem(value: 'daily', child: Text('Harian')),
                        DropdownMenuItem(
                            value: 'weekly', child: Text('Mingguan')),
                      ],
                      onChanged: (v) => setState(() => _repeatInterval = v!),
                      decoration:
                          const InputDecoration(labelText: 'Interval Tugas'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _scheduleTime == null
                                ? 'Waktu belum dipilih'
                                // MODIFIKASI: Gunakan DateFormat untuk tampilan yang lebih baik
                                : 'Jadwal: ${DateFormat('dd MMM yyyy, HH:mm').format(_scheduleTime!)}',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final now = DateTime.now();
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _scheduleTime ?? now,
                              firstDate: now,
                              lastDate: DateTime(now.year + 2),
                            );
                            if (pickedDate != null) {
                              final pickedTime = await showTimePicker(
                                // ignore: use_build_context_synchronously
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                    _scheduleTime ?? now),
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
                        onPressed: _isSubmitting ? null : _submitUpdate,
                        child: Text(_isSubmitting
                            ? 'Menyimpan...'
                            : 'Simpan Perubahan'),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
