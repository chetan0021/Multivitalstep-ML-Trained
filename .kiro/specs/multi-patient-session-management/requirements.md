# Requirements Document

## Introduction

This document specifies the requirements for a multi-patient session management system for the Vital Step application. The system enables clinics and research facilities to manage multiple patient profiles, track test sessions per patient, and maintain data isolation between different clinic devices. The feature introduces a dual-mode operation (Host Mode and Patient Mode) while preserving all existing functionality and data flows to the Digital Ocean backend.

## Glossary

- **App**: The Vital Step mobile application
- **Host_Account**: The logged-in user account (userId stored in GetStorage) whose data resides in the Digital Ocean backend
- **Host_User_Id**: The unique identifier of the Host_Account, used as a partition key in the New_Supabase_Project
- **Device_ID**: Hardware-generated unique identifier written to SD card, tied to the Host_Account in Digital Ocean
- **Digital_Ocean_Backend**: The existing REST API at `https://plankton-app-6cr5g.ondigitalocean.app/api` storing all user accounts, devices, assessments, and test records
- **Existing_Supabase**: The existing Supabase instance at `https://aoujgxqgixpanztyyshc.supabase.co` containing only the vitalStep table with kill-switch functionality
- **New_Supabase_Project**: A brand new, separate Supabase project created by the admin containing research_patients and patient_readings tables
- **Research_Patients_Table**: Table in New_Supabase_Project storing patient profile information
- **Patient_Readings_Table**: Table in New_Supabase_Project storing copies of test data linked to patients
- **Patient_Code**: A sequential identifier in format PT-0001, PT-0002, etc., unique per Host_User_Id
- **Host_Mode**: The default app operation mode where the app behaves as it does today, with no patient UI visible
- **Patient_Mode**: An optional app operation mode activated via settings toggle, enabling patient management UI and data switching
- **Active_Patient**: The currently selected patient in Patient_Mode for whom test data is being collected
- **Dashboard**: The app screen displaying test result graphs and statistics
- **Test_Reading**: A completed test record containing trial1, trial2, trial3, hand, posture, and assessment_type values
- **Dual_Write_Pattern**: The process of saving test data to both Digital_Ocean_Backend and New_Supabase_Project simultaneously
- **CSV_Export**: A comma-separated values file containing patient profile and all associated test readings

## Requirements

### Requirement 1: Application Mode Management

**User Story:** As a clinic administrator, I want to toggle between Host Mode and Patient Mode, so that I can choose whether to manage individual patient sessions or operate the device in standard mode.

#### Acceptance Criteria

1. THE App SHALL provide a settings toggle to switch between Host_Mode and Patient_Mode
2. WHEN Host_Mode is active, THE App SHALL hide all patient management UI elements
3. WHEN Host_Mode is active, THE Dashboard SHALL fetch data from Digital_Ocean_Backend
4. WHEN Patient_Mode is active, THE App SHALL display patient search, registration, and session management UI elements
5. WHEN Patient_Mode is active AND an Active_Patient is selected, THE Dashboard SHALL fetch data from New_Supabase_Project filtered by the Active_Patient patient_id
6. WHEN Patient_Mode is active AND no Active_Patient is selected, THE Dashboard SHALL display a prompt to select or register a patient
7. THE App SHALL persist the selected mode (Host_Mode or Patient_Mode) across app restarts
8. THE App SHALL default to Host_Mode on first installation

### Requirement 2: Patient Registration

**User Story:** As a clinic administrator, I want to register new patients with their demographic information, so that I can track their test sessions individually.

#### Acceptance Criteria

1. WHEN Patient_Mode is active, THE App SHALL provide a patient registration form
2. THE Patient_Registration_Form SHALL accept name (text, maximum 100 characters)
3. THE Patient_Registration_Form SHALL accept age (integer, range 0 to 150)
4. THE Patient_Registration_Form SHALL accept gender (text)
5. THE Patient_Registration_Form SHALL accept contact information (text, maximum 50 characters)
6. THE Patient_Registration_Form SHALL accept notes (text, maximum 500 characters)
7. WHEN a patient is registered, THE App SHALL generate a unique Patient_Code in sequential format starting from PT-0001
8. THE Patient_Code sequence SHALL be unique per Host_User_Id
9. WHEN a patient is registered, THE App SHALL save the patient profile to Research_Patients_Table in New_Supabase_Project with Host_User_Id as partition key
10. IF the patient registration fails due to network connectivity, THEN THE App SHALL display an error message and retain the entered data for retry

### Requirement 3: Patient Search and Selection

**User Story:** As a clinic administrator, I want to search for patients by name or patient code, so that I can quickly select the correct patient before conducting a test.

#### Acceptance Criteria

