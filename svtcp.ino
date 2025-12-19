#include <WiFi.h>
#include <ArduinoJson.h>

// WiFi Access Point
const char* ssid = "ESP32_AP";
const char* password = "12345678";

WiFiServer server(8080);
bool sendingEnabled = false;  // Biến điều khiển gửi dữ liệu

// 🔥 SỬA: Biến để kiểm soát thời gian gửi dữ liệu
unsigned long previousSendMillis = 0;
const long sendInterval = 1000;  // Gửi mỗi 1 giây

// 🔥 THÊM: Biến để kiểm tra client timeout
unsigned long lastClientActivity = 0;
const long clientTimeout = 10000;  // 10 giây timeout

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("====================================");
  Serial.println("🚀 KHỞI ĐỘNG ESP32 SENSOR SERVER");
  Serial.println("====================================");

  randomSeed(analogRead(0));
  WiFi.softAP(ssid, password);
  Serial.print("📡 Wi-Fi Access Point: ");
  Serial.println(ssid);
  Serial.print("🔗 ESP32 IP: ");
  Serial.println(WiFi.softAPIP());

  server.begin();
  Serial.println("✅ TCP Server đã khởi động trên cổng 8080");
  Serial.println("====================================\n");
}

void loop() {
  WiFiClient client = server.available();

  if (client) {
    Serial.println("💻 Client mới đã kết nối!");
    client.println("CONNECTED");
    
    // 🔥 RESET các biến thời gian
    previousSendMillis = 0;
    lastClientActivity = millis();
    sendingEnabled = false;

    while (client.connected()) {
      unsigned long currentMillis = millis();
      
      // 🔥 ƯU TIÊN 1: LUÔN KIỂM TRA LỆNH TỪ CLIENT
      while (client.available() > 0) {
        String cmd = client.readStringUntil('\n');
        cmd.trim();

        if (cmd.length() > 0) {
          Serial.print("📩 Nhận lệnh từ Client: ");
          Serial.println(cmd);
          lastClientActivity = currentMillis; // 🔥 CẬP NHẬT HOẠT ĐỘNG

          if (cmd == "START") {
            sendingEnabled = true;
            previousSendMillis = currentMillis; // Reset timer gửi
            Serial.println("▶️ Bắt đầu gửi dữ liệu cảm biến...");
            client.println("{\"status\":\"SENDING STARTED\"}");
          } 
          else if (cmd == "STOP") {
            sendingEnabled = false;
            Serial.println("⏹ Dừng gửi dữ liệu cảm biến.");
            client.println("{\"status\":\"SENDING STOPPED\"}");
          } 
          else if (cmd == "SENDINGCOMPLETE") {
            Serial.println("✅ Đã nhận được dữ liệu");
            client.println("{\"status\":\"SENDING COMPLETE\"}");
          }
          else if (cmd == "PING") {
            // 🔥 THÊM: Lệnh ping để kiểm tra kết nối
            client.println("{\"status\":\"PONG\"}");
          }
        }
      }

      // 🔥 ƯU TIÊN 2: GỬI DỮ LIỆU NẾU ĐƯỢC BẬT
      if (sendingEnabled && (currentMillis - previousSendMillis >= sendInterval)) {
        previousSendMillis = currentMillis;
        
        int temperature = random(20, 36);
        int humidity = random(40, 90);

        StaticJsonDocument<200> doc;
        doc["type"] = "sensors";
        doc["temperature"] = temperature;
        doc["humidity"] = humidity;
        doc["timestamp"] = currentMillis; // 🔥 THÊM TIMESTAMP

        String jsonString;
        serializeJson(doc, jsonString);
        client.println(jsonString);

        Serial.print("📤 Gửi dữ liệu: ");
        Serial.println(jsonString);
        
        lastClientActivity = currentMillis; // 🔥 CẬP NHẬT HOẠT ĐỘNG
      }

      // 🔥 KIỂM TRA CLIENT TIMEOUT (nếu không có hoạt động trong 10s)
      if (currentMillis - lastClientActivity > clientTimeout) {
        Serial.println("⏰ Client timeout, ngắt kết nối...");
        break;
      }

      // 🔥 SỬA: KHÔNG DÙNG DELAY() - thay bằng kiểm tra nhanh
      // Giữ CPU không quá tải nhưng vẫn responsive
      unsigned long loopStart = millis();
      while (millis() - loopStart < 5) {
        // 🔥 KIỂM TRA LỆNH LIÊN TỤC TRONG 5ms
        if (client.available() > 0) {
          break; // Thoát ngay nếu có lệnh
        }
      }
      
      // 🔥 KIỂM TRA KẾT NỐI
      if (!client.connected()) {
        Serial.println("🔌 Client đã ngắt kết nối.");
        break;
      }
    }

    client.stop();
    sendingEnabled = false; // 🔥 ĐẢM BẢO TẮT GỬI DỮ LIỆU
    Serial.println("🔌 Đã đóng kết nối với client.\n");
  }
}