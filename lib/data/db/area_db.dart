import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/area.dart';
import '../../domain/sensor.dart';

class AreaDatabase {
  static final AreaDatabase instance = AreaDatabase._init();
  static Database? _database;

  AreaDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('area.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final Directory docDir = await getApplicationDocumentsDirectory();
    final String path = join(docDir.path, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Bảng khu vực
    await db.execute('''
      CREATE TABLE areas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        sensorCount INTEGER NOT NULL,
        status INTEGER NOT NULL
      )
    ''');

    // Bảng cảm biến - ĐÃ DẸP TIMESTAMP
    await db.execute('''
      CREATE TABLE sensors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        areaName TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT,
        value REAL,
        status TEXT
      )
    ''');

    // Dữ liệu mẫu ban đầu
    await db.insert('areas', {
      'name': 'Tầng 1 - Khu A',
      'description': 'Khu vực văn phòng chính',
      'sensorCount': 2,
      'status': 0,
    });

    await db.insert('areas', {
      'name': 'Tầng 2 - Khu B',
      'description': 'Khu vực phòng họp',
      'sensorCount': 1,
      'status': 0,
    });

    // Dữ liệu cảm biến - KHÔNG CÒN TIMESTAMP
    await db.insert('sensors', {
      'areaName': 'Tầng 1 - Khu A',
      'name': 'temperature',
      'type': 'Temperature',
      'value': 25.0,
      'status': 'normal',
    });

    await db.insert('sensors', {
      'areaName': 'Tầng 1 - Khu A',
      'name': 'humidity',
      'type': 'Humidity',
      'value': 60.0,
      'status': 'normal',
    });

    await db.insert('sensors', {
      'areaName': 'Tầng 2 - Khu B',
      'name': 'Cảm biến ánh sáng',
      'type': 'Light',
      'value': 300.0,
      'status': 'normal',
    });
  }

  // 🔹 Lấy danh sách khu vực
  Future<List<Area>> getAreas() async {
    final db = await database;
    final result = await db.query('areas');

    // DEBUG: In ra console để kiểm tra
    print('📋 DEBUG getAreas: ${result.length} khu vực');
    for (var area in result) {
      print('🏠 ${area['name']} - ${area['sensorCount']} cảm biến');
    }

    return result.map((json) {
      return Area(
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        sensorCount: json['sensorCount'] as int,
        status: (json['status'] as int) == 0
            ? AreaStatus.normal
            : AreaStatus.alert,
      );
    }).toList();
  }

  // 🔹 Lấy danh sách cảm biến theo khu vực
  Future<List<Sensor>> getSensors(String areaName) async {
    final db = await database;
    final result = await db.query(
      'sensors',
      where: 'areaName = ?',
      whereArgs: [areaName],
    );

    // DEBUG: In ra console để kiểm tra
    print('📟 DEBUG getSensors($areaName): ${result.length} cảm biến');
    for (var sensor in result) {
      print('   🔸 ${sensor['name']}: ${sensor['value']}');
    }

    return result.map((json) {
      return Sensor(
        name: json['name'] as String,
        type: json['type'] as String? ?? 'Unknown',
        value: json['value'] != null ? (json['value'] as num).toDouble() : 0.0,
        status: (json['status'] as String?) == 'normal'
            ? SensorStatus.normal
            : SensorStatus.alert,
        // KHÔNG CÒN TIMESTAMP
      );
    }).toList();
  }

  // 🔹 Thêm khu vực mới
  Future<void> insertArea(Area area) async {
    final db = await database;
    await db.insert('areas', {
      'name': area.name,
      'description': area.description,
      'sensorCount': area.sensorCount,
      'status': area.status == AreaStatus.normal ? 0 : 1,
    });
    print('✅ Đã thêm khu vực: ${area.name}');
  }

  // 🔹 Thêm cảm biến mới - ĐƠN GIẢN HƠN
  Future<void> insertSensor(String areaName, Sensor sensor) async {
    final db = await database;

    await db.insert('sensors', {
      'areaName': areaName,
      'name': sensor.name,
      'type': sensor.type,
      'value': sensor.value,
      'status': sensor.status == SensorStatus.normal ? 'normal' : 'alert',
      // KHÔNG CÒN TIMESTAMP
    });

    // Cập nhật sensor count
    await updateAreaSensorCount(areaName);
    print('✅ Đã thêm cảm biến: ${sensor.name} cho $areaName');
  }

  // 🔹 Lấy tổng số cảm biến
  Future<int> getTotalSensors() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM sensors');
    final total = Sqflite.firstIntValue(result) ?? 0;
    print('🔢 DEBUG getTotalSensors: $total cảm biến');
    return total;
  }

  // 🔹 Cập nhật giá trị cảm biến theo tên
  Future<void> updateSensorValue(String sensorName, double newValue) async {
    final db = await database;
    final count = await db.update(
      'sensors',
      {'value': newValue}, // KHÔNG CÒN TIMESTAMP
      where: 'name = ?',
      whereArgs: [sensorName],
    );

    if (count > 0) {
      print('🔄 Đã cập nhật cảm biến "$sensorName" => $newValue');
    } else {
      print('⚠️ Không tìm thấy cảm biến "$sensorName" để cập nhật!');
    }
  }

  // 🔹 Cập nhật số lượng cảm biến cho khu vực
  Future<void> updateAreaSensorCount(String areaName) async {
    final db = await database;

    // Đếm số sensor thực tế
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM sensors WHERE areaName = ?',
      [areaName],
    );
    final int count = Sqflite.firstIntValue(result) ?? 0;

    // Cập nhật sensorCount trong bảng areas
    await db.update(
      'areas',
      {'sensorCount': count},
      where: 'name = ?',
      whereArgs: [areaName],
    );
    print('🔢 Đã cập nhật sensorCount cho $areaName: $count cảm biến');
  }

  // 🔹 Xóa khu vực (và toàn bộ cảm biến bên trong)
  Future<void> deleteArea(String areaName) async {
    final db = await database;
    await db.delete('sensors', where: 'areaName = ?', whereArgs: [areaName]);
    await db.delete('areas', where: 'name = ?', whereArgs: [areaName]);
    print('🗑️ Đã xóa khu vực: $areaName');
  }

  // 🔹 Xóa cảm biến
  Future<void> deleteSensor(String name, String areaName) async {
    final db = await database;
    await db.delete('sensors', where: 'name = ?', whereArgs: [name]);

    // ✅ CẬP NHẬT LẠI SENSOR COUNT
    await updateAreaSensorCount(areaName);
    print('🗑️ Đã xóa cảm biến: $name');
  }

  // 🔹 Kiểm tra xem cảm biến đã tồn tại chưa
  Future<bool> sensorExists(String sensorName) async {
    final db = await database;
    final result = await db.query(
      'sensors',
      where: 'name = ?',
      whereArgs: [sensorName],
    );
    return result.isNotEmpty;
  }

  // 🔹 Đóng database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
