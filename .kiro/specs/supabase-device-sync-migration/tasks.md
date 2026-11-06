# Implementation Plan: Supabase Device Sync Migration

## Overview

Implements the parallel Supabase-backed architecture alongside the existing Digital Ocean backend. The plan is structured in ten phases: database migrations, Edge Function, admin tooling, Flutter app services and UI, ESP32 firmware, tests, and documentation. Digital Ocean is never removed; all new work is additive.

## Tasks

---

- [ ] 1. Phase 1 — Supabase Database Setup

  - [ ] 1.1 Create `supabase/migrations/20240001_devices.sql`
    - Create the `devices` table with all columns, UNIQUE constraint, and indexes as specified
    - Add all RLS policies (service_role_all, user_read_own_device, user_update_own_device)
    - Add `claim_device` RPC (returns JSON, handles device_not_found and device_already_claimed)
    - Add `unclaim_device` RPC (returns JSON, handles device_not_found and not_owner)
    - Add `admin_provision_devices` RPC with bcrypt hashing, REVOKE/GRANT permissions
    - Add `verify_device_secret` RPC used by the Edge Function; REVOKE/GRANT to service_role only
    - Enable pgcrypto extension at top of file
    - _Requirements: 1.1–1.6, 5.1–5.7, 6.1–6.4, 7.5_

  - [ ] 1.2 Create `supabase/migrations/20240002_measurements.sql`
    - Create the `measurements` table with all columns, FK to `devices`, optional FKs to `research_patients` and `assessments`
    - Add CHECK constraint on `time_source IN ('ntp','server_time','corrected')`
    - Create indexes on `device_id`, `patient_id`, `measured_at DESC`
    - Add RLS policies (service_role_all, user_read_own_measurements with EXISTS subquery)
    - _Requirements: 2.1–2.6_

  - [ ] 1.3 Create `supabase/migrations/20240003_extend_assessments.sql`
    - Add columns `device_ref`, `hand`, `posture`, `title`, `status`, `completed_at` using `ADD COLUMN IF NOT EXISTS`
    - Add CHECK constraint on `status IN ('pending','in_progress','completed','cancelled')`
    - Create trigger function `assessments_set_completed_at` and trigger `trg_assessments_completed_at`
    - Create partial index on `(device_ref, status) WHERE status = 'pending'`
    - _Requirements: 3.1–3.4_

  - [ ] 1.4 Create `supabase/migrations/20240004_extend_patients.sql`
    - Add `target_lo NUMERIC(10,2)` and `target_hi NUMERIC(10,2)` columns using `ADD COLUMN IF NOT EXISTS`
    - Add CHECK constraint `chk_target_range` ensuring `target_lo IS NULL OR target_hi IS NULL OR target_lo < target_hi`
    - _Requirements: 4.1–4.4_

  - [ ] 1.5 Create `supabase/config.toml`
    - Add `[functions.device-sync]` section with `verify_jwt = false`
    - _Requirements: 7.1, 7.6_

---

