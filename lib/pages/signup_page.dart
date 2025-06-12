import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fe/pages/login_page.dart'; // Pastikan path ini benar

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // GlobalKey untuk mengelola state dari Form
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  // State untuk dropdown gender dan loading indicator
  String? _selectedGender;
  final List<String> _genders = ['Male', 'Female'];

  bool isObscure = true;
  bool _isLoading = false;

  final String baseUrl =
      'https://plant-parent-helper-be-103949415038.us-central1.run.app';

  Future<void> registerUser() async {
    // Jalankan validasi form terlebih dahulu
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Tampilkan loading indicator
      });

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/users'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': _name.text,
            'email': _email.text,
            'gender': _selectedGender, // Ambil dari state dropdown
            'password': _password.text,
          }),
        );

        // Periksa apakah widget masih ada di tree sebelum melanjutkan
        if (!mounted) return;

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registrasi berhasil 🌱")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          // Menangani error dari server, termasuk email yang sudah terdaftar
          final resBody = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(resBody['message'] ??
                    "Gagal mendaftar. Silakan coba lagi.")),
          );
        }
      } catch (e) {
        // Menangani error koneksi atau lainnya
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Terjadi kesalahan jaringan: ${e.toString()}")),
        );
      } finally {
        // Hentikan loading indicator setelah selesai
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Selalu dispose controller untuk menghindari memory leak
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.lightGreen,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        // Menggunakan Form widget untuk validasi
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Name", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  hintText: "Enter your name",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text("Email", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _email,
                keyboardType:
                    TextInputType.emailAddress, // Keyboard type untuk email
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  // Validasi format email menggunakan regular expression
                  String pattern =
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                  RegExp regex = RegExp(pattern);
                  if (!regex.hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text("Gender", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 5),
              // Dropdown untuk Gender
              DropdownButtonFormField<String>(
                value: _selectedGender,
                hint: const Text("Select your gender"),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                items: _genders.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Silakan pilih gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text("Password", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _password,
                obscureText: isObscure,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  suffixIcon: IconButton(
                    icon: Icon(
                        isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        isObscure = !isObscure;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  if (value.length < 8 || value.length > 12) {
                    return 'Password harus 8-12 karakter';
                  }
                  if (!value.contains(RegExp(r'[A-Z]'))) {
                    return 'Harus mengandung minimal 1 huruf besar';
                  }
                  if (!value.contains(RegExp(r'[a-z]'))) {
                    return 'Harus mengandung minimal 1 huruf kecil';
                  }
                  if (!value.contains(RegExp(r'[0-9]'))) {
                    return 'Harus mengandung minimal 1 angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : registerUser, // Nonaktifkan tombol saat loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        "Sign Up",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
