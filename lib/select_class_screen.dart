import 'package:flutter/material.dart';
import 'package:preskom/daily_attendance_screen.dart';
import 'package:preskom/daily_history_screen.dart';
import 'package:preskom/monthly_recap_screen.dart';
import 'package:preskom/profile_screen.dart';

enum NavigationPurpose { attendance, history, recap }

class SelectClassScreen extends StatefulWidget {
  final NavigationPurpose purpose;
  final String userName;
  final String userEmail;
  final String userNip; // TAMBAHKAN INI

  const SelectClassScreen({
    super.key,
    required this.purpose,
    required this.userName,
    required this.userEmail,
    required this.userNip, // Wajib dikirim dari Home
  });

  @override
  State<SelectClassScreen> createState() => _SelectClassScreenState();
}

class _SelectClassScreenState extends State<SelectClassScreen> {
  final List<String> _allClasses = [
    'X RPL', 'XI RPL', 'XII RPL',
    'X TKJ', 'XI TKJ', 'XII TKJ',
    'X WEB', 'XI WEB', 'XII WEB',
    'X MOBILE', 'XI MOBILE', 'XII MOBILE',
  ];

  late List<String> _filteredClasses;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredClasses = _allClasses;
    _searchController.addListener(_filterClasses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterClasses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClasses = _allClasses.where((className) {
        return className.toLowerCase().contains(query);
      }).toList();
    });
  }

  String _getTitle() {
    switch (widget.purpose) {
      case NavigationPurpose.attendance: return 'Pilih Kelas Presensi';
      case NavigationPurpose.history: return 'Pilih Kelas Riwayat';
      case NavigationPurpose.recap: return 'Pilih Kelas Rekap';
    }
  }

  void _navigateToScreen(String className) {
    Widget screen;
    switch (widget.purpose) {
      case NavigationPurpose.attendance:
      // Mengirimkan data lengkap ke DailyAttendanceScreen
        screen = DailyAttendanceScreen(
          selectedClass: className,
          userName: widget.userName,
          userEmail: widget.userEmail,
          userNip: widget.userNip, // Kirim NIP
        );
        break;
      case NavigationPurpose.history:
        screen = DailyHistoryScreen(className: className);
        break;
      case NavigationPurpose.recap:
        screen = MonthlyRecapScreen(className: className);
        break;
      default:
        return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFD32F2F),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                _getTitle(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFB71C1C)),
                  ),
                  Container(color: Colors.black.withOpacity(0.4)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildContent(context),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Kelas SMK Telkom',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 15),
          _buildSearchField(),
          const SizedBox(height: 20),
          _filteredClasses.isEmpty
              ? const Center(child: Text('Kelas tidak ditemukan'))
              : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: _filteredClasses.length,
            itemBuilder: (context, index) {
              return _buildClassCard(_filteredClasses[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Cari Kelas (Misal: RPL)',
          prefixIcon: Icon(Icons.search, color: Color(0xFFD32F2F)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildClassCard(String name) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 3,
      child: InkWell(
        onTap: () => _navigateToScreen(name),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.class_outlined, color: Color(0xFFD32F2F), size: 30),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Menu'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
      selectedItemColor: const Color(0xFFD32F2F),
      onTap: (index) {
        if (index == 0) Navigator.of(context).popUntil((route) => route.isFirst);
        if (index == 1) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                name: widget.userName,
                email: widget.userEmail,
                nip: widget.userNip, // Mengirim NIP ke profil
              ),
            ),
          );
        }
      },
    );
  }
}