1. WHEN Patient_Mode is active, THE App SHALL provide a patient search interface
2. THE Patient_Search_Interface SHALL filter patients by Patient_Code matching partial or full input
3. THE Patient_Search_Interface SHALL filter patients by name matching partial or full input
4. THE Patient_Search_Results SHALL display only patients with matching Host_User_Id
5. THE Patient_Search_Results SHALL display Patient_Code, name, age, and gender for each matching patient
6. WHEN a patient is selected from search results, THE App SHALL set that patient as Active_Patient
7. WHEN a patient is selected, THE App SHALL persist the Active_Patient selection across app restarts within Patient_Mode
8. THE Patient_Search_Interface SHALL return results within 2 seconds for databases containing up to 10,000 patient records per Host_User_Id

### Requirement 4: Test Data Dual-Write Operation

**User Story:** As a system administrator, I want test readings to be saved to both the Digital Ocean backend and the new Supabase project, so that existing functionality is preserved while patient-specific tracking is enabled.

#### Acceptance Criteria

1. WHEN a test completes, THE App SHALL save the Test_Reading to Digital_Ocean_Backend using the existing flow
2. WHEN a test completes AND Patient_Mode is active AND an Active_Patient is selected, THE App SHALL save a copy of the Test_Reading to Patient_Readings_Table in New_Supabase_Project
3. THE Test_Reading copy SHALL include trial1, trial2, trial3, hand, posture, assessment_type, patient_id, Host_User_Id, and created_at timestamp
4. IF the save to Digital_Ocean_Backend fails, THEN THE App SHALL not proceed with the save to New_Supabase_Project
5. IF the save to Digital_Ocean_Backend succeeds AND the save to New_Supabase_Project fails, THEN THE App SHALL queue the patient reading for retry
6. THE App SHALL retry queued patient readings when network connectivity is restored
7. THE App SHALL preserve Device_ID association in Digital_Ocean_Backend unchanged
8. WHEN Host_Mode is active, THE App SHALL save Test_Reading only to Digital_Ocean_Backend

### Requirement 5: Dashboard Data Source Switching

**User Story:** As a clinic administrator, I want the dashboard to show patient-specific data when a patient is selected, so that I can review that patient's test history and trends.

#### Acceptance Criteria

1. WHEN Host_Mode is active, THE Dashboard SHALL fetch all test data from Digital_Ocean_Backend filtered by Host_User_Id
2. WHEN Patient_Mode is active AND an Active_Patient is selected, THE Dashboard SHALL fetch all test data from New_Supabase_Project filtered by patient_id
3. THE Dashboard SHALL display the same UI widgets regardless of data source
4. THE Dashboard SHALL display the data source mode (Host or Patient name) in the header
5. WHEN switching between Host_Mode and Patient_Mode, THE Dashboard SHALL refresh data from the appropriate source within 2 seconds
6. WHEN in Patient_Mode AND the Active_Patient changes, THE Dashboard SHALL refresh data for the new Active_Patient within 2 seconds

### Requirement 6: Patient Session View

**User Story:** As a clinic administrator, I want to view all test sessions for a selected patient, so that I can review their assessment history and progress.

#### Acceptance Criteria

1. WHEN Patient_Mode is active AND an Active_Patient is selected, THE App SHALL provide a patient session view
2. THE Patient_Session_View SHALL display patient profile information (Patient_Code, name, age, gender, contact, notes)
3. THE Patient_Session_View SHALL display all Test_Reading records for the Active_Patient sorted by created_at descending
4. THE Patient_Session_View SHALL display for each Test_Reading the date, hand, posture, trial1, trial2, trial3, and calculated average values
5. THE Patient_Session_View SHALL calculate and display average grip strength across all trials for each Test_Reading
6. THE Patient_Session_View SHALL update in real-time when new test data is saved

### Requirement 7: CSV Export Functionality

**User Story:** As a clinic administrator, I want to export patient test data to CSV format, so that I can analyze data in external tools or share with researchers.

#### Acceptance Criteria

1. WHEN Patient_Mode is active AND an Active_Patient is selected, THE Patient_Session_View SHALL provide a CSV export button
2. WHEN the CSV export button is activated, THE App SHALL generate a CSV file containing patient profile and all Test_Reading records
3. THE CSV file SHALL include header row with columns: Patient_Code, Name, Age, Gender, Contact, Test_Date, Hand, Posture, Trial_1_Kg, Trial_2_Kg, Trial_3_Kg, Average_Kg
4. THE CSV file SHALL include one data row per Test_Reading with all fields populated
5. THE CSV file SHALL be named in format: PatientCode_ExportDate.csv (e.g., PT-0001_2024-01-15.csv)
6. THE App SHALL save the CSV file to the device's downloads folder
7. THE App SHALL display a confirmation message with file location after successful export
8. IF the CSV export fails, THEN THE App SHALL display an error message with the failure reason

### Requirement 8: Multi-Device Data Isolation

