import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// Import file main.dart để dùng chung các class Prescription và MedicineDetail
import 'main.dart'; 

class DatabaseHelper {
  // Tạo singleton để đảm bảo chỉ có 1 kết nối DB được mở
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mediremind.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        // Bật tính năng Khóa ngoại (Foreign Keys) cho SQLite
        await db.execute('PRAGMA foreign_keys = ON'); 
      },
      onCreate: _createDB,
    );
  }

  // TẠO CÁC BẢNG (TABLES) THEO ĐÚNG THIẾT KẾ TUẦN 3
  Future _createDB(Database db, int version) async {
    // 1. Bảng Đơn Thuốc
    await db.execute('''
      CREATE TABLE don_thuoc (
        id TEXT PRIMARY KEY,
        title TEXT,
        start_date TEXT,
        end_date TEXT
      )
    ''');

    // 2. Bảng Chi Tiết Thuốc
    await db.execute('''
      CREATE TABLE chi_tiet_thuoc (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        don_thuoc_id TEXT,
        name TEXT,
        total_stock INTEGER,
        morning_dose INTEGER,
        midday_dose INTEGER,
        evening_dose INTEGER,
        morning_time TEXT,
        midday_time TEXT,
        evening_time TEXT,
        FOREIGN KEY (don_thuoc_id) REFERENCES don_thuoc (id) ON DELETE CASCADE
      )
    ''');

    // 3. Bảng Nhật Ký Uống Thuốc (Lịch sử)
    await db.execute('''
      CREATE TABLE nhat_ky_uong (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        don_thuoc_id TEXT,
        date TEXT,
        history_key TEXT,
        FOREIGN KEY (don_thuoc_id) REFERENCES don_thuoc (id) ON DELETE CASCADE
      )
    ''');
  }

  // ==========================================
  // CÁC HÀM API XỬ LÝ DỮ LIỆU (CRUD)
  // ==========================================

  // 1. THÊM HOẶC CẬP NHẬT ĐƠN THUỐC (INSERT / UPDATE)
  Future<void> savePrescription(Prescription p) async {
    final db = await instance.database;

    // Bắt đầu một Transaction (đảm bảo nếu lỗi thì không bị lưu thiếu dữ liệu)
    await db.transaction((txn) async {
      // Lưu thông tin chung vào bảng don_thuoc
      await txn.insert('don_thuoc', {
        'id': p.id,
        'title': p.title,
        'start_date': p.startDate.toIso8601String(),
        'end_date': p.endDate.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace); // Nếu trùng ID thì ghi đè (Cập nhật)

      // Xóa chi tiết thuốc và lịch sử cũ (nếu đang sửa đơn) để chèn cái mới
      await txn.delete('chi_tiet_thuoc', where: 'don_thuoc_id = ?', whereArgs: [p.id]);
      await txn.delete('nhat_ky_uong', where: 'don_thuoc_id = ?', whereArgs: [p.id]);

      // Lưu danh sách thuốc vào bảng chi_tiet_thuoc
      for (var med in p.medicines) {
        var medMap = med.toMap();
        await txn.insert('chi_tiet_thuoc', {
          'don_thuoc_id': p.id,
          'name': medMap['name'],
          'total_stock': medMap['totalStock'],
          'morning_dose': medMap['mDose'],
          'midday_dose': medMap['midDose'],
          'evening_dose': medMap['eDose'],
          'morning_time': medMap['mTime'],
          'midday_time': medMap['midTime'],
          'evening_time': medMap['eTime'],
        });
      }

      // Lưu lịch sử uống vào bảng nhat_ky_uong
      p.history.forEach((date, keys) {
        for (var key in keys) {
          txn.insert('nhat_ky_uong', {
            'don_thuoc_id': p.id,
            'date': date,
            'history_key': key,
          });
        }
      });
    });
  }

  // 2. LẤY TOÀN BỘ DANH SÁCH (SELECT)
  Future<List<Prescription>> getAllPrescriptions() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('don_thuoc');
    List<Prescription> result = [];

    for (var map in maps) {
      String id = map['id'];

      // Lấy danh sách thuốc của đơn này
      final medMaps = await db.query('chi_tiet_thuoc', where: 'don_thuoc_id = ?', whereArgs: [id]);
      List<MedicineDetail> medicines = medMaps.map((m) => MedicineDetail.fromMap({
        'name': m['name'], 'totalStock': m['total_stock'],
        'mDose': m['morning_dose'], 'midDose': m['midday_dose'], 'eDose': m['evening_dose'],
        'mTime': m['morning_time'], 'midTime': m['midday_time'], 'eTime': m['evening_time'],
      })).toList();

      // Lấy lịch sử uống của đơn này
      final historyMaps = await db.query('nhat_ky_uong', where: 'don_thuoc_id = ?', whereArgs: [id]);
      Map<String, List<String>> history = {};
      for (var h in historyMaps) {
        String date = h['date'] as String;
        String key = h['history_key'] as String;
        if (!history.containsKey(date)) history[date] = [];
        history[date]!.add(key);
      }

      // Đóng gói lại thành Object Prescription
      result.add(Prescription(
        id: id,
        title: map['title'],
        startDate: DateTime.parse(map['start_date']),
        endDate: DateTime.parse(map['end_date']),
        medicines: medicines,
        history: history,
      ));
    }
    return result;
  }

  // 3. XÓA ĐƠN THUỐC (DELETE)
  Future<void> deletePrescription(String id) async {
    final db = await instance.database;
    // Nhờ cấu hình ON DELETE CASCADE, xóa don_thuoc sẽ tự động xóa sạch thuốc và lịch sử con
    await db.delete('don_thuoc', where: 'id = ?', whereArgs: [id]); 
  }
}