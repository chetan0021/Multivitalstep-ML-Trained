# Vital Step Data Collection — Developer Notes

## Dual Supabase Client Architecture

### Why Two Supabase Clients?

The app uses **two separate Supabase clients** for distinct purposes:

1. **`Supabase.instance.client`** (existing, initialized via `Supabase.initialize()`)
   - URL: `https://aoujgxqgixpanztyyshc.supabase.co`
   - Purpose: **Kill-switch only** — `AccountsService.killApp()` checks the `vitalStep`
     table to remotely disable the app.
   - Do NOT add patient tables here; this must remain a clean kill-switch control plane.

2. **`patientSupabaseClient`** (new global `SupabaseClient` in `lib/main.dart`)
   - URL: `https://cbebmpgsbxqdzpfgqulj.supabase.co` (default; overridable at build time)
   - Purpose: **Patient data** — stores `research_patients` and `patient_readings` tables.
   - Initialized directly via `SupabaseClient(url, anonKey)` constructor because
     `Supabase.initialize()` only supports one named instance.

### Build-Time Configuration

The patient Supabase URL and anon key are injected at build time using `--dart-define`:

```bash
# Development
flutter run \
  --dart-define=PATIENT_SUPABASE_URL=https://cbebmpgsbxqdzpfgqulj.supabase.co \
  --dart-define=PATIENT_SUPABASE_ANON_KEY=eyJ...your_anon_key...

# Production build (APK)
flutter build apk \
  --dart-define=PATIENT_SUPABASE_URL=https://cbebmpgsbxqdzpfgqulj.supabase.co \
  --dart-define=PATIENT_SUPABASE_ANON_KEY=eyJ...your_anon_key...

# Production build (App Bundle)
flutter build appbundle \
  --dart-define=PATIENT_SUPABASE_URL=https://cbebmpgsbxqdzpfgqulj.supabase.co \
  --dart-define=PATIENT_SUPABASE_ANON_KEY=eyJ...your_anon_key...
```

If `--dart-define` is not provided, the defaults hardcoded in `main.dart` are used.

---

## Dual-Write Pattern

When a test completes in **Patient Mode** with an active patient selected:

1. Test data is saved to **Digital Ocean** (existing flow, completely unchanged).
2. Only if step 1 succeeds → a copy is also saved to **Patient Supabase**.
3. If step 2 fails → the reading is queued in `GetStorage` for automatic retry.

The dual-write guard lives in `TestResultViewModel._handleDualWrite()`. It is called
from the success path only, so the Supabase write is **never** attempted if the Digital
Ocean write fails (satisfies Requirement 4.4).

### Retry Queue

Failed patient readings are stored in `GetStorage` under key `patient_readings_retry_queue`
as a JSON array. Each item includes:

```json
{
  "patientId":      "uuid",
  "hostUserId":     "123",
  "trial1":         "25.5",
  "trial2":         "26.0",
  "trial3":         "24.8",
  "hand":           "Right",
  "posture":        "Seated",
  "assessmentType": "42",
  "createdAt":      "2024-01-15T10:30:00.000Z",
  "enqueuedAt":     "2024-01-15T10:30:01.000Z",
  "attemptCount":   0,
  "nextRetryAt":    "2024-01-15T10:30:03.000Z"
}
```

Retry is triggered automatically when `ConnectionManagerService` detects that
connectivity is restored. Exponential back-off schedule:

| Attempt | Delay |
|---------|-------|
| 1st     | 2 s   |
| 2nd     | 4 s   |
| 3rd     | 8 s   |
| 4th     | 16 s  |
| 5th     | 32 s  |
| After 5 | Permanently failed — logged, removed from queue, user notified |

---

## Host Mode vs Patient Mode

| Feature                  | Host Mode (default)             | Patient Mode                              |
|--------------------------|---------------------------------|-------------------------------------------|
| Dashboard data source    | Digital Ocean API               | Patient Supabase (filtered by patient_id) |
| Test save destination    | Digital Ocean only              | Digital Ocean + Patient Supabase          |
| Patient UI visible       | ❌ Hidden                       | ✅ Visible                                |
| Mode persisted in        | `GetStorage` `app_mode = false` | `GetStorage` `app_mode = true`            |

Switch between modes via **Settings → Research Mode toggle** in AccountView.

---

## GetStorage Key Map

| Key                            | Type     | Purpose                                                     |
|--------------------------------|----------|-------------------------------------------------------------|
| `app_mode`                     | `bool`   | `false` = Host Mode (default), `true` = Patient Mode        |
| `active_patient_id`            | `String?`| UUID of currently selected ResearchPatient                  |
| `active_patient_code`          | `String?`| PT-XXXX display code                                        |
| `active_patient_name`          | `String?`| Patient name shown in dashboard header                      |
| `patient_readings_retry_queue` | `String` | JSON-serialised list of pending Supabase writes             |
| `selected_device`              | `Map`    | Persisted device selection (device-selection feature)       |
| `device_selection_state`       | `Map`    | Full device selection state including connection statuses   |

---

## Database Schema

The New Supabase Project at `https://cbebmpgsbxqdzpfgqulj.supabase.co` requires
these tables. Run this SQL migration in the Supabase SQL editor:

```sql
-- research_patients table
CREATE TABLE research_patients (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_code   TEXT NOT NULL,
  name           TEXT NOT NULL,
  age            INTEGER NOT NULL CHECK (age >= 0 AND age <= 150),
  gender         TEXT NOT NULL,
  contact        TEXT DEFAULT '',
  notes          TEXT DEFAULT '',
  host_user_id   TEXT NOT NULL,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_patient_code_per_host UNIQUE (patient_code, host_user_id)
);
CREATE INDEX idx_research_patients_host_user_id ON research_patients (host_user_id);

-- patient_readings table
CREATE TABLE patient_readings (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id      UUID NOT NULL REFERENCES research_patients(id) ON DELETE CASCADE,
  trial1          NUMERIC(10, 2) NOT NULL,
  trial2          NUMERIC(10, 2) NOT NULL,
  trial3          NUMERIC(10, 2) NOT NULL,
  hand            TEXT NOT NULL,
  posture         TEXT NOT NULL,
  assessment_type TEXT NOT NULL,
  host_user_id    TEXT NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_patient_readings_patient_id   ON patient_readings (patient_id);
CREATE INDEX idx_patient_readings_host_user_id ON patient_readings (host_user_id);

-- Row Level Security (recommended for production)
ALTER TABLE research_patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_readings  ENABLE ROW LEVEL SECURITY;
```

---

## Patient Code Format

Patient codes follow the pattern `PT-NNNN` where `NNNN` is a zero-padded 4-digit
integer, unique per `host_user_id`:

- First patient for a device: `PT-0001`
- Sequential thereafter: `PT-0002`, `PT-0003`, …, `PT-9999`
- Codes are device-scoped — two different clinic devices may both have a `PT-0001`

Code generation logic is in `PatientService.getNextPatientCode()`. On concurrent
registration race conditions, a database-level UNIQUE constraint catches duplicates
and the service retries with the next sequential number (up to 3 attempts).