**User Story:** As a clinic with multiple devices, I want each device to see only its own patients, so that different clinics or departments don't see each other's patient data.

#### Acceptance Criteria

1. THE App SHALL use Host_User_Id as a partition key for all queries to Research_Patients_Table
2. THE App SHALL use Host_User_Id as a partition key for all queries to Patient_Readings_Table
3. THE Patient_Search_Interface SHALL return only patients where Host_User_Id matches the logged-in Host_Account
4. THE Dashboard in Patient_Mode SHALL display only Test_Reading records where Host_User_Id matches the logged-in Host_Account
5. THE App SHALL not display or allow access to patient records from different Host_User_Id values
6. THE App SHALL enforce Host_User_Id filtering at the application layer before displaying any patient data

### Requirement 9: Database Schema for New Supabase Project

**User Story:** As a system administrator, I want the new Supabase project to have properly structured tables, so that patient data is stored consistently and can be queried efficiently.

#### Acceptance Criteria

1. THE New_Supabase_Project SHALL contain a table named research_patients
2. THE research_patients table SHALL have columns: id (uuid primary key), patient_code (text), name (text), age (integer), gender (text), contact (text), notes (text), host_user_id (text), created_at (timestamp)
3. THE research_patients table SHALL enforce unique constraint on (patient_code, host_user_id)
4. THE research_patients table SHALL have an index on host_user_id for query performance
5. THE New_Supabase_Project SHALL contain a table named patient_readings
6. THE patient_readings table SHALL have columns: id (uuid primary key), patient_id (uuid foreign key to research_patients.id), trial1 (numeric), trial2 (numeric), trial3 (numeric), hand (text), posture (text), assessment_type (text), host_user_id (text), created_at (timestamp)
7. THE patient_readings table SHALL have an index on patient_id for query performance
8. THE patient_readings table SHALL have an index on host_user_id for query performance
9. THE patient_readings table SHALL enforce foreign key constraint linking patient_id to research_patients.id

### Requirement 10: Backward Compatibility and Safety

**User Story:** As a system administrator, I want the new patient management feature to not interfere with existing functionality, so that current users can continue using the app without disruption.

#### Acceptance Criteria

1. THE App SHALL maintain read-only access to Digital_Ocean_Backend for existing data queries
2. THE App SHALL not modify the schema or data in Digital_Ocean_Backend
3. THE App SHALL not access or modify Existing_Supabase vitalStep table or kill-switch functionality
4. THE Device_ID value SHALL remain unchanged and continue to be associated with Host_Account in Digital_Ocean_Backend
5. WHEN Host_Mode is active, THE App SHALL function identically to the current production version
6. THE App SHALL continue to check kill-switch status from Existing_Supabase regardless of mode
7. IF New_Supabase_Project is unreachable, THE App SHALL continue to save test data to Digital_Ocean_Backend in both Host_Mode and Patient_Mode

### Requirement 11: Error Handling and Resilience

**User Story:** As a clinic administrator, I want the app to handle network failures gracefully, so that test sessions are not interrupted by connectivity issues.

#### Acceptance Criteria

1. IF New_Supabase_Project is offline during patient registration, THEN THE App SHALL queue the registration request for retry and display a warning message
2. IF New_Supabase_Project is offline during test save, THEN THE App SHALL queue the patient reading for retry and continue with Digital_Ocean_Backend save
3. THE App SHALL retry queued operations automatically when connectivity is detected
4. THE App SHALL limit retry attempts to 5 per queued operation with exponential backoff (2s, 4s, 8s, 16s, 32s)
5. IF all retry attempts fail, THEN THE App SHALL log the failure and notify the user with the operation details
6. THE App SHALL display network status indicator showing connection state to New_Supabase_Project when in Patient_Mode
7. IF Digital_Ocean_Backend is offline during test save, THEN THE App SHALL display an error and not proceed with New_Supabase_Project save

### Requirement 12: Patient Code Sequential Generation

**User Story:** As a clinic administrator, I want patient codes to be generated sequentially per device, so that I can easily identify the order in which patients were registered.

#### Acceptance Criteria

1. WHEN the first patient is registered for a Host_User_Id, THE App SHALL generate Patient_Code as PT-0001
2. WHEN subsequent patients are registered, THE App SHALL generate Patient_Code by incrementing the numeric portion (PT-0002, PT-0003, etc.)
3. THE App SHALL query New_Supabase_Project to determine the highest existing Patient_Code numeric value for the Host_User_Id before generating a new code
4. IF the query to determine the next Patient_Code fails, THEN THE App SHALL retry up to 3 times before displaying an error
5. THE Patient_Code generation SHALL handle concurrent registration attempts by using database-level unique constraint to prevent duplicates
6. IF a duplicate Patient_Code is detected during registration, THEN THE App SHALL retry generation with the next sequential number
