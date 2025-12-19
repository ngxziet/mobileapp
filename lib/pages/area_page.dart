import 'package:flutter/material.dart';
import '../domain/area.dart';
import '../data/db/area_db.dart';
import '../widgets/info_card.dart';
import '../widgets/sensor_card.dart';
import '../widgets/add_sensor_dialog.dart';
import '../domain/sensor.dart';
import '../data/repository/tcp.dart';

class AreaPage extends StatefulWidget {
  final Area area;

  const AreaPage({Key? key, required this.area}) : super(key: key);

  @override
  _AreaPageState createState() => _AreaPageState();
}

class _AreaPageState extends State<AreaPage> {
  List<Sensor> sensors = [];
  bool _isLoading = false; // ✅ THÊM LOADING STATE

  @override
  void initState() {
    super.initState();
    loadSensors();

    // 🔌 Kết nối ESP32 với error handling
    _connectToESP32();
  }

  void _connectToESP32() async {
    try {
      await esp32Client.connect();


      // 🔔 Khi ESP32 gửi dữ liệu mới → reload lại DB
      esp32Client.onDataUpdated = () {
        print("🔄 Nhận tín hiệu cập nhật từ ESP32, load lại sensor...");
        loadSensors();
      };
    } catch (e) {
      print("❌ Lỗi kết nối ESP32: $e");
    }
  }

  void loadSensors() async {
    if (_isLoading) return; // ✅ TRÁNH GỌI NHIỀU LẦN

    setState(() => _isLoading = true);

    try {
      final db = AreaDatabase.instance;
      List<Sensor> data = await db.getSensors(widget.area.name);

      setState(() {
        sensors = data;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Lỗi load sensors: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tính số cảnh báo trong khu vực
    int alerts = sensors.where((s) => s.status == SensorStatus.alert).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: const [
            Icon(Icons.bar_chart, color: Colors.blue),
            SizedBox(width: 8),
            Text('Quản Lý Khu Vực', style: TextStyle(color: Colors.black)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.grey[700]),
            onPressed: () {},
          ),
          const CircleAvatar(child: Text('AD'), backgroundColor: Colors.blue),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.area.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.area.description,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // Hiển thị loading khi đang tải
              if (_isLoading) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 20),
              ],

              // Hàng 2 InfoCard
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InfoCard(
                      title: 'Tổng cảm biến',
                      value: sensors.length
                          .toString(), // ✅ DÙNG sensors.length THAY VÌ widget.area.sensorCount
                      color: Colors.orange,
                      icon: Icons.sensors,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InfoCard(
                      title: 'Số cảnh báo',
                      value: alerts.toString(),
                      color: Colors.red,
                      icon: Icons.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Hàng 2 nút
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => AddSensorDialog(
                            areaName: widget.area.name,
                            onUpdated:
                                loadSensors, // ✅ TRUYỀN loadSensors LÀM CALLBACK
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Thêm cảm biến',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.black),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Quay lại',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Danh sách SensorCard
              if (sensors.isEmpty && !_isLoading) ...[
                const Center(
                  child: Text(
                    "Chưa có cảm biến nào",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ] else ...[
                Wrap(
                  spacing: 4,
                  runSpacing: 6,
                  children: sensors.map((sensor) {
                    return SensorCard(
                      sensor: sensor,
                      onDelete: () async {
                        bool? confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Xác nhận xóa"),
                            content: Text(
                              "Bạn có chắc muốn xóa cảm biến '${sensor.name}' không?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Hủy"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  "Xóa",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          final db = AreaDatabase.instance;
                          await db.deleteSensor(sensor.name, widget.area.name);
                          loadSensors(); // ✅ RELOAD LẠI DANH SÁCH

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Đã xóa cảm biến '${sensor.name}'"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
