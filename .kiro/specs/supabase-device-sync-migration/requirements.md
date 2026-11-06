# Requirements Document

## Introduction

This feature migrates the VitalStep palm pressure measurement system from its current Digital Ocean–only architecture to a parallel Supabase-backed architecture. The migration introduces:

1. **Supabase backend extensions** — new `devices` and `measurements` tables, RLS policies, RPCs for device claiming, and a Deno/TypeScript Edge Function (`device-sync`) that authenticates ESP32 devices and exchanges data with them.
2. **Flutter app changes** — device pairing screen, device status card, BLE epoch field, Supabase-sourced measurement display, time-estimate badge, and environment-based Supabase URL configuration.
3. **ESP32 firmware** — full rewrite targeting the ESP32-3248S035 (ST7796 320×480 touchscreen, LVGL UI), SD-card queuing, HTTPS sync to the Edge Function, battery monitoring, NTP/BLE time handling, and QR-code pairing display.

**Migration strategy:** Digital Ocean stays live **permanently** — old devices and the existing app version will continue using it unchanged. The new Supabase-backed version is a parallel app build sharing the same UI and codebase, with the database layer switched to Supabase. The Digital Ocean backend is **never removed**.

**Two app versions:**
- **App v1 (existing)**: Digital Ocean backend, existing color scheme, old ESP32 devices
- **App v2 (new)**: Supabase backend, refined color scheme (sea-green teal + warm coral/amber accent), new ESP32-3248S035 devices with touchscreen

**Accounts in App v2:** Both specialist (doctor) accounts and patient accounts work fully — all existing flows (login, sign up, assessments, dashboards, specialist-patient linking) are preserved and connected to the new Supabase backend.

---

## Glossary

- **Device**: An ESP32-3248S035 hardware unit that measures palm pressure and syncs results to Supabase.
- **Device_Code**: A provisioned 9-character identifier in the format `VS-XXXXXX` written to the device's SD card and displayed as a QR code.
- **Device_Secret**: A provisioned secret written to the device's SD card, used for HTTPS authentication alongside `Device_Code`.
- **Device_Sync_Function**: The Supabase Edge Function (`device-sync`) running Deno/TypeScript that authenticates devices and handles measurement upload/download.
- **Measurement**: A palm-pressure test result produced by a Device, comprising three force trials, metadata (hand, posture), time fields, and battery state.
- **SD_Queue**: The collection of JSON files stored on the device's SD card representing Measurement records pending upload.
- **Flutter_App**: The existing VitalStep Flutter application running on a clinician's or patient's smartphone.
- **Patient_Profile**: A row in the Supabase `research_patients` table, extended with `target_lo` and `target_hi` pressure target fields.
- **Assessment**: A row in the Supabase `assessments` table (extended from Digital Ocean), representing a scheduled test request sent to a Device.
- **RPC**: A Supabase Remote Procedure Call (PostgreSQL function exposed over REST).
- **RLS**: Row-Level Security — Supabase's per-row access control mechanism.
- **BLE_Epoch**: A Unix timestamp (seconds since 1970-01-01 UTC) written by the Flutter app to the Device over BLE to set approximate device time when NTP is unavailable.
- **time_source**: An enum field on Measurement: `ntp` (synchronized via NTP), `server_time` (set from Edge Function response), or `corrected` (estimated from BLE_Epoch + elapsed time).
- **time_valid**: A boolean flag on Measurement indicating whether the recorded timestamp is considered accurate.
- **LVGL**: Light and Versatile Graphics Library — the embedded UI framework used on the ESP32-3248S035 screen.
- **ST7796**: The display controller for the ESP32-3248S035 320×480 TFT screen.
- **Digital_Ocean**: The existing Node.js/PostgreSQL backend at `backend.sp4ameya.com`, which remains live throughout the migration.
- **Kill_Switch**: The existing Supabase table (`vitalStep`) used to remotely disable the Flutter app.
- **patientSupabaseClient**: The second Supabase client already initialized in `main.dart` targeting `cbebmpgsbxqdzpfgqulj.supabase.co`.

