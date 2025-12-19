// lib/domain/sensor.dart

class Sensor {
  final String name;           // Tên cảm biến
  final String type;           // Loại cảm biến
  final double value;          // Giá trị hiện tại (số)
  final SensorStatus status;   // Trạng thái cảnh báo
  final DateTime? timestamp;   // Thời gian cập nhật (có thể null)

  Sensor({
    required this.name,
    required this.type,
    required this.value,
    this.status = SensorStatus.normal,
    this.timestamp,
  });
}

// Enum trạng thái cảm biến
enum SensorStatus {
  normal,  // Bình thường
  alert,   // Cảnh báo
}

// Extension tiện hiển thị chữ trên UI
extension SensorStatusExtension on SensorStatus {
  String get label {
    switch (this) {
      case SensorStatus.normal:
        return "Bình thường";
      case SensorStatus.alert:
        return "Cảnh báo";
    }
  }

  // Color có thể dùng trực tiếp trong UI
  int get colorValue {
    switch (this) {
      case SensorStatus.normal:
        return 0xFF4CAF50; // xanh lá
      case SensorStatus.alert:
        return 0xFFF44336; // đỏ
    }
  }
}