- [ ] 2. Phase 2 — Edge Function (`device-sync`)

  - [ ] 2.1 Create `supabase/functions/device-sync/deno.json`
    - Add import map pointing to Deno std and esm.sh supabase-js@2
    - _Requirements: 7.1_

  - [ ] 2.2 Create `supabase/functions/device-sync/index.ts` — auth and routing
    - Implement `serve` handler skeleton; enforce POST-only (405)
    - Validate `apikey` header against `SUPABASE_ANON_KEY` env var (401 `missing_apikey`)
    - Read `x-device-code` and `x-device-secret` headers; return 401 `missing_credentials` if absent
    - Create service-role Supabase client from env vars
    - Call `verify_device_secret` RPC; return 401 `invalid_credentials` on failure
    - Update `devices.last_seen_at = NOW()` on successful auth
    - _Requirements: 7.1–7.6_

  - [ ] 2.3 Extend `index.ts` — measurement ingestion
    - Parse request body JSON; return 400 `invalid_json` on parse failure
    - Enforce batch size ≤ 6; return 400 `batch_too_large` if exceeded
    - Implement `validateMeasurement` helper (all required fields, ISO 8601 date, valid `time_source`)
    - Validate all measurements before inserting any (atomic batch semantics)
    - Build insert rows, overriding `time_valid` based on `time_source` (corrected → false, ntp/server_time → true)
    - Insert via supabase-js; return 500 on insert error
    - Mark referenced assessments as `completed` after successful insert
    - _Requirements: 8.1–8.7_

  - [ ] 2.4 Extend `index.ts` — response payload construction
    - Refresh device row to get current `owner_user_id`
    - Query `assessments` for at most 1 pending row matching `device_ref`
    - Query `measurements` for 5 most recent rows for this device
    - Query `research_patients` for `target_lo`/`target_hi` when device is claimed
    - Build and return JSON response: `{ server_time, queue, history, owner, target }`
    - _Requirements: 9.1–9.6_

  - [ ]* 2.5 Write Deno unit tests for Edge Function auth
    - Test missing `x-device-code` → 401 `missing_credentials`
    - Test missing `x-device-secret` → 401 `missing_credentials`
    - Test invalid credential pair → 401 `invalid_credentials`
    - Test valid credentials → 200 with `server_time` field
    - _Requirements: 7.2–7.5_

  - [ ]* 2.6 Write Deno property test for batch size enforcement (Property 8)
    - **Property 8: Measurement Batch Size Enforcement**
    - **Validates: Requirements 8.2, 8.3**
    - For every batch size from 7 to 20, assert HTTP 400 and `{"error":"batch_too_large"}`

  - [ ]* 2.7 Write Deno property test for time_source → time_valid override (Property 9)
    - **Property 9: Time Source Determines time_valid**
    - **Validates: Requirements 8.6, 8.7**
    - For each of `["ntp", "server_time", "corrected"]`, upload a measurement with the inverse `time_valid` value and assert the stored row has the correct `time_valid`

  - [ ] 2.8 Checkpoint — Edge Function complete
    - Ensure all Deno tests pass, ask the user if questions arise.

---

- [ ] 3. Phase 3 — Admin Provisioning Script

  - [ ] 3.1 Create `scripts/provision-devices.ts`
    - Read `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` from environment; exit 1 with error message if missing
    - Parse count argument from `Deno.args[0]`; exit 1 if not a positive integer
    - Create service-role Supabase client
    - Call `admin_provision_devices(p_count)` RPC; exit 1 with error if call fails or returns no data
    - Create `./provisioned/` directory
    - Write one JSON file per device: `{"device_code":"VS-XXXXXX","device_secret":"<secret>"}`
    - Print confirmation line per device and summary count
    - _Requirements: 6.5–6.7_

---

- [ ] 4. Phase 4 — Flutter App Config & Services

  - [ ] 4.1 Create `lib/app/app_config.dart`
    - Implement `AppConfig` class with `enableDeviceSync` (`bool.fromEnvironment('ENABLE_DEVICE_SYNC', defaultValue: false)`) and `appFlavor` constants
    - Add `isV2` getter
    - _Requirements: 15.1–15.4_

  - [ ] 4.2 Create `lib/ui/common/app_colors_v2.dart`
    - Import `app_colors.dart` without removing any existing constants
    - Add `kcCoralAccent`, `kcCoralAccentDark`, `kcV2PrimaryGradient`, `kcV2BadgeColor`, `kcOnCoral` constants with color values from the design
    - _Requirements: (supports Phase 5–6 UI)_

  - [ ] 4.3 Create `lib/services/device_service.dart`
    - Implement `DeviceStatus` model with `fromJson` factory and `isOnline` getter (< 5 minutes = online)
    - Implement `ClaimResult` and `UnclaimResult` sealed result types
    - Implement `DeviceService.claimDevice` calling `claim_device` RPC via `patientSupabaseClient`
    - Implement `DeviceService.unclaimDevice` calling `unclaim_device` RPC
    - Implement `DeviceService.getDeviceStatus` — SELECT from `devices` by `owner_user_id`
    - Implement `DeviceService.getPendingUploadCount` — count `measurements` with `time_valid = false`
    - _Requirements: 12.1–12.6, 11.4–11.8_

  - [ ]* 4.4 Write Flutter property test for `DeviceStatus.isOnline` (Property 16)
    - **Property 16: Online Status Threshold**
    - **Validates: Requirements 12.2**
    - For 100 random durations < 300 seconds, assert `isOnline = true`
    - For 100 random durations ≥ 300 seconds, assert `isOnline = false`

  - [ ] 4.5 Create `lib/services/measurement_service.dart`
    - Implement `DeviceMeasurement` model with `fromJson` factory
    - Implement `UnifiedMeasurement` model with `average` getter and `showTimeEstimatedBadge` getter (`!timeValid || timeSource == 'corrected'`)
    - Implement `MeasurementService.fetchDeviceMeasurements` — fetch from `measurements` table for user's devices
    - Implement `MeasurementService.merge` — combine DO and Supabase items, sort descending by `createdAt`
    - _Requirements: 14.1–14.5_

  - [ ]* 4.6 Write Flutter property test for `MeasurementService.merge` (Property 15)
    - **Property 15: Measurement Merge Preserves All Items and Chronological Order**
    - **Validates: Requirements 14.1, 14.2**
    - For 100 random (doCount, supCount) pairs, assert output length equals sum and items are sorted newest-first

  - [ ] 4.7 Update `lib/services/ble_provisioning_service.dart` — add epoch field
    - In `sendWifiCredentials`, add `"epoch": DateTime.now().millisecondsSinceEpoch ~/ 1000` to the JSON payload
    - No other methods modified
    - _Requirements: 13.1–13.4_

  - [ ]* 4.8 Write Flutter property test for BLE epoch payload (Property 14)
    - **Property 14: BLE Epoch Payload Completeness**
    - **Validates: Requirements 13.1, 13.2, 13.3**
    - For 100 arbitrary (ssid, password) pairs, assert serialized payload contains correct ssid, password, and epoch within ±5 seconds of now

  - [ ] 4.9 Checkpoint — Services complete
    - Ensure all Flutter service tests pass, ask the user if questions arise.