---

## Requirements

### Requirement 1: Supabase Database Schema — Devices Table

**User Story:** As a system administrator, I want a `devices` table in Supabase so that each registered ESP32 device has a persistent identity, owner linkage, and sync state record.

#### Acceptance Criteria

1. THE Database SHALL contain a `devices` table with columns: `id` (UUID PK), `device_code` (TEXT UNIQUE NOT NULL), `device_secret_hash` (TEXT NOT NULL), `owner_user_id` (TEXT), `claimed_at` (TIMESTAMPTZ), `last_seen_at` (TIMESTAMPTZ), `battery_pct` (INTEGER), `battery_v` (NUMERIC(5,2)), `is_charging` (BOOLEAN), `firmware_version` (TEXT), `created_at` (TIMESTAMPTZ DEFAULT NOW()).
2. THE Database SHALL enforce a UNIQUE constraint on `device_code` in the `devices` table.
3. WHEN a device row has `owner_user_id` IS NULL, THE Database SHALL consider the device unclaimed.
4. THE Database SHALL enable Row-Level Security on the `devices` table.
5. THE Database SHALL include an RLS policy allowing a device to read its own row using its `device_code` via the Edge Function service role.
6. THE Database SHALL include an RLS policy allowing an authenticated app user to read and update a `devices` row where `owner_user_id` matches the user's ID.

---

### Requirement 2: Supabase Database Schema — Measurements Table

**User Story:** As a system administrator, I want a `measurements` table in Supabase so that all device-recorded palm pressure trials are durably stored and queryable by the Flutter app.

#### Acceptance Criteria

1. THE Database SHALL contain a `measurements` table with columns: `id` (UUID PK DEFAULT gen_random_uuid()), `device_id` (UUID NOT NULL REFERENCES devices(id)), `patient_id` (UUID REFERENCES research_patients(id)), `assessment_id` (UUID REFERENCES assessments(id)), `trial1` (NUMERIC(10,2) NOT NULL), `trial2` (NUMERIC(10,2) NOT NULL), `trial3` (NUMERIC(10,2) NOT NULL), `hand` (TEXT NOT NULL), `posture` (TEXT NOT NULL), `battery_pct` (INTEGER), `battery_v` (NUMERIC(5,2)), `is_charging` (BOOLEAN), `measured_at` (TIMESTAMPTZ NOT NULL), `time_source` (TEXT NOT NULL CHECK IN ('ntp','server_time','corrected')), `time_valid` (BOOLEAN NOT NULL DEFAULT false), `sd_filename` (TEXT), `created_at` (TIMESTAMPTZ DEFAULT NOW()).
2. THE Database SHALL enforce a foreign key from `measurements.device_id` to `devices.id`.
3. THE Database SHALL enable Row-Level Security on the `measurements` table.
4. THE Database SHALL include an RLS policy allowing the Device_Sync_Function (service role) to insert measurements.
5. THE Database SHALL include an RLS policy allowing an authenticated app user to read measurements where the related `devices.owner_user_id` matches the user's ID.
6. THE Database SHALL create indexes on `measurements(device_id)` and `measurements(patient_id)` for query performance.

---

### Requirement 3: Supabase Database Schema — Assessments Table Extension

**User Story:** As a clinician, I want the `assessments` table extended with device-facing fields so that a Device knows which test to run, for which patient, and in what context.

#### Acceptance Criteria

1. THE Database SHALL add columns `device_ref` (TEXT), `hand` (TEXT), `posture` (TEXT), `title` (TEXT), `status` (TEXT DEFAULT 'pending' CHECK IN ('pending','in_progress','completed','cancelled')), and `completed_at` (TIMESTAMPTZ) to the `assessments` table via a SQL migration.
2. WHEN `status` is set to `completed`, THE Database SHALL record `completed_at` as the current timestamp via a trigger or application logic.
3. THE Database SHALL enforce the invariant that any row with `status = 'completed'` has a non-NULL `completed_at` value, and any row with `status != 'completed'` has `completed_at = NULL`.
4. THE Database SHALL NOT drop or alter any existing `assessments` columns, preserving Digital_Ocean compatibility.

