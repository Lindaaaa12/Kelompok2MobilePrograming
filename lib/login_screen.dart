import 'package:flutter/material.dart';
import 'package:preskom/home_screen.dart';
import 'package:preskom/register_screen.dart';
import 'package:preskom/helpers/profile_db_helper.dart'; // Import Helper Database

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nipController = TextEditingController();

  // Inisialisasi Database Helper
  final ProfileDbHelper _dbHelper = ProfileDbHelper();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nipController.dispose();
    super.dispose();
  }

  // FUNGSI VALIDASI LOGIN
  void _login() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text;
      String nip = _nipController.text.trim();

      // 1. Cari data di database berdasarkan Email
      final userData = await _dbHelper.getProfileByEmail(email);

      if (userData != null) {
        // 2. Cek apakah Password dan NIP cocok
        if (userData['password'] == password && userData['nip'] == nip) {

          // JIKA BERHASIL
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login Berhasil'),
              backgroundColor: Colors.green,
            ),
          );

          // Pindah ke HomeScreen dengan membawa data asli dari database
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userName: userData['name'],
                userEmail: userData['email'],
                userNip: userData['nip'],
              ),
            ),
          );
        } else {
          // JIKA PASSWORD ATAU NIP SALAH
          _showError('NIP atau Password salah!');
        }
      } else {
        // JIKA EMAIL TIDAK DITEMUKAN
        _showError('Email tidak terdaftar!');
      }
    }
  }

  // Helper untuk menampilkan pesan error
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
            ),
          ),

          // Logo Area
          Positioned(
            top: screenHeight * 0.08,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8)
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.school, size: 50, color: Color(0xFFd32f2f)),
                  ),
                ),
              ),
            ),
          ),

          // Form White Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.7,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                  ]
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'Selamat Datang',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFd32f2f)
                        ),
                      ),
                      Text(
                        'Masuk untuk melanjutkan!',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 30),

                      // Input NIP
                      _buildLabel('NIP / KODE GURU'),
                      TextFormField(
                        controller: _nipController,
                        decoration: _buildInputDecoration(
                          hint: 'Masukkan NIP Anda',
                          icon: Icons.badge_outlined,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'NIP wajib diisi';
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Input Email
                      _buildLabel('EMAIL'),
                      TextFormField(
                        controller: _emailController,
                        decoration: _buildInputDecoration(
                          hint: 'Masukkan email Anda',
                          icon: Icons.email_outlined,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email wajib diisi';
                          if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Input Password
                      _buildLabel('KATA SANDI'),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _buildInputDecoration(
                          hint: 'Masukkan kata sandi Anda',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: const Color(0xFFd32f2f)
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password wajib diisi';
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      // Login Button
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFd32f2f),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 55),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text(
                            'MASUK',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Link Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Belum punya akun? '),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterScreen())
                              );
                            },
                            child: const Text(
                              'Daftar Sekarang',
                              style: TextStyle(
                                  color: Color(0xFFd32f2f),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper Label
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFd32f2f),
              letterSpacing: 1.1
          ),
        ),
      ),
    );
  }

  // Widget Helper Input Decoration
  InputDecoration _buildInputDecoration({required String hint, required IconData icon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFFd32f2f), size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFffcdd2).withOpacity(0.3),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
    );
  }
}
