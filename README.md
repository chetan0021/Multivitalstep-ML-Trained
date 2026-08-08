# Multi-Patient VitalStep App

## Overview
This is a Flutter-based mobile application designed for conducting clinical trials and research with multiple patients. It tracks patient demographics, dominant hand, health conditions, and multi-trial test readings (e.g., Trial 1, Trial 2, Trial 3, Posture, Test Date).

## Architecture & Integrations
The application serves as the primary data collection tool and integrates with two major backend systems for persistence and CRM management:

### 1. Supabase (Database Backend)
- **Primary Data Store**: All patient registrations and test readings are stored locally (using Hive/GetStorage) and synced to a cloud Supabase PostgreSQL database.
- **Tables Used**:
  - `research_patients`: Stores demographic info (name, code, phone, age, gender, condition, dominant hand, device ID).
  - `patient_readings`: Stores the individual test trials (left/right trials, averages, posture, test date).
- **Offline-First Sync**: Uses a queue system to handle offline scenarios. Data is pushed to Supabase when the device regains connectivity.

### 2. HubSpot CRM (via Custom Backend)
The app pushes all registered patients and completed tests to a centralized HubSpot CRM so researchers can view clinical profiles in a single dashboard. 
- **Endpoint Structure**:
  - `POST /api/v1/hubspot/contacts`: Handles initial patient registration. Stores clinical fields like `gender`, `condition`, `device_id`, `age`, and `dominant_hand`.
  - `POST /api/v1/hubspot/sync/contact`: Handles test reading synchronization. Automatically links test trials (e.g., `trial1`, `left_avg`, `posture`) to the patient created in the previous step.
- **Fail-safes**: If a patient is registered without a phone number (which HubSpot requires for unique identification), the sync gracefully skips to prevent application crashes while keeping the data safe in Supabase.

## Agent Artifacts and Diagnostics
Included in this repository is an `agent_artifacts` folder containing various Python diagnostic scripts that were used to reverse-engineer, test, and validate the HubSpot API endpoints during development.
These scripts simulate the exact payload structure the Flutter app uses to push data to HubSpot.

## Built With
- **Flutter** (Dart) - UI Framework
- **Supabase** - Cloud PostgreSQL Database & Auth
- **HubSpot API** - CRM Integration (via custom proxy)
- **GetStorage / Hive** - Local persistence and queuing
