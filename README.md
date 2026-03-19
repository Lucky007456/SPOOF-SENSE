<div align="center">

<img src="assets/banner.png" alt="Spoof Sense Banner" width="100%"/>

# 🛡️ SPOOF SENSE

### Real-Time GPS Spoofing & Jamming Detection System

[![License: MIT](https://img.shields.io/badge/License-MIT-00d4ff.svg?style=for-the-badge)](LICENSE)
[![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)](src/index.html)
[![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)](src/style.css)
[![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)](src/index.html)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](database/schema.sql)
[![Leaflet](https://img.shields.io/badge/Leaflet-199900?style=for-the-badge&logo=leaflet&logoColor=white)](https://leafletjs.com)
[![Chart.js](https://img.shields.io/badge/Chart.js-FF6384?style=for-the-badge&logo=chartdotjs&logoColor=white)](https://www.chartjs.org)

**A military-grade, real-time GPS threat monitoring dashboard that detects jamming and spoofing attacks using ESP32 hardware, IMU telemetry, and machine learning heuristics.**

[🚀 Live Demo](#quick-start) · [📖 Documentation](#documentation) · [🔧 Hardware Setup](#hardware-requirements) · [🐛 Report Bug](https://github.com/issues)

---

</div>

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Quick Start](#-quick-start)
- [Hardware Requirements](#-hardware-requirements)
- [Supabase Setup](#-supabase-database-setup)
- [How Detection Works](#-how-detection-works)
- [Dashboard Panels](#-dashboard-panels)
- [Configuration](#-configuration)
- [API Reference](#-api-reference)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌐 Overview

**Spoof Sense** is an advanced, browser-based GPS threat detection platform designed to identify and alert users about GPS **jamming** (signal blocking) and **spoofing** (fake signal injection) attacks in real-time.

The system connects to an **ESP32 microcontroller** via WebSocket, which streams live GPS, IMU (accelerometer + gyroscope), and signal quality data. The dashboard applies real-time heuristic analysis to classify the GPS signal state as **NORMAL**, **JAMMED**, or **SPOOFED**, and logs all threat events to a **Supabase** PostgreSQL database for persistent storage and historical analysis.

> **Why does this matter?** GPS spoofing and jamming attacks are increasingly common threats targeting drones, autonomous vehicles, fleet management systems, and critical infrastructure. Spoof Sense provides an affordable, open-source solution for detection and monitoring.

---

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🗺️ **Live Threat Map** | Full-screen Leaflet map with real-time marker tracking, trail visualization, and threat zone rings |
| 🔥 **Threat Heatmap** | Dynamic heatmap overlay showing threat concentration areas over time |
| 📊 **IMU Telemetry Charts** | Real-time accelerometer, gyroscope, and speed comparison charts (60-sample rolling window) |
| 📡 **Signal Strength Monitor** | Live SNR (Signal-to-Noise Ratio) chart for satellite signal quality tracking |
| 🎯 **Threat Level Meter** | Visual threat level indicator with gradient bar (0–100%) |
| 🔔 **Toast Notifications** | Instant color-coded alerts for state transitions (Normal → Jammed → Spoofed) |
| 📝 **Threat Event Log** | Scrollable, filterable log of all detected threats with timestamps and coordinates |
| 💾 **Supabase Integration** | Automatic threat event persistence with daily aggregation triggers |
| 📤 **CSV Export** | One-click export of all logged threat events to CSV format |
| 🌙 **Dark/Light Theme** | Premium dual-theme UI with smooth transitions and persistent preference |
| 🤖 **Mock Data Mode** | Built-in simulation mode for testing without hardware |
| 📱 **Responsive Design** | Adaptive glass-morphism panels over the full-screen map |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        SPOOF SENSE SYSTEM                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐    WebSocket     ┌──────────────────────────┐ │
│  │   ESP32 MCU  │ ──────────────── │   Browser Dashboard      │ │
│  │              │   JSON Stream    │                          │ │
│  │  ┌────────┐  │                  │  ┌────────────────────┐  │ │
│  │  │ NEO-6M │  │  GPS + IMU Data  │  │  Detection Engine  │  │ │
│  │  │  GPS   │  │ ───────────────► │  │  (Heuristic AI)    │  │ │
│  │  └────────┘  │                  │  └────────┬───────────┘  │ │
│  │  ┌────────┐  │                  │           │              │ │
│  │  │ MPU6050│  │                  │  ┌────────▼───────────┐  │ │
│  │  │  IMU   │  │                  │  │  Visualization     │  │ │
│  │  └────────┘  │                  │  │  • Leaflet Map     │  │ │
│  └──────────────┘                  │  │  • Chart.js Graphs │  │ │
│                                    │  │  • Threat Log      │  │ │
│                                    │  └────────┬───────────┘  │ │
│                                    │           │              │ │
│                                    └───────────┼──────────────┘ │
│                                                │                │
│                                    ┌───────────▼──────────────┐ │
│                                    │   Supabase PostgreSQL    │ │
│                                    │  • gps_events table      │ │
│                                    │  • daily_stats (trigger) │ │
│                                    │  • recent_threats view   │ │
│                                    │  • threat_heatmap view   │ │
│                                    └──────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | HTML5, CSS3, Vanilla JS | Core dashboard UI |
| **Mapping** | Leaflet.js + Leaflet.heat | Interactive map & heatmap |
| **Charts** | Chart.js 4.x | Real-time data visualization |
| **Database** | Supabase (PostgreSQL) | Persistent event storage |
| **Hardware** | ESP32 + NEO-6M GPS + MPU6050 IMU | Data acquisition |
| **Protocol** | WebSocket | Real-time data streaming |
| **Fonts** | Orbitron + JetBrains Mono | Military-tech aesthetic |
| **Design** | Glassmorphism + CSS Variables | Premium dark/light themes |

---

## 📁 Project Structure

```
SPOOF-SENSE/
│
├── src/                          # Source code
│   ├── index.html                # Main dashboard (HTML + JS)
│   └── style.css                 # Complete stylesheet (dark/light themes)
│
├── database/                     # Database layer
│   └── schema.sql                # Supabase PostgreSQL schema
│                                 #   • gps_events table
│                                 #   • daily_stats table + trigger
│                                 #   • recent_threats view
│                                 #   • threat_heatmap view
│                                 #   • Row Level Security policies
│
├── docs/                         # Documentation
│   ├── SETUP_GUIDE.md            # Detailed setup instructions
│   ├── HARDWARE_GUIDE.md         # Hardware wiring & ESP32 firmware
│   └── API_REFERENCE.md          # WebSocket message format & DB API
│
├── assets/                       # Static assets
│   └── banner.png                # Project banner image
│
├── .gitignore                    # Git ignore rules
├── LICENSE                       # MIT License
├── CONTRIBUTING.md               # Contribution guidelines
└── README.md                     # This file
```

---

## 🚀 Quick Start

### Option 1: Instant Demo (No Hardware)

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/SPOOF-SENSE.git
cd SPOOF-SENSE

# 2. Open the dashboard
# Simply open src/index.html in your browser
start src/index.html          # Windows
open src/index.html           # macOS
xdg-open src/index.html       # Linux
```

> The dashboard automatically enters **Mock Mode** when no ESP32 is connected, generating simulated GPS events so you can explore the full UI.

### Option 2: Live Hardware Connection

```bash
# 1. Flash ESP32 with the firmware (see docs/HARDWARE_GUIDE.md)
# 2. Connect ESP32 to your WiFi network
# 3. Open the dashboard and enter WebSocket URL
#    Default: ws://192.168.1.100:81
# 4. Click CONNECT
```

### Option 3: With Supabase Persistence

```bash
# 1. Create a Supabase project at https://supabase.com
# 2. Run database/schema.sql in the SQL Editor
# 3. Open the dashboard — enter your Project URL + anon key
# 4. All threat events are now auto-saved to PostgreSQL
```

---

## 🔧 Hardware Requirements

| Component | Model | Purpose | Qty |
|-----------|-------|---------|-----|
| Microcontroller | ESP32 DevKit V1 | WiFi + WebSocket server | 1 |
| GPS Module | u-blox NEO-6M | Position, speed, HDOP, satellite data | 1 |
| IMU Sensor | MPU6050 | Accelerometer + Gyroscope (6-axis) | 1 |
| Antenna | GPS active antenna | Satellite signal reception | 1 |
| Power | USB cable / LiPo battery | Power supply | 1 |
| Wires | Jumper wires | Connections | ~10 |

> 📖 See [docs/HARDWARE_GUIDE.md](docs/HARDWARE_GUIDE.md) for detailed wiring diagrams and ESP32 firmware code.

---

## 💾 Supabase Database Setup

### 1. Create Project
Go to [supabase.com](https://supabase.com) → New Project → Note your **Project URL** and **anon key**.

### 2. Run Schema

Open the **SQL Editor** in your Supabase dashboard and paste the contents of [`database/schema.sql`](database/schema.sql).

This creates:

| Object | Type | Description |
|--------|------|-------------|
| `gps_events` | Table | Stores every GPS event with IMU data |
| `daily_stats` | Table | Auto-aggregated daily statistics |
| `update_daily_stats()` | Trigger | Auto-updates daily_stats on each insert |
| `recent_threats` | View | Last 100 non-NORMAL events |
| `threat_heatmap` | View | 7-day threat location aggregation |

### 3. Connect Dashboard
On first load, enter your **Project URL** and **anon key** in the setup modal. Credentials are saved in `localStorage` for auto-reconnect.

---

## 🧠 How Detection Works

### Jamming Detection
GPS jamming involves broadcasting noise on GPS frequencies (L1: 1575.42 MHz) to overwhelm receivers.

| Indicator | Threshold | Description |
|-----------|-----------|-------------|
| Satellite Count | < 3 | Too few satellites for valid fix |
| HDOP | > 10.0 | Horizontal dilution of precision exceeded |
| SNR | < 15 dB | Signal-to-noise ratio below usable level |
| Fix Age | > 10s | No valid GPS fix for extended period |

### Spoofing Detection
GPS spoofing involves broadcasting fake GPS signals to deceive the receiver into reporting a false position.

| Indicator | Threshold | Description |
|-----------|-----------|-------------|
| Speed | > 300 km/h (83 m/s) | Exceeds physical speed limits |
| GPS vs IMU Velocity | Δ > 5 m/s | Mismatch between GPS-reported and IMU-calculated speed |
| Position Jump | > 100m/s | Sudden impossible position change |
| HDOP Pattern | Constant low | Unusually perfect signal (too good to be true) |

---

## 📊 Dashboard Panels

### Top Bar
- **SPOOF_SENSE** logo with connection controls
- WebSocket URL input with CONNECT/DISCONNECT
- Connection status pill (LIVE / MOCK / RETRYING / OFFLINE)
- Real-time counters: Normal | Jammed | Spoofed | Uptime
- Dark/Light theme toggle

### Left Panel
- **Signal Status** — Current state with animated icon, HDOP, satellites, speed, coordinates
- **Threat Level Meter** — Gradient bar showing 0–100% threat assessment
- **Signal Strength Chart** — Rolling SNR graph (30 samples)
- **Today's Stats** — Total events, uptime %, jam/spoof counts, avg satellites/HDOP

### Right Panel
- **Threat Log** — Live scrolling event log with severity badges
- **Export CSV** — Download all logged events
- **DB Sync Badge** — Shows events loaded from Supabase

### Bottom Panel
- **IMU Telemetry** — Three real-time charts:
  - Accelerometer X/Y/Z (m/s²)
  - Gyroscope X/Y/Z (rad/s)
  - Speed Comparison: GPS vs IMU estimate

### Map Layer
- **Full-screen OpenStreetMap** with dark theme filter
- **Live position marker** with color-coded status
- **Trail markers** showing movement history (25 points)
- **Threat zone rings** around jam/spoof locations
- **Heatmap overlay** showing threat concentration

---

## ⚙️ Configuration

### WebSocket Data Format
The ESP32 must send JSON over WebSocket in this format:

```json
{
  "status": "NORMAL",
  "lat": 13.0827,
  "lng": 80.2707,
  "speed_mps": 2.4,
  "satellites": 9,
  "hdop": 1.2,
  "ax": 0.12,
  "ay": -0.34,
  "az": 9.81,
  "gx": 0.01,
  "gy": -0.02,
  "gz": 0.005,
  "snr": 35.0,
  "timestamp": 1710864000000
}
```

### Theme Persistence
Theme preference is stored in `localStorage` as `ss-theme` (`dark` | `light`).

### Supabase Credentials
Saved in `localStorage` as `sb-url` and `sb-key`. Clear browser data to reset.

---

## 📡 API Reference

### WebSocket Messages

| Field | Type | Description |
|-------|------|-------------|
| `status` | string | `NORMAL` / `JAMMED` / `SPOOFED` |
| `lat` | float | Latitude in decimal degrees |
| `lng` | float | Longitude in decimal degrees |
| `speed_mps` | float | GPS ground speed in m/s |
| `satellites` | int | Number of visible satellites |
| `hdop` | float | Horizontal Dilution of Precision |
| `ax`, `ay`, `az` | float | Accelerometer readings (m/s²) |
| `gx`, `gy`, `gz` | float | Gyroscope readings (rad/s) |
| `snr` | float | Signal-to-Noise Ratio (dB) |
| `timestamp` | long | Unix epoch milliseconds |

### Supabase Tables

See [`database/schema.sql`](database/schema.sql) for full schema with indexes, triggers, views, and RLS policies.

---

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Lakshmanan R**
- GitHub: [@lakshmanan-r](https://github.com/lakshmanan-r)

---

<div align="center">

**Built with ❤️ for GPS Security Research**

⭐ Star this repo if you find it useful!

</div>
