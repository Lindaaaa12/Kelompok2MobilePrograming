import 'dart:io';
import 'package:flutter/material.dart';
import 'package:preskom/models/student.dart';
import 'package:preskom/helpers/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MonthlyRecapScreen extends StatefulWidget {
  final String className;

  const MonthlyRecapScreen({super.key, required this.className});

  @override
  State<MonthlyRecapScreen> createState() => _MonthlyRecapScreenState();
}

class _MonthlyRecapScreenState extends State<MonthlyRecapScreen> {
  final DbHelper _dbHelper = DbHelper();
  List<Map<String, dynamic>> _monthlyData = [];
  bool _isLoading = true;

  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    setState(() => _isLoading = true);
    try {
      final students = await _dbHelper.getStudentsByClass(widget.className);
      setState(() {
        _monthlyData = students.map((s) => {
          'name': s.name,
          'hadir': s.status == AttendanceStatus.hadir ? 1 : 0,
          'izin': s.status == AttendanceStatus.izin ? 1 : 0,
          'sakit': s.status == AttendanceStatus.sakit ? 1 : 0,
          'alpa': s.status == AttendanceStatus.alpa ? 1 : 0,
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD32F2F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadMonthlyData();
    }
  }

  // --- FUNGSI DOWNLOAD YANG SUDAH DIPERBAIKI TOTAL ---
  Future<void> _downloadCSV() async {
    try {
      if (Platform.isAndroid) {
        // 1. Meminta Izin Akses Semua File (Wajib untuk Android 11+)
        var status = await Permission.manageExternalStorage.request();

        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Harap izinkan "Akses Semua File" agar file bisa disimpan di folder Download.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          await openAppSettings(); // Membuka pengaturan jika izin ditolak
          return;
        }
      }

      // 2. Siapkan Data CSV
      List<List<dynamic>> rows = [];
      rows.add(["No", "Nama Siswa", "Hadir (H)", "Izin (I)", "Sakit (S)", "Alpa (A)"]);

      for (int i = 0; i < _monthlyData.length; i++) {
        var d = _monthlyData[i];
        rows.add([i + 1, d['name'], d['hadir'], d['izin'], d['sakit'], d['alpa']]);
      }

      String csvData = const ListToCsvConverter().convert(rows);

      // 3. Tentukan Lokasi Jalur Folder Download Utama (/storage/emulated/0/Download)
      String path = "";
      if (Platform.isAndroid) {
        path = "/storage/emulated/0/Download";
        // Cek apakah jalur tersebut ada, jika tidak gunakan jalur dokumen
        final dir = Directory(path);
        if (!await dir.exists()) {
          final fallbackDir = await getExternalStorageDirectory();
          path = fallbackDir!.path;
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        path = directory.path;
      }

      String fileName = "Rekap_${widget.className}_${DateFormat('yyyyMMdd').format(_startDate)}.csv";
      File file = File("$path/$fileName");

      // 4. Tulis File ke Penyimpanan
      await file.writeAsString(csvData);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text("Berhasil!"),
              ],
            ),
            content: Text(
              "File rekap berhasil disimpan ke folder Download utama.\n\nNama File:\n$fileName",
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("TUTUP"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String rangeLabel = "${DateFormat('dd MMM yyyy', 'id').format(_startDate)} - ${DateFormat('dd MMM yyyy', 'id').format(_endDate)}";

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text('Rekap - ${widget.className}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFFD32F2F),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_for_offline),
            onPressed: _monthlyData.isEmpty ? null : _downloadCSV,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
          : Column(
        children: [
          GestureDetector(
            onTap: _selectDateRange,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFD32F2F).withOpacity(0.3)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  const Text("Periode Rekap (Klik untuk ubah)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.date_range, color: Color(0xFFD32F2F), size: 18),
                      const SizedBox(width: 10),
                      Text(rangeLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: _monthlyData.isEmpty
                    ? const Center(child: Text("Tidak ada data dalam periode ini"))
                    : SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('Nama')),
                      DataColumn(label: Text('H', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('I', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('S', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('A', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                    ],
                    rows: _monthlyData.map((data) {
                      return DataRow(cells: [
                        DataCell(SizedBox(width: 100, child: Text(data['name'], overflow: TextOverflow.ellipsis))),
                        DataCell(Text(data['hadir'].toString())),
                        DataCell(Text(data['izin'].toString())),
                        DataCell(Text(data['sakit'].toString())),
                        DataCell(Text(data['alpa'].toString())),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
