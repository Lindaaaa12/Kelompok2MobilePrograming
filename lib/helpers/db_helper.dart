import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';

class DbHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'preskom_v2.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            className TEXT,
            status TEXT DEFAULT 'none'
          )
        ''');
      },
    );
  }

  // Simpan Siswa Baru
  Future<int> insertStudent(Student student) async {
    Database db = await database;
    return await db.insert(
      'students',
      {
        'name': student.name,
        'className': student.className,
        'status': student.status.name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Ambil Siswa Berdasarkan Kelas
  Future<List<Student>> getStudentsByClass(String className) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'className = ?',
      whereArgs: [className],
    );

    if (maps.isEmpty) return [];

    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  // PERBAIKAN: Tambahkan fungsi updateStudentStatus ini
  Future<int> updateStudentStatus(int id, String statusName) async {
    Database db = await database;
    return await db.update(
      'students',
      {'status': statusName}, // Mengupdate kolom status
      where: 'id = ?',        // Berdasarkan ID siswa
      whereArgs: [id],
    );
  }
}
