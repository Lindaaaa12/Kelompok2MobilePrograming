import 'package:flutter/material.dart';
import 'package:preskom/models/student.dart';
import 'package:preskom/helpers/db_helper.dart';
import 'package:preskom/profile_screen.dart';
import 'package:preskom/add_student_screen.dart';
import 'package:intl/intl.dart';

class StudentAttendance extends Student {
  StudentAttendance({
    super.id,
    required super.name,
    required super.className,
    super.status,
  });

  factory StudentAttendance.fromStudent(Student s) {
    return StudentAttendance(
      id: s.id,
      name: s.name,
      className: s.className,
      status: s.status,
    );
  }
}

class DailyAttendanceScreen extends StatefulWidget {
  final String selectedClass;
  final String userName;
  final String userEmail;
  final String userNip; // TAMBAHKAN INI agar bisa dikirim ke Profile

  const DailyAttendanceScreen({
    super.key,
    required this.selectedClass,
    required this.userName,
    required this.userEmail,
    required this.userNip, // Wajib diisi
  });

  @override
  State<DailyAttendanceScreen> createState() => _DailyAttendanceScreenState();
}

class _DailyAttendanceScreenState extends State<DailyAttendanceScreen> {
  List<StudentAttendance> _allStudents = [];
  List<StudentAttendance> _filteredStudents = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final DbHelper _dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    _loadStudentsFromDatabase();
    _searchController.addListener(_filterStudents);
  }

  Future<void> _loadStudentsFromDatabase() async {
    setState(() => _isLoading = true);
    try {
      final data = await _dbHelper.getStudentsByClass(widget.selectedClass);

      setState(() {
        _allStudents = data.map((s) => StudentAttendance.fromStudent(s)).toList();
        _filteredStudents = _allStudents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error loading students: $e");
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterStudents);
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        return student.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _updateAttendance(StudentAttendance student, AttendanceStatus newStatus) {
    setState(() {
      if (student.status == newStatus) {
        student.status = AttendanceStatus.none;
      } else {
        student.status = newStatus;
      }
    });
  }

  void _saveAttendance() async {
    if (_allStudents.isEmpty) return;

    for (var student in _allStudents) {
      if (student.id != null) {
        await _dbHelper.updateStudentStatus(student.id!, student.status.name);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Presensi berhasil disimpan!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    }
  }

  void _navigateToAddStudent() async {
    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddStudentScreen(className: widget.selectedClass)
      ),
    );
    if (refresh == true) _loadStudentsFromDatabase();
  }

  int get _attendedStudentCount =>
      _allStudents.where((s) => s.status != AttendanceStatus.none).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
          : CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFD32F2F),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Presensi ${widget.selectedClass}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              background: Container(color: const Color(0xFFB71C1C)),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              TextButton.icon(
                onPressed: _navigateToAddStudent,
                icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 18),
                label: const Text(
                  'Tambah Siswa',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.save, color: Colors.white),
                tooltip: 'Simpan Presensi',
                onPressed: _saveAttendance,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildContent() {
    String formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());

    if (_allStudents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: Column(
            children: [
              const Icon(Icons.group_off, size: 80, color: Colors.grey),
              const SizedBox(height: 10),
              Text("Belum ada siswa di kelas ${widget.selectedClass}",
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _navigateToAddStudent,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Siswa Manual'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white
                ),
              )
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Color(0xFFD32F2F)),
                const SizedBox(width: 10),
                Text(
                  formattedDate,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
          Text(
            'Terisi: $_attendedStudentCount / ${_allStudents.length} Siswa',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildSearchField(),
          const SizedBox(height: 15),
          _buildAttendanceTable(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari nama...',
        prefixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildAttendanceTable() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(0.6),
          1: FlexColumnWidth(2.5),
          2: FlexColumnWidth(0.7),
          3: FlexColumnWidth(0.7),
          4: FlexColumnWidth(0.7),
          5: FlexColumnWidth(0.7),
        },
        children: [
          _buildHeaderRow(),
          for (int i = 0; i < _filteredStudents.length; i++)
            _buildStudentRow(_filteredStudents[i], i + 1),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFD32F2F)),
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('No', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text('Nama', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('H', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('I', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('S', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('A', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ],
    );
  }

  TableRow _buildStudentRow(StudentAttendance s, int index) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Text(index.toString(), textAlign: TextAlign.center)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8), child: Text(s.name, overflow: TextOverflow.ellipsis, maxLines: 1)),
        _statusBtn(s, AttendanceStatus.hadir, Colors.green),
        _statusBtn(s, AttendanceStatus.izin, Colors.blue),
        _statusBtn(s, AttendanceStatus.sakit, Colors.orange),
        _statusBtn(s, AttendanceStatus.alpa, Colors.red),
      ],
    );
  }

  Widget _statusBtn(StudentAttendance s, AttendanceStatus status, Color color) {
    bool active = s.status == status;
    return InkWell(
      onTap: () => _updateAttendance(s, status),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Container(
            height: 22,
            width: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? color : Colors.white,
              border: Border.all(color: active ? color : Colors.grey.shade400, width: 2),
            ),
            child: active ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
          ),
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
          // PERBAIKAN: Kirim name, email, DAN NIP ke ProfileScreen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                name: widget.userName,
                email: widget.userEmail,
                nip: widget.userNip, // Tambahkan parameter ini
              ),
            ),
          );
        }
      },
    );
  }
}
