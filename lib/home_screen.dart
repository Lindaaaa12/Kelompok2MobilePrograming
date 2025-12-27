import 'package:flutter/material.dart';
import 'package:preskom/profile_screen.dart';
import 'package:preskom/select_class_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userNip; // TAMBAHKAN INI

  const HomeScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userNip, // Wajib diisi saat login berhasil
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Meneruskan data user lengkap ke SelectClassScreen
  void _navigateToSelectClass(BuildContext context, NavigationPurpose purpose) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectClassScreen(
          purpose: purpose,
          userName: widget.userName,
          userEmail: widget.userEmail,
          userNip: widget.userNip, // Teruskan NIP ke estafet berikutnya
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFFD32F2F),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: const Color(0xFFD32F2F)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          const Color(0xFFD32F2F).withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selamat Datang, Bapak/Ibu Guru',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            Text(
                              widget.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.school,
                              color: Colors.white, size: 30),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AttendanceCard(),
                  const SizedBox(height: 30),
                  const Text(
                    'Layanan Utama',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildMenuGrid(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return Column(
      children: [
        _MenuTile(
          icon: Icons.assignment_turned_in_rounded,
          title: 'Presensi Harian',
          subtitle: 'Input data kehadiran siswa hari ini',
          color: Colors.blue.shade700,
          onTap: () =>
              _navigateToSelectClass(context, NavigationPurpose.attendance),
        ),
        _MenuTile(
          icon: Icons.history_rounded,
          title: 'Riwayat Kehadiran',
          subtitle: 'Lihat data kehadiran sebelumnya',
          color: Colors.orange.shade800,
          onTap: () =>
              _navigateToSelectClass(context, NavigationPurpose.history),
        ),
        _MenuTile(
          icon: Icons.insert_chart_rounded,
          title: 'Rekap & Laporan Bulanan',
          subtitle: 'Download laporan format CSV/Excel',
          color: Colors.green.shade700,
          onTap: () => _navigateToSelectClass(context, NavigationPurpose.recap),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      elevation: 10,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFFD32F2F),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded), label: 'Beranda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded), label: 'Profil'),
      ],
      onTap: (index) {
        if (index == 1) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                name: widget.userName,
                email: widget.userEmail,
                nip: widget.userNip, // KIRIM NIP KE PROFIL
              ),
            ),
          );
        }
      },
    );
  }
}

// Widget pendukung (AttendanceCard & MenuTile) tetap sama seperti sebelumnya
class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 110,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD32F2F).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sistem Presensi Digital',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  'SMK Telkom Lampung\nTahun Ajaran 2025/2026',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            bottom: 0,
            child: Image.asset(
              'assets/images/orang.png',
              height: 130,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person, size: 80, color: Colors.white24),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
