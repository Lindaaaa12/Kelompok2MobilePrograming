import 'package:flutter/material.dart';
import 'package:preskom/helpers/db_helper.dart';
import 'package:preskom/models/student.dart';

class AddStudentScreen extends StatefulWidget {
  final String className;

  const AddStudentScreen({super.key, required this.className});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final DbHelper _dbHelper = DbHelper();
  bool _isSaving = false;

  // Fungsi untuk menyimpan siswa ke Database
  Future<void> _saveStudent() async {
    // 1. Validasi input nama tidak boleh kosong
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        // 2. Buat objek student baru
        final newStudent = Student(
          name: _nameController.text.trim(),
          className: widget.className,
          status: AttendanceStatus.none,
        );

        // 3. Simpan ke Database via DbHelper
        await _dbHelper.insertStudent(newStudent);

        // 4. Beri feedback sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Siswa ${newStudent.name} berhasil ditambahkan!'),
              backgroundColor: Colors.green,
            ),
          );
          // Kembali ke halaman sebelumnya dengan membawa nilai 'true' agar list di-refresh
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Siswa - ${widget.className}'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nama Lengkap Siswa',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama siswa...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.person, color: Color(0xFFD32F2F)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveStudent, // Menjalankan fungsi simpan
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Siswa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