---

- [ ] 5. Phase 5 — Flutter UI — Device Pairing

  - [ ] 5.1 Create `lib/ui/views/device_pairing/device_pairing_viewmodel.dart`
    - Implement `DevicePairingViewModel extends BaseViewModel`
    - Implement `onQrDetected` with regex `^vitalstep://pair\?code=(VS-[A-Z0-9]{6})$` to extract code
    - Implement `onCodeChanged`, `onManualSubmit` calling `DeviceService.claimDevice`
    - Map `device_not_found` → "Device code not found. Check the code and try again."
    - Map `device_already_claimed` → "This device is already paired to another account."
    - Map network error → generic retry message
    - Dispose `TextEditingController` on `dispose()`
    - _Requirements: 11.1–11.8_

  - [ ]* 5.2 Write Flutter unit tests for `DevicePairingViewModel` QR parsing (Property 13)
    - **Property 13: QR URI Encoding**
    - **Validates: Requirements 16.3, 21.1, 11.3**
    - Assert valid `vitalstep://pair?code=VS-A1B2C3` extracts `VS-A1B2C3`
    - Assert malformed URIs (wrong scheme, missing code param, non-VS code) are ignored

  - [ ] 5.3 Create `lib/ui/views/device_pairing/device_pairing_view.dart`
    - Implement `DevicePairingView extends StackedView<DevicePairingViewModel>`
    - Add `MobileScanner` widget calling `vm.onQrDetected`
    - Add `TextField` for manual Device_Code entry with `TextCapitalization.characters`
    - Add `ElevatedButton` calling `vm.onManualSubmit`
    - Show `CircularProgressIndicator` when `vm.isBusy`
    - Show `vm.errorMessage` in red text when non-null
    - Use `kcPrimaryColor` for AppBar and button background, `kcCoralAccent` for suffix icon
    - _Requirements: 11.1–11.8_

  - [ ] 5.4 Register device pairing route in `lib/app/app.router.dart`
    - Add `DevicePairingView` route; ensure it is reachable from the account screen
    - _Requirements: 11.1_

  - [ ] 5.5 Add "Pair Device" entry point to account screen
    - Add a list tile or button in the account/settings screen that navigates to `DevicePairingView`
    - Gate with `AppConfig.enableDeviceSync` so it only appears in v2 builds
    - _Requirements: 11.1_

---

