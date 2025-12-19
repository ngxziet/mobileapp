// lib/widgets/sensor_card.dart
import 'package:flutter/material.dart';
import '../domain/sensor.dart';
import 'package:intl/intl.dart'; // để format timestamp

class SensorCard extends StatelessWidget {
  final Sensor sensor;
  final VoidCallback? onDelete; // nút xóa

  const SensorCard({
    Key? key,
    required this.sensor,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Màu trạng thái
    Color statusColor = Color(sensor.status.colorValue);

    // Tính width để 2 thẻ vừa 1 hàng với padding
    double cardWidth = MediaQuery.of(context).size.width * 0.46;

    // Format thời gian nếu có
    String timestampText = sensor.timestamp != null
        ? DateFormat('HH:mm dd/MM/yyyy').format(sensor.timestamp!)
        : "-";

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên cảm biến
          Text(sensor.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          // Loại cảm biến
          Text("Loại: ${sensor.type}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          // Giá trị hiện tại
          Text("Giá trị: ${sensor.value}", style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          // Trạng thái
          Text("Trạng thái: ${sensor.status.label}",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
          const SizedBox(height: 4),
          // Thời gian cập nhật
          Text("Cập nhật: $timestampText", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          // Hàng cuối: nút xóa
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2), // nền đỏ nhạt
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red), // viền đỏ
              ),
              child: const Text(
                "Xóa cảm biến",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
