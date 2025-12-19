import 'dart:io';
import 'dart:convert';
import '../db/area_db.dart';

class ESP32Client {
  late Socket _socket;
  Function()? onDataUpdated;

  Future<void> connect() async {
    try {
      print("🔌 Kết nối đến ESP32...");
      _socket = await Socket.connect(
        '192.168.4.1',
        8080,
      ); // ⚠️ Đổi IP & PORT theo ESP32 của bạn
      print("✅ Đã kết nối với ESP32");

      _socket.listen(
        (data) async {
          final message = utf8.decode(data).trim();
          print("📡 Nhận dữ liệu: $message");

          try {
            // ✅ Thử parse JSON từ ESP32
            final jsonData = json.decode(message);

            if (jsonData is Map && jsonData['type'] == 'sensors') {
              final db = AreaDatabase.instance;

              if (jsonData.containsKey('temperature')) {
                final temp = (jsonData['temperature'] as num).toDouble();
                await db.updateSensorValue('temperature', temp);
                print("💾 Đã lưu temperature = $temp vào DB");
              }

              if (jsonData.containsKey('humidity')) {
                final hum = (jsonData['humidity'] as num).toDouble();
                await db.updateSensorValue('humidity', hum);
                print("💾 Đã lưu humidity = $hum vào DB");
              }

              // 🔹 Callback để UI cập nhật lại
              if (onDataUpdated != null) onDataUpdated!();
            }
          } catch (e) {
            // 🔹 Nếu không phải JSON, fallback sang kiểu cũ "sensor:value"
            if (message.contains(':')) {
              final parts = message.split(':');
              final sensorName = parts[0];
              final sensorValue = double.tryParse(parts[1]) ?? 0;

              final db = AreaDatabase.instance;
              await db.updateSensorValue(sensorName, sensorValue);

              print("💾 Đã lưu $sensorName = $sensorValue vào DB");

              if (onDataUpdated != null) onDataUpdated!();
            } else {
              print("⚠️ Dữ liệu không hợp lệ hoặc không nhận dạng được!");
            }
          }
        },
        onError: (error) {
          print("⚠️ Lỗi ESP32: $error");
        },
        onDone: () {
          print("❌ Mất kết nối ESP32");
        },
      );
    } catch (e) {
      print("🚫 Không thể kết nối đến ESP32: $e");
    }
  }

  void send(String message) {
    try {
      _socket.write(message);
      print("📤 Gửi dữ liệu: $message");
    } catch (e) {
      print("⚠️ Lỗi gửi dữ liệu: $e");
    }
  }

  void disconnect() {
    _socket.destroy();
    print("🔌 Ngắt kết nối ESP32");
  }
}

// ✅ Singleton
final esp32Client = ESP32Client();
