-- ===============================================================================
-- Vital Step Data Collection - New Supabase Project Setup
-- ===============================================================================
-- 
-- Project URL: https://cbebmpgsbxqdzpfgqulj.supabase.co
-- 
-- Instructions:
-- 1. Log in to the Supabase dashboard at https://cbebmpgsbxqdzpfgqulj.supabase.co
-- 2. Navigate to SQL Editor
-- 3. Create a new query and paste this entire script
-- 4. Execute the script to create tables, indexes, and policies
-- 
-- ===============================================================================

-- ─── TABLE: research_patients ───────────────────────────────────────────────
-- Stores patient profile information for multi-patient session management
-- Each Host_User_Id (device) maintains its own isolated patient registry

CREATE TABLE research_patients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_code TEXT NOT NULL,
  name TEXT NOT NULL,
  age INTEGER NOT NULL CHECK (age >= 0 AND age <= 150),
  gender TEXT NOT NULL,
  contact TEXT DEFAULT '',
  notes TEXT DEFAULT '',
  host_user_id TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_patient_code_per_host UNIQUE (patient_code, host_user_id)
);

CREATE INDEX idx_research_patients_host_user_id ON research_patients (host_user_id);

-- ─── TABLE: patient_readings ─────────────────────────────────────────────────
-- Stores copies of test data linked to patients from research_patients table
-- Enables per-patient test tracking alongside existing Digital Ocean backend

CREATE TABLE patient_readings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL REFERENCES research_patients(id) ON DELETE CASCADE,
  trial1 NUMERIC(10, 2) NOT NULL,
  trial2 NUMERIC(10, 2) NOT NULL,
  trial3 NUMERIC(10, 2) NOT NULL,
  hand TEXT NOT NULL,
  posture TEXT NOT NULL,
  assessment_type TEXT NOT NULL,
  host_user_id TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_patient_readings_patient_id ON patient_readings (patient_id);
CREATE INDEX idx_patient_readings_host_user_id ON patient_readings (host_user_id);

-- ─── ROW LEVEL SECURITY ──────────────────────────────────────────────────────
-- Enable RLS to provide security foundation (policies configured below)

ALTER TABLE research_patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_readings ENABLE ROW LEVEL SECURITY;

-- ─── POLICIES ────────────────────────────────────────────────────────────────
-- Currently permissive - data isolation enforced at application layer
-- Future enhancement: filter by host_user_id using JWT claims

CREATE POLICY "Allow all operations" ON research_patients FOR ALL USING (true);
CREATE POLICY "Allow all operations" ON patient_readings FOR ALL USING (true);

-- ===============================================================================
-- Setup Complete
-- ===============================================================================
-- 
-- Next Steps:
-- 1. Verify tables were created: Check Tables view in Supabase dashboard
-- 2. Update Flutter app with Supabase URL and Anon Key via --dart-define:
--    flutter run \
--      --dart-define=PATIENT_SUPABASE_URL=https://cbebmpgsbxqdzpfgqulj.supabase.co \
--      --dart-define=PATIENT_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
-- 
-- ===============================================================================
