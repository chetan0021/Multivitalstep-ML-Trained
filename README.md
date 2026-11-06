# VitalStep — Palm Pressure Measurement App

> **SP4 Ameya Innovation Labs Private Limited**  
> Bangalore, Karnataka, India  
> Contact: engineeringameya@gmail.com

---

## What This Is

VitalStep is a Flutter mobile application for clinical palm pressure (grip strength) measurement. It connects to an ESP32-based physical device, collects 3-trial pressure readings per session, runs ML-powered analysis, and syncs data to both HubSpot CRM and Supabase.

The project currently has **two parallel versions**:

| Version | Backend | Device | Status |
|---|---|---|---|
| **App v1** (existing) | Digital Ocean | Old ESP32 (no display) | ✅ Live |
| **App v2** (in development) | Supabase | ESP32-3248S035 (3.5" 320×480 touchscreen) | 🚧 In Progress |

---

## Quick Start

### Prerequisites
- Flutter SDK ≥ 3.0.3
- Android Studio or VS Code with Flutter extension
- Android device or emulator

### Run App v1 (existing, Digital Ocean backend)
```bash
flutter pub get
flutter run
```

### Run App v2 (Supabase backend, new device features)
```bash
flutter pub get
flutter run \
  --dart-define=APP_FLAVOR=v2 \
  --dart-define=ENABLE_DEVICE_SYNC=true \
  --dart-define=PATIENT_SUPABASE_URL=https://cbebmpgsbxqdzpfgqulj.supabase.co \
  --dart-define=PATIENT_SUPABASE_ANON_KEY=<anon_key>
```

### Build Release APK (App v1)
```bash
flutter build apk --release
```

### Build Release APK (App v2)
```bash
flutter build apk --release \
  --dart-define=APP_FLAVOR=v2 \
  --dart-define=ENABLE_DEVICE_SYNC=true \
  --dart-define=PATIENT_SUPABASE_URL=https://cbebmpgsbxqdzpfgqulj.supabase.co \
  --dart-define=PATIENT_SUPABASE_ANON_KEY=<anon_key>
```

---

## Environment Variables (`--dart-define`)

| Variable | App v1 | App v2 | Description |
|---|---|---|---|
| `APP_FLAVOR` | `v1` (default) | `v2` | Which version to build |
| `ENABLE_DEVICE_SYNC` | `false` (default) | `true` | Gates new v2 UI (device pairing, status card) |
| `PATIENT_SUPABASE_URL` | existing default | `https://cbebmpgsbxqdzpfgqulj.supabase.co` | Supabase project URL |
| `PATIENT_SUPABASE_ANON_KEY` | existing default | `<anon_key>` | Supabase publishable key |
| `GROQ_API_KEY` | hardcoded default | hardcoded default | Groq LLM key (never changes) |

> **Never put the Supabase service role key in the app.** It is only used server-side in the Edge Function.

---

## Architecture Overview

```
┌─────────────────────┐     ┌─────────────────────────────────────────┐
│   Flutter App v1    │────▶│  Digital Ocean (backend.sp4ameya.com)   │
│  (existing users)   │     │  /api/auth, /api/user, /api/test, etc.  │
└─────────────────────┘     └─────────────────────────────────────────┘

┌─────────────────────┐     ┌─────────────────────────────────────────┐
│   Flutter App v2    │────▶│  Supabase (cbebmpgsbxqdzpfgqulj)        │
│  (new users)        │     │  devices, measurements, assessments      │
└─────────────────────┘     │  research_patients, patient_readings     │
         │                  └──────────────────┬──────────────────────┘
         │ BLE (WiFi setup only)               │ device-sync Edge Function
         ▼                                     ▼
┌─────────────────────┐     ┌─────────────────────────────────────────┐
│  ESP32-3248S035     │────▶│  HTTPS POST /functions/v1/device-sync   │
│  3.5" Touchscreen   │     │  Auth: x-device-code + x-device-secret  │
│  ST7796 320×480     │     └─────────────────────────────────────────┘
│  LVGL UI            │
│  SD card queue      │     ┌─────────────────────────────────────────┐
│  HX711 load cell    │────▶│  ML Model (vitalstep.onrender.com)      │
└─────────────────────┘     │  POST /api/v1/ml/predict                │
                            └─────────────────────────────────────────┘

                            ┌─────────────────────────────────────────┐
                            │  Groq LLM (api.groq.com)                │
                            │  llama-3.3-70b-versatile                │
                            │  Patient-friendly narrative generation   │
                            └─────────────────────────────────────────┘

                            ┌─────────────────────────────────────────┐
                            │  HubSpot CRM (via vitalstep.onrender)   │
                            │  Patient contact + test reading sync     │
                            └─────────────────────────────────────────┘
```

---

## Project Structure

```
lib/
  app/
    app_config.dart         ← Build flavor flags (App v1 / v2)
    app.router.dart         ← All screen routes
    app.locator.dart        ← Service locator (GetIt)
  services/
    ai_service.dart         ← ML prediction + Groq narrative
    analysis_service.dart   ← Rule-based fallback analysis
    api_calls_service.dart  ← Digital Ocean REST API calls
    ble_provisioning_service.dart  ← BLE WiFi setup for ESP32
    device_service.dart     ← [v2] Supabase device claim/status
    hubspot_service.dart    ← HubSpot CRM sync
    login_service.dart      ← Auth (Digital Ocean)
    measurement_service.dart ← [v2] Supabase measurements
    mode_service.dart       ← Host/Patient mode toggle
    patient_service.dart    ← Research patient CRUD (Supabase)
  ui/
    common/
      app_colors.dart       ← v1 color palette (teal + blue)
      app_colors_v2.dart    ← [v2] adds coral/amber accent
    views/
      home_tab/             ← Patient home dashboard
      compare/              ← Left vs Right hand comparison
      test_result/          ← ML + Groq results screen
      assessment_history/   ← Test logs with Left/Right tabs
      device_pairing/       ← [v2] QR + manual device pairing
      ble_scan/             ← BLE device scan
      wifi_scan/            ← WiFi network list
      wifi_credentials/     ← WiFi password entry
      patient_session/      ← Patient session management
      ...
  Model/
    test.dart               ← Test result model
    research_patient.dart   ← Research patient model
    patient_reading.dart    ← Patient reading model
    ...

supabase/
  config.toml               ← Edge Function config
  migrations/
    20240001_devices.sql    ← devices table + RPCs
    20240002_measurements.sql ← measurements table
    20240003_extend_assessments.sql
    20240004_extend_patients.sql
  functions/
    device-sync/
      index.ts              ← Complete Deno/TypeScript Edge Function

firmware/
  src/
    config.h                ← Device credentials + pin defs
    display/
      display_driver.cpp    ← ST7796 + LVGL init
      screens.cpp           ← All 4 LVGL screen layouts
    sync/
      sync_manager.cpp      ← HTTPS sync state machine
      sd_queue.cpp          ← SD card JSON queue
    sensors/
      battery.cpp           ← ADC → voltage → percentage
    time/
      time_manager.cpp      ← NTP / server_time / BLE epoch
    ble/
      ble_provisioning.cpp  ← BLE WiFi + epoch field
    qr/
      qr_render.cpp         ← QR code on LVGL canvas

scripts/
  provision-devices.ts      ← Admin: generate device codes + secrets

.kiro/specs/
  supabase-device-sync-migration/
    requirements.md         ← 25 requirements (EARS format)
    design.md               ← Full technical design
    tasks.md                ← 52 implementation tasks
```

---

## Key Features

### App v1 (Live)
- ✅ Patient & Specialist account login/signup
- ✅ Assessment scheduling and management
- ✅ 3-trial palm pressure testing
- ✅ ML-powered analysis (VitalStep Render server)
- ✅ Groq LLM patient-friendly narratives
- ✅ Left/Right hand comparison with balance score
- ✅ Trend charts (week/month/year)
- ✅ PDF report generation
- ✅ HubSpot CRM sync (patient + test data)
- ✅ Research Patient mode (separate Supabase project)
- ✅ BLE WiFi provisioning for ESP32 devices
- ✅ Push notifications (flutter_local_notifications)

### App v2 (In Development)
- 🚧 All App v1 features preserved
- 🚧 Supabase as primary backend (parallel with Digital Ocean)
- 🚧 Device pairing via QR code or manual code entry
- 🚧 Device status card (battery, online/offline, last sync)
- 🚧 "Time Estimated" badge on device-uploaded measurements
- 🚧 Coral/amber accent color scheme (`#FF6B35`)

### ESP32-3248S035 Firmware (In Development)
- 🚧 LVGL touchscreen UI (320×480 ST7796)
- 🚧 QR code pairing display
- 🚧 Live weight reading display during test
- 🚧 Trial results + target range indicator
- 🚧 SD card offline queue (JSON files)
- 🚧 HTTPS sync to Supabase Edge Function
- 🚧 Battery monitoring (2×18650 in series)
- 🚧 NTP + server time + BLE epoch time sources

---

## Supabase Setup

The project uses **two Supabase projects**:

| Project | URL | Purpose |
|---|---|---|
| Kill-switch | `aoujgxqgixpanztyyshc.supabase.co` | Remote app disable only |
| Main data | `cbebmpgsbxqdzpfgqulj.supabase.co` | Research patients, readings, devices, measurements |

### Apply Migrations (main data project)
Run in order in the Supabase SQL Editor:
1. `supabase/migrations/20240001_devices.sql`
2. `supabase/migrations/20240002_measurements.sql`
3. `supabase/migrations/20240003_extend_assessments.sql`
4. `supabase/migrations/20240004_extend_patients.sql`

### Deploy Edge Function
```bash
supabase functions deploy device-sync --project-ref cbebmpgsbxqdzpfgqulj
```

Set the function secret:
```bash
supabase secrets set SB_SECRET_KEY=<your_service_role_key> \
  --project-ref cbebmpgsbxqdzpfgqulj
```

### Provision ESP32 Devices (Admin Only)
```bash
export SUPABASE_URL=https://cbebmpgsbxqdzpfgqulj.supabase.co
export SUPABASE_SERVICE_ROLE_KEY=<service_role_key>
deno run --allow-net --allow-env --allow-write scripts/provision-devices.ts 10
```
This generates 10 device code/secret pairs in `./provisioned/` — copy each to the device's SD card.

---

## API Keys & Credentials

| Key | Location | Notes |
|---|---|---|
| Digital Ocean base URL | `lib/ui/common/app_strings.dart` | Never remove (App v1) |
| Supabase Kill-switch URL + anon key | `lib/main.dart` | Hardcoded (safe, public) |
| Supabase Patient URL + anon key | `lib/main.dart` (via dart-define) | Hardcoded default OK |
| Groq API key | `lib/services/ai_service.dart` | `String.fromEnvironment` with default |
| ML backend URL | `lib/services/ai_service.dart` | Public endpoint, no auth |
| HubSpot backend URL | `lib/services/hubspot_service.dart` | Proxied via Render |

> ⚠️ The Groq key has been removed from plain source and uses `String.fromEnvironment` with the key as `defaultValue`. This satisfies GitHub push protection. Generate a new key at console.groq.com if the default expires.

---

## Formulas & Technical Reference

See `FORMULAS_AND_TECHNICAL_REFERENCE.md` for:
- Trial average calculation
- Home screen hand strength formulas
- Dashboard weekly/monthly/all-time averages
- Compare screen balance score and severity thresholds
- Test result radar chart (Peak, Consistency, Symmetry)
- ML model input/output specification
- Groq prompt templates
- Fallback rule-based analysis

---

## For New Developers — Kiro Spec

The full feature spec for App v2 + ESP32 firmware is at:
```
.kiro/specs/supabase-device-sync-migration/
  requirements.md   ← What needs to be built (25 requirements)
  design.md         ← How to build it (SQL, TypeScript, Dart, C++ code)
  tasks.md          ← 52 implementation tasks in dependency order
```

Open this project in Kiro IDE and the spec will be automatically loaded. You can run tasks directly from Kiro's task runner.

---

## Built With

- **Flutter** (Dart) — Mobile UI
- **Supabase** — Auth, PostgreSQL, Edge Functions (Deno)
- **Digital Ocean** — Legacy backend (Node.js/PostgreSQL)
- **LVGL** — Embedded UI on ESP32
- **ArduinoJSON** — ESP32 JSON handling
- **GetStorage** — Local key-value storage
- **fl_chart** — Charts and graphs
- **stacked** — MVVM architecture
- **mobile_scanner** — QR code scanning
- **flutter_blue_plus** — BLE communication
