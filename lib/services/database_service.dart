import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// PERBAIKAN IMPORT: Mengarah ke file model yang baru
import 'package:preskom/models/student.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('preskom.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Tabel Users (Digunakan untuk Login User dan juga Data Siswa)
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        password TEXT,
        dob TEXT,
        profileImage TEXT,
        className TEXT,
        status TEXT DEFAULT 'none'
      )
    ''');
  }

  // FUNGSI REGISTRASI
  Future<int> registerUser(Map<String, dynamic> data) async {
    final db = await instance.database;
    try {
      return await db.insert('users', data, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint("Error registerUser: $e");
      return 0;
    }
  }

  // FUNGSI LOGIN
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await instance.database;
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (result.isNotEmpty) {
        return result.first;
      }
    } catch (e) {
      debugPrint("Error loginUser: $e");
    }
    return null;
  }

  // FUNGSI AMBIL SISWA PER KELAS
  Future<List<Map<String, dynamic>>> getUsersByClass(String className) async {
    final db = await instance.database;
    try {
      return await db.query(
        'users',
        where: 'className = ?',
        whereArgs: [className],
      );
    } catch (e) {
      debugPrint("Error getUsersByClass: $e");
      return [];
    }
  }

  // FUNGSI UPDATE PROFIL
  Future<int> updateUserProfile(int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    try {
      return await db.update(
        'users',
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint("Error updateUserProfile: $e");
      return 0;
    }
  }

  // FUNGSI UPDATE ABSENSI (Menggunakan AttendanceStatus dari models/student.dart)
  Future<int> updateAttendance(int userId, AttendanceStatus status) async {
    final db = await instance.database;
    try {
      return await db.update(
        'users',
        {'status': status.name}, // status.name menghasilkan string 'hadir', 'izin', dll
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      debugPrint("Error updateAttendance: $e");
      return 0;
    }
  }
}
