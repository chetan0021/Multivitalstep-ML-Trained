# VitalStep — Project Status & Roadmap

> Last updated: Based on current codebase state  
> Maintained by: SP4 Ameya Innovation Labs

---

## ✅ Completed (App v1 — Live)

### Core App
- [x] Patient account login, signup, profile management
- [x] Specialist (doctor) account login, signup
- [x] Specialist-patient linking (doctor sees linked patients)
- [x] Assessment creation and management
- [x] 3-trial palm pressure test flow
- [x] Test result display with ML analysis
- [x] Left/Right hand comparison (balance score, severity classification)
- [x] Assessment history with Left/Right tab switcher
- [x] Trend charts (week/month/year grouping, line + bar chart)
- [x] Timestamps on test cards (date + time with AM/PM)
- [x] PDF report generation and sharing
- [x] WhatsApp sharing of test results
- [x] Push notifications (scheduled, background)
- [x] FAQ screen
- [x] Privacy policy and terms of service screens
- [x] Kill-switch (remote app disable via Supabase)

### ML & AI
- [x] VitalStep ML model integration (vitalstep.onrender.com)
- [x] Groq LLM narrative generation (llama-3.3-70b-versatile)
- [x] Age-derived from DOB and passed to ML for accurate benchmarks
- [x] Patient-specific data (palm measurements, condition) sent to ML
- [x] ML result caching (fingerprint-based, persisted via GetStorage)
- [x] Nutrition category removed from AI recommendations
- [x] "Palm Pressure" terminology (replaced "grip strength" throughout)
- [x] ML timeout increased to 60s (handles Render cold starts)
- [x] Groq timeout increased to 30s
- [x] Groq system prompt updated to exclude nutrition advice

### Research Patient Mode
- [x] Host/Patient mode toggle (GetStorage)
- [x] Patient registration with all clinical fields
- [x] Patient search by name or code
- [x] Patient history view with trend chart
- [x] CSV export and share
- [x] Dual-write: Digital Ocean + Supabase (patient_readings)
- [x] Retry queue for failed Supabase writes (exponential backoff)
- [x] Deduplication guard (patientId:testId key)
- [x] Staleness guard (5-minute freshness check)

### HubSpot CRM Integration
- [x] Patient registration sync (POST /api/v1/hubspot/contacts)
- [x] Test reading sync (POST /api/v1/hubspot/sync/contact)
- [x] Hand-specific trial fields (left_trial_1/2/3, right_avg, etc.)
- [x] Fallback to /sync/contact if /contacts fails
- [x] PATCH existing contacts on 409 conflict
- [x] Phone number normalization (strips non-digit chars, min 10 digits)

### BLE & Device
- [x] BLE scan for PalmPressure-XXXX devices
- [x] WiFi credential provisioning over BLE
- [x] WiFi network scan (device scans and notifies)
- [x] WiFi status monitoring (CONNECTING → CONNECTED/FAILED)
- [x] Device pairing/unpairing via Digital Ocean backend

### UI & Visual
- [x] Premium teal/blue color scheme
- [x] Overflow fixes across all screens (Expanded + TextOverflow.ellipsis)
- [x] Missing asset fallbacks (errorBuilder on all Image.asset calls)
- [x] All 16 asset images added to assets/ folder
- [x] PDF logo path fixed (assets/Logo.jpeg)
- [x] "Grip Test" → "Palm Pressure Test" throughout app
- [x] Stale build cache fixed (flutter clean resolved Chetan→Appmaker path issue)

### Infrastructure
- [x] Git repository initialized and pushed to GitHub
- [x] Groq API key moved to String.fromEnvironment (passes GitHub push protection)
- [x] FORMULAS_AND_TECHNICAL_REFERENCE.md created
- [x] DEVELOPER_NOTES.md documents dual Supabase client architecture

---

## 🚧 In Progress (App v2 — Supabase + New Device)

### Supabase Backend (Phase 1–3)
- [ ] `supabase/migrations/20240001_devices.sql` — devices table + all RPCs
- [ ] `supabase/migrations/20240002_measurements.sql` — measurements table
- [ ] `supabase/migrations/20240003_extend_assessments.sql` — device-facing columns
- [ ] `supabase/migrations/20240004_extend_patients.sql` — target_lo / target_hi
- [ ] `supabase/config.toml` — verify_jwt = false for device-sync
- [ ] `supabase/functions/device-sync/index.ts` — complete Edge Function
- [ ] `scripts/provision-devices.ts` — admin device provisioning

