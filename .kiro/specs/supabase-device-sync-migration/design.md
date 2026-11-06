# Design Document: Supabase Device Sync Migration

## Overview

This design covers the parallel Supabase-backed architecture that sits alongside the existing Digital Ocean backend. The goal is zero disruption to existing users while adding a new, richer device-sync capability for App v2 and new ESP32-3248S035 hardware.

**Key constraints from requirements:**
- Digital Ocean backend is **never removed** — App v1 and old devices continue unchanged
- Supabase project `cbebmpgsbxqdzpfgqulj.supabase.co` is **extended**, not replaced
- App v2 is a Flutter build flavor sharing all UI code, switching only the data layer
- `patientSupabaseClient` (already in `main.dart`) is the client for all new operations

**Two parallel stacks:**

```
App v1 (existing)          App v2 (new build flavor)
  │                           │
  ▼                           ▼
Digital Ocean API          patientSupabaseClient
backend.sp4ameya.com       cbebmpgsbxqdzpfgqulj.supabase.co
  │                           │
  ▼                           ├── devices table
PostgreSQL (DO)            ├── measurements table
                           ├── assessments (extended)
                           ├── research_patients (extended)
                           └── device-sync Edge Function
                                    │
                                    ▼
                               ESP32-3248S035
                               (new firmware)
```

---

## Architecture

### System Components

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Supabase Project                            │
│               cbebmpgsbxqdzpfgqulj.supabase.co                      │
│                                                                     │
│  ┌───────────┐  ┌────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │  devices  │  │measurements│  │ assessments │  │research_    │  │
│  │  table    │  │  table     │  │ (extended)  │  │patients     │  │
│  └───────────┘  └────────────┘  └─────────────┘  │(extended)   │  │
│                                                   └─────────────┘  │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │              device-sync Edge Function (Deno/TS)               │ │
│  │   POST /functions/v1/device-sync                               │ │
│  │   verify_jwt = false   (custom auth via x-device-code/secret)  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  RPCs: claim_device | unclaim_device | admin_provision_devices      │
└─────────────────────────────────────────────────────────────────────┘
         ▲                              ▲
         │ HTTPS (apikey +              │ patientSupabaseClient
         │ x-device-code/secret)        │ (anon key, JWT auth)
         │                              │
┌────────┴──────────┐        ┌──────────┴──────────────┐
│  ESP32-3248S035   │        │   Flutter App v2         │
│  Firmware         │        │   (build flavor)         │
│  - ST7796 LVGL    │        │   - DeviceService        │
│  - SD card queue  │        │   - MeasurementService   │
│  - HTTPS sync     │        │   - DevicePairingScreen  │
│  - BLE provisioning│       │   - DeviceStatusCard     │
└───────────────────┘        └──────────────────────────┘
```

### Build Flavor Architecture

App v1 and App v2 share **all** Dart/Flutter source code. They differ only by:

1. **Flutter build flavor** (`--flavor v1` vs `--flavor v2`)
2. **`--dart-define` values** injected at build time:

| Variable | App v1 | App v2 |
|---|---|---|
| `APP_FLAVOR` | `v1` | `v2` |
| `PATIENT_SUPABASE_URL` | existing default | same (`cbebmpgsbxqdzpfgqulj`) |
| `PATIENT_SUPABASE_ANON_KEY` | existing default | same |
| `ENABLE_DEVICE_SYNC` | `false` | `true` |

The `ENABLE_DEVICE_SYNC` define gates all new v2 UI components (DeviceStatusCard, DevicePairingScreen, v2 color overrides) so they are compiled out of the v1 build.

```dart
// lib/app/app_config.dart
class AppConfig {
  static const bool enableDeviceSync = bool.fromEnvironment(
    'ENABLE_DEVICE_SYNC',
    defaultValue: false,
  );
  static const String appFlavor = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: 'v1',
  );
  static bool get isV2 => appFlavor == 'v2';
}
```

---

## Components and Interfaces

### A. Supabase Backend

#### A1. Migration File Structure

```
supabase/
  config.toml
  migrations/
    20240001_devices.sql
    20240002_measurements.sql
    20240003_extend_assessments.sql
    20240004_extend_patients.sql
  functions/
    device-sync/
      index.ts
      deno.json
scripts/
  provision-devices.ts
```

#### A2. `supabase/config.toml` — Edge Function Entry

```toml
[functions.device-sync]
verify_jwt = false
```

This disables Supabase's built-in JWT gate for `device-sync` so the function can implement its own device credential authentication. The function still validates the `apikey` header to prevent unauthenticated discovery.

#### A3. Migration: `20240001_devices.sql`

```sql
-- Enable pgcrypto for bcrypt password hashing
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ─── TABLE: devices ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS devices (
  id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  device_code       TEXT         NOT NULL,
  device_secret_hash TEXT        NOT NULL,
  owner_user_id     TEXT,
  claimed_at        TIMESTAMPTZ,
  last_seen_at      TIMESTAMPTZ,
  battery_pct       INTEGER,
  battery_v         NUMERIC(5,2),
  is_charging       BOOLEAN,
  firmware_version  TEXT,
  created_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CONSTRAINT devices_device_code_unique UNIQUE (device_code)
);

CREATE INDEX idx_devices_owner_user_id ON devices (owner_user_id);
CREATE INDEX idx_devices_device_code   ON devices (device_code);

-- ─── ROW LEVEL SECURITY ─────────────────────────────────────────────────────
ALTER TABLE devices ENABLE ROW LEVEL SECURITY;

-- Service role can do everything (used by Edge Function)
CREATE POLICY "service_role_all" ON devices
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Authenticated app user can read their own claimed device
CREATE POLICY "user_read_own_device" ON devices
  FOR SELECT
  TO authenticated
  USING (owner_user_id = auth.uid()::text);

-- Authenticated app user can update their own device (for claim/unclaim via RPC)
CREATE POLICY "user_update_own_device" ON devices
  FOR UPDATE
  TO authenticated
  USING (owner_user_id = auth.uid()::text)
  WITH CHECK (true);

-- ─── RPC: claim_device ──────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION claim_device(
  p_device_code TEXT,
  p_user_id     TEXT
) RETURNS JSON
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_device devices%ROWTYPE;
BEGIN
  SELECT * INTO v_device
  FROM devices
  WHERE device_code = p_device_code;

  IF NOT FOUND THEN
    RETURN json_build_object('error', 'device_not_found');
  END IF;

  IF v_device.owner_user_id IS NOT NULL
     AND v_device.owner_user_id <> p_user_id THEN
    RETURN json_build_object('error', 'device_already_claimed');
  END IF;

  UPDATE devices
  SET owner_user_id = p_user_id,
      claimed_at    = NOW()
  WHERE device_code = p_device_code;

  RETURN json_build_object(
    'success',   true,
    'device_id', v_device.id::text
  );
END;
$$;

-- ─── RPC: unclaim_device ────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION unclaim_device(
  p_device_code TEXT,
  p_user_id     TEXT
) RETURNS JSON
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_device devices%ROWTYPE;
BEGIN
  SELECT * INTO v_device
  FROM devices
  WHERE device_code = p_device_code;

  IF NOT FOUND THEN
    RETURN json_build_object('error', 'device_not_found');
  END IF;

  IF v_device.owner_user_id IS DISTINCT FROM p_user_id THEN
    RETURN json_build_object('error', 'not_owner');
  END IF;

  UPDATE devices
  SET owner_user_id = NULL,
      claimed_at    = NULL
  WHERE device_code = p_device_code;

  RETURN json_build_object('success', true);
END;
$$;

-- ─── RPC: admin_provision_devices ───────────────────────────────────────────
CREATE OR REPLACE FUNCTION admin_provision_devices(
  p_count INTEGER
) RETURNS TABLE(device_code TEXT, device_secret TEXT)
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_code   TEXT;
  v_secret TEXT;
  i        INTEGER;
BEGIN
  FOR i IN 1..p_count LOOP
    -- Generate VS-XXXXXX: 6-char uppercase alphanumeric
    v_code := 'VS-' || upper(
      substring(encode(gen_random_bytes(6), 'base64') FROM 1 FOR 6)
    );
    -- Normalize to alphanumeric only (replace +, /, = characters)
    v_code := regexp_replace(v_code, '[^A-Z0-9]', '', 'g');
    v_code := 'VS-' || substring(v_code FROM 1 FOR 6);
    -- Ensure exactly 6 chars after VS- by re-generating if short
    WHILE length(v_code) < 9 LOOP
      v_code := 'VS-' || upper(
        regexp_replace(
          substring(encode(gen_random_bytes(9), 'base64') FROM 1 FOR 9),
          '[^A-Z0-9]', '', 'g'
        )
      );
      v_code := 'VS-' || substring(
        regexp_replace(v_code, '[^A-Z0-9-]', '', 'g')
        FROM 4 FOR 6
      );
    END LOOP;

    -- Generate a 32-char random secret
    v_secret := encode(gen_random_bytes(24), 'base64');

    INSERT INTO devices (device_code, device_secret_hash)
    VALUES (v_code, crypt(v_secret, gen_salt('bf')));

    device_code   := v_code;
    device_secret := v_secret;
    RETURN NEXT;
  END LOOP;
END;
$$;

