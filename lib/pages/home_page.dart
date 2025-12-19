import 'package:flutter/material.dart';
import '../data/db/area_db.dart';
import '../widgets/info_card.dart';
import '../widgets/area_card.dart';
import '../domain/area.dart';
import '../pages/area_page.dart';
import '../pages/login_page.dart';
import '../widgets/add_area_dialog.dart';
import '../data/repository/tcp.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Area> areas = [];
  int totalSensors = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _connectToESP32();
  }

  /// 🔹 Khởi tạo dữ liệu
  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadAreas(), _loadTotalSensors()]);
    setState(() => _isLoading = false);
  }

  /// 🔹 Kết nối ESP32
  void _connectToESP32() async {
    try {
      await esp32Client.connect();
      print("✅ Đã kết nối ESP32 từ HomePage");
    } catch (e) {
      print("❌ Lỗi kết nối ESP32: $e");
    }
  }

  /// 🔹 Load tổng cảm biến
  Future<void> _loadTotalSensors() async {
    final count = await AreaDatabase.instance.getTotalSensors();
    setState(() => totalSensors = count);
  }

  /// 🔹 Load danh sách khu vực
  Future<void> _loadAreas() async {
    final data = await AreaDatabase.instance.getAreas();
    setState(() => areas = data);
  }

  /// 🔹 Reload toàn bộ dữ liệu
  Future<void> _reloadAll() async {
    await Future.wait([_loadAreas(), _loadTotalSensors()]);
  }

  /// 🔹 Xử lý khi switch thay đổi - CHỈ CHO "khuvuc1"
  void _handleSwitchChanged(bool value, Area area) {
    // ✅ CHỈ xử lý nếu là khu vực "khuvuc1"
    print('🔍 DEBUG: Switch ${area.name} thay đổi thành: $value');
    if (area.name == "khuvuc1") {
      if (value) {
        // Switch = true (sang phải) → Gửi START (bật gửi dữ liệu)
        print('🚀 Gửi lệnh START cho ${area.name}');
        esp32Client.send('START\n');
      } else {
        // Switch = false (sang trái) → Gửi STOP (tắt gửi dữ liệu)
        print('🛑 Gửi lệnh STOP cho ${area.name}');
        esp32Client.send('STOP\n');
      }
    } else {
      // ✅ Các khu vực khác không làm gì cả
      print('ℹ️ Switch của ${area.name} được thay đổi, nhưng không gửi lệnh');
    }
  }

  /// 🔹 Xử lý xóa khu vực
  Future<void> _handleDeleteArea(Area area) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa khu vực "${area.name}" không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AreaDatabase.instance.deleteArea(area.name);
        await _reloadAll();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Đã xóa khu vực "${area.name}"'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Lỗi khi xóa: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 🔹 Điều hướng đến trang chi tiết khu vực
  Future<void> _navigateToAreaPage(Area area) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AreaPage(area: area)),
    );
    await _reloadAll();
  }

  @override
  Widget build(BuildContext context) {
    final totalAlerts = areas.where((a) => a.status == AreaStatus.alert).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.blue),
            SizedBox(width: 8),
            Text('Quản Lý Khu Vực', style: TextStyle(color: Colors.black)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              child: Text('AD', style: TextStyle(fontSize: 12)),
              backgroundColor: Colors.blue,
            ),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Đăng xuất'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Quản lý khu vực',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Theo dõi và quản lý các khu vực',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: InfoCard(
                          title: 'Tổng khu vực',
                          value: areas.length.toString(),
                          color: Colors.blue,
                          icon: Icons.apartment,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InfoCard(
                          title: 'Tổng cảm biến',
                          value: totalSensors.toString(),
                          color: Colors.orange,
                          icon: Icons.sensors,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InfoCard(
                          title: 'Số cảnh báo',
                          value: totalAlerts.toString(),
                          color: Colors.red,
                          icon: Icons.warning,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Nút thêm khu vực
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AddAreaDialog(onUpdated: _reloadAll),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Thêm khu vực mới',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Danh sách khu vực
                  Expanded(
                    child: areas.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.apartment,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Chưa có khu vực nào",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 0.85,
                                ),
                            itemCount: areas.length,
                            itemBuilder: (context, index) {
                              final area = areas[index];
                              return AreaCard(
                                area: area,
                                onTap: () => _navigateToAreaPage(area),
                                onSwitchChanged: (value) =>
                                    _handleSwitchChanged(value, area),
                                onDelete: () => _handleDeleteArea(area),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
