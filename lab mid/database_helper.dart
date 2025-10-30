import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:doctor_app/theme/theme.dart';
import 'package:doctor_app/model/patient_model.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _db;
  Future<Database> get database async => _db ??= await _initDB();

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, kDBName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $kTablePatients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        phone TEXT NOT NULL,
        notes TEXT,
        imagePath TEXT,
        docPaths TEXT
      )
    ''');
  }

  Future<int> insertPatient(Patient p) async {
    final db = await database;
    return await db.insert(kTablePatients, p.toMap());
  }

  Future<List<Patient>> getAllPatients() async {
    final db = await database;
    final rows = await db.query(kTablePatients, orderBy: 'id DESC');
    return rows.map((r) => Patient.fromMap(r)).toList();
  }

  Future<int> updatePatient(Patient p) async {
    final db = await database;
    return await db
        .update(kTablePatients, p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> deletePatient(int id) async {
    final db = await database;
    return await db.delete(kTablePatients, where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