---

### Requirement 4: Supabase Database Schema — Patient Profile Extension

**User Story:** As a clinician, I want patient profiles to store target pressure bounds so that the Device can display whether a patient's measurement is within their personalized target range.

#### Acceptance Criteria

1. THE Database SHALL add columns `target_lo` (NUMERIC(10,2)) and `target_hi` (NUMERIC(10,2)) to the `research_patients` table via a SQL migration.
2. WHEN both `target_lo` and `target_hi` are NULL, THE Database SHALL treat the patient as having no personalized target range.
3. THE Database SHALL allow `target_lo` and `target_hi` to be NULL (no mandatory target).
4. WHEN `target_lo` IS NOT NULL AND `target_hi` IS NOT NULL, THE Database SHALL enforce a CHECK constraint `target_lo < target_hi`.

---

### Requirement 5: Supabase RPCs — Device Claiming

**User Story:** As a patient or clinician, I want to claim a Device using its QR code so that my account is linked to that device and I can receive its measurements.

#### Acceptance Criteria

1. THE Database SHALL expose an RPC `claim_device(p_device_code TEXT, p_user_id TEXT) RETURNS JSON` that sets `owner_user_id = p_user_id` and `claimed_at = NOW()` on the matching `devices` row.
2. WHEN `p_device_code` does not match any row in `devices`, THE RPC `claim_device` SHALL return a JSON error `{"error": "device_not_found"}`.
3. WHEN the device is already claimed by a different user, THE RPC `claim_device` SHALL return a JSON error `{"error": "device_already_claimed"}`.
4. WHEN the claim succeeds, THE RPC `claim_device` SHALL return `{"success": true, "device_id": "<uuid>"}`.
5. THE Database SHALL expose an RPC `unclaim_device(p_device_code TEXT, p_user_id TEXT) RETURNS JSON` that sets `owner_user_id = NULL` and `claimed_at = NULL` only when `owner_user_id = p_user_id`.
6. WHEN `unclaim_device` is called with a `p_device_code` that does not match any row in `devices`, THE RPC SHALL return `{"error": "device_not_found"}`.
7. WHEN `unclaim_device` is called by a user whose ID does not match `owner_user_id` on an existing device row, THE RPC SHALL return `{"error": "not_owner"}`.

---

### Requirement 6: Supabase RPCs — Admin Device Provisioning

**User Story:** As a system administrator, I want an RPC and a TypeScript script to bulk-provision devices so that factory-new units have a Device_Code and Device_Secret before they ship.

#### Acceptance Criteria

1. THE Database SHALL expose an RPC `admin_provision_devices(p_count INTEGER) RETURNS TABLE(device_code TEXT, device_secret TEXT)` callable only with the service role key.
2. WHEN `admin_provision_devices` is called with `p_count = N`, THE RPC SHALL insert N new rows into `devices` and return N pairs of `(device_code, device_secret)`.
3. THE RPC SHALL generate each `device_code` in the format `VS-XXXXXX` where `XXXXXX` is a cryptographically random uppercase alphanumeric string.
4. THE RPC SHALL store `device_secret_hash = crypt(device_secret, gen_salt('bf'))` in the `devices` row rather than storing the plaintext secret.
5. THE Admin_Script (`scripts/provision-devices.ts`) SHALL call `admin_provision_devices`, receive the plaintext secrets, and write one SD card file per device containing `device_code` and `device_secret`.
6. THE Admin_Script SHALL format each SD card file as valid JSON: `{"device_code":"VS-XXXXXX","device_secret":"<secret>"}`.
7. IF the Admin_Script cannot connect to Supabase, THEN THE Admin_Script SHALL print an error message and exit with code 1 without writing any files.

---

### Requirement 7: Supabase Edge Function — device-sync Authentication

**User Story:** As a Device, I want to authenticate with the Edge Function using my Device_Code and Device_Secret so that only provisioned devices can submit measurements or receive assignments.

#### Acceptance Criteria