- [ ] 6. Phase 6 — Flutter UI — Device Status Card

  - [ ] 6.1 Create `lib/ui/widgets/device_status_card.dart`
    - Implement `DeviceStatusCard` stateless widget with `DeviceStatus status` and `int pendingUploads` parameters
    - Implement `_OnlineBadge` — green circle + "Online" or grey + "Offline"
    - Implement `_BatteryIndicator` — icon changes at >60%, >20% thresholds; red below 20%
    - Implement `_LastSeenLabel` — relative time (just now / X min ago / X hr ago / X day(s) ago)
    - Show pending uploads count in coral when > 0
    - _Requirements: 12.1–12.5_

  - [ ] 6.2 Create `DeviceStatusCardLoader` stateful widget
    - On `initState`, call `DeviceService.getDeviceStatus` and `getPendingUploadCount`
    - Set up a `Timer.periodic(Duration(seconds: 30), ...)` to refresh
    - Cancel timer in `dispose()`
    - Render `DeviceStatusCard` when data available; render nothing (0-height box) when no device claimed
    - _Requirements: 12.1, 12.6_

  - [ ] 6.3 Inject `DeviceStatusCardLoader` into home views
    - In `lib/ui/views/home/home_view.dart`, insert `if (AppConfig.enableDeviceSync) DeviceStatusCardLoader(...)` at top of body
    - In `lib/ui/views/home_specialist/home_specialist_view.dart`, same injection
    - Pass `currentUserId` from the view's ViewModel
    - _Requirements: 12.1_

---

- [ ] 7. Phase 7 — Flutter UI — Measurement Display

  - [ ] 7.1 Integrate `MeasurementService.merge` into dashboard/history screen
    - In the relevant view or ViewModel, call `MeasurementService.fetchDeviceMeasurements` when `AppConfig.enableDeviceSync`
    - Call `MeasurementService.merge` with the existing Digital Ocean history list and the fetched device measurements
    - Pass the merged list to the UI list builder
    - Preserve existing DO data-fetching code untouched
    - _Requirements: 14.1–14.5, 22.1–22.2_

  - [ ] 7.2 Add "Time Estimated" badge to measurement cards
    - In the measurement card widget, show a badge/chip labelled "Time Estimated" when `UnifiedMeasurement.showTimeEstimatedBadge` is true
    - Style badge with `kcV2BadgeColor`
    - _Requirements: 14.3–14.4_

---

