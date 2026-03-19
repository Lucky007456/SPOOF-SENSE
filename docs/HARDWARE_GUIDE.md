# 🔧 Hardware Guide — Spoof Sense

Complete hardware setup guide for the Spoof Sense GPS threat detection system.

---

## Components Required

| # | Component | Model / Spec | Approx. Cost (USD) | Purchase |
|---|-----------|-------------|--------------------:|----------|
| 1 | Microcontroller | ESP32 DevKit V1 (38-pin) | $5–8 | Amazon, AliExpress |
| 2 | GPS Module | u-blox NEO-6M with antenna | $6–10 | Amazon, AliExpress |
| 3 | IMU Sensor | MPU6050 (GY-521 breakout) | $2–4 | Amazon, AliExpress |
| 4 | GPS Antenna | 25×25mm ceramic active antenna | Included with NEO-6M | — |
| 5 | Breadboard | Half-size (400 tie points) | $2 | Amazon |
| 6 | Jumper Wires | M-M and M-F, 10cm | $2 | Amazon |
| 7 | USB Cable | Micro-USB (data + power) | $2 | Amazon |
| 8 | (Optional) Battery | 3.7V LiPo 1000mAh + TP4056 | $4 | Amazon |

**Total estimated cost: ~$20–30 USD**

---

## Wiring Diagram

### NEO-6M GPS → ESP32

| NEO-6M Pin | ESP32 Pin | Wire Color (Suggested) |
|-----------|-----------|----------------------|
| VCC | 3.3V | 🔴 Red |
| GND | GND | ⚫ Black |
| TX | GPIO 16 (RX2) | 🟢 Green |
| RX | GPIO 17 (TX2) | 🟡 Yellow |

### MPU6050 IMU → ESP32

| MPU6050 Pin | ESP32 Pin | Wire Color (Suggested) |
|------------|-----------|----------------------|
| VCC | 3.3V | 🔴 Red |
| GND | GND | ⚫ Black |
| SDA | GPIO 21 (SDA) | 🔵 Blue |
| SCL | GPIO 22 (SCL) | 🟣 Purple |
| INT | (Not connected) | — |

### Connection Overview

```
     ┌────────────────────────┐
     │       ESP32 DevKit     │
     │                        │
     │  3.3V ──┬──────────┐   │
     │         │          │   │
     │  GND ──┬┤──────┐   │   │
     │        ││      │   │   │
     │  G16 ──┼┼──┐   │   │   │
     │  G17 ──┼┼──┼─┐ │   │   │
     │  G21 ──┼┼──┼─┼─┼─┐ │   │
     │  G22 ──┼┼──┼─┼─┼─┼─┐   │
     └────────┼┼──┼─┼─┼─┼─┼───┘
              ││  │ │ │ │ │
     ┌────────┼┼──┼─┼─┘ │ │
     │ NEO-6M ││  │ │   │ │
     │  VCC ──┘│  │ │   │ │
     │  GND ───┘  │ │   │ │
     │  TX ───────┘ │   │ │
     │  RX ─────────┘   │ │
     └───────────────────┘ │
     ┌─────────────────────┘
     │ MPU6050
     │  VCC ── 3.3V (shared)
     │  GND ── GND (shared)
     │  SDA ── G21
     │  SCL ── G22
     └────────────────────
```

---

## ESP32 Firmware

### Required Arduino Libraries

Install these via Arduino IDE Library Manager:

| Library | Version | Purpose |
|---------|---------|---------|
| `TinyGPS++` | 1.0+ | GPS NMEA parsing |
| `MPU6050_light` | 1.1+ | IMU data reading |
| `WebSocketsServer` | 2.4+ | WebSocket server |
| `ArduinoJson` | 7.0+ | JSON serialization |
| `Wire` | Built-in | I2C communication |

### Firmware Sketch