1. THE Device_Sync_Function SHALL accept HTTPS POST requests at the path `/functions/v1/device-sync`.
2. THE Device_Sync_Function SHALL read `x-device-code` and `x-device-secret` from the request headers for every request.
3. WHEN `x-device-code` or `x-device-secret` is missing from the request headers, THE Device_Sync_Function SHALL respond with HTTP 401 and body `{"error":"missing_credentials"}`.
4. WHEN the provided `x-device-secret` does not match the stored hash for the given `x-device-code`, THE Device_Sync_Function SHALL respond with HTTP 401 and body `{"error":"invalid_credentials"}`.
5. WHEN authentication succeeds, THE Device_Sync_Function SHALL update `devices.last_seen_at = NOW()` for the authenticated device row.
6. THE Device_Sync_Function SHALL also accept the Supabase `apikey` header to satisfy Supabase's built-in JWT gate.

---

### Requirement 8: Supabase Edge Function — Measurement Upload

**User Story:** As a Device, I want to upload batches of measurements to the Edge Function so that test results are stored in Supabase even when the device had no connectivity during the test.

#### Acceptance Criteria

1. WHEN the request body contains a `measurements` array, THE Device_Sync_Function SHALL insert each measurement into the `measurements` table.
2. THE Device_Sync_Function SHALL accept up to 6 measurements per request.
3. WHEN a `measurements` array contains more than 6 items, THE Device_Sync_Function SHALL respond with HTTP 400 and body `{"error":"batch_too_large"}`.
4. WHEN all measurements are inserted successfully, THE Device_Sync_Function SHALL respond with HTTP 200 and a `server_time` field (ISO 8601 UTC) in the response body.
5. WHEN any measurement in the batch fails validation (e.g., missing required field, unrecognized `time_source` value), THE Device_Sync_Function SHALL respond with HTTP 422 and a descriptive error without inserting any rows from the batch.
6. IF the `time_source` field in any measurement object is missing, null, or not one of `ntp`, `server_time`, or `corrected`, THEN THE Device_Sync_Function SHALL reject the entire batch with HTTP 422 and body `{"error": "invalid_time_source"}`.
6. WHEN `time_source` is `corrected`, THE Device_Sync_Function SHALL accept the uploaded `measured_at` value as-is and set `time_valid = false` on those rows.
7. WHEN `time_source` is `ntp` or `server_time`, THE Device_Sync_Function SHALL set `time_valid = true` on those rows.

---

### Requirement 9: Supabase Edge Function — Device Response Payload

**User Story:** As a Device, I want the Edge Function to return the current server time, pending assessment queue, recent measurement history, owner link status, and patient targets in a single response so that the device screen stays current after every sync.

#### Acceptance Criteria

1. THE Device_Sync_Function SHALL include `server_time` (ISO 8601 UTC string) in every successful response.
2. THE Device_Sync_Function SHALL include a `queue` array in the response containing at most 1 pending Assessment where `device_ref` matches the device's `device_code` and `status = 'pending'`.
3. THE Device_Sync_Function SHALL include a `history` array in the response containing the 5 most recent Measurement rows for the authenticated device, ordered by `measured_at DESC`.
4. THE Device_Sync_Function SHALL include an `owner` object in the response with fields `claimed` (boolean) and `owner_user_id` (string or null).
5. WHEN the device has an owner with a Patient_Profile that has non-null `target_lo` and `target_hi`, THE Device_Sync_Function SHALL include a `target` object with `lo` and `hi` numeric fields in the response.
6. WHEN the device has no owner or no patient target, THE Device_Sync_Function SHALL include `"target": null` in the response.

---

### Requirement 10: SQL Migrations

**User Story:** As a developer, I want all schema changes delivered as versioned SQL migration files so that they can be applied consistently across environments.

#### Acceptance Criteria

