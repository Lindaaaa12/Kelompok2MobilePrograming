import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:preskom/helpers/profile_db_helper.dart';
import 'package:preskom/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String nip;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.nip,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileDbHelper _dbHelper = ProfileDbHelper();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _imagePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    _loadProfileData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      final data = await _dbHelper.getProfileByEmail(widget.email);

      if (data != null) {
        setState(() {
          _emailController.text = data['email'] ?? widget.email;
          _phoneController.text = data['phone'] ?? "";
          _imagePath = data['image_path'];
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
      _saveToDatabase();
    }
  }

  // PERBAIKAN DI SINI: Menggunakan updateProfile agar Password tidak hilang
  Future<void> _saveToDatabase() async {
    try {
      await _dbHelper.updateProfile(widget.email, {
        'email': _emailController.text.trim(),
        'name': widget.name,
        'phone': _phoneController.text.trim(),
        'image_path': _imagePath,
        // Kita tidak perlu mengirimkan 'password' dan 'nip' di sini,
        // karena updateProfile hanya mengubah kolom yang dikirim saja.
      });
      debugPrint("Profil berhasil diupdate tanpa menghapus password.");
    } catch (e) {
      debugPrint("Gagal update profil: $e");
    }
  }

  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 220.0,
            pinned: true,
            backgroundColor: const Color(0xFFD32F2F),
            flexibleSpace: FlexibleSpaceBar(background: _buildHeader()),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _handleLogout,
                tooltip: 'Log Out',
              ),
            ],
          ),
          SliverToBoxAdapter(child: _buildProfileBody(context)),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildHeader() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/background.png',
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(color: Colors.grey),
        ),
        Container(
          color: Colors.black.withOpacity(0.4),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                        child: _imagePath == null ? const Icon(Icons.person, size: 60, color: Colors.white) : null,
                      ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.edit, size: 15, color: Color(0xFFD32F2F)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCardReadOnly('NIP / Kode Guru (Tetap)', widget.nip, Icons.badge_outlined),
          const SizedBox(height: 15),
          _buildInfoCardReadOnly('Jabatan', 'Tenaga Pengajar', Icons.work_outline),
          const SizedBox(height: 15),
          _buildEditableInfoCard('Email Profil', _emailController, Icons.email_outlined),
          const SizedBox(height: 15),
          _buildEditableInfoCard('No. HP', _phoneController, Icons.phone_android_outlined, isPhone: true, hint: "Belum diatur"),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildInfoCardReadOnly(String label, String value, IconData leadingIcon) {
    return Card(
      elevation: 0,
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(leadingIcon, size: 20, color: Colors.grey),
                const SizedBox(width: 12),
                Text(value, style: const TextStyle(color: Colors.black54, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableInfoCard(String label, TextEditingController controller, IconData leadingIcon, {bool isPhone = false, String hint = ""}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(leadingIcon, size: 20, color: const Color(0xFFD32F2F).withOpacity(0.7)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: isPhone ? TextInputType.phone : TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: hint,
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (_) => _saveToDatabase(),
                  ),
                ),
                Icon(Icons.edit_note_rounded, color: Colors.grey[400], size: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      elevation: 10,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFFD32F2F),
      unselectedItemColor: Colors.grey,
      currentIndex: 1,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded), label: 'Profil'),
      ],
      onTap: (index) {
        if (index == 0) Navigator.of(context).pop();
      },
    );
  }
}
