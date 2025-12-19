// lib/widgets/add_area_dialog.dart
import 'package:flutter/material.dart';
import '../domain/area.dart';
import '../data/db/area_db.dart';

class AddAreaDialog extends StatefulWidget {
  final VoidCallback onUpdated; // callback khi DB cập nhật để HomePage reload

  const AddAreaDialog({Key? key, required this.onUpdated}) : super(key: key);

  @override
  _AddAreaDialogState createState() => _AddAreaDialogState();
}

class _AddAreaDialogState extends State<AddAreaDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  bool isLoading = false; // trạng thái khi lưu DB

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white, // nền trắng
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thêm khu vực mới",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text("Tên khu vực"),
            TextField(controller: nameController),
            const SizedBox(height: 12),
            Text("Mô tả"),
            TextField(controller: descController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // nền xanh dương
                      foregroundColor: Colors.white, // chữ trắng
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            String name = nameController.text.trim();
                            String desc = descController.text.trim();
                            if (name.isEmpty) return;

                            setState(() => isLoading = true);

                            // tạo Area mới
                            Area newArea = Area(
                              name: name,
                              description: desc,
                              sensorCount: 0,
                              status: AreaStatus.normal,
                            );

                            // lưu vào database
                            await AreaDatabase.instance.insertArea(newArea);

                            // thông báo HomePage reload lại danh sách
                            widget.onUpdated();

                            // đóng dialog
                            Navigator.pop(context);
                          },
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Tạo"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: const Text("Hủy"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