1. THE Codebase SHALL contain a `supabase/migrations/` directory.
2. THE Codebase SHALL contain a migration file `supabase/migrations/20240001_devices.sql` that creates the `devices` table with all columns, indexes, and RLS policies from Requirements 1 and 5–6.
3. THE Codebase SHALL contain a migration file `supabase/migrations/20240002_measurements.sql` that creates the `measurements` table with all columns, indexes, and RLS policies from Requirement 2.
4. THE Codebase SHALL contain a migration file `supabase/migrations/20240003_extend_assessments.sql` that adds the columns from Requirement 3 to the `assessments` table.
5. THE Codebase SHALL contain a migration file `supabase/migrations/20240004_extend_patients.sql` that adds `target_lo` and `target_hi` from Requirement 4 to `research_patients`.
6. WHEN all migration files are applied in order, THE Database SHALL be in a consistent state with no foreign key violations.

---

### Requirement 11: Flutter App — Device Pairing Screen

**User Story:** As a patient or clinician, I want to pair my smartphone to a Device by scanning its QR code or typing the Device_Code manually so that I receive its measurements in my account.

#### Acceptance Criteria

1. THE Flutter_App SHALL provide a device pairing screen accessible from the account or settings area.
2. WHEN the pairing screen opens, THE Flutter_App SHALL display a QR code scanner and a text input field for manual Device_Code entry.
3. WHEN the QR scanner reads a URI in the format `vitalstep://pair?code=VS-XXXXXX`, THE Flutter_App SHALL extract the Device_Code and pre-fill the text input.
4. WHEN the user submits a Device_Code, THE Flutter_App SHALL call the `claim_device` RPC via `patientSupabaseClient`.
5. WHEN `claim_device` returns `{"success": true}`, THE Flutter_App SHALL display a success confirmation, wait for the user to acknowledge it, and then navigate back.
6. WHEN `claim_device` returns `{"error": "device_not_found"}`, THE Flutter_App SHALL display the message "Device code not found. Check the code and try again."
7. WHEN `claim_device` returns `{"error": "device_already_claimed"}`, THE Flutter_App SHALL display the message "This device is already paired to another account."
8. WHEN the network call fails, THE Flutter_App SHALL display a generic retry error message and allow the user to try again.

---

### Requirement 12: Flutter App — Device Status Card

**User Story:** As a patient or clinician, I want a device status card on the home or dashboard screen so that I can see whether my Device is online, its battery level, last sync time, and how many measurements are pending upload.

#### Acceptance Criteria

1. THE Flutter_App SHALL display a device status card on the patient home and doctor/specialist dashboard screens when a Device is claimed by the signed-in user.
2. THE Flutter_App SHALL show an "Online" indicator when the device's `last_seen_at` is within 5 minutes of the current time, and "Offline" otherwise.
3. THE Flutter_App SHALL display the device's `battery_pct` as a percentage with a battery icon.
4. THE Flutter_App SHALL display `last_seen_at` as a human-readable relative time (e.g., "3 minutes ago").
5. THE Flutter_App SHALL display the count of Measurement rows for this device where `time_valid = false` as "pending uploads".
6. WHEN the device has no claimed owner matching the signed-in user, THE Flutter_App SHALL not display the device status card.

---

### Requirement 13: Flutter App — BLE Epoch Field

**User Story:** As a Device, I want the Flutter app to write the current Unix epoch time over BLE when provisioning Wi-Fi credentials so that the device has a usable time reference before NTP synchronizes.

#### Acceptance Criteria

1. THE Flutter_App SHALL add an `epoch` field (Unix timestamp, integer seconds) to the JSON object written to the `WIFI_CREDS` BLE characteristic (UUID `6b1a0003-4b4a-4a3f-9f0a-3a2b6c8e1a10`).
2. WHEN writing BLE Wi-Fi credentials, THE Flutter_App SHALL set `epoch` to `DateTime.now().millisecondsSinceEpoch ~/ 1000`.
3. THE Flutter_App SHALL write the updated payload as `{"ssid":"...","password":"...","epoch":<unix_ts>}`.
4. THE BLE provisioning service (`ble_provisioning_service.dart`) SHALL be updated to include the epoch field in all credential writes without altering the existing SSID/password logic.

---

### Requirement 14: Flutter App — Supabase Measurement Display