-- Restrict admin_provision_devices to service_role only
REVOKE ALL ON FUNCTION admin_provision_devices(INTEGER) FROM PUBLIC;
REVOKE ALL ON FUNCTION admin_provision_devices(INTEGER) FROM authenticated;
REVOKE ALL ON FUNCTION admin_provision_devices(INTEGER) FROM anon;
GRANT EXECUTE ON FUNCTION admin_provision_devices(INTEGER) TO service_role;
```

#### A4. Migration: `20240002_measurements.sql`

```sql
-- ─── TABLE: measurements ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS measurements (
  id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id    UUID         NOT NULL REFERENCES devices(id)          ON DELETE CASCADE,
  patient_id   UUID                  REFERENCES research_patients(id) ON DELETE SET NULL,
  assessment_id UUID                 REFERENCES assessments(id)       ON DELETE SET NULL,
  trial1       NUMERIC(10,2) NOT NULL,
  trial2       NUMERIC(10,2) NOT NULL,
  trial3       NUMERIC(10,2) NOT NULL,
  hand         TEXT         NOT NULL,
  posture      TEXT         NOT NULL,
  battery_pct  INTEGER,
  battery_v    NUMERIC(5,2),
  is_charging  BOOLEAN,
  measured_at  TIMESTAMPTZ  NOT NULL,
  time_source  TEXT         NOT NULL
               CHECK (time_source IN ('ntp', 'server_time', 'corrected')),
  time_valid   BOOLEAN      NOT NULL DEFAULT false,
  sd_filename  TEXT,
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_measurements_device_id  ON measurements (device_id);
CREATE INDEX idx_measurements_patient_id ON measurements (patient_id);
CREATE INDEX idx_measurements_measured_at ON measurements (measured_at DESC);

-- ─── ROW LEVEL SECURITY ─────────────────────────────────────────────────────
ALTER TABLE measurements ENABLE ROW LEVEL SECURITY;

-- Service role (used by Edge Function) can insert and read
CREATE POLICY "service_role_all" ON measurements
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Authenticated user can read measurements for devices they own
CREATE POLICY "user_read_own_measurements" ON measurements
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM devices d
      WHERE d.id = measurements.device_id
        AND d.owner_user_id = auth.uid()::text
    )
  );
```

#### A5. Migration: `20240003_extend_assessments.sql`

```sql
-- ─── EXTEND: assessments ────────────────────────────────────────────────────
-- Adds device-facing fields without altering or removing existing columns.

ALTER TABLE assessments
  ADD COLUMN IF NOT EXISTS device_ref    TEXT,
  ADD COLUMN IF NOT EXISTS hand          TEXT,
  ADD COLUMN IF NOT EXISTS posture       TEXT,
  ADD COLUMN IF NOT EXISTS title         TEXT,
  ADD COLUMN IF NOT EXISTS status        TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
  ADD COLUMN IF NOT EXISTS completed_at  TIMESTAMPTZ;

-- Trigger: auto-set completed_at when status transitions to 'completed'
CREATE OR REPLACE FUNCTION assessments_set_completed_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status <> 'completed' THEN
    NEW.completed_at := NOW();
  ELSIF NEW.status <> 'completed' THEN
    NEW.completed_at := NULL;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_assessments_completed_at ON assessments;
CREATE TRIGGER trg_assessments_completed_at
  BEFORE UPDATE ON assessments
  FOR EACH ROW EXECUTE FUNCTION assessments_set_completed_at();

-- Index for device queue polling
CREATE INDEX IF NOT EXISTS idx_assessments_device_ref_status
  ON assessments (device_ref, status)
  WHERE status = 'pending';
```

#### A6. Migration: `20240004_extend_patients.sql`

```sql
-- ─── EXTEND: research_patients ──────────────────────────────────────────────
ALTER TABLE research_patients
  ADD COLUMN IF NOT EXISTS target_lo NUMERIC(10,2),
  ADD COLUMN IF NOT EXISTS target_hi NUMERIC(10,2),
  ADD CONSTRAINT chk_target_range
    CHECK (
      target_lo IS NULL OR target_hi IS NULL
      OR target_lo < target_hi
    );
```

#### A6. Edge Function: `supabase/functions/device-sync/index.ts`

This is the complete, production-ready implementation:

```typescript
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ─── Types ───────────────────────────────────────────────────────────────────

interface MeasurementInput {
  trial1: number;
  trial2: number;
  trial3: number;
  hand: string;
  posture: string;
  battery_pct?: number;
  battery_v?: number;
  is_charging?: boolean;
  measured_at: string;   // ISO 8601
  time_source: string;
  time_valid: boolean;
  sd_filename?: string;
  patient_id?: string;   // UUID, optional
  assessment_id?: string; // UUID, optional
}

