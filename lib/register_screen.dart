import 'package:flutter/material.dart';
import 'package:preskom/home_screen.dart';
import 'package:preskom/helpers/profile_db_helper.dart'; // Import Helper Database

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _teacherCodeController = TextEditingController();

  // Inisialisasi Database Helper
  final ProfileDbHelper _dbHelper = ProfileDbHelper();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _teacherCodeController.dispose();
    super.dispose();
  }

  // Fungsi Helper untuk menampilkan pesan kesalahan (Notifikasi)
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange[800],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Fungsi Register yang menyimpan ke database dengan validasi keunikan
  void _register() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String nip = _teacherCodeController.text.trim();

      try {
        // 1. Validasi: Cek apakah Email sudah digunakan
        final existingEmail = await _dbHelper.getProfileByEmail(email);
        if (existingEmail != null) {
          _showErrorSnackBar('Email ini sudah terdaftar. Gunakan email lain!');
          return;
        }

        // 2. Validasi: Cek apakah NIP / Kode Guru sudah digunakan
        // Memanggil fungsi getProfileByNip (Pastikan fungsi ini sudah Anda tambahkan di ProfileDbHelper)
        final existingNip = await _dbHelper.getProfileByNip(nip);
        if (existingNip != null) {
          _showErrorSnackBar('NIP / Kode Guru ini sudah terdaftar!');
          return;
        }

        // 3. Jika Email & NIP unik, jalankan penyimpanan
        await _dbHelper.saveProfile({
          'email': email,
          'name': _nameController.text.trim(),
          'nip': nip,
          'password': _passwordController.text,
          'jabatan': 'Tenaga Pengajar',
          'phone': '',
          'image_path': null,
        });

        if (!mounted) return;

        // 4. TAMPILKAN DIALOG BERHASIL
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Berhasil',
                style: TextStyle(color: Color(0xFFd32f2f), fontWeight: FontWeight.bold)),
            content: const Text('Akun Anda telah berhasil dibuat. Silakan masuk ke halaman utama.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup Dialog

                  // NAVIGASI KE HOME: Kirim data estafet
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        userName: _nameController.text.trim(),
                        userEmail: email,
                        userNip: nip,
                      ),
                    ),
                  );
                },
                child: const Text('MASUK SEKARANG',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFd32f2f))),
              ),
            ],
          ),
        );
      } catch (e) {
        _showErrorSnackBar('Pendaftaran gagal. Terjadi kesalahan sistem.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
            ),
          ),

          // Logo Area
          Positioned(
            top: screenHeight * 0.05,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 120,
                height: 120,
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

          // Form Container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.75,
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
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Daftar Akun',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFd32f2f)
                        ),
                      ),
                      Text(
                        'Lengkapi data untuk bergabung!',
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 25),

                      _buildLabel('NAMA LENGKAP'),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: _buildInputDecoration(
                          hint: 'Masukkan nama lengkap',
                          icon: Icons.person_outline,
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 15),

                      _buildLabel('EMAIL'),
                      TextFormField(
                        controller: _emailController,
                        decoration: _buildInputDecoration(
                          hint: 'email@sekolah.com',
                          icon: Icons.email_outlined,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email wajib diisi';
                          if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      _buildLabel('KATA SANDI'),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _buildInputDecoration(
                          hint: 'Masukkan kata sandi',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFd32f2f)),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) => (value == null || value.length < 6) ? 'Minimal 6 karakter' : null,
                      ),
                      const SizedBox(height: 15),

                      _buildLabel('NIP / KODE GURU'),
                      TextFormField(
                        controller: _teacherCodeController,
                        decoration: _buildInputDecoration(
                          hint: 'Masukkan NIP atau kode guru',
                          icon: Icons.verified_user_outlined,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Kode guru wajib diisi';
                          return null;
                        },
                      ),

                      const SizedBox(height: 35),

                      ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFd32f2f),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 55),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text(
                            'DAFTAR SEKARANG',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Sudah punya akun? '),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Masuk!',
                              style: TextStyle(
                                  color: Color(0xFFd32f2f),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
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

  // UI Helper Widgets
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 8),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFd32f2f), letterSpacing: 1.1),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required IconData icon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFFd32f2f), size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFffcdd2).withOpacity(0.3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
    );
  }
}
