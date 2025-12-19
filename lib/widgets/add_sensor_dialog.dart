import 'package:flutter/material.dart';
import '../domain/sensor.dart';
import '../data/db/area_db.dart';

class AddSensorDialog extends StatefulWidget {
  final String areaName;
  final VoidCallback onUpdated;

  const AddSensorDialog({
    Key? key,
    required this.areaName,
    required this.onUpdated,
  }) : super(key: key);

  @override
  State<AddSensorDialog> createState() => _AddSensorDialogState();
}

class _AddSensorDialogState extends State<AddSensorDialog> {
  final TextEditingController nameController = TextEditingController();
  String selectedType = "Temperature";
  bool isLoading = false;

  Future<void> _createSensor() async {
    final String name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập tên cảm biến"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final newSensor = Sensor(
        name: name,
        type: selectedType,
        value: 0.0,
        status: SensorStatus.normal,
        // KHÔNG CÒN TIMESTAMP
      );

      await AreaDatabase.instance.insertSensor(widget.areaName, newSensor);

      widget.onUpdated(); // cập nhật lại danh sách ở AreaPage
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã thêm cảm biến mới"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("❌ Lỗi thêm cảm biến: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi thêm cảm biến: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Thêm cảm biến mới",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text("Tên cảm biến"),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Nhập tên cảm biến",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Loại cảm biến"),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                    value: "Temperature",
                    child: Text("Temperature"),
                  ),
                  DropdownMenuItem(value: "Humidity", child: Text("Humidity")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _createSensor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Tạo",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.black),
                      ),
                      child: const Text(
                        "Hủy",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
