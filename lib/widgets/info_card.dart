import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;   // Tiêu đề của thẻ, ví dụ: "Tổng Khu Vực"
  final String value;   // Giá trị hiển thị, ví dụ: "3" hoặc "5"
  final Color color;   // Màu chủ đạo cho icon và giá trị
  final IconData icon;   // Icon hiển thị trên thẻ

  // Constructor bắt buộc các tham số
  const InfoCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, // chiều rộng cố định
      padding: EdgeInsets.all(12), // khoảng cách bên trong
      decoration: BoxDecoration(
        color: Colors.white, // nền trắng
        borderRadius: BorderRadius.circular(12), // bo góc
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)], // bóng mờ nhẹ
      ),
      child: Column(
        children: [
          Icon(icon, color: color), // icon màu chủ đạo
          SizedBox(height: 8), // khoảng cách giữa icon và tiêu đề
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]), // tiêu đề nhỏ, màu xám
            textAlign: TextAlign.center, // căn giữa
          ),
          SizedBox(height: 4), // khoảng cách giữa tiêu đề và giá trị
          Text(
            value,
            style: TextStyle(
              fontSize: 16, // font lớn hơn
              fontWeight: FontWeight.bold, // in đậm
              color: color, // màu chủ đạo
            ),
          ),
        ],
      ),
    );
  }
}