- [ ] 8. Phase 8 — ESP32 Firmware

  - [ ] 8.1 Create `firmware/src/config.h`
    - Define `DEVICE_CODE`, `DEVICE_SECRET` string constants (populated from provisioned SD file at runtime; constants used as fallback compile-time stubs)
    - Define `SUPABASE_URL`, `EDGE_FUNCTION_URL`, `SUPABASE_ANON_KEY`
    - Define `BATTERY_ADC_PIN` (GPIO 34), `CHARGE_DETECT_PIN` (GPIO 35)
    - Define sync interval constants: `SYNC_INTERVAL_PAIRED_MS` (180 000), `SYNC_INTERVAL_UNPAIRED_MS` (4 000), `SYNC_INTERVAL_PENDING_MS` (15 000)
    - _Requirements: 18.1, 19.1_

  - [ ] 8.2 Create `firmware/src/display/display_driver.cpp`
    - Initialize ST7796 at 320×480 via SPI in `displayInit()`
    - Register LVGL flush callback `lvglFlushCb` that calls the TFT driver `pushColors`
    - Initialize LVGL with display and input device (resistive touch via XPT2046)
    - _Requirements: 16.1–16.2_

  - [ ] 8.3 Create `firmware/src/display/screens.cpp`
    - Implement `buildMainScreenUnclaimed()` — status bar, QR canvas placeholder, device code label, sync status
    - Implement `buildMainScreenClaimed()` — status bar, VitalStep Ready label, last sync, pending count, START TEST button, recent results list
    - Implement `buildTestScreen()` — trial number label, live weight value (72px bold), progress bar, instruction text
    - Implement `buildResultsScreen()` — all 3 trial values, average (highlighted), in-range / out-of-range indicator, SYNC NOW button
    - Implement status bar helper (battery icon + %, WiFi icon, clock)
    - _Requirements: 16.3–16.8_

  - [ ] 8.4 Create `firmware/src/sync/sd_queue.cpp`
    - Implement `writeRecord(const Measurement& m)` — serialize to JSON, write to `/queue/<epoch>_<trial1>.json`
    - Implement `readRecord(const String& filename, Measurement& out)` — deserialize JSON to struct
    - Implement `deleteFile(const String& filename)`
    - Implement `listFiles()` — return sorted list of filenames in `/queue/`
    - Fallback: if SD write fails, log to Serial and set a flag for direct memory upload
    - _Requirements: 17.1–17.6_

  - [ ]* 8.5 Write ESP32 Unity test for SD card round-trip (Property 10)
    - **Property 10: SD Card Round-Trip**
    - **Validates: Requirements 17.3, 17.6**
    - Write a `Measurement` struct, read it back, assert every field is equal

  - [ ] 8.6 Create `firmware/src/sync/sync_manager.cpp`
    - Implement state machine: `IDLE_PAIRED`, `IDLE_UNPAIRED`, `PENDING_UPLOADS`, `POST_TEST`, `SYNCING`, `RETRY_BACKOFF`
    - Implement `doSync()`: build headers (`apikey`, `x-device-code`, `x-device-secret`), collect up to 6 SD files into measurements array, POST to Edge Function
    - On HTTP 200: parse `server_time`, `queue`, `history`, `owner`; update RTC; delete uploaded SD files; emit `EVENT_CLAIMED` if `owner.claimed` transitions to true
    - On non-200: stay in `RETRY_BACKOFF`; do not delete SD files
    - Implement cadence timer logic
    - _Requirements: 18.1–18.7_

  - [ ] 8.7 Create `firmware/src/sensors/battery.cpp`
    - Implement `readVoltage()` — ADC raw → voltage using `(raw / 4095.0) * 3.3 * 2.0`
    - Implement `voltageToPercent(float voltage)` — linear map 6.0V→0%, 8.4V→100%, clamped to [0, 100]
    - Implement `isCharging()` — `digitalRead(CHARGE_DETECT_PIN) == HIGH`
    - Implement 30-second refresh ticker
    - _Requirements: 19.1–19.5_

  - [ ]* 8.8 Write ESP32 Unity tests for battery (Property 11)
    - **Property 11: Battery Voltage-to-Percentage Monotonicity and Bounds**
    - **Validates: Requirements 19.2**
    - `test_battery_bounds`: assert 8.4V → 100, 6.0V → 0, clamped outside range
    - `test_battery_monotonic`: assert non-decreasing from 6.0V to 8.4V in 0.1V steps

  - [ ] 8.9 Create `firmware/src/time/time_manager.cpp`
    - Implement `onBleEpochReceived(int64_t epochSeconds)` — store epoch + `millis()` snapshot
    - Implement `onNtpSuccess()` — set `_source = NTP`
    - Implement `onServerTimeReceived(const String& isoTime)` — skip if NTP already set; otherwise parse and `settimeofday`; set `_source = SERVER_TIME`
    - Implement `currentTimeSource()` and `currentTimeValid()` helpers
    - Implement `nowISO()` — derive from BLE epoch + elapsed when corrected; use RTC otherwise
    - _Requirements: 20.1–20.5_

  - [ ] 8.10 Update `firmware/src/ble/ble_provisioning.cpp`
    - In the WIFI_CREDS characteristic write handler, parse `epoch` field from the incoming JSON and call `TimeManager::onBleEpochReceived(epoch)`
    - All other BLE provisioning logic (SSID/password) unchanged
    - _Requirements: 13.1–13.4, 20.3_

  - [ ] 8.11 Create `firmware/src/qr/qr_render.cpp`
    - Implement `renderQrCode(lv_obj_t* parent, const String& uri)` using the `qrcode` C library
    - Scale QR modules to fill a 200×200 LVGL canvas
    - Fallback: if QR render fails, display device code as plain text label
    - _Requirements: 16.3, 21.1–21.5_

  - [ ] 8.12 Checkpoint — Firmware complete
    - Ensure all Unity tests pass and firmware compiles cleanly; ask the user if questions arise.

---

