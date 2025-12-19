// lib/widgets/area_card.dart
import 'package:flutter/material.dart';
import '../domain/area.dart';

// ✅ Chuyển StatelessWidget thành StatefulWidget để switch có trạng thái
class AreaCard extends StatefulWidget {
  final Area area;
  final VoidCallback? onTap; // Nhấn vào card
  final ValueChanged<bool>? onSwitchChanged; // Switch
  final VoidCallback? onDelete; // Icon thùng rác

  const AreaCard({
    Key? key,
    required this.area,
    this.onTap,
    this.onSwitchChanged,
    this.onDelete,
  }) : super(key: key);

  @override
  _AreaCardState createState() => _AreaCardState();
}

class _AreaCardState extends State<AreaCard> {
  // ✅ Thêm biến cục bộ để lưu trạng thái switch
  late bool switchValue;

  @override
  void initState() {
    super.initState();
    // ✅ Khởi tạo switchValue dựa trên trạng thái Area
    switchValue = widget.area.status == AreaStatus.alert;
  }

  @override
  Widget build(BuildContext context) {
    // Màu trạng thái
    Color statusColor = widget.area.status == AreaStatus.normal
        ? Colors.green
        : Colors.red;

    // Tính width để 2 thẻ vừa 1 hàng với padding
    double cardWidth = MediaQuery.of(context).size.width * 0.46;

    return GestureDetector(
      onTap: widget.onTap, // Nhấn card
      child: Container(
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
            // Tên khu vực
            Text(
              widget.area.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            // Mô tả khu vực
            Text(
              widget.area.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            // Số cảm biến
            Text(
              "${widget.area.sensorCount} cảm biến",
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(
              height: 4,
            ), // khoảng cách giữa số cảm biến và trạng thái
            // Trạng thái dạng “chip”
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2), // nền nhạt
                border: Border.all(color: statusColor), // viền
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.area.status.label,
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Hàng cuối: Switch + Icon thùng rác
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ✅ Switch có trạng thái cục bộ, cập nhật UI khi nhấn
                Switch(
                  value: switchValue,
                  onChanged: (value) {
                    setState(() {
                      switchValue = value; // cập nhật trạng thái cục bộ
                    });
                    if (widget.onSwitchChanged != null) {
                      widget.onSwitchChanged!(value); // gọi callback nếu có
                    }
                  },
                  activeColor: Colors.blue,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                // Icon thùng rác (chưa implement logic)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
