import 'package:flutter/foundation.dart';

// 1. Tambahkan Enum ini agar status bisa dibaca oleh class Student
enum AttendanceStatus { hadir, izin, sakit, alpa, none }

class Student {
  final int? id; // Menggunakan int? agar ID bisa otomatis dari Database (Auto Increment)
  final String name;
  final String className;
  AttendanceStatus status;

  Student({
    this.id,
    required this.name,
    required this.className,
    this.status = AttendanceStatus.none,
  });

  // 2. Factory method untuk mengubah data dari Database (Map) menjadi Objek Student
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      className: map['className'],
      status: AttendanceStatus.values.firstWhere(
            (e) => e.name == (map['status'] ?? 'none'),
        orElse: () => AttendanceStatus.none,
      ),
    );
  }

  // 3. Method untuk mengubah Objek Student menjadi Map (untuk disimpan ke Database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id, // Hanya masukkan ID jika sudah ada (bukan data baru)
      'name': name,
      'className': className,
      'status': status.name, // Menyimpan enum sebagai String (misal: 'hadir')
    };
  }
}
