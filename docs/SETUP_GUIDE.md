# 📖 Setup Guide — Spoof Sense

This guide walks you through setting up the entire Spoof Sense system from scratch.

---

## Prerequisites

| Requirement | Minimum Version | Purpose |
|-------------|----------------|---------|
| Web Browser | Chrome 90+ / Firefox 88+ / Edge 90+ | Dashboard UI |
| Git | 2.30+ | Version control |
| ESP32 + sensors | See Hardware Guide | Data acquisition |
| Supabase account | Free tier | Database (optional) |

---

## Step 1: Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/SPOOF-SENSE.git
cd SPOOF-SENSE
```

---

## Step 2: Open the Dashboard

No build step is required! Simply open the HTML file:

```bash
# Windows
start src/index.html

# macOS
open src/index.html

# Linux
xdg-open src/index.html
```

The dashboard will automatically start in **Mock Mode**, simulating GPS data with cycling NORMAL → JAMMED → SPOOFED events.

---

## Step 3: Connect ESP32 (Optional)

1. Flash the ESP32 with the firmware (see [HARDWARE_GUIDE.md](HARDWARE_GUIDE.md))
2. Ensure ESP32 and your computer are on the same WiFi network
3. Enter the ESP32's WebSocket URL in the top bar (default: `ws://192.168.1.100:81`)
4. Click **CONNECT**
5. The status pill should change to **LIVE** (green)

---

## Step 4: Setup Supabase Database (Optional)

### 4.1 Create a Supabase Project
1. Go to [supabase.com](https://supabase.com) and sign up / log in
2. Click **New Project**
3. Choose a name, password, and region
4. Wait for the project to initialize

### 4.2 Run the Schema
1. Navigate to **SQL Editor** in your Supabase dashboard
2. Click **New query**
3. Copy and paste the entire contents of [`database/schema.sql`](../database/schema.sql)
4. Click **Run** (or press Ctrl+Enter)
5. Verify: run `SELECT count(*) FROM public.gps_events;` — should return 0

### 4.3 Get API Credentials
1. Go to **Settings → API**
2. Copy the **Project URL** (e.g., `https://xxxx.supabase.co`)
3. Copy the **anon/public key** (starts with `eyJ...`)

### 4.4 Connect Dashboard to Supabase
1. Refresh the dashboard — the Supabase setup modal will appear
2. Paste your **Project URL** and **anon key**
3. Click **CONNECT DB**
4. The DB status strip should show **CONNECTED** with a green indicator

> **Note:** Credentials are saved in your browser's `localStorage`. Clear browser data to reset.

---

## Step 5: Verify Everything Works

| Check | Expected Result |
|-------|----------------|
| Dashboard loads | Map visible with mock data flowing |
| Mock events cycle | Status changes: NORMAL → JAMMED → SPOOFED |
| Charts update | IMU and SNR charts show live data |
| Threat log fills | JAMMED and SPOOFED events appear in the right panel |
| DB records saved | `dbCount` in the DB strip increments (if Supabase connected) |
| Theme toggle | Smooth transition between dark and light themes |
| CSV export | Downloads a `.csv` file with logged threats |

---

## Troubleshooting

| Issue | Solution |
|-------|---------|
| Map tiles not loading | Check internet connection (tiles load from OpenStreetMap CDN) |
| WebSocket won't connect | Verify ESP32 IP address and port, check firewall settings |
| Supabase errors | Verify schema was run successfully, check RLS policies |
| Charts not rendering | Ensure Chart.js CDN is accessible, check browser console |
| Blank screen | Check browser console for JavaScript errors |

---

## Next Steps

- Read [HARDWARE_GUIDE.md](HARDWARE_GUIDE.md) for ESP32 wiring and firmware
- Read [API_REFERENCE.md](API_REFERENCE.md) for WebSocket data format details
- Explore the [database schema](../database/schema.sql) for custom queries
