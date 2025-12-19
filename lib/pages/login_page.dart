import 'package:flutter/material.dart';
import '../pages/home_page.dart'; // import trang HomePage để chuyển sang sau khi đăng nhập

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState(); // tạo state cho LoginPage
}

class _LoginPageState extends State<LoginPage> {
  // Controller để lấy dữ liệu từ TextField
  final TextEditingController usernameController = TextEditingController(
    text: "admin",
  ); // giá trị mặc định là "admin"
  final TextEditingController passwordController = TextEditingController(
    text: "123456",
  ); // giá trị mặc định là "123456"

  // Username và Password đúng để kiểm tra
  final String correctUsername = "admin";
  final String correctPassword = "123456";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8EEFA), // màu nền của trang
      body: Center(
        // căn giữa nội dung
        child: Container(
          width: 350, // chiều rộng cố định
          padding: EdgeInsets.all(24), // khoảng cách bên trong container
          decoration: BoxDecoration(
            color: Colors.white, // nền trắng
            borderRadius: BorderRadius.circular(16), // bo góc 16
            boxShadow: [
              // thêm bóng mờ (đổ bóng)
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // column chỉ chiếm không gian con
            children: [
              // Logo hoặc biểu tượng đầu trang
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue, // nền xanh
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bar_chart,
                  size: 40,
                  color: Colors.white,
                ), // icon biểu tượng
              ),
              SizedBox(height: 16), // khoảng cách
              Text(
                'Quản Lý Khu Vực', // tiêu đề
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4), // khoảng cách nhỏ
              Text(
                'Đăng nhập để truy cập hệ thống giám sát', // mô tả
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600], // màu xám
                ),
                textAlign: TextAlign.center, // căn giữa
              ),
              SizedBox(height: 24), // khoảng cách trước TextField
              // TextField nhập Username
              TextField(
                controller: usernameController, // gắn controller
                decoration: InputDecoration(
                  labelText: 'Tên đăng nhập', // nhãn
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), // bo góc ô nhập
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ), // padding bên trong
                ),
              ),
              SizedBox(height: 16), // khoảng cách giữa 2 TextField
              // TextField nhập Password
              TextField(
                controller: passwordController, // gắn controller
                obscureText: true, // ẩn mật khẩu
                decoration: InputDecoration(
                  labelText: 'Mật khẩu', // nhãn
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), // bo góc
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ), // padding bên trong
                ),
              ),
              SizedBox(height: 24), // khoảng cách trước nút đăng nhập
              // Nút Đăng Nhập
              SizedBox(
                width: double.infinity, // chiếm toàn bộ chiều ngang
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // màu nền nút
                    padding: EdgeInsets.symmetric(vertical: 14), // padding nút
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // bo góc nút
                    ),
                  ),
                  child: Text('Đăng Nhập', style: TextStyle(fontSize: 16)),
                  onPressed: () {
                    // Lấy dữ liệu từ TextField
                    String username = usernameController.text;
                    String password = passwordController.text;

                    // Kiểm tra thông tin đăng nhập
                    if (username == correctUsername &&
                        password == correctPassword) {
                      // Đúng username và password, chuyển sang HomePage
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    } else {
                      // Sai thông tin, hiển thị cảnh báo
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Lỗi đăng nhập"), // tiêu đề cảnh báo
                          content: Text(
                            "Tên đăng nhập hoặc mật khẩu không đúng!",
                          ), // nội dung
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context), // đóng hộp thoại
                              child: Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
