import 'package:flutter/material.dart';

// Ganti dengan path ke halaman login-mu yang sebenarnya jika sudah ada.
// Contoh: import 'package:plant_parent_helper/features/auth/presentation/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Parent Helper',
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      theme: ThemeData(
        // Tema utama aplikasi dengan skema warna hijau dan putih
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
          primary: Colors.green,
          secondary: Colors.lightGreen,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white, // Warna ikon dan teks di AppBar
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      // Aplikasi akan langsung membuka LoginPage sebagai halaman pertama.
      home: const LoginPage(),
    );
  }
}

/// Ini adalah halaman login sementara.
/// Ganti widget ini dengan halaman login dari struktur folder `features` kamu nanti.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: const Center(
        child: Text(
          'Ini adalah Halaman Login',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