```cpp
#include <WiFi.h>
#include <WebSocketsServer.h>
#include <ArduinoJson.h>
#include <TinyGPS++.h>
#include <Wire.h>
#include <MPU6050_light.h>

// ── WiFi Config ─────────────────────────────────
const char* WIFI_SSID = "YOUR_WIFI_SSID";
const char* WIFI_PASS = "YOUR_WIFI_PASSWORD";

// ── Objects ─────────────────────────────────────
WebSocketsServer ws(81);
TinyGPSPlus gps;
MPU6050 mpu(Wire);
HardwareSerial gpsSerial(2);  // UART2: RX=16, TX=17

// ── Detection Thresholds ────────────────────────
const int   MIN_SATS      = 3;
const float MAX_HDOP      = 10.0;
const float MAX_SPEED     = 83.0;   // ~300 km/h
const float IMU_MISMATCH  = 5.0;    // m/s
const int   FIX_TIMEOUT   = 10000;  // ms

unsigned long lastFix = 0;

void setup() {
  Serial.begin(115200);
  gpsSerial.begin(9600, SERIAL_8N1, 16, 17);

  // IMU
  Wire.begin();
  mpu.begin();
  mpu.calcOffsets();

  // WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected: " + WiFi.localIP().toString());

  // WebSocket
  ws.begin();
  ws.onEvent(wsEvent);
}

void loop() {
  ws.loop();

  // Read GPS
  while (gpsSerial.available()) {
    gps.encode(gpsSerial.read());
  }

  // Read IMU
  mpu.update();

  // Send data every 1 second
  static unsigned long lastSend = 0;
  if (millis() - lastSend >= 1000) {
    lastSend = millis();
    sendData();
  }
}

String detectStatus(float spd, int sats, float hdop, float imuSpd) {
  // Jamming checks
  if (sats < MIN_SATS) return "JAMMED";
  if (hdop > MAX_HDOP) return "JAMMED";
  if (millis() - lastFix > FIX_TIMEOUT) return "JAMMED";

  // Spoofing checks
  if (spd > MAX_SPEED) return "SPOOFED";
  if (abs(spd - imuSpd) > IMU_MISMATCH) return "SPOOFED";

  return "NORMAL";
}

void sendData() {
  float lat = gps.location.isValid() ? gps.location.lat() : 0;
  float lng = gps.location.isValid() ? gps.location.lng() : 0;
  float spd = gps.speed.isValid()    ? gps.speed.mps()    : 0;
  int   sat = gps.satellites.isValid()? gps.satellites.value(): 0;
  float hdp = gps.hdop.isValid()     ? gps.hdop.hdop()    : 99;

  if (gps.location.isUpdated()) lastFix = millis();

  float imuSpd = sqrt(pow(mpu.getAccX(), 2) +
                      pow(mpu.getAccY(), 2));

  String status = detectStatus(spd, sat, hdp, imuSpd);

  JsonDocument doc;
  doc["status"]     = status;
  doc["lat"]        = lat;
  doc["lng"]        = lng;
  doc["speed_mps"]  = spd;
  doc["satellites"] = sat;
  doc["hdop"]       = hdp;
  doc["ax"]         = mpu.getAccX();
  doc["ay"]         = mpu.getAccY();
  doc["az"]         = mpu.getAccZ();
  doc["gx"]         = mpu.getGyroX();
  doc["gy"]         = mpu.getGyroY();
  doc["gz"]         = mpu.getGyroZ();
  doc["snr"]        = 0;  // Requires custom NMEA parsing
  doc["timestamp"]  = millis();

  String json;
  serializeJson(doc, json);
  ws.broadcastTXT(json);
}

void wsEvent(uint8_t num, WStype_t type, uint8_t* payload, size_t length) {
  if (type == WStype_CONNECTED) {
    Serial.printf("Client %u connected\n", num);
  }
}
```

### Upload Steps

1. Open **Arduino IDE** → File → Preferences
2. Add ESP32 board URL: `https://dl.espressif.com/dl/package_esp32_index.json`
3. Install **ESP32** board from Board Manager
4. Select board: **ESP32 Dev Module**
5. Install all required libraries from Library Manager
6. Update `WIFI_SSID` and `WIFI_PASS` in the sketch
7. Connect ESP32 via USB
8. Select correct COM port
9. Click **Upload**

---

## Testing Without GPS Lock

If testing indoors without GPS satellite reception:
- The dashboard will automatically enter **Mock Mode**
- Or connect the ESP32 — it will send data with `lat=0, lng=0` until outdoor GPS lock

---

## Power Options

| Option | Description |
|--------|-------------|
| USB | Simplest — connect to laptop/PC |
| Power Bank | Portable — any 5V USB power bank |
| LiPo + TP4056 | Compact — 3.7V LiPo with charging module |
| Car 12V adapter | Vehicle mount — 12V → 5V USB converter |

---

## Safety Notes

⚠️ **GPS Jamming is illegal in most jurisdictions.** This project is designed for **detection only** — to identify when your GPS signal is being attacked. Never use this project to jam or spoof GPS signals.