**User Story:** As a patient, I want measurements uploaded by my Device to appear in the existing dashboards alongside app-entered readings so that I have a single unified history.

#### Acceptance Criteria

1. THE Flutter_App SHALL fetch Measurement rows from the `measurements` Supabase table for the signed-in user's device(s) via `patientSupabaseClient`.
2. THE Flutter_App SHALL merge device Measurement rows with existing Digital_Ocean test history in chronological order on the assessment history and dashboard screens.
3. WHEN a Measurement row has `time_valid = false`, THE Flutter_App SHALL display a "Time Estimated" badge on that measurement entry.
4. WHEN a Measurement row has `time_source = 'corrected'`, THE Flutter_App SHALL include that row in the "Time Estimated" badge display.
5. THE Flutter_App SHALL NOT remove or alter the existing Digital_Ocean data fetching logic during the parallel migration.

---

### Requirement 15: Flutter App — Environment Configuration

**User Story:** As a developer, I want the Supabase URL and publishable (anon) key to be injectable at build time via environment config so that no secret credentials are bundled in the app binary.

#### Acceptance Criteria

1. THE Flutter_App SHALL read the Supabase project URL from the `--dart-define` key `PATIENT_SUPABASE_URL`, falling back to the existing default URL.
2. THE Flutter_App SHALL read the Supabase anon (publishable) key from the `--dart-define` key `PATIENT_SUPABASE_ANON_KEY`, falling back to the existing default key.
3. THE Flutter_App SHALL NOT include the Supabase service role key or any other privileged secret in the app source or binary.
4. THE Flutter_App SHALL use only the anon key (`patientSupabaseClient`) for all user-facing operations; privileged operations SHALL be performed by the Device_Sync_Function using its server-side service role.

---

### Requirement 16: ESP32 Firmware — Display and LVGL UI

**User Story:** As a device user, I want the ESP32-3248S035 touchscreen to show test status, measurement results, pairing QR code, and sync state so that the device is operable without a smartphone.

#### Acceptance Criteria

1. THE Device SHALL initialize the ST7796 display driver at 320×480 resolution on boot.
2. THE Device SHALL run LVGL for all UI rendering.
3. THE Device SHALL display a QR code encoding the URI `vitalstep://pair?code=<Device_Code>` on the main screen when unclaimed.
4. WHEN a test is in progress, THE Device SHALL display the current trial number, live weight reading in kg, and a progress indicator.
5. WHEN a test completes, THE Device SHALL display all three trial values and the computed average in kg.
6. THE Device SHALL display the current battery percentage and a charging indicator on all screens.
7. THE Device SHALL display the sync status (last sync time, pending uploads count) on the main screen.
8. WHEN the device is offline, THE Device SHALL display an "Offline" indicator on the main screen.

---

### Requirement 17: ESP32 Firmware — SD Card Queue

**User Story:** As a Device, I want each completed measurement saved to the SD card as a JSON file so that results are never lost when the network is unavailable at test time.

#### Acceptance Criteria

1. WHEN a test completes, THE Device SHALL write a JSON file to the SD card before attempting any network upload.
2. THE Device SHALL name each SD card file using the pattern `/queue/<timestamp>_<trial1>.json` where `<timestamp>` is the Unix epoch at measurement time and `<trial1>` is the first trial value.
3. THE JSON file SHALL contain: `device_code`, `trial1`, `trial2`, `trial3`, `hand`, `posture`, `battery_pct`, `battery_v`, `is_charging`, `measured_at` (ISO 8601), `time_source`, `time_valid`.
4. WHEN a file is successfully uploaded to the Device_Sync_Function, THE Device SHALL delete that file from the SD card.
5. WHEN the SD card cannot be written, THE Device SHALL log the error, display a warning on screen, and attempt a direct network upload of the measurement from memory as a fallback for that test.
6. THE SD card queue parser SHALL produce an equivalent object when re-reading a file that was previously written (round-trip property: `parse(write(record)) == record`).

---

### Requirement 18: ESP32 Firmware — HTTPS Sync

