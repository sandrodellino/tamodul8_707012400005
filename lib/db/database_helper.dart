import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/pembacaan_sensor.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const namaTabel = 'pembacaan_sensor';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'aiot_peringatan_dini.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pembacaan_sensor (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jenis_sensor TEXT NOT NULL,
            nilai REAL NOT NULL,
            lokasi_pos TEXT NOT NULL,
            waktu TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // CREATE: INSERT INTO pembacaan_sensor ...
  Future<int> tambahPembacaan(PembacaanSensor pembacaan) async {
    final db = await database;
    return db.insert(namaTabel, pembacaan.toMap());
  }

  // READ: SELECT * FROM pembacaan_sensor ORDER BY waktu DESC
  Future<List<PembacaanSensor>> ambilSemuaPembacaan() async {
    final db = await database;
    final hasil = await db.query(namaTabel, orderBy: 'waktu DESC, id DESC');
    return hasil.map((baris) => PembacaanSensor.fromMap(baris)).toList();
  }

  // READ: pembacaan terbaru untuk setiap jenis sensor (dasar status siaga)
  Future<Map<String, PembacaanSensor>> ambilPembacaanTerbaruPerJenis() async {
    final db = await database;
    final hasil = await db.rawQuery('''
      SELECT * FROM pembacaan_sensor AS p
      WHERE p.id = (
        SELECT p2.id FROM pembacaan_sensor AS p2
        WHERE p2.jenis_sensor = p.jenis_sensor
        ORDER BY p2.waktu DESC, p2.id DESC
        LIMIT 1
      )
    ''');
    return {
      for (final baris in hasil)
        baris['jenis_sensor'] as String: PembacaanSensor.fromMap(baris),
    };
  }

  // UPDATE: UPDATE pembacaan_sensor SET nilai = ? WHERE id = ?
  Future<int> ubahNilaiPembacaan(int id, double nilaiBaru) async {
    final db = await database;
    return db.update(
      namaTabel,
      {'nilai': nilaiBaru},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE: DELETE FROM pembacaan_sensor WHERE id = ?
  Future<int> hapusPembacaan(int id) async {
    final db = await database;
    return db.delete(namaTabel, where: 'id = ?', whereArgs: [id]);
  }
}
