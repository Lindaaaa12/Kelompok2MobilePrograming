import 'package:flutter/material.dart';
import 'package:preskom/models/student.dart';
import 'package:preskom/helpers/db_helper.dart';
import 'package:intl/intl.dart'; // Pastikan intl sudah ada di pubspec.yaml

class DailyHistoryScreen extends StatefulWidget {
  final String className;

  const DailyHistoryScreen({super.key, required this.className});

  @override
  State<DailyHistoryScreen> createState() => _DailyHistoryScreenState();
}

class _DailyHistoryScreenState extends State<DailyHistoryScreen> {
  final DbHelper _dbHelper = DbHelper();

  Map<AttendanceStatus, int> _attendanceCounts = {
    AttendanceStatus.hadir: 0,
    AttendanceStatus.izin: 0,
    AttendanceStatus.sakit: 0,
    AttendanceStatus.alpa: 0,
  };

  List<Student> _currentClassStudents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _dbHelper.getStudentsByClass(widget.className);

    setState(() {
      _currentClassStudents = data;
      _calculateCounts();
      _isLoading = false;
    });
  }

  void _calculateCounts() {
    int hadir = 0, izin = 0, sakit = 0, alpa = 0;

    for (var student in _currentClassStudents) {
      switch (student.status) {
        case AttendanceStatus.hadir: hadir++; break;
        case AttendanceStatus.izin: izin++; break;
        case AttendanceStatus.sakit: sakit++; break;
        case AttendanceStatus.alpa: alpa++; break;
        case AttendanceStatus.none: break;
      }
    }

    _attendanceCounts = {
      AttendanceStatus.hadir: hadir,
      AttendanceStatus.izin: izin,
      AttendanceStatus.sakit: sakit,
      AttendanceStatus.alpa: alpa,
    };
  }

  void _showStudentListDialog(AttendanceStatus status, String title) {
    List<Student> filteredStudents;
    if (status == AttendanceStatus.none) {
      filteredStudents = _currentClassStudents;
    } else {
      filteredStudents = _currentClassStudents.where((s) => s.status == status).toList();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: filteredStudents.isEmpty
              ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('Tidak ada data siswa.', textAlign: TextAlign.center),
          )
              : ListView.builder(
            shrinkWrap: true,
            itemCount: filteredStudents.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFEE7E7),
                  child: Icon(Icons.person, color: Color(0xFFD32F2F), size: 20),
                ),
                title: Text(filteredStudents[index].name),
                subtitle: Text("Status: ${filteredStudents[index].status.name}"),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup', style: TextStyle(color: Color(0xFFD32F2F))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil tanggal hari ini
    String formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text('Riwayat - ${widget.className}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFFD32F2F),
        iconTheme: const IconThemeData(color: Colors.white),
        // ICON TAMBAH SISWA DI ATAS SUDAH DIHAPUS
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // PERUBAHAN TEKS: Rekap Harian + Tanggal
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                child: Column(
                  children: [
                    const Text(
                      'Rekap Harian',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formattedDate,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Tabel Statistik
              _buildAttendanceGrid(),

              const SizedBox(height: 40),

              if (_currentClassStudents.isEmpty)
                const Column(
                  children: [
                    Icon(Icons.person_off, size: 60, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Belum ada data siswa di kelas ini", style: TextStyle(color: Colors.grey)),
                  ],
                )
              else
                const Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("Klik angka pada tabel untuk melihat detail nama siswa",
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                  ],
                )
            ],
          ),
        ),
      ),
      // FLOATING ACTION BUTTON SUDAH DIHAPUS
    );
  }

  Widget _buildAttendanceGrid() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Table(
          border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey[200]!, width: 1)),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
              children: [
                _buildHeaderCell('Hadir'),
                _buildHeaderCell('Izin'),
                _buildHeaderCell('Sakit'),
                _buildHeaderCell('Alpa'),
                _buildHeaderCell('Total'),
              ],
            ),
            TableRow(
              children: [
                _buildCountCell(_attendanceCounts[AttendanceStatus.hadir]!, Colors.green, AttendanceStatus.hadir),
                _buildCountCell(_attendanceCounts[AttendanceStatus.izin]!, Colors.blue, AttendanceStatus.izin),
                _buildCountCell(_attendanceCounts[AttendanceStatus.sakit]!, Colors.orange, AttendanceStatus.sakit),
                _buildCountCell(_attendanceCounts[AttendanceStatus.alpa]!, Colors.red, AttendanceStatus.alpa),
                _buildCountCell(_currentClassStudents.length, Colors.black, AttendanceStatus.none),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Text(
          title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildCountCell(int count, Color color, AttendanceStatus status) {
    return InkWell(
      onTap: () => _showStudentListDialog(status, 'Daftar Siswa'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Text(count.toString(), textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
      ),
    );
  }
}