- [ ] 9. Phase 9 — Tests

  - [ ]* 9.1 Write Flutter unit test for `DeviceStatus.isOnline` boundary
    - Assert `isOnline = true` when `lastSeenAt` is exactly 299 seconds ago
    - Assert `isOnline = false` when `lastSeenAt` is exactly 300 seconds ago
    - Assert `isOnline = false` when `lastSeenAt` is null
    - _Requirements: 12.2_

  - [ ]* 9.2 Write Flutter property-based test for `MeasurementService.merge` (comprehensive, Property 15)
    - **Property 15: Measurement Merge Preserves All Items and Chronological Order**
    - **Validates: Requirements 14.1, 14.2**
    - 100 iterations with random list sizes; assert length, presence of all items, and descending sort

  - [ ]* 9.3 Write Flutter tests for `DevicePairingViewModel` QR parsing edge cases (Property 13)
    - **Property 13: QR URI Encoding**
    - **Validates: Requirements 11.3, 16.3, 21.1**
    - Test 20+ URI variants: valid, wrong scheme, missing param, lowercase code, extra params; assert correct accept/reject

  - [ ]* 9.4 Write Deno integration test for Edge Function auth (valid + invalid credential pairs)
    - Test missing headers → 401
    - Test wrong secret → 401
    - Test valid provisioned credentials → 200
    - _Requirements: 7.2–7.4_

  - [ ]* 9.5 Write Deno property test for batch size (Property 8 — comprehensive)
    - **Property 8: Measurement Batch Size Enforcement**
    - **Validates: Requirements 8.2, 8.3**
    - Batch sizes 0–6 → 200; batch sizes 7–20 → 400 with `batch_too_large`; no rows inserted on rejection

  - [ ]* 9.6 Write Deno test for `time_valid` override (Property 9 — explicit cases)
    - **Property 9: Time Source Determines time_valid**
    - **Validates: Requirements 8.6, 8.7**
    - Upload `time_source=corrected, time_valid=true` → stored `time_valid=false`
    - Upload `time_source=ntp, time_valid=false` → stored `time_valid=true`
    - Upload `time_source=server_time, time_valid=false` → stored `time_valid=true`

  - [ ]* 9.7 Write ESP32 Unity test for `SdQueue` round-trip (Property 10 — standalone test file)
    - **Property 10: SD Card Round-Trip**
    - **Validates: Requirements 17.3, 17.6**
    - Ten distinct `Measurement` structs with varying field values; assert field-for-field equality after write→read

  - [ ]* 9.8 Write ESP32 Unity test for battery bounds and monotonicity (Property 11 — standalone)
    - **Property 11: Battery Voltage-to-Percentage Monotonicity and Bounds**
    - **Validates: Requirements 19.2**
    - Boundary values, clamping, 0.1V step monotonicity

---

- [ ] 10. Phase 10 — Documentation

  - [ ] 10.1 Create `README.md` (or update root README with a Supabase Device Sync section)
    - Document all required environment variables: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_ANON_KEY`, `PATIENT_SUPABASE_URL`, `PATIENT_SUPABASE_ANON_KEY`, `ENABLE_DEVICE_SYNC`, `APP_FLAVOR`
    - Document deploy steps: apply migrations in order, deploy Edge Function, run provisioning script
    - Document build commands for App v1 and App v2 with `--dart-define` flags
    - _Requirements: 6.7, 15.1–15.2_

  - [ ] 10.2 Update `DEVELOPER_NOTES.md` with two-version strategy
    - Explain the v1 / v2 parallel architecture and why Digital Ocean is never removed
    - Document the `AppConfig.enableDeviceSync` gate pattern
    - Document the `patientSupabaseClient` as the entry point for all Supabase operations
    - _Requirements: 22.1–22.3_

---

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP build
- Each task references specific requirements for traceability
- Migration files must be applied in numeric order (20240001 → 20240004)
- The `ENABLE_DEVICE_SYNC` build flag gates all Phase 5–7 UI; App v1 builds are unaffected
- Digital Ocean endpoints are never modified or removed (Requirements 22.1–22.3)
- Property tests in Phases 4 and 9 each target a named property from the design's Correctness Properties section
- The `verify_device_secret` RPC lives in `20240001_devices.sql` alongside the other device RPCs

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.3", "1.4", "1.5", "2.1"] },
    { "id": 1, "tasks": ["2.2", "3.1", "4.1", "4.2"] },
    { "id": 2, "tasks": ["2.3", "4.3", "4.5", "4.7", "8.1"] },
    { "id": 3, "tasks": ["2.4", "4.4", "4.6", "4.8", "8.2", "8.3", "8.4", "8.9"] },
    { "id": 4, "tasks": ["2.5", "2.6", "2.7", "4.9", "5.1", "7.1", "8.5", "8.6", "8.7", "8.10"] },
    { "id": 5, "tasks": ["2.8", "5.2", "5.3", "7.2", "8.8", "8.11"] },
    { "id": 6, "tasks": ["5.4", "5.5", "6.1", "8.12"] },
    { "id": 7, "tasks": ["6.2", "9.1", "9.2", "9.3", "9.4", "9.5", "9.6", "9.7", "9.8"] },
    { "id": 8, "tasks": ["6.3"] },
    { "id": 9, "tasks": ["10.1", "10.2"] }
  ]
}
```