**User Story:** As a Device, I want to upload queued measurements and receive assessment assignments over HTTPS so that data flows between the device and the backend reliably.

#### Acceptance Criteria

1. THE Device SHALL make HTTPS POST requests to the Device_Sync_Function with headers `apikey: <supabase_anon_key>`, `x-device-code: <Device_Code>`, and `x-device-secret: <Device_Secret>`.
2. THE Device SHALL upload up to 6 queued SD card files per sync request.
3. WHEN the sync response contains a `server_time` field, THE Device SHALL update its internal clock to `server_time`.
4. WHEN the sync response contains a non-empty `queue` array, THE Device SHALL store the pending assessment and present it on the touchscreen for the user to start.
5. WHEN the sync response contains a non-empty `history` array, THE Device SHALL update its local display of recent results.
6. THE Device SHALL follow this sync cadence: immediately after a test completes (regardless of pending files); every 15 seconds while SD card files are pending; every 4 seconds while unpaired (to detect claim events); every 180 seconds as a heartbeat when paired and idle.
7. IF a sync request fails due to a network error, THEN THE Device SHALL retry on the next cadence interval without deleting SD card files.

---

### Requirement 19: ESP32 Firmware — Battery Monitoring

**User Story:** As a device user, I want accurate battery state information on the device screen and in uploaded measurements so that I know when to charge the device.

#### Acceptance Criteria

1. THE Device SHALL read battery voltage from the ADC pin connected to the 2×18650 series battery pack.
2. THE Device SHALL compute `battery_pct` as an integer percentage by mapping the measured voltage against the discharge curve of two 18650 cells in series (8.4 V = 100%, 6.0 V = 0%).
3. THE Device SHALL set `is_charging` to true when the charging circuit's charge-indicator signal is active.
4. THE Device SHALL include `battery_pct`, `battery_v`, and `is_charging` in every Measurement record and every sync request body.
5. THE Device SHALL refresh battery readings at least once every 30 seconds.

---

### Requirement 20: ESP32 Firmware — Time Handling

**User Story:** As a Device, I want to record accurate timestamps for every measurement so that the data is useful for clinical trend analysis even when NTP was not available at test time.

#### Acceptance Criteria

1. WHEN the device boots and has Wi-Fi, THE Device SHALL synchronize its RTC via NTP and set `time_source = 'ntp'` for subsequent measurements.
2. WHEN NTP fails but the Device_Sync_Function returns a `server_time`, THE Device SHALL set its clock from `server_time` and set `time_source = 'server_time'` for subsequent measurements.
3. WHEN neither NTP nor `server_time` is available but a BLE_Epoch was received, THE Device SHALL derive the measurement timestamp as `BLE_Epoch + elapsed_seconds_since_ble_write` and set `time_source = 'corrected'` and `time_valid = false`.
4. WHEN no time source is available, THE Device SHALL set `time_valid = false` and use an approximate elapsed timestamp.
5. THE Device SHALL include `time_source` and `time_valid` in every Measurement JSON file and every upload payload.

---

### Requirement 21: ESP32 Firmware — Device Pairing via QR Code

**User Story:** As a patient or clinician, I want to scan the QR code shown on the device screen to initiate pairing in the Flutter app so that pairing does not require manual code entry.

#### Acceptance Criteria

1. WHEN the Device is unclaimed (`owner_user_id` IS NULL as reported in the sync response), THE Device SHALL display a QR code on the touchscreen encoding the URI `vitalstep://pair?code=<Device_Code>`.
2. WHEN the Device receives a sync response with `owner.claimed = true`, THE Device SHALL remove the QR code display and show the main measurement screen.
3. THE QR code SHALL be rendered using an LVGL-compatible QR code library or manually drawn pixels on the ST7796 display.
4. THE Device_Code used in the QR code SHALL be the value read from the SD card file written by the Admin_Script.
5. WHEN the Device is unclaimed and the Device_Code cannot be read from the SD card (file missing, corrupt, or not yet written), THE Device SHALL display an error screen indicating that pairing is unavailable until the SD card is correctly provisioned.

---