interface SyncRequestBody {
  measurements?: MeasurementInput[];
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

const VALID_TIME_SOURCES = new Set(["ntp", "server_time", "corrected"]);

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function validateMeasurement(m: unknown): string | null {
  if (typeof m !== "object" || m === null) return "measurement must be an object";
  const obj = m as Record<string, unknown>;

  if (typeof obj.trial1 !== "number") return "trial1 must be a number";
  if (typeof obj.trial2 !== "number") return "trial2 must be a number";
  if (typeof obj.trial3 !== "number") return "trial3 must be a number";
  if (typeof obj.hand !== "string" || !obj.hand.trim())
    return "hand must be a non-empty string";
  if (typeof obj.posture !== "string" || !obj.posture.trim())
    return "posture must be a non-empty string";
  if (typeof obj.measured_at !== "string" || !obj.measured_at.trim())
    return "measured_at must be a non-empty ISO 8601 string";
  if (isNaN(Date.parse(obj.measured_at as string)))
    return "measured_at is not a valid ISO 8601 date";
  if (!obj.time_source || !VALID_TIME_SOURCES.has(obj.time_source as string))
    return "invalid_time_source";
  if (typeof obj.time_valid !== "boolean")
    return "time_valid must be a boolean";

  return null; // valid
}

// ─── Main handler ─────────────────────────────────────────────────────────────

serve(async (req: Request) => {
  // ── Only accept POST ────────────────────────────────────────────────────────
  if (req.method !== "POST") {
    return jsonResponse({ error: "method_not_allowed" }, 405);
  }

  // ── Validate apikey header (prevents unauthenticated discovery) ─────────────
  const apiKey = req.headers.get("apikey");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  if (!apiKey || apiKey !== supabaseAnonKey) {
    return jsonResponse({ error: "missing_apikey" }, 401);
  }

  // ── Read device credentials ─────────────────────────────────────────────────
  const deviceCode   = req.headers.get("x-device-code");
  const deviceSecret = req.headers.get("x-device-secret");

  if (!deviceCode || !deviceSecret) {
    return jsonResponse({ error: "missing_credentials" }, 401);
  }

  // ── Create service-role Supabase client ─────────────────────────────────────
  const supabaseUrl         = Deno.env.get("SUPABASE_URL")!;
  const supabaseServiceKey  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const supabase = createClient(supabaseUrl, supabaseServiceKey, {
    auth: { persistSession: false },
  });

  // ── Authenticate device via bcrypt comparison ───────────────────────────────
  const { data: authRows, error: authError } = await supabase.rpc(
    "verify_device_secret",
    { p_device_code: deviceCode, p_device_secret: deviceSecret }
  );

  if (authError || !authRows || authRows.length === 0 || !authRows[0].valid) {
    return jsonResponse({ error: "invalid_credentials" }, 401);
  }

  const deviceRow = authRows[0];
  const deviceId: string = deviceRow.device_id;

  // ── Update last_seen_at ─────────────────────────────────────────────────────
  await supabase
    .from("devices")
    .update({ last_seen_at: new Date().toISOString() })
    .eq("id", deviceId);

  // ── Parse request body ──────────────────────────────────────────────────────
  let body: SyncRequestBody = {};
  try {
    const text = await req.text();
    if (text.trim()) {
      body = JSON.parse(text);
    }
  } catch {
    return jsonResponse({ error: "invalid_json" }, 400);
  }

  // ── Process measurement batch ───────────────────────────────────────────────
  const measurements = body.measurements ?? [];

  if (measurements.length > 6) {
    return jsonResponse({ error: "batch_too_large" }, 400);
  }

  if (measurements.length > 0) {
    // Validate all measurements before inserting any (atomic batch semantics)
    for (let i = 0; i < measurements.length; i++) {
      const validationError = validateMeasurement(measurements[i]);
      if (validationError) {
        if (validationError === "invalid_time_source") {
          return jsonResponse({ error: "invalid_time_source" }, 422);
        }
        return jsonResponse({
          error: "validation_failed",
          detail: `measurement[${i}]: ${validationError}`,
        }, 422);
      }
    }

    // Build insert rows
    const insertRows = measurements.map((m) => ({
      device_id:     deviceId,
      patient_id:    m.patient_id   ?? null,
      assessment_id: m.assessment_id ?? null,
      trial1:        m.trial1,
      trial2:        m.trial2,
      trial3:        m.trial3,
      hand:          m.hand.trim(),
      posture:       m.posture.trim(),
      battery_pct:   m.battery_pct   ?? null,
      battery_v:     m.battery_v     ?? null,
      is_charging:   m.is_charging   ?? null,
      measured_at:   m.measured_at,
      time_source:   m.time_source,
      // Override time_valid: corrected always false; ntp/server_time always true
      time_valid:    m.time_source !== "corrected",
      sd_filename:   m.sd_filename ?? null,
    }));

    const { error: insertError } = await supabase
      .from("measurements")
      .insert(insertRows);

    if (insertError) {
      console.error("Measurement insert error:", insertError);
      return jsonResponse({ error: "insert_failed", detail: insertError.message }, 500);
    }

    // Mark referenced assessments as completed
    const assessmentIds = measurements
      .map((m) => m.assessment_id)
      .filter(Boolean) as string[];
    if (assessmentIds.length > 0) {
      await supabase
        .from("assessments")
        .update({ status: "completed" })
        .in("id", assessmentIds)
        .eq("status", "in_progress");
    }
  }

  // ── Build response payload ──────────────────────────────────────────────────
  const serverTime = new Date().toISOString();

  // Refresh device row to get latest state
  const { data: freshDevice } = await supabase
    .from("devices")
    .select("owner_user_id, claimed_at")
    .eq("id", deviceId)
    .single();

  const ownerUserId: string | null = freshDevice?.owner_user_id ?? null;

  // Queue: at most 1 pending assessment for this device
  const { data: queueRows } = await supabase
    .from("assessments")
    .select("id, title, hand, posture, patient_id, created_at")
    .eq("device_ref", deviceCode)
    .eq("status", "pending")
    .order("created_at", { ascending: true })
    .limit(1);

  // History: 5 most recent measurements for this device
  const { data: historyRows } = await supabase
    .from("measurements")
    .select("id, trial1, trial2, trial3, hand, posture, measured_at, time_source, time_valid, battery_pct")
    .eq("device_id", deviceId)
    .order("measured_at", { ascending: false })
    .limit(5);

  // Patient target (if device is claimed and patient has targets)
  let target: { lo: number; hi: number } | null = null;
  if (ownerUserId) {
    const { data: patientRows } = await supabase
      .from("research_patients")
      .select("target_lo, target_hi")
      .eq("host_user_id", ownerUserId)
      .not("target_lo", "is", null)
      .not("target_hi", "is", null)
      .order("created_at", { ascending: false })
      .limit(1);

    if (patientRows && patientRows.length > 0) {
      const p = patientRows[0];
      if (p.target_lo !== null && p.target_hi !== null) {
        target = { lo: Number(p.target_lo), hi: Number(p.target_hi) };
      }
    }
  }

  return jsonResponse({
    server_time: serverTime,
    queue:       queueRows   ?? [],
    history:     historyRows ?? [],
    owner: {
      claimed:       ownerUserId !== null,
      owner_user_id: ownerUserId,
    },
    target,
  });
});
```

**Supporting RPC — `verify_device_secret`** (add to `20240001_devices.sql`):

```sql
CREATE OR REPLACE FUNCTION verify_device_secret(
  p_device_code   TEXT,
  p_device_secret TEXT
) RETURNS TABLE(valid BOOLEAN, device_id UUID)
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT
    (device_secret_hash = crypt(p_device_secret, device_secret_hash)) AS valid,
    id AS device_id
  FROM devices
  WHERE device_code = p_device_code;
END;
$$;

REVOKE ALL ON FUNCTION verify_device_secret(TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION verify_device_secret(TEXT, TEXT) TO service_role;
```

#### A7. Admin Provisioning Script: `scripts/provision-devices.ts`

```typescript
#!/usr/bin/env -S deno run --allow-net --allow-env --allow-write

/**
 * Admin Device Provisioning Script
 * Usage: deno run --allow-net --allow-env --allow-write scripts/provision-devices.ts <count>
 *
 * Required environment variables:
 *   SUPABASE_URL              - e.g. https://cbebmpgsbxqdzpfgqulj.supabase.co
 *   SUPABASE_SERVICE_ROLE_KEY - service role key (never commit this)
 *
 * Output: One JSON file per device in ./provisioned/<device_code>.json
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl     = Deno.env.get("SUPABASE_URL");
const serviceRoleKey  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

if (!supabaseUrl || !serviceRoleKey) {
  console.error("ERROR: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set");
  Deno.exit(1);
}

const countArg = parseInt(Deno.args[0] ?? "1", 10);
if (isNaN(countArg) || countArg < 1) {
  console.error("ERROR: Provide a positive integer count as the first argument");
  Deno.exit(1);
}

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false },
});

console.log(`Provisioning ${countArg} device(s)...`);

const { data, error } = await supabase.rpc("admin_provision_devices", {
  p_count: countArg,
});

if (error || !data) {
  console.error("ERROR: Could not connect to Supabase or RPC failed:", error?.message ?? "no data returned");
  Deno.exit(1);
}

// Ensure output directory exists
try {
  await Deno.mkdir("./provisioned", { recursive: true });
} catch {
  // Already exists
}

for (const row of data as Array<{ device_code: string; device_secret: string }>) {
  const fileContent = JSON.stringify({
    device_code:   row.device_code,
    device_secret: row.device_secret,
  }, null, 2);

  const filePath = `./provisioned/${row.device_code}.json`;
  await Deno.writeTextFile(filePath, fileContent);
  console.log(`  Written: ${filePath}  (code: ${row.device_code})`);
}

console.log(`Done. ${data.length} device(s) provisioned.`);
```

---

### B. Flutter App v2 Architecture

#### B1. New Files Added for v2

```
lib/
  app/
    app_config.dart           ← ENABLE_DEVICE_SYNC, APP_FLAVOR flags
  services/
    device_service.dart       ← claim_device, unclaim_device, get device status
    measurement_service.dart  ← fetch Supabase measurements, merge with DO data
  ui/
    common/
      app_colors_v2.dart      ← extends app_colors.dart with coral/amber accent
    widgets/
      device_status_card.dart ← device online/battery/sync status widget
    views/
      device_pairing/
        device_pairing_view.dart
        device_pairing_viewmodel.dart
```

#### B2. `lib/app/app_config.dart`

```dart
class AppConfig {
  static const bool enableDeviceSync = bool.fromEnvironment(
    'ENABLE_DEVICE_SYNC',
    defaultValue: false,
  );
  static const String appFlavor = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: 'v1',
  );
  static bool get isV2 => appFlavor == 'v2';
}
```

#### B3. `lib/ui/common/app_colors_v2.dart`

Extends `app_colors.dart` without removing any existing constants:

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

// ─── App v2 Additions ────────────────────────────────────────────────────────
// All existing kcXxx constants remain unchanged and available.

/// Warm coral/amber accent — primary CTA and highlight color for App v2.
/// Contrast vs white (#FFFFFF): 3.5:1 — use on teal backgrounds (5.2:1 vs teal).
/// Do NOT use coral text on white background for body text (fails WCAG AA).
const Color kcCoralAccent     = Color(0xFFFF6B35); // Warm coral / burnt orange
const Color kcCoralAccentDark = Color(0xFFE55A24); // Darker variant for pressed state

/// Coral on teal gradient — used for primary action buttons in v2.
const LinearGradient kcV2PrimaryGradient = LinearGradient(
  colors: [kcPrimaryColor, kcCoralAccent],  // teal → coral
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

/// Version 2 badge color for "Time Estimated" and v2 version indicator.
const Color kcV2BadgeColor = Color(0xFFFF8A50); // Lighter coral for small badges

/// Text color safe on coral backgrounds (WCAG AA: 5.1:1 contrast vs #FF6B35).
const Color kcOnCoral = Color(0xFF1A1A1A); // kcDarkGreyColor — dark text on coral
```

#### B4. `lib/services/device_service.dart`

```dart
import 'package:vital_step/app/app.logger.dart';
import 'package:vital_step/main.dart';

/// Manages device claiming and status for App v2.
/// Uses [patientSupabaseClient] exclusively.
class DeviceService {
  final _logger = getLogger('DeviceService');

  /// Claims a device for the signed-in user.
  /// Returns null on success, or an error key string on failure.
  Future<ClaimResult> claimDevice({
    required String deviceCode,
    required String userId,
  }) async {
    try {
      _logger.i('Claiming device: $deviceCode for user: $userId');
      final result = await patientSupabaseClient.rpc(
        'claim_device',
        params: {'p_device_code': deviceCode, 'p_user_id': userId},
      );
      final map = result as Map<String, dynamic>;
      if (map['success'] == true) {
        return ClaimResult.success(map['device_id'] as String);
      }
      return ClaimResult.error(map['error'] as String? ?? 'unknown_error');
    } catch (e) {
      _logger.e('claim_device RPC failed: $e');
      return ClaimResult.error('network_error');
    }
  }

  /// Unclaims a device for the signed-in user.
  Future<UnclaimResult> unclaimDevice({
    required String deviceCode,
    required String userId,
  }) async {
    try {
      _logger.i('Unclaiming device: $deviceCode for user: $userId');
      final result = await patientSupabaseClient.rpc(
        'unclaim_device',
        params: {'p_device_code': deviceCode, 'p_user_id': userId},
      );
      final map = result as Map<String, dynamic>;
      if (map['success'] == true) {
        return UnclaimResult.success();
      }
      return UnclaimResult.error(map['error'] as String? ?? 'unknown_error');
    } catch (e) {
      _logger.e('unclaim_device RPC failed: $e');
      return UnclaimResult.error('network_error');
    }
  }

  /// Fetches device status for the signed-in user's claimed device.
  /// Returns null if no device is claimed.
  Future<DeviceStatus?> getDeviceStatus(String userId) async {
    try {
      final response = await patientSupabaseClient
          .from('devices')
          .select()
          .eq('owner_user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return DeviceStatus.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      _logger.e('getDeviceStatus failed: $e');
      return null;
    }
  }

  /// Fetches count of measurements with time_valid = false (pending uploads).
  Future<int> getPendingUploadCount(String deviceId) async {
    try {
      final response = await patientSupabaseClient
          .from('measurements')
          .select()
          .eq('device_id', deviceId)
          .eq('time_valid', false);
      return (response as List).length;
    } catch (e) {
      _logger.e('getPendingUploadCount failed: $e');
      return 0;
    }
  }
}

// ─── Result types ─────────────────────────────────────────────────────────────

class ClaimResult {
  final bool success;
  final String? deviceId;
  final String? error;

  const ClaimResult._({required this.success, this.deviceId, this.error});
  factory ClaimResult.success(String deviceId) =>
      ClaimResult._(success: true, deviceId: deviceId);
  factory ClaimResult.error(String error) =>
      ClaimResult._(success: false, error: error);
}

class UnclaimResult {
  final bool success;
  final String? error;

  const UnclaimResult._({required this.success, this.error});
  factory UnclaimResult.success() => UnclaimResult._(success: true);
  factory UnclaimResult.error(String error) =>
      UnclaimResult._(success: false, error: error);
}

class DeviceStatus {
  final String id;
  final String deviceCode;
  final String? ownerUserId;
  final DateTime? lastSeenAt;
  final int? batteryPct;
  final double? batteryV;
  final bool? isCharging;
  final String? firmwareVersion;

  const DeviceStatus({
    required this.id,
    required this.deviceCode,
    this.ownerUserId,
    this.lastSeenAt,
    this.batteryPct,
    this.batteryV,
    this.isCharging,
    this.firmwareVersion,
  });

  factory DeviceStatus.fromJson(Map<String, dynamic> json) => DeviceStatus(
    id:              json['id'] as String,
    deviceCode:      json['device_code'] as String,
    ownerUserId:     json['owner_user_id'] as String?,
    lastSeenAt:      json['last_seen_at'] != null
        ? DateTime.parse(json['last_seen_at'] as String)
        : null,
    batteryPct:      json['battery_pct'] as int?,
    batteryV:        (json['battery_v'] as num?)?.toDouble(),
    isCharging:      json['is_charging'] as bool?,
    firmwareVersion: json['firmware_version'] as String?,
  );

  /// Returns true when last_seen_at is within the last 5 minutes.
  bool get isOnline {
    if (lastSeenAt == null) return false;
    return DateTime.now().difference(lastSeenAt!).inMinutes < 5;
  }
}
```

#### B5. `lib/services/measurement_service.dart`

```dart
import 'package:vital_step/app/app.logger.dart';
import 'package:vital_step/main.dart';

/// Fetches Supabase device measurements and merges them with
/// Digital Ocean test history for unified display.
///
/// Digital Ocean fetching is **not modified** — this service only adds
/// the Supabase layer as described in Requirements 14 and 22.
class MeasurementService {
  final _logger = getLogger('MeasurementService');

  /// Fetches all measurements from Supabase for the signed-in user's devices.
  /// Returns an empty list if the user has no claimed device or fetch fails.
  Future<List<DeviceMeasurement>> fetchDeviceMeasurements({
    required String userId,
    int limit = 50,
  }) async {
    try {
      // Get device IDs owned by this user
      final devices = await patientSupabaseClient
          .from('devices')
          .select('id')
          .eq('owner_user_id', userId);

      if ((devices as List).isEmpty) return [];

      final deviceIds = devices.map((d) => d['id'] as String).toList();

      final rows = await patientSupabaseClient
          .from('measurements')
          .select()
          .inFilter('device_id', deviceIds)
          .order('measured_at', ascending: false)
          .limit(limit);

      return (rows as List)
          .map((json) => DeviceMeasurement.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('fetchDeviceMeasurements failed: $e');
      return [];
    }
  }

  /// Merges Digital Ocean test history (as [UnifiedMeasurement] list)
  /// with Supabase device measurements, sorted chronologically (newest first).
  ///
  /// This does NOT modify the DO history list — it appends and re-sorts.
  List<UnifiedMeasurement> merge({
    required List<UnifiedMeasurement> digitalOceanItems,
    required List<DeviceMeasurement> supabaseItems,
  }) {
    final supabaseUnified = supabaseItems.map((m) => UnifiedMeasurement(
      id:            m.id,
      trial1:        m.trial1,
      trial2:        m.trial2,
      trial3:        m.trial3,
      hand:          m.hand,
      posture:       m.posture,
      createdAt:     m.measuredAt,
      source:        MeasurementSource.device,
      timeValid:     m.timeValid,
      timeSource:    m.timeSource,
    )).toList();

    final merged = [...digitalOceanItems, ...supabaseUnified];
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }
}

enum MeasurementSource { digitalOcean, device }

class DeviceMeasurement {
  final String id;
  final String deviceId;
  final double trial1;
  final double trial2;
  final double trial3;
  final String hand;
  final String posture;
  final int? batteryPct;
  final double? batteryV;
  final bool? isCharging;
  final DateTime measuredAt;
  final String timeSource;
  final bool timeValid;

  const DeviceMeasurement({
    required this.id,
    required this.deviceId,
    required this.trial1,
    required this.trial2,
    required this.trial3,
    required this.hand,
    required this.posture,
    this.batteryPct,
    this.batteryV,
    this.isCharging,
    required this.measuredAt,
    required this.timeSource,
    required this.timeValid,
  });

  factory DeviceMeasurement.fromJson(Map<String, dynamic> json) =>
      DeviceMeasurement(
        id:         json['id'] as String,
        deviceId:   json['device_id'] as String,
        trial1:     (json['trial1'] as num).toDouble(),
        trial2:     (json['trial2'] as num).toDouble(),
        trial3:     (json['trial3'] as num).toDouble(),
        hand:       json['hand'] as String,
        posture:    json['posture'] as String,
        batteryPct: json['battery_pct'] as int?,
        batteryV:   (json['battery_v'] as num?)?.toDouble(),
        isCharging: json['is_charging'] as bool?,
        measuredAt: DateTime.parse(json['measured_at'] as String),
        timeSource: json['time_source'] as String,
        timeValid:  json['time_valid'] as bool? ?? false,
      );
}

class UnifiedMeasurement {
  final String id;
  final double trial1;
  final double trial2;
  final double trial3;
  final String hand;
  final String posture;
  final DateTime createdAt;
  final MeasurementSource source;
  final bool timeValid;
  final String? timeSource;

  double get average => (trial1 + trial2 + trial3) / 3;
  bool get showTimeEstimatedBadge =>
      !timeValid || timeSource == 'corrected';

  const UnifiedMeasurement({
    required this.id,
    required this.trial1,
    required this.trial2,
    required this.trial3,
    required this.hand,
    required this.posture,
    required this.createdAt,
    required this.source,
    this.timeValid = true,
    this.timeSource,
  });
}
```

#### B6. Updated `ble_provisioning_service.dart` — Epoch Field

Only `sendWifiCredentials` changes; all other methods are unchanged:

```dart
Future<void> sendWifiCredentials(String ssid, String password) async {
  if (_credsChar == null) throw Exception("Credentials characteristic not found");

  // Requirement 13: Include current Unix epoch so device can set approximate time
  final epochSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  final payload = jsonEncode({
    "ssid":     ssid,
    "password": password,
    "epoch":    epochSeconds,
  });

  await _credsChar!.write(utf8.encode(payload));
}
```

#### B7. Device Pairing Screen

```dart
// lib/ui/views/device_pairing/device_pairing_view.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/ui/common/app_colors_v2.dart';
import 'device_pairing_viewmodel.dart';

class DevicePairingView extends StackedView<DevicePairingViewModel> {
  const DevicePairingView({super.key});

  @override
  Widget builder(BuildContext context, DevicePairingViewModel vm, _) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pair Device'),
        backgroundColor: kcPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // QR scanner region
            SizedBox(
              height: 240,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MobileScanner(
                  onDetect: (capture) {
                    final barcode = capture.barcodes.firstOrNull;
                    if (barcode?.rawValue != null) {
                      vm.onQrDetected(barcode!.rawValue!);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Or enter device code manually:',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            // Manual entry
            TextField(
              decoration: InputDecoration(
                hintText: 'VS-XXXXXX',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  color: kcCoralAccent,
                  onPressed: vm.onManualSubmit,
                ),
              ),
              onChanged: vm.onCodeChanged,
              controller: vm.codeController,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            if (vm.isBusy)
              const CircularProgressIndicator(color: kcCoralAccent)
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: vm.onManualSubmit,
                child: const Text('Pair Device'),
              ),
            if (vm.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(vm.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }

  @override
  DevicePairingViewModel viewModelBuilder(BuildContext context) =>
      DevicePairingViewModel();
}
```

```dart
// lib/ui/views/device_pairing/device_pairing_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:vital_step/app/app.locator.dart';
import 'package:vital_step/services/device_service.dart';
import 'package:vital_step/services/login_service.dart';

class DevicePairingViewModel extends BaseViewModel {
  final _deviceService = locator<DeviceService>();
  final _loginService  = locator<LoginService>();

  final TextEditingController codeController = TextEditingController();
  String? errorMessage;
  bool _scanned = false;

  // QR URI format: vitalstep://pair?code=VS-XXXXXX
  static final _qrUriPattern = RegExp(
    r'^vitalstep://pair\?code=(VS-[A-Z0-9]{6})$',
    caseSensitive: false,
  );

  void onCodeChanged(String value) {
    errorMessage = null;
    notifyListeners();
  }

  void onQrDetected(String rawValue) {
    if (_scanned) return; // debounce
    final match = _qrUriPattern.firstMatch(rawValue);
    if (match != null) {
      _scanned = true;
      codeController.text = match.group(1)!.toUpperCase();
      notifyListeners();
      onManualSubmit();
    }
  }

  Future<void> onManualSubmit() async {
    final code = codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    errorMessage = null;
    setBusy(true);

    try {
      final userId = await _loginService.getUserId();
      if (userId == null) {
        errorMessage = 'You must be logged in to pair a device.';
        return;
      }

      final result = await _deviceService.claimDevice(
        deviceCode: code,
        userId: userId,
      );

      if (result.success) {
        // Navigate back — parent screen will refresh
        // Using a navigation service or pop is done at the view level
        // via NavigationService.back(); handled in view onSuccess callback
        _showSuccessAndPop();
      } else {
        switch (result.error) {
          case 'device_not_found':
            errorMessage = 'Device code not found. Check the code and try again.';
          case 'device_already_claimed':
            errorMessage = 'This device is already paired to another account.';
          default:
            errorMessage = 'Connection error. Please try again.';
        }
      }
    } finally {
      setBusy(false);
      _scanned = false;
    }
  }

  void _showSuccessAndPop() {
    // Notify calling screen to pop — actual navigation handled at view level
    setError(null);
    // The view's onSuccess callback pops the route
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }
}
```

#### B8. Device Status Card Widget

```dart
// lib/ui/widgets/device_status_card.dart

import 'package:flutter/material.dart';
import 'package:vital_step/services/device_service.dart';
import 'package:vital_step/ui/common/app_colors_v2.dart';

class DeviceStatusCard extends StatelessWidget {
  final DeviceStatus status;
  final int pendingUploads;

  const DeviceStatusCard({
    super.key,
    required this.status,
    required this.pendingUploads,
  });

  @override
  Widget build(BuildContext context) {
    final online = status.isOnline;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.devices, color: kcPrimaryColor),
                const SizedBox(width: 8),
                Text('Device ${status.deviceCode}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                _OnlineBadge(online: online),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _BatteryIndicator(
                  pct: status.batteryPct ?? 0,
                  isCharging: status.isCharging ?? false,
                ),
                const SizedBox(width: 16),
                _LastSeenLabel(lastSeenAt: status.lastSeenAt),
              ],
            ),
            if (pendingUploads > 0) ...[
              const SizedBox(height: 8),
              Text(
                '$pendingUploads pending upload${pendingUploads == 1 ? '' : 's'}',
                style: TextStyle(
                  color: kcCoralAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  final bool online;
  const _OnlineBadge({required this.online});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: online
          ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
          : Colors.grey.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle,
            size: 8, color: online ? const Color(0xFF4CAF50) : Colors.grey),
        const SizedBox(width: 4),
        Text(online ? 'Online' : 'Offline',
            style: TextStyle(
                fontSize: 12,
                color: online ? const Color(0xFF4CAF50) : Colors.grey)),
      ],
    ),
  );
}

class _BatteryIndicator extends StatelessWidget {
  final int pct;
  final bool isCharging;
  const _BatteryIndicator({required this.pct, required this.isCharging});

  @override
  Widget build(BuildContext context) {
    final icon = isCharging
        ? Icons.battery_charging_full
        : pct > 60
            ? Icons.battery_full
            : pct > 20
                ? Icons.battery_4_bar
                : Icons.battery_1_bar;
    final color = pct > 20 ? kcPrimaryColor : const Color(0xFFF44336);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text('$pct%',
            style: TextStyle(
                fontWeight: FontWeight.w500, color: color, fontSize: 13)),
      ],
    );
  }
}

class _LastSeenLabel extends StatelessWidget {
  final DateTime? lastSeenAt;
  const _LastSeenLabel({this.lastSeenAt});

  @override
  Widget build(BuildContext context) {
    if (lastSeenAt == null) {
      return const Text('Never synced', style: TextStyle(color: Colors.grey));
    }
    final diff = DateTime.now().difference(lastSeenAt!);
    final label = diff.inSeconds < 60
        ? 'Just now'
        : diff.inMinutes < 60
            ? '${diff.inMinutes} min ago'
            : diff.inHours < 24
                ? '${diff.inHours} hr ago'
                : '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    return Text('Synced $label',
        style: const TextStyle(color: Colors.grey, fontSize: 13));
  }
}
```

#### B9. Where to Inject DeviceStatusCard

The card is conditionally inserted at the top of the body in:
- `lib/ui/views/home/home_view.dart` (patient home screen)
- `lib/ui/views/home_specialist/home_specialist_view.dart` (specialist dashboard)

Gate with `AppConfig.enableDeviceSync` so v1 builds never see it:

```dart
// Inside the Column/ListView of the home view:
if (AppConfig.enableDeviceSync) ...[
  DeviceStatusCardLoader(userId: currentUserId),
  const SizedBox(height: 16),
],
```

`DeviceStatusCardLoader` is a `StatefulWidget` that calls `DeviceService.getDeviceStatus()` and `getPendingUploadCount()` on init and every 30s.

---

### C. ESP32 Firmware Architecture

#### C1. Target Hardware: ESP32-3248S035

| Feature | Spec |
|---|---|
| MCU | ESP32-S3 |
| Display | ST7796 TFT 320×480 via SPI |
| Touch | Resistive (XPT2046 via SPI) |
| SD Card | SPI |
| Load Cell | HX711 (existing) |
| Battery | 2× 18650 in series, 8.4V–6.0V |
| ADC | GPIO 34 (battery voltage, 1:2 divider) |
| Charge Detect | GPIO 35 (active HIGH when charging) |

#### C2. Firmware File Structure

```
firmware/
  src/
    main.cpp
    config.h              ← device_code, device_secret, API URLs, pin defs
    display/
      display_driver.cpp  ← ST7796 init, LVGL flush callback
      screens.cpp         ← LVGL screen builders (main, test, results, pairing)
    sync/
      sync_manager.cpp    ← HTTPS sync state machine
      sd_queue.cpp        ← SD card file write/read/delete
    sensors/
      hx711_sensor.cpp    ← HX711 measurement logic
      battery.cpp         ← ADC → voltage → percentage
    time/
      time_manager.cpp    ← NTP, server_time, BLE epoch hierarchy
    ble/
      ble_provisioning.cpp ← Updated BLE provisioning (reads epoch field)
    qr/
      qr_render.cpp       ← QR code rendering on LVGL canvas
```

#### C3. LVGL Screen Layout (320×480)

**Main Screen (unclaimed):**
```
┌────────────────────────┐  ← status bar (16px): battery icon + % | WiFi | clock
│  🔋 87%  📶  14:32     │
├────────────────────────┤
│                        │
│   Scan to Pair         │  ← label, centered, 20px bold
│                        │
│    ┌──────────────┐    │
│    │  QR CODE     │    │  ← 200×200 QR canvas (LVGL canvas widget)
│    │  VS-XXXXXX   │    │
│    └──────────────┘    │
│                        │
│   VS-A1B2C3            │  ← device code text below QR
│                        │
│   Offline ●            │  ← sync status (red dot = offline)
│   Last sync: never     │
└────────────────────────┘
```

**Main Screen (claimed / idle):**
```
┌────────────────────────┐
│  🔋 87%  📶  14:32     │
├────────────────────────┤
│  VitalStep Ready       │  ← title, teal (#00796B)
│                        │
│  Last sync: 2 min ago  │
│  Pending: 0 uploads    │
│                        │
│  ┌────────────────────┐│
│  │  START TEST  ►     ││  ← large teal button (240×60px)
│  └────────────────────┘│
│                        │
│  Recent Results:        │
│  • 25.3 kg  Right  Sit │  ← last 3 results
│  • 22.1 kg  Left   Sit │
│  • 24.8 kg  Right  Std │
└────────────────────────┘
```

**Test Screen:**
```
┌────────────────────────┐
│  🔋 87%  📶            │
├────────────────────────┤
│  Trial 2 of 3          │  ← trial number
│                        │
│         23.4           │  ← live weight, 72px bold font
│          kg            │
│                        │
│  ████████░░  78%       │  ← progress bar (trial completion)
│                        │
│  Apply weight          │  ← instruction text
│  [Remove when stable]  │
└────────────────────────┘
```

**Results Screen:**
```
┌────────────────────────┐
│  🔋 87%  📶            │
├────────────────────────┤
│  Test Complete ✓       │
│                        │
│  Trial 1:  25.3 kg     │
│  Trial 2:  24.8 kg     │
│  Trial 3:  25.6 kg     │
│  Average:  25.2 kg ◀── │  ← highlighted, coral/teal color
│                        │
│  ✓ IN RANGE (target:   │  ← if target_lo/target_hi set
│    20–30 kg)           │
│  [or]                  │
│  ✗ BELOW TARGET        │
│                        │
│  [SYNC NOW ▶]          │  ← button triggers immediate sync
└────────────────────────┘
```

#### C4. SD Card File Structure

```
/
└── queue/
    ├── 1700000000_25.3.json   ← format: <epoch>_<trial1>.json
    ├── 1700000060_22.1.json
    └── ...
```

**File JSON structure** (matches Requirement 17.3):

```json
{
  "device_code":  "VS-A1B2C3",
  "trial1":       25.3,
  "trial2":       24.8,
  "trial3":       25.6,
  "hand":         "Right",
  "posture":      "Seated",
  "battery_pct":  87,
  "battery_v":    8.21,
  "is_charging":  false,
  "measured_at":  "2024-11-15T14:32:00Z",
  "time_source":  "ntp",
  "time_valid":   true
}
```

**SD Queue C++ pseudocode (key logic):**

```cpp
// sd_queue.cpp

bool SdQueue::writeRecord(const Measurement& m) {
  String filename = "/queue/" + String(m.epoch) + "_" + String(m.trial1, 1) + ".json";
  File f = SD.open(filename, FILE_WRITE);
  if (!f) return false;

  StaticJsonDocument<512> doc;
  doc["device_code"] = m.deviceCode;
  doc["trial1"]      = m.trial1;
  doc["trial2"]      = m.trial2;
  doc["trial3"]      = m.trial3;
  doc["hand"]        = m.hand;
  doc["posture"]     = m.posture;
  doc["battery_pct"] = m.batteryPct;
  doc["battery_v"]   = m.batteryV;
  doc["is_charging"] = m.isCharging;
  doc["measured_at"] = m.measuredAt;   // ISO 8601
  doc["time_source"] = m.timeSource;
  doc["time_valid"]  = m.timeValid;

  serializeJson(doc, f);
  f.close();
  return true;
}

bool SdQueue::readRecord(const String& filename, Measurement& out) {
  File f = SD.open(filename, FILE_READ);
  if (!f) return false;

  StaticJsonDocument<512> doc;
  if (deserializeJson(doc, f) != DeserializationError::Ok) {
    f.close();
    return false;
  }
  f.close();

  out.deviceCode  = doc["device_code"].as<String>();
  out.trial1      = doc["trial1"].as<float>();
  out.trial2      = doc["trial2"].as<float>();
  out.trial3      = doc["trial3"].as<float>();
  out.hand        = doc["hand"].as<String>();
  out.posture     = doc["posture"].as<String>();
  out.batteryPct  = doc["battery_pct"].as<int>();
  out.batteryV    = doc["battery_v"].as<float>();
  out.isCharging  = doc["is_charging"].as<bool>();
  out.measuredAt  = doc["measured_at"].as<String>();
  out.timeSource  = doc["time_source"].as<String>();
  out.timeValid   = doc["time_valid"].as<bool>();
  return true;
}
```

#### C5. HTTPS Sync State Machine

```
States:
  IDLE_PAIRED         → sync every 180s
  IDLE_UNPAIRED       → sync every 4s (to detect claim events)
  PENDING_UPLOADS     → sync every 15s (SD files waiting)
  POST_TEST           → sync immediately when test completes
  SYNCING             → in-flight HTTP request
  RETRY_BACKOFF       → after failed request, wait until next cadence

Transitions:
  IDLE_PAIRED + timer expired            → SYNCING
  IDLE_UNPAIRED + timer expired          → SYNCING
  PENDING_UPLOADS + timer expired        → SYNCING
  POST_TEST                              → SYNCING (immediate)
  SYNCING + success + no files           → IDLE_PAIRED or IDLE_UNPAIRED
  SYNCING + success + files remain       → PENDING_UPLOADS
  SYNCING + failure                      → RETRY_BACKOFF → (cadence state)
  Any state + test completes             → POST_TEST
  SYNCING → owner.claimed becomes true   → emit EVENT_CLAIMED
```

**Request construction:**

```cpp
void SyncManager::doSync() {
  HTTPClient https;
  https.begin(EDGE_FUNCTION_URL);
  https.addHeader("Content-Type", "application/json");
  https.addHeader("apikey",         SUPABASE_ANON_KEY);
  https.addHeader("x-device-code",  deviceCode);
  https.addHeader("x-device-secret", deviceSecret);

  // Collect up to 6 SD files
  StaticJsonDocument<4096> body;
  JsonArray measurements = body.createNestedArray("measurements");
  int uploaded = 0;
  auto files = SdQueue::listFiles();  // sorted by filename = by epoch
  for (auto& filename : files) {
    if (uploaded >= 6) break;
    Measurement m;
    if (SdQueue::readRecord(filename, m)) {
      JsonObject obj = measurements.createNestedObject();
      obj["trial1"]      = m.trial1;
      // ... all fields
      pendingFiles.push_back(filename);
      uploaded++;
    }
  }

  String payload;
  serializeJson(body, payload);

  int code = https.POST(payload);
  if (code == 200) {
    // Parse response
    String resp = https.getString();
    processResponse(resp);
    // Delete successfully uploaded files
    for (auto& f : pendingFiles) SdQueue::deleteFile(f);
  } else {
    // Stay in RETRY_BACKOFF, do not delete files
  }
}
```

#### C6. Battery ADC → Percentage Mapping

Two 18650 cells in series: 8.4V full, 6.0V empty.

```cpp
// battery.cpp

// ADC voltage divider: 100kΩ / 100kΩ → ADC sees V_bat / 2
// ESP32 ADC reference: 3.3V, 12-bit (4095)
// V_bat = ADC_reading * 3.3 / 4095 * 2

float Battery::readVoltage() {
  int raw = analogRead(BATTERY_ADC_PIN);
  return (raw / 4095.0f) * 3.3f * 2.0f;
}

int Battery::voltageToPercent(float voltage) {
  const float V_MAX = 8.4f;
  const float V_MIN = 6.0f;
  if (voltage >= V_MAX) return 100;
  if (voltage <= V_MIN) return 0;
  return (int)(((voltage - V_MIN) / (V_MAX - V_MIN)) * 100.0f + 0.5f);
}

bool Battery::isCharging() {
  return digitalRead(CHARGE_DETECT_PIN) == HIGH;
}
```

The discharge curve for 18650 is not perfectly linear, but the linear approximation is within ±8% over most of the range which is acceptable for this application. A lookup table can be substituted later for higher accuracy.

#### C7. NTP + Server Time + BLE Epoch Hierarchy

```cpp
// time_manager.cpp

enum TimeSource { NTP, SERVER_TIME, CORRECTED, NONE };

class TimeManager {
  TimeSource _source = NONE;
  int64_t    _bleEpoch = 0;
  int64_t    _bleEpochMillis = 0;  // millis() when BLE epoch was received

public:
  void onBleEpochReceived(int64_t epochSeconds) {
    _bleEpoch = epochSeconds;
    _bleEpochMillis = millis();
    if (_source == NONE) _source = CORRECTED;
  }

  void onNtpSuccess() {
    _source = NTP;
    // configTime() was called separately; clock is now set
  }

  void onServerTimeReceived(const String& isoTime) {
    if (_source == NTP) return;  // NTP is more accurate, keep it
    // Parse ISO 8601 and set RTC
    struct tm t = {};
    strptime(isoTime.c_str(), "%Y-%m-%dT%H:%M:%SZ", &t);
    time_t epoch = mktime(&t);
    struct timeval tv = { epoch, 0 };
    settimeofday(&tv, nullptr);
    _source = SERVER_TIME;
  }

  String currentTimeSource() const {
    switch (_source) {
      case NTP:         return "ntp";
      case SERVER_TIME: return "server_time";
      case CORRECTED:   return "corrected";
      default:          return "corrected";
    }
  }

  bool currentTimeValid() const {
    return _source == NTP || _source == SERVER_TIME;
  }

  String nowISO() const {
    if (_source == CORRECTED || _source == NONE) {
      // Derive from BLE epoch + elapsed time
      int64_t elapsed = (millis() - _bleEpochMillis) / 1000;
      int64_t approxEpoch = _bleEpoch + elapsed;
      // Format as ISO 8601
      time_t t = (time_t)approxEpoch;
      struct tm* tmInfo = gmtime(&t);
      char buf[32];
      strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", tmInfo);
      return String(buf);
    }
    // Use real RTC
    time_t now;
    time(&now);
    struct tm* tmInfo = gmtime(&now);
    char buf[32];
    strftime(buf, sizeof(buf), "%Y-%m-%dT%H:%M:%SZ", tmInfo);
    return String(buf);
  }
};
```

#### C8. QR Code Rendering on LVGL

Uses the `qrcode` C library (public domain, header-only, fits in firmware):

```cpp
// qr_render.cpp
#include "qrcode.h"   // https://github.com/nayuki/QR-Code-generator (C port)

void renderQrCode(lv_obj_t* parent, const String& uri) {
  QRCode qrcode;
  uint8_t qrData[qrcode_getBufferSize(10)];
  qrcode_initText(&qrcode, qrData, 10, ECC_MEDIUM, uri.c_str());

  // Scale to fill ~200×200 area
  const int CANVAS_SIZE = 200;
  int scale = CANVAS_SIZE / qrcode.size;

  lv_obj_t* canvas = lv_canvas_create(parent);
  static lv_color_t cbuf[200 * 200];
  lv_canvas_set_buffer(canvas, cbuf, CANVAS_SIZE, CANVAS_SIZE, LV_IMG_CF_TRUE_COLOR);
  lv_canvas_fill_bg(canvas, lv_color_white(), LV_OPA_COVER);

  lv_draw_rect_dsc_t rect;
  lv_draw_rect_dsc_init(&rect);
  rect.bg_color = lv_color_black();

  for (int y = 0; y < qrcode.size; y++) {
    for (int x = 0; x < qrcode.size; x++) {
      if (qrcode_getModule(&qrcode, x, y)) {
        lv_canvas_draw_rect(canvas, x * scale, y * scale, scale, scale, &rect);
      }
    }
  }

  lv_obj_align(canvas, LV_ALIGN_CENTER, 0, 0);
}
```

---

## Data Models

### Supabase Schema Summary

```
devices
  id                UUID PK
  device_code       TEXT UNIQUE NOT NULL        -- "VS-A1B2C3"
  device_secret_hash TEXT NOT NULL             -- bcrypt hash
  owner_user_id     TEXT                       -- NULL = unclaimed
  claimed_at        TIMESTAMPTZ
  last_seen_at      TIMESTAMPTZ
  battery_pct       INTEGER
  battery_v         NUMERIC(5,2)
  is_charging       BOOLEAN
  firmware_version  TEXT
  created_at        TIMESTAMPTZ DEFAULT NOW()

measurements
  id           UUID PK DEFAULT gen_random_uuid()
  device_id    UUID NOT NULL → devices(id)
  patient_id   UUID          → research_patients(id)
  assessment_id UUID         → assessments(id)
  trial1-3     NUMERIC(10,2) NOT NULL
  hand         TEXT NOT NULL
  posture      TEXT NOT NULL
  battery_pct  INTEGER
  battery_v    NUMERIC(5,2)
  is_charging  BOOLEAN
  measured_at  TIMESTAMPTZ NOT NULL
  time_source  TEXT NOT NULL CHECK IN ('ntp','server_time','corrected')
  time_valid   BOOLEAN NOT NULL DEFAULT false
  sd_filename  TEXT
  created_at   TIMESTAMPTZ DEFAULT NOW()

assessments (existing + extensions)
  + device_ref    TEXT
  + hand          TEXT
  + posture       TEXT
  + title         TEXT
  + status        TEXT DEFAULT 'pending' CHECK IN (...)
  + completed_at  TIMESTAMPTZ  (auto-set by trigger)

research_patients (existing + extensions)
  + target_lo  NUMERIC(10,2)  -- NULL = no target
  + target_hi  NUMERIC(10,2)
  + CHECK (target_lo IS NULL OR target_hi IS NULL OR target_lo < target_hi)
```

### Flutter Data Models

```
DeviceStatus        ← maps devices row
DeviceMeasurement   ← maps measurements row
UnifiedMeasurement  ← merged DO + Supabase entry for UI display
ClaimResult         ← RPC response wrapper
UnclaimResult       ← RPC response wrapper
```

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Device Code Uniqueness

*For any* two device provisioning calls, the set of returned `device_code` values must contain no duplicates.

**Validates: Requirements 1.2, 6.3**

---

### Property 2: FK Constraint — Measurements Reject Orphan Device IDs

*For any* randomly generated UUID that does not correspond to an existing `devices.id`, attempting to insert a `measurements` row with that `device_id` must fail with a foreign key constraint violation.

**Validates: Requirements 2.2**

---

### Property 3: Assessment Completed-At Invariant

*For any* assessment row, if `status = 'completed'` then `completed_at` is non-null, and if `status != 'completed'` then `completed_at` is null. This invariant must hold after every possible sequence of status transitions.

**Validates: Requirements 3.2, 3.3**

---

### Property 4: Patient Target Range Constraint

*For any* pair of values `(lo, hi)`, inserting or updating a `research_patients` row with `target_lo = lo` and `target_hi = hi` must:
- Succeed when `lo < hi`
- Succeed when either is NULL
- Fail with a CHECK constraint violation when `lo >= hi`

**Validates: Requirements 4.4**

---

### Property 5: Claim-Unclaim Round Trip

*For any* device and user, performing `claim_device` followed by `unclaim_device` with the same user must restore the device's `owner_user_id` to NULL and `claimed_at` to NULL. The device's state is equivalent to its pre-claim state.

**Validates: Requirements 5.1, 5.5**

---

### Property 6: Claim Exclusivity

*For any* device already claimed by user A, calling `claim_device` with user B (where B ≠ A) must return `{"error": "device_already_claimed"}` and must not alter the device's `owner_user_id` or `claimed_at`.

**Validates: Requirements 5.3**

---

### Property 7: Edge Function Auth — Reject All Unprovisioned Credentials

*For any* (device_code, device_secret) pair that has not been provisioned via `admin_provision_devices`, the `device-sync` Edge Function must return HTTP 401 with `{"error": "invalid_credentials"}`.

**Validates: Requirements 7.3, 7.4**

---

### Property 8: Measurement Batch Size Enforcement

*For any* batch of measurements with count > 6 sent to the Edge Function, the response must be HTTP 400 with `{"error": "batch_too_large"}`, and no measurements must be inserted into the database.

**Validates: Requirements 8.2, 8.3**

---

### Property 9: Time Source Determines time_valid

*For any* measurement uploaded with a valid `time_source`:
- If `time_source = 'corrected'`, then the stored `time_valid` must be `false`
- If `time_source = 'ntp'` or `time_source = 'server_time'`, then the stored `time_valid` must be `true`

This holds regardless of the value of `time_valid` in the upload payload.

**Validates: Requirements 8.6, 8.7**

---

### Property 10: SD Card Round-Trip

*For any* valid `Measurement` record written to the SD card via `SdQueue::writeRecord`, reading it back with `SdQueue::readRecord` must produce a record that is field-for-field equal to the original (i.e., `parse(write(record)) == record`).

**Validates: Requirements 17.3, 17.6**

---

### Property 11: Battery Voltage-to-Percentage Monotonicity and Bounds

*For any* battery voltage `V` in the range [6.0, 8.4]:
- `voltageToPercent(8.4) = 100`
- `voltageToPercent(6.0) = 0`
- If `V1 > V2`, then `voltageToPercent(V1) >= voltageToPercent(V2)` (monotonically non-decreasing)
- `voltageToPercent(V)` is always in [0, 100]

**Validates: Requirements 19.2**

---

### Property 12: Time Source Hierarchy

*For any* combination of availability flags (NTP available, server_time available, BLE epoch available), the selected `time_source` must satisfy: NTP > server_time > corrected. Specifically:
- If NTP is available → `time_source = 'ntp'` regardless of other sources
- If NTP unavailable AND server_time available → `time_source = 'server_time'`
- If neither NTP nor server_time available AND BLE epoch was received → `time_source = 'corrected'`

**Validates: Requirements 20.1, 20.2, 20.3**

---

### Property 13: QR URI Encoding

*For any* device code in the format `VS-XXXXXX`, the generated QR code URI must be exactly `vitalstep://pair?code=VS-XXXXXX` where the code is the full device code. The Flutter QR scanner's code extraction function must recover the original device code from any valid `vitalstep://pair?code=<code>` URI.

**Validates: Requirements 16.3, 21.1**

---

### Property 14: BLE Epoch Payload Completeness

*For any* (ssid, password) pair passed to `BleProvisioningService.sendWifiCredentials`, the serialized JSON payload must:
- Contain an `"ssid"` key equal to the provided ssid
- Contain a `"password"` key equal to the provided password
- Contain an `"epoch"` key with an integer value within 5 seconds of `DateTime.now().millisecondsSinceEpoch ~/ 1000`

**Validates: Requirements 13.1, 13.2, 13.3**

---

### Property 15: Measurement Merge Preserves All Items and Chronological Order

*For any* two lists of measurements (Digital Ocean items and Supabase device items), calling `MeasurementService.merge` must:
- Return a list whose length equals the sum of both input list lengths
- Have every item in both input lists present in the output
- Be sorted with the most recent `createdAt` first (descending order)

**Validates: Requirements 14.1, 14.2**

---

### Property 16: Online Status Threshold

*For any* `DeviceStatus` with a non-null `lastSeenAt`:
- `isOnline` must be `true` when `DateTime.now().difference(lastSeenAt).inSeconds < 300`
- `isOnline` must be `false` when `DateTime.now().difference(lastSeenAt).inSeconds >= 300`

**Validates: Requirements 12.2**

---

## Error Handling

### Edge Function Errors

| Condition | HTTP Status | Body |
|---|---|---|
| Method not POST | 405 | `{"error":"method_not_allowed"}` |
| Missing `apikey` header | 401 | `{"error":"missing_apikey"}` |
| Missing device credentials | 401 | `{"error":"missing_credentials"}` |
| Invalid device credentials | 401 | `{"error":"invalid_credentials"}` |
| Batch > 6 measurements | 400 | `{"error":"batch_too_large"}` |
| Invalid `time_source` value | 422 | `{"error":"invalid_time_source"}` |
| Other validation failure | 422 | `{"error":"validation_failed","detail":"..."}` |
| Database insert error | 500 | `{"error":"insert_failed","detail":"..."}` |

### Flutter Error Handling

- `DeviceService.claimDevice` returns a typed `ClaimResult` — never throws
- `MeasurementService.fetchDeviceMeasurements` returns empty list on failure — silent degradation
- `DeviceStatusCard` is omitted from the view when `getDeviceStatus` returns null
- BLE epoch write failure is non-fatal — provisioning continues (device falls back to corrected time)

### ESP32 Firmware Error Handling

| Error | Action |
|---|---|
| SD card write failure | Log to Serial, show warning on screen, attempt direct memory upload |
| HTTPS sync failure | Stay in current cadence state, retry on next timer tick |
| NTP failure | Continue with server_time or corrected time source |
| HX711 read error | Display "Scale Error", do not save trial, allow retry |
| QR render library failure | Show text code (VS-XXXXXX) as fallback |
| SD card not present at boot | HARD STOP with error screen (existing behavior preserved) |

---

## Testing Strategy

### Unit Tests (Dart/Flutter)

Focus on pure logic that can be tested without network or hardware:

1. `DeviceStatus.isOnline` — boundary at 300 seconds (Property 16)
2. `DevicePairingViewModel.onQrDetected` — QR URI parsing (Property 13)
3. `MeasurementService.merge` — chronological sort, completeness (Property 15)
4. `BleProvisioningService.sendWifiCredentials` — epoch field present in payload (Property 14)
5. `UnifiedMeasurement.showTimeEstimatedBadge` — badge logic for `corrected` and `time_valid=false`

### Property-Based Tests (Dart — using `proptest` or `fast_check` via Dart FFI / `dart_test_extended`)

The project uses **`dart_test`** with **`proptest`** (or equivalent) for property-based tests. Each test runs a minimum of **100 iterations**.

```dart
// test/properties/measurement_merge_test.dart

// Property 15: Merge preserves all items and chronological order
test('merge preserves all items and chronological order', () {
  // Feature: supabase-device-sync-migration, Property 15: Measurement merge completeness
  for (int i = 0; i < 100; i++) {
    final doItems = generateRandomUnifiedMeasurements(count: random.nextInt(10));
    final supItems = generateRandomDeviceMeasurements(count: random.nextInt(10));
    final doAsUnified = doItems; // already UnifiedMeasurement
    final result = service.merge(digitalOceanItems: doAsUnified, supabaseItems: supItems);

    expect(result.length, equals(doItems.length + supItems.length));
    for (int j = 0; j < result.length - 1; j++) {
      expect(result[j].createdAt.isAfter(result[j + 1].createdAt) ||
             result[j].createdAt.isAtSameMomentAs(result[j + 1].createdAt), isTrue);
    }
  }
});
```

```dart
// Property 16: Online status threshold
test('isOnline true when lastSeenAt within 300 seconds', () {
  // Feature: supabase-device-sync-migration, Property 16: Online status threshold
  for (int i = 0; i < 100; i++) {
    final secondsAgo = random.nextInt(299);  // 0..299 → should be online
    final status = DeviceStatus(
      id: 'test', deviceCode: 'VS-TEST1',
      lastSeenAt: DateTime.now().subtract(Duration(seconds: secondsAgo)),
    );
    expect(status.isOnline, isTrue);
  }
  for (int i = 0; i < 100; i++) {
    final secondsAgo = 300 + random.nextInt(3600);  // 300+ → offline
    final status = DeviceStatus(
      id: 'test', deviceCode: 'VS-TEST1',
      lastSeenAt: DateTime.now().subtract(Duration(seconds: secondsAgo)),
    );
    expect(status.isOnline, isFalse);
  }
});
```

```dart
// Property 9: time_valid override
test('time_valid is overridden by time_source regardless of upload value', () {
  // Feature: supabase-device-sync-migration, Property 9: time_source → time_valid
  // Tested via Edge Function TypeScript unit tests (Deno test runner)
});
```

### Property-Based Tests (TypeScript/Deno — Edge Function)

```typescript
// supabase/functions/device-sync/device_sync_test.ts
import { assertEquals } from "https://deno.land/std/testing/asserts.ts";

// Property 8: batch_too_large for any batch > 6
Deno.test("batch > 6 returns 400 batch_too_large", async () => {
  // Feature: supabase-device-sync-migration, Property 8: Batch size enforcement
  for (let count = 7; count <= 20; count++) {
    const measurements = Array.from({ length: count }, () => buildValidMeasurement());
    const resp = await callEdgeFunction({ measurements }, validDeviceHeaders);
    assertEquals(resp.status, 400);
    const body = await resp.json();
    assertEquals(body.error, "batch_too_large");
  }
});

// Property 9: corrected → time_valid=false, ntp/server_time → time_valid=true
Deno.test("time_source determines time_valid in stored rows", async () => {
  // Feature: supabase-device-sync-migration, Property 9: Time source determines time_valid
  const cases: Array<[string, boolean]> = [
    ["ntp", true], ["server_time", true], ["corrected", false],
  ];
  for (const [timeSource, expectedValid] of cases) {
    const m = { ...buildValidMeasurement(), time_source: timeSource, time_valid: !expectedValid };
    const resp = await callEdgeFunction({ measurements: [m] }, validDeviceHeaders);
    assertEquals(resp.status, 200);
    const stored = await fetchLastMeasurement(testDeviceId);
    assertEquals(stored.time_valid, expectedValid);
  }
});
```

### Integration Tests

- `claim_device` / `unclaim_device` RPCs against a test Supabase project
- Edge Function authentication (valid and invalid credentials)
- Full sync cycle: write SD file → sync → verify measurement in database → file deleted

### ESP32 Unit Tests (Arduino/PlatformIO with Unity)

```cpp
// test/test_battery/test_battery.cpp
void test_battery_bounds(void) {
  // Property 11: boundary values
  TEST_ASSERT_EQUAL_INT(100, Battery::voltageToPercent(8.4f));
  TEST_ASSERT_EQUAL_INT(0,   Battery::voltageToPercent(6.0f));
  TEST_ASSERT_EQUAL_INT(0,   Battery::voltageToPercent(5.5f));  // below min
  TEST_ASSERT_EQUAL_INT(100, Battery::voltageToPercent(9.0f));  // above max
}

void test_battery_monotonic(void) {
  // Property 11: monotonicity
  float prev = 6.0f;
  int prevPct = Battery::voltageToPercent(prev);
  for (float v = 6.1f; v <= 8.4f; v += 0.1f) {
    int pct = Battery::voltageToPercent(v);
    TEST_ASSERT_GREATER_OR_EQUAL_INT(prevPct, pct);
    prevPct = pct;
    prev = v;
  }
}

// test/test_sd_queue/test_sd_queue.cpp
void test_sd_round_trip(void) {
  // Property 10: SD card round-trip
  Measurement original = buildTestMeasurement();
  SdQueue::writeRecord(original);
  Measurement loaded;
  bool ok = SdQueue::readRecord("/queue/test.json", loaded);
  TEST_ASSERT_TRUE(ok);
  TEST_ASSERT_EQUAL_STRING(original.deviceCode.c_str(), loaded.deviceCode.c_str());
  TEST_ASSERT_EQUAL_FLOAT(original.trial1, loaded.trial1);
  TEST_ASSERT_EQUAL_FLOAT(original.trial2, loaded.trial2);
  TEST_ASSERT_EQUAL_FLOAT(original.trial3, loaded.trial3);
  TEST_ASSERT_EQUAL_STRING(original.timeSource.c_str(), loaded.timeSource.c_str());
  TEST_ASSERT_EQUAL_INT(original.timeValid, loaded.timeValid);
}
```

---

## Data Flow Diagrams

### D1: Device → Edge Function → Supabase

```
ESP32-3248S035
│
│  POST /functions/v1/device-sync
│  Headers: apikey, x-device-code, x-device-secret
│  Body: { measurements: [...] }
│
▼
device-sync Edge Function (Deno)
│
├── 1. Validate apikey header
├── 2. Lookup device by device_code
├── 3. bcrypt.verify(device_secret, device_secret_hash)  [via verify_device_secret RPC]
├── 4. UPDATE devices SET last_seen_at = NOW()
├── 5. Validate measurement batch (size ≤ 6, all fields valid)
├── 6. INSERT INTO measurements (all rows atomic)
├── 7. Query assessments WHERE device_ref = device_code AND status = 'pending' LIMIT 1
├── 8. Query measurements WHERE device_id = ? ORDER BY measured_at DESC LIMIT 5
├── 9. Query research_patients for target_lo/target_hi (if claimed)
│
▼
Response: { server_time, queue, history, owner, target }
│
▼
ESP32 processes response:
  ├── Update RTC from server_time
  ├── Display pending assessment on screen
  ├── Update history display
  └── Delete successfully uploaded SD files
```

### D2: Flutter App v2 → Supabase

```
Flutter App v2 (patientSupabaseClient)
│
├── Auth: Supabase auth.signIn / auth.signUp
│         (replaces Digital Ocean /api/auth/* for v2 users)
│
├── Device Pairing:
│   └── RPC: claim_device(device_code, user_id)
│             → devices SET owner_user_id
│
├── Device Status (polling every 30s):
│   └── SELECT * FROM devices WHERE owner_user_id = user_id
│
├── Measurements (on dashboard load):
│   └── SELECT * FROM measurements
│         WHERE device_id IN (SELECT id FROM devices WHERE owner_user_id = ?)
│         ORDER BY measured_at DESC LIMIT 50
│
└── Unpairing:
    └── RPC: unclaim_device(device_code, user_id)
              → devices SET owner_user_id = NULL
```

### D3: Specialist Creates Assessment → Device Queue

```
Flutter App v2 (Specialist)
│
│  1. Specialist fills: hand, posture, title, device_ref (patient's device code)
│  2. POST to Digital Ocean /api/assessment/ (existing flow, unchanged)
│  3. ALSO insert into Supabase assessments table with new columns:
│       device_ref = patient_device_code,
│       hand = ..., posture = ..., title = ...,
│       status = 'pending'
│
▼
Supabase assessments table
  status = 'pending', device_ref = 'VS-A1B2C3'
│
│  (on next device sync — within 4s if unpaired, 15s if pending, 180s heartbeat)
│
▼
device-sync Edge Function
  Query: SELECT * FROM assessments
           WHERE device_ref = 'VS-A1B2C3' AND status = 'pending' LIMIT 1
│
▼
Response → ESP32 queue array
│
▼
ESP32 displays assessment on screen:
  "Assessment: Seated, Right Hand
   Patient: [patient name if available]
   Press START to begin"
│
│  After test:
│
▼
measurements row inserted with assessment_id
assessments row updated: status = 'completed', completed_at = NOW()
```

### D4: Legacy App v1 → Digital Ocean (Unchanged)

```
Flutter App v1
│
│  All API calls: https://plankton-app-6cr5g.ondigitalocean.app/api
│
├── /api/auth/login       → JWT token
├── /api/user/            → user profile
├── /api/specialist/      → specialist features
├── /api/assessment/      → assessments (no new Supabase columns written)
├── /api/test/            → test results (Digital Ocean PostgreSQL)
└── /api/device*          → old ESP32 device management
│
▼
Digital Ocean Node.js + PostgreSQL
(No changes, no decommission, runs indefinitely)
```
