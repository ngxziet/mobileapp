// lib/domain/area.dart

// Lớp Area dùng để đại diện cho một khu vực trong hệ thống
class Area {
  final String name;          // Tên khu vực, ví dụ: "Tầng 1 - Khu A"
  final String description;   // Mô tả chi tiết khu vực, ví dụ: "Khu vực văn phòng chính"
  final int sensorCount;      // Số lượng cảm biến được lắp đặt trong khu vực
  final AreaStatus status;    // Trạng thái cảnh báo hiện tại của khu vực (bình thường hoặc cảnh báo)

  // Constructor bắt buộc nhập tên, mô tả, số cảm biến.
  // Trạng thái mặc định là bình thường (AreaStatus.normal)
  Area({
    required this.name,
    required this.description,
    required this.sensorCount,
    this.status = AreaStatus.normal,
  });
}

// Enum AreaStatus định nghĩa trạng thái của khu vực
enum AreaStatus {
  normal,   // Bình thường, không có cảnh báo
  alert,    // Cảnh báo, có vấn đề cần chú ý
}

// Extension tiện ích để chuyển AreaStatus thành chuỗi hiển thị dễ đọc
extension AreaStatusExtension on AreaStatus {
  String get label {
    switch (this) {
      case AreaStatus.normal:
        return "Bình thường"; // Chuỗi hiển thị cho trạng thái normal
      case AreaStatus.alert:
        return "Cảnh báo";   // Chuỗi hiển thị cho trạng thái alert
    }
  }
}