### Requirement 22: Parallel Migration — Digital Ocean Preservation

**User Story:** As a product owner, I want the Digital Ocean backend to remain fully operational throughout the Supabase migration so that existing users experience no downtime.

#### Acceptance Criteria

1. THE Flutter_App SHALL continue calling all existing Digital_Ocean API endpoints (`/api/auth/*`, `/api/user/*`, `/api/specialist/*`, `/api/assessment/*`, `/api/test/*`, `/api/device*`) without modification.
2. THE Flutter_App SHALL add Supabase data sources as supplementary paths only, never replacing Digital_Ocean calls during the migration.
3. WHEN a Digital_Ocean call fails, THE Flutter_App SHALL NOT fall back to the Supabase path; the error handling SHALL remain unchanged from the existing implementation.
4. THE Codebase SHALL document the exact conditions under which each Digital_Ocean endpoint can be decommissioned (post-verification checklist).
5. WHEN all features described in Requirements 11–21 are verified end-to-end in production, THE Team SHALL update `DEVELOPER_NOTES.md` to reflect the decommission plan before removing any Digital_Ocean URL.

---

### Requirement 23: Specialist and Patient Account Parity in App v2

**User Story:** As a specialist (doctor) or patient, I want all my existing account features to work in the new Supabase-backed app so that I lose no functionality when switching to the new version.

#### Acceptance Criteria

1. THE App_v2 SHALL support specialist account login, signup, and dashboard using the Supabase auth and data layer.
2. THE App_v2 SHALL support patient account login, signup, and dashboard using the Supabase auth and data layer.
3. THE App_v2 SHALL preserve the specialist-patient linking feature (doctor sees linked patients and their data).
4. THE App_v2 SHALL preserve the assessment creation flow for specialists (hand, posture, title fields now also sent to device queue).
5. THE App_v2 SHALL preserve all existing app screens and navigation — no UI screens shall be removed.
6. WHEN a specialist views a patient's dashboard in App_v2, THE App_v2 SHALL show both Digital_Ocean legacy test results AND new Supabase measurements in a unified timeline.

---

### Requirement 24: Digital Ocean Backend Preserved Permanently

**User Story:** As a product owner, I want the Digital Ocean backend to remain fully operational and unchanged so that existing App_v1 users and old ESP32 devices continue working without interruption.

#### Acceptance Criteria

1. THE App_v1 (existing app) SHALL continue operating against the Digital_Ocean backend at `https://plankton-app-6cr5g.ondigitalocean.app/api` without any code changes.
2. THE Digital_Ocean backend SHALL NOT be decommissioned, and no Digital_Ocean API endpoints SHALL be removed from the codebase.
3. THE App_v2 codebase SHALL be a separate Flutter build flavor (or separate project copy) that shares all UI code but switches the data layer to Supabase.
4. WHEN a user is on App_v1, ALL data operations SHALL go to Digital_Ocean only.
5. WHEN a user is on App_v2, NEW data operations (devices, measurements, new assessments) SHALL go to Supabase, while legacy data display can include both sources.

---

### Requirement 25: App v2 Visual Identity — Refined Color Scheme

**User Story:** As a product owner, I want App v2 to have a slightly different visual identity from App v1 so that users and developers can distinguish the two versions at a glance.

#### Acceptance Criteria

1. THE App_v2 SHALL retain the existing sea-green teal primary color (`#00796B`) as the main brand color.
2. THE App_v2 SHALL introduce a warm coral/amber accent color (`#FF6B35` or similar warm tone) to complement the existing teal palette.
3. THE App_v2 SHALL update `app_colors.dart` for the v2 build to add the new accent color without removing any existing color constants.
4. THE App_v2 SHALL apply the new accent color to key interactive elements such as call-to-action buttons, badge highlights, and active tab indicators.
5. THE App_v2 color palette SHALL remain accessible (minimum WCAG AA contrast ratio of 4.5:1 for text on backgrounds).
6. THE App_v2 SHALL display a small "v2" version tag or a subtle color-coded indicator on the splash/login screen so users know which version they are running.
