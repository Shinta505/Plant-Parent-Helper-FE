import 'dart:convert';
import 'package:fe/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fe/pages/plant_list_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  // State untuk kontrol UI
  bool _isLoading = false;
  bool _isObscure = true;

  // Ganti dengan IP Address mesin Anda jika menjalankan di HP fisik
  final String baseUrl =
      'https://plant-parent-helper-be-103949415038.us-central1.run.app';

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    // Validasi input sederhana
    if (_email.text.isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password tidak boleh kosong.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _email.text,
          'password': _password.text,
        }),
      );

      // PERBAIKAN: Cek 'mounted' sebelum menggunakan BuildContext
      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // MODIFIKASI: Ambil 'accessToken' dan 'userId' dari response
        final String token = responseData['accessToken'];
        final int userId =
            responseData['userId']; // Pastikan backend mengirimkan 'userId'

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PlantListPage(
              token: token,
              userId: userId, // Kirim userId ke halaman selanjutnya
            ),
          ),
        );
      } else {
        // Jika login gagal (misal: status 401 atau 404)
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(errorData['msg'] ?? 'Email atau password salah 😐')),
        );
      }
    } catch (e) {
      // PERBAIKAN: Tangani error koneksi/jaringan
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal terhubung ke server: ${e.toString()}')),
      );
    } finally {
      // PERBAIKAN: Pastikan loading state selalu kembali false
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            // Menggunakan SingleChildScrollView
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Selamat Datang Kembali,",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Login untuk merawat tanamanmu 🌱",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                Image.asset("assets/images/image-login.png", height: 180),
                const SizedBox(height: 30),

                // Form Email
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon:
                        const Icon(Icons.email_outlined, color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Form Password
                TextField(
                  controller: _password,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 30),

                // Tombol Login dengan Indikator Loading
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : loginUser, // Nonaktifkan tombol saat loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text("Login",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),

                // Tombol ke Halaman Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupPage()),
                        );
                      },
                      child: const Text("Sign up",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.lightGreen)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
