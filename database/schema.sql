-- ============================================================
--  SPOOF SENSE — Supabase Database Schema
--  Run this entire file in your Supabase SQL Editor
--  Project: GPS Spoofing & Jamming Detection Dashboard
-- ============================================================

-- ── TABLE: gps_events ──────────────────────────────────────────
-- Stores every threat event (JAMMED or SPOOFED) captured by
-- the dashboard from the ESP32 WebSocket stream.

create table if not exists public.gps_events (
  id          bigserial primary key,

  -- Classification
  status      text not null check (status in ('NORMAL', 'JAMMED', 'SPOOFED')),

  -- GPS data
  latitude    double precision not null,
  longitude   double precision not null,
  speed_mps   double precision default 0,
  satellites  integer default 0,
  hdop        double precision default 0,

  -- IMU data
  ax          double precision default 0,
  ay          double precision default 0,
  az          double precision default 0,
  gx          double precision default 0,
  gy          double precision default 0,
  gz          double precision default 0,

  -- Signal quality
  snr         double precision default 0,

  -- Metadata
  device_id   text default 'esp32-01',
  created_at  timestamptz not null default now()
);

-- ── INDEX for fast time-range queries ─────────────────────────
create index if not exists idx_gps_events_created_at
  on public.gps_events (created_at desc);

create index if not exists idx_gps_events_status
  on public.gps_events (status);

-- ── ROW LEVEL SECURITY ────────────────────────────────────────
alter table public.gps_events enable row level security;

-- Allow anonymous inserts (dashboard pushes data)
create policy "anon_insert" on public.gps_events
  for insert to anon
  with check (true);

-- Allow anonymous selects (dashboard reads data)
create policy "anon_select" on public.gps_events
  for select to anon
  using (true);

-- ── TABLE: daily_stats ────────────────────────────────────────
-- Aggregated daily summary (updated by DB trigger)

create table if not exists public.daily_stats (
  id            bigserial primary key,
  stat_date     date not null unique default current_date,
  total_events  integer default 0,
  normal_count  integer default 0,
  jammed_count  integer default 0,
  spoofed_count integer default 0,
  avg_sats      double precision default 0,
  avg_hdop      double precision default 0,
  avg_snr       double precision default 0,
  updated_at    timestamptz default now()
);

alter table public.daily_stats enable row level security;

create policy "anon_select_stats" on public.daily_stats
  for select to anon using (true);

create policy "anon_insert_stats" on public.daily_stats
  for insert to anon with check (true);

create policy "anon_update_stats" on public.daily_stats
  for update to anon using (true);

-- ── TRIGGER: auto-update daily_stats on new gps_event ─────────
create or replace function public.update_daily_stats()
returns trigger language plpgsql as $$
begin
  insert into public.daily_stats (
    stat_date, total_events,
    normal_count, jammed_count, spoofed_count,
    avg_sats, avg_hdop, avg_snr, updated_at
  )
  values (
    current_date, 1,
    case when NEW.status = 'NORMAL'  then 1 else 0 end,
    case when NEW.status = 'JAMMED'  then 1 else 0 end,
    case when NEW.status = 'SPOOFED' then 1 else 0 end,
    NEW.satellites, NEW.hdop, NEW.snr, now()
  )
  on conflict (stat_date) do update set
    total_events  = daily_stats.total_events  + 1,
    normal_count  = daily_stats.normal_count  + case when NEW.status = 'NORMAL'  then 1 else 0 end,
    jammed_count  = daily_stats.jammed_count  + case when NEW.status = 'JAMMED'  then 1 else 0 end,
    spoofed_count = daily_stats.spoofed_count + case when NEW.status = 'SPOOFED' then 1 else 0 end,
    avg_sats      = (daily_stats.avg_sats  * daily_stats.total_events + NEW.satellites) / (daily_stats.total_events + 1),
    avg_hdop      = (daily_stats.avg_hdop  * daily_stats.total_events + NEW.hdop)       / (daily_stats.total_events + 1),
    avg_snr       = (daily_stats.avg_snr   * daily_stats.total_events + NEW.snr)        / (daily_stats.total_events + 1),
    updated_at    = now();
  return NEW;
end;
$$;

create trigger trg_update_daily_stats
  after insert on public.gps_events
  for each row execute function public.update_daily_stats();

-- ── VIEW: recent_threats ──────────────────────────────────────
-- Handy view for last 100 threat events (not NORMAL)

create or replace view public.recent_threats as
  select
    id, status, latitude, longitude,
    speed_mps, satellites, hdop, snr,
    device_id, created_at
  from public.gps_events
  where status != 'NORMAL'
  order by created_at desc
  limit 100;

-- ── VIEW: threat_heatmap ──────────────────────────────────────
-- For loading heatmap data on dashboard startup

create or replace view public.threat_heatmap as
  select
    latitude, longitude, status,
    count(*) as event_count
  from public.gps_events
  where status != 'NORMAL'
    and created_at >= now() - interval '7 days'
  group by latitude, longitude, status;

-- ── SAMPLE VERIFY ─────────────────────────────────────────────
-- Run these to verify setup:
-- select count(*) from public.gps_events;
-- select * from public.daily_stats;
-- select * from public.recent_threats limit 5;

-- ============================================================
--  SETUP COMPLETE
--  Next steps:
--  1. Copy your Supabase Project URL from Settings > API
--  2. Copy your anon/public key from Settings > API
--  3. Enter both in the dashboard modal on first load
--  4. Done — threats auto-save to gps_events table
-- ============================================================
