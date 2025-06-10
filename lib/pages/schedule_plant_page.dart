import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fe/pages/plant_list_page.dart';
import '../services/notification_service.dart';
import 'package:fe/pages/nearest_store_page.dart';
import 'package:fe/pages/profile_page.dart';

class SchedulePlantPage extends StatefulWidget {
  final String token;
  final int userId;

  const SchedulePlantPage({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<SchedulePlantPage> createState() => _SchedulePlantPageState();
}

class _SchedulePlantPageState extends State<SchedulePlantPage> {
  final String baseUrl =
      'https://plant-parent-helper-be-103949415038.us-central1.run.app';
  late Future<List<dynamic>> _tasksFuture;
  final int _selectedIndex = 1;

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.init();
    _tasksFuture = fetchTodayTasks();
  }

  Future<void> _scheduleNotificationsForTasks(List<dynamic> tasks) async {
    for (var task in tasks) {
      final String plantName = task['plant']?['name'] ?? 'Tanaman Anda';
      final String taskType =
          task['type'] == 'watering' ? 'menyiram' : 'memberi pupuk';

      await _notificationService.scheduleTaskNotification(
        id: task['id'],
        title: 'Jangan Lupa! Waktunya Merawat Tanaman',
        body: 'Saatnya $taskType tanaman "$plantName".',
        scheduledTime: DateTime.parse(task['schedule_time']).toLocal(),
        repeatInterval: task['repeatInterval'] ?? 'none',
      );
    }
  }

  Future<List<dynamic>> fetchTodayTasks() async {
    final url = Uri.parse('$baseUrl/tasks');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (!mounted) return [];

      if (response.statusCode == 200) {
        List<dynamic> allTasks = jsonDecode(response.body);

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        List<dynamic> userTasks = allTasks.where((task) {
          return task['plant'] != null &&
              task['plant']['userId'] == widget.userId;
        }).toList();

        List<dynamic> todayTasks = userTasks.where((task) {
          final scheduleTime = DateTime.parse(task['schedule_time']).toLocal();
          final scheduleDate =
              DateTime(scheduleTime.year, scheduleTime.month, scheduleTime.day);
          final status = task['status'];
          final repeat = task['repeatInterval'] ?? 'none';

          if (repeat == 'none') {
            return status == 'pending' && scheduleDate == today;
          }
          if (repeat == 'daily') return true;
          if (repeat == 'weekly') return scheduleTime.weekday == now.weekday;
          if (repeat == 'monthly') return scheduleTime.day == now.day;

          return false;
        }).toList();

        todayTasks.sort((a, b) {
          final timeA = DateTime.parse(a['schedule_time']).toLocal();
          final timeB = DateTime.parse(b['schedule_time']).toLocal();
          return timeA.compareTo(timeB);
        });

        await _scheduleNotificationsForTasks(todayTasks);

        return todayTasks;
      } else {
        throw Exception(jsonDecode(response.body)['msg']);
      }
    } catch (e) {
      throw Exception("Gagal memuat jadwal: ${e.toString()}");
    }
  }

  String formatTimeInZones(DateTime time) {
    final wib = time.toUtc().add(const Duration(hours: 7));
    final wita = time.toUtc().add(const Duration(hours: 8));
    final wit = time.toUtc().add(const Duration(hours: 9));
    final london = time.toUtc().add(const Duration(hours: 1));

    final formatter = DateFormat('dd MMM yyyy, HH:mm:ss');

    return '''
WIB   : ${formatter.format(wib)} (GMT+7)
WITA  : ${formatter.format(wita)} (GMT+8)
WIT   : ${formatter.format(wit)} (GMT+9)
London: ${formatter.format(london)} (GMT+1)
''';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _deleteTask(int taskId) async {
    final url = Uri.parse('$baseUrl/tasks/$taskId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSnackBar("Jadwal berhasil dihapus");
        await _notificationService.cancelNotification(taskId);
        setState(() => _tasksFuture = fetchTodayTasks());
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['msg'] ?? 'Gagal menghapus tugas');
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}", isError: true);
    }
  }

  Future<void> _showDeleteConfirmationDialog(
      int taskId, String plantName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                    'Apakah Anda yakin ingin menghapus jadwal untuk tanaman "$plantName"?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTask(taskId);
              },
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
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
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                NearestStorePage(token: widget.token, userId: widget.userId),
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

  Widget _buildTaskCard(Map<String, dynamic> task) {
    String timeString = task['schedule_time'].toString().replaceAll('Z', '');
    final scheduleTime = DateTime.parse(timeString);
    final now = DateTime.now();
    final bool isOverdue =
        now.isAfter(scheduleTime) && task['status'] == 'pending';
    final plant = task['plant'] ?? {};
    final taskType = task['type'] ?? 'other';
    final taskNote = task['note'];
    final int taskId = task['id'];
    final String plantName = plant['name'] ?? 'Tanaman';

    IconData iconData;
    String taskName;
    switch (taskType) {
      case 'watering':
        iconData = Icons.water_drop;
        taskName = 'Penyiraman';
        break;
      case 'fertilizing':
        iconData = Icons.compost;
        taskName = 'Pemupukan';
        break;
      default:
        iconData = Icons.task;
        taskName = 'Tugas Lain';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isOverdue ? Colors.orange.shade50 : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue ? Colors.orange.shade300 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 8),
        child: Row(
          children: [
            Icon(iconData,
                color: isOverdue ? Colors.orange : Colors.lightGreen, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(taskName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(plantName, style: const TextStyle(fontSize: 16)),
                  if (taskNote != null && taskNote.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text("Catatan: $taskNote",
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic)),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('HH:mm').format(scheduleTime),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? Colors.orange.shade800 : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    formatTimeInZones(scheduleTime),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.right,
                  ),
                ),
                if (isOverdue) ...[
                  Chip(
                    label: const Text("Terlewat"),
                    backgroundColor: Colors.orange.shade100,
                    labelStyle: TextStyle(color: Colors.orange.shade900),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.delete_forever, color: Colors.red.shade400),
                    onPressed: () =>
                        _showDeleteConfirmationDialog(taskId, plantName),
                    tooltip: 'Hapus Jadwal',
                  )
                ],
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jadwal Hari Ini",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() => _tasksFuture = fetchTodayTasks()),
        child: FutureBuilder<List<dynamic>>(
          future: _tasksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "Tidak ada jadwal untuk hari ini. Waktunya bersantai! 🥳",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              );
            }
            final tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) => _buildTaskCard(tasks[index]),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
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
