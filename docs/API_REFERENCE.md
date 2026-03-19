# 📡 API Reference — Spoof Sense

Complete reference for the WebSocket communication protocol and Supabase database API.

---

## WebSocket Protocol

### Connection

```
URL: ws://<ESP32_IP>:81
Protocol: WebSocket (RFC 6455)
Data Format: JSON (UTF-8)
Interval: 1 message per second
Direction: Server (ESP32) → Client (Browser)
```

### Message Schema

```json
{
  "status":     "NORMAL | JAMMED | SPOOFED",
  "lat":        13.0827,
  "lng":        80.2707,
  "speed_mps":  2.4,
  "satellites": 9,
  "hdop":       1.2,
  "ax":         0.12,
  "ay":        -0.34,
  "az":         9.81,
  "gx":         0.01,
  "gy":        -0.02,
  "gz":         0.005,
  "snr":        35.0,
  "imu_speed":  2.1,
  "timestamp":  1710864000000
}
```

### Field Reference

| Field | Type | Unit | Range | Description |
|-------|------|------|-------|-------------|
| `status` | `string` | — | `NORMAL`, `JAMMED`, `SPOOFED` | Current GPS classification |
| `lat` | `float` | degrees | -90 to 90 | WGS84 latitude |
| `lng` | `float` | degrees | -180 to 180 | WGS84 longitude |
| `speed_mps` | `float` | m/s | 0 to 300+ | GPS ground speed |
| `satellites` | `int` | count | 0 to 32 | Visible GPS satellites |
| `hdop` | `float` | — | 0 to 100 | Horizontal Dilution of Precision |
| `ax` | `float` | m/s² | -16 to 16 | Accelerometer X-axis |
| `ay` | `float` | m/s² | -16 to 16 | Accelerometer Y-axis |
| `az` | `float` | m/s² | -16 to 16 | Accelerometer Z-axis (~9.81 at rest) |
| `gx` | `float` | rad/s | -2000 to 2000 | Gyroscope X-axis |
| `gy` | `float` | rad/s | -2000 to 2000 | Gyroscope Y-axis |
| `gz` | `float` | rad/s | -2000 to 2000 | Gyroscope Z-axis |
| `snr` | `float` | dB | 0 to 50 | Signal-to-Noise Ratio |
| `imu_speed` | `float` | m/s | 0+ | IMU-estimated speed (optional) |
| `timestamp` | `long` | ms | Unix epoch | Event timestamp |

---

## Supabase Database API

### Tables

#### `gps_events`
Primary event storage table.

```sql
CREATE TABLE public.gps_events (
  id          BIGSERIAL PRIMARY KEY,
  status      TEXT NOT NULL CHECK (status IN ('NORMAL', 'JAMMED', 'SPOOFED')),
  latitude    DOUBLE PRECISION NOT NULL,
  longitude   DOUBLE PRECISION NOT NULL,
  speed_mps   DOUBLE PRECISION DEFAULT 0,
  satellites  INTEGER DEFAULT 0,
  hdop        DOUBLE PRECISION DEFAULT 0,
  ax          DOUBLE PRECISION DEFAULT 0,
  ay          DOUBLE PRECISION DEFAULT 0,
  az          DOUBLE PRECISION DEFAULT 0,
  gx          DOUBLE PRECISION DEFAULT 0,
  gy          DOUBLE PRECISION DEFAULT 0,
  gz          DOUBLE PRECISION DEFAULT 0,
  snr         DOUBLE PRECISION DEFAULT 0,
  device_id   TEXT DEFAULT 'esp32-01',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

#### `daily_stats`
Auto-aggregated daily summary (updated by trigger).

```sql
CREATE TABLE public.daily_stats (
  id            BIGSERIAL PRIMARY KEY,
  stat_date     DATE NOT NULL UNIQUE DEFAULT CURRENT_DATE,
  total_events  INTEGER DEFAULT 0,
  normal_count  INTEGER DEFAULT 0,
  jammed_count  INTEGER DEFAULT 0,
  spoofed_count INTEGER DEFAULT 0,
  avg_sats      DOUBLE PRECISION DEFAULT 0,
  avg_hdop      DOUBLE PRECISION DEFAULT 0,
  avg_snr       DOUBLE PRECISION DEFAULT 0,
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);
```

### Views

#### `recent_threats`
Last 100 non-NORMAL events.

```sql
SELECT * FROM public.recent_threats;
```

#### `threat_heatmap`
7-day threat location aggregation for heatmap rendering.

```sql
SELECT latitude, longitude, status, event_count
FROM public.threat_heatmap;
```

### Indexes

| Index | Table | Column(s) | Purpose |
|-------|-------|-----------|---------|
| `idx_gps_events_created_at` | `gps_events` | `created_at DESC` | Fast time-range queries |
| `idx_gps_events_status` | `gps_events` | `status` | Fast status filtering |

### Row Level Security

All tables have RLS enabled with anonymous access policies:

| Policy | Table | Operation | Rule |
|--------|-------|-----------|------|
| `anon_insert` | `gps_events` | INSERT | Allow all |
| `anon_select` | `gps_events` | SELECT | Allow all |
| `anon_select_stats` | `daily_stats` | SELECT | Allow all |
| `anon_insert_stats` | `daily_stats` | INSERT | Allow all |
| `anon_update_stats` | `daily_stats` | UPDATE | Allow all |

### Supabase JavaScript Client Usage

```javascript
// Initialize
const supabase = window.supabase.createClient(
  'https://xxxx.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
);

// Insert event
const { error } = await supabase.from('gps_events').insert([{
  status:     'JAMMED',
  latitude:   13.0827,
  longitude:  80.2707,
  speed_mps:  0,
  satellites: 1,
  hdop:       15.2,
  ax: 0.1, ay: -0.2, az: 9.8,
  gx: 0.01, gy: -0.01, gz: 0.005,
  snr: 8.5,
  created_at: new Date().toISOString()
}]);

// Query today's events
const today = new Date();
today.setHours(0, 0, 0, 0);

const { data, error } = await supabase
  .from('gps_events')
  .select('*')
  .gte('created_at', today.toISOString())
  .order('created_at', { ascending: false })
  .limit(200);

// Get daily stats
const { data: stats } = await supabase
  .from('daily_stats')
  .select('*')
  .eq('stat_date', new Date().toISOString().split('T')[0])
  .single();
```

---

## Detection Thresholds

These thresholds are used by the ESP32 firmware for classification:

| Parameter | Threshold | Triggers |
|-----------|-----------|----------|
| `satellites` | < 3 | JAMMED |
| `hdop` | > 10.0 | JAMMED |
| Fix age | > 10s | JAMMED |
| `speed_mps` | > 83 m/s (300 km/h) | SPOOFED |
| GPS-IMU velocity delta | > 5 m/s | SPOOFED |

---

## Error Handling

### WebSocket Errors
- On connection failure → auto-fallback to Mock Mode
- On disconnect → auto-retry every 3 seconds
- On invalid JSON → silently ignored

### Supabase Errors
- On connection failure → dashboard continues in local-only mode
- On insert failure → DB dot turns red, event still shown in UI
- Credentials saved in `localStorage` for auto-reconnect