### Flutter App v2 (Phase 4–7)
- [ ] `lib/app/app_config.dart` — build flavor flags
- [ ] `lib/ui/common/app_colors_v2.dart` — teal + coral (#FF6B35) palette
- [ ] `lib/services/device_service.dart` — claim/unclaim/status
- [ ] `lib/services/measurement_service.dart` — fetch + merge
- [ ] BLE epoch field in `ble_provisioning_service.dart`
- [ ] Device pairing screen (QR scanner + manual entry)
- [ ] Device status card widget (battery, online/offline, last sync)
- [ ] Inject status card into home/specialist views
- [ ] "Time Estimated" badge on measurement cards
- [ ] Merged measurement display (Supabase + Digital Ocean unified)

### ESP32-3248S035 Firmware (Phase 8)
- [ ] `firmware/src/config.h`
- [ ] ST7796 display driver + LVGL init
- [ ] LVGL screen layouts (main unclaimed, main claimed, test, results)
- [ ] SD card queue (write/read/delete/list JSON files)
- [ ] HTTPS sync state machine (POST_TEST=immediate, PENDING=15s, etc.)
- [ ] Battery ADC → voltage → percentage (8.4V=100%, 6.0V=0%)
- [ ] Time manager (NTP > server_time > BLE epoch > corrected)
- [ ] BLE provisioning update (read epoch from JSON payload)
- [ ] QR code rendering on LVGL canvas

### Tests (Phase 9)
- [ ] Flutter property test: DeviceStatus.isOnline (300s threshold)
- [ ] Flutter property test: MeasurementService.merge (completeness + sort)
- [ ] Flutter test: DevicePairingViewModel QR URI parsing
- [ ] Deno test: Edge Function auth (valid + invalid credentials)
- [ ] Deno property test: batch size enforcement (>6 → 400)
- [ ] Deno test: time_valid override (corrected→false, ntp→true)
- [ ] ESP32 Unity test: SD card round-trip
- [ ] ESP32 Unity test: battery voltage → percentage

### Documentation (Phase 10)
- [x] README.md — comprehensive project overview
- [x] PROJECT_STATUS.md — this file
- [ ] Env vars and deploy steps section in README
- [ ] DEVELOPER_NOTES.md — two-version strategy

---

## 📋 Planned (Future)

### App v2 — After Firmware Integration
- [ ] Over-the-air firmware update mechanism
- [ ] Doctor creates assessment from app → appears on device screen within 3 minutes
- [ ] Assessment pending/completed state visible in app
- [ ] Battery low alert to doctor (< 15%)
- [ ] Device silent for 24h alert to doctor
- [ ] Certificate pinning on ESP32 firmware
- [ ] Supabase Realtime subscription for live measurement updates

### Decommission Plan (After App v2 Verified)
When all App v2 features are verified in production:
1. Announce migration timeline to App v1 users
2. Add in-app upgrade prompt in App v1
3. Run both versions in parallel for 90 days
4. Remove Digital Ocean API calls from shared codebase
5. Keep Digital Ocean running for historical data access only

> ⚠️ **Digital Ocean is NEVER removed until all App v1 users have migrated and all data has been verified in Supabase.**

---

## 🔑 Key Technical Decisions

| Decision | Rationale |
|---|---|
| Two parallel app versions (v1/v2) | Zero disruption to existing users and old devices |
| Extend Supabase #2 (not new project) | Reuse existing `patientSupabaseClient` already in main.dart |
| `ENABLE_DEVICE_SYNC` dart-define flag | Compiles out all v2 UI from v1 builds |
| Edge Function `verify_jwt = false` | ESP32 devices have no JWT; custom auth via device code+secret |
| bcrypt for device secret hash | SHA256 is reversible with rainbow tables; bcrypt is not |
| SD card queue before HTTPS sync | Offline-first — test data is never lost |
| LVGL for device UI | Industry standard for embedded touchscreen UI on ESP32 |
| Coral accent (#FF6B35) for v2 | Visually distinguishes v2 from v1 at a glance |

---

## 📦 Repository Links

| Repo | URL | Contains |
|---|---|---|
| Main app (App v1 complete) | https://github.com/chetan0021/Multivitalstep-ML-Trained | Full Flutter app + spec |
| New version (App v2 + firmware) | https://github.com/chetan0021/vitalstep_with_firmware | This repo |

---

## 🧑‍💻 For New Developers

1. Clone this repo
2. Run `flutter pub get`
3. Open in Kiro IDE — the spec at `.kiro/specs/supabase-device-sync-migration/` loads automatically
4. Start with Phase 1 tasks (SQL migrations) — they have no dependencies
5. Follow the task dependency waves in `tasks.md` — earlier waves must complete before later ones
6. The design document (`design.md`) contains complete code for every file — copy, adapt, and implement
7. Never modify Digital Ocean API calls — App v1 must keep working

### Key files to read first
1. `README.md` — this file
2. `.kiro/specs/supabase-device-sync-migration/design.md` — complete technical design with code
3. `DEVELOPER_NOTES.md` — architecture decisions and GetStorage key map
4. `FORMULAS_AND_TECHNICAL_REFERENCE.md` — all calculation formulas
