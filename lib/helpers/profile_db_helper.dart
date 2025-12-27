import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProfileDbHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  _initDb() async {
    String path = join(await getDatabasesPath(), 'profile_teacher.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE teacher_profile (
            email TEXT PRIMARY KEY,
            name TEXT,
            phone TEXT,
            nip TEXT,
            jabatan TEXT,
            image_path TEXT,
            password TEXT 
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          try {
            await db.execute("ALTER TABLE teacher_profile ADD COLUMN password TEXT");
          } catch (e) {
            print("Kolom password mungkin sudah ada: $e");
          }
        }
      },
    );
  }

  // Digunakan saat REGISTER (Mendaftar akun baru)
  Future<void> saveProfile(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'teacher_profile',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- SOLUSI UTAMA AGAR DATA TIDAK TERHAPUS ---
  // Gunakan fungsi ini di halaman Profil saat ganti foto/update data
  Future<int> updateProfile(String email, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      'teacher_profile',
      data,
      where: 'email = ?',
      // Gunakan trim untuk menghindari kesalahan spasi yang tidak disengaja
      whereArgs: [email.trim()],
    );
  }

  // Ambil data untuk Validasi Login & Tampilan Profil
  Future<Map<String, dynamic>?> getProfileByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'teacher_profile',
      where: 'email = ?',
      whereArgs: [email.trim()],
    );
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  // Ambil data berdasarkan NIP untuk validasi Register
  Future<Map<String, dynamic>?> getProfileByNip(String nip) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'teacher_profile',
      where: 'nip = ?',
      whereArgs: [nip.trim()],
    );
    if (maps.isNotEmpty) return maps.first;
    return null;
  }
}
