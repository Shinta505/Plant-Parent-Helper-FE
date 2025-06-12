import 'package:flutter/material.dart';
import 'package:fe/pages/login_page.dart';
import 'package:fe/services/notification_service.dart';

Future<void> main() async {
  // 🚀 WAJIB: Memastikan semua binding Flutter siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 WAJIB: Menginisialisasi service notifikasi saat aplikasi dimulai
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Navigasi awal Anda sudah benar
      home: LoginPage(),
    );
  }
}
