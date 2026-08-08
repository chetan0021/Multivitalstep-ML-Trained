# Implementation Plan: Multi-Patient Session Management

## Overview

This implementation plan adds multi-patient session management to the Vital Step Flutter app following the existing Stacked MVVM architecture. The feature introduces dual-mode operation (Host Mode and Patient Mode), a second Supabase client for patient data, new data models, services, views, and dual-write test data capture. All tasks follow the existing codebase patterns and integrate seamlessly with the current Digital Ocean backend.

## Tasks

- [x] 1. Database Schema Setup and App Configuration
  - Create SQL migration script for New Supabase Project with `research_patients` and `patient_readings` tables
  - Update `pubspec.yaml` to change app name to `vital_step_data_collection` and description
  - Create tinted/desaturated logo asset `assets/Logo3_datacollection.png` from existing `Logo3.png`
  - Update `flutter_launcher_icons.yaml` to use new logo and run icon generator
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8, 9.9_

- [x] 2. Initialize Second Supabase Client in main.dart
  - [x] 2.1 Add second Supabase client initialization in `lib/main.dart`
    - Import `supabase_flutter` if not already imported
    - Create global `late final SupabaseClient patientSupabaseClient;` before `main()`
    - Initialize `patientSupabaseClient` directly (not via `Supabase.initialize()`) using `const String.fromEnvironment()` with keys `PATIENT_SUPABASE_URL` and `PATIENT_SUPABASE_ANON_KEY`
    - Use the provided URL `https://cbebmpgsbxqdzpfgqulj.supabase.co` and anon key as defaults
    - _Requirements: N/A (Infrastructure)_

- [ ]* 2.2 Write unit test for second Supabase client initialization
    - Test that `patientSupabaseClient` is initialized and distinct from `Supabase.instance.client`
    - Test that it uses the correct URL and anon key
    - _Requirements: N/A (Infrastructure)_

- [x] 3. Create Data Models
  - [x] 3.1 Create `lib/Model/research_patient.dart` with Freezed annotations
    - Define `ResearchPatient` class with fields: `id`, `patientCode`, `name`, `age`, `gender`, `contact`, `notes`, `hostUserId`, `createdAt`
    - Add `fromJson` and `toJson` factory methods
    - _Requirements: 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8_

  - [x] 3.2 Create `lib/Model/patient_reading.dart` with Freezed annotations
    - Define `PatientReading` class with fields: `id`, `patientId`, `trial1`, `trial2`, `trial3`, `hand`, `posture`, `assessmentType`, `hostUserId`, `createdAt`
    - Add `average` getter: `(trial1 + trial2 + trial3) / 3`
    - Add `toTest()` adapter method to convert to existing `Test` model for dashboard reuse
    - Add `fromJson` and `toJson` factory methods
    - _Requirements: 4.3, 6.4, 6.5_

  - [x] 3.3 Create transfer objects `PatientRegistrationData` and `PatientReadingData` in `lib/Model/`
    - `PatientRegistrationData`: name, age, gender, contact, notes (no hostUserId, injected by service)
    - `PatientReadingData`: patientId, hostUserId, trial1, trial2, trial3, hand, posture, assessmentType
    - _Requirements: 2.1, 4.2_

  - [x] 3.4 Run code generation: `flutter pub run build_runner build --delete-conflicting-outputs`
    - Generate `.freezed.dart` and `.g.dart` files for new models
    - _Requirements: N/A (Infrastructure)_


  - [ ]* 3.5 Write property test for PatientReading average getter
    - **Property 11: Average Calculation Correctness**
    - **Validates: Requirements 6.5**
    - Use `test` package to generate random trial value combinations and assert `(t1 + t2 + t3) / 3` matches `average` getter
    - Minimum 100 iterations
    - _Requirements: 6.5_

  - [ ]* 3.6 Write property test for PatientCode sequential format
    - **Property 5: Patient Code Sequential Format**
    - **Validates: Requirements 2.7, 12.1, 12.2**
    - For index `n` in `[1, 9999]`, assert `formatPatientCode(n)` returns string matching `PT-NNNN` with `n` zero-padded to 4 digits
    - Minimum 100 iterations
    - _Requirements: 2.7, 12.1, 12.2_

  - [ ]* 3.7 Write property test for form field length validation
    - **Property 8: Form Field Length Validation**
    - **Validates: Requirements 2.2, 2.5, 2.6**
    - For strings longer than max (100/50/500), validate returns non-null; at or below max, returns null
    - Minimum 100 iterations
    - _Requirements: 2.2, 2.5, 2.6_

- [x] 4. Implement ModeService
  - [x] 4.1 Create `lib/services/mode_service.dart`
    - Use `GetStorage` (already initialized in `main.dart`) to persist mode and active patient
    - Implement `isPatientMode` getter reading key `app_mode` (default `false` = Host Mode)
    - Implement `setPatientMode(bool value)` — clear active patient when switching to Host Mode
    - Implement `hasActivePatient`, `activePatientId`, `activePatientCode`, `activePatientName` getters
    - Implement `setActivePatient({required patientId, required patientCode, required patientName})`
    - Implement `clearActivePatient()`
    - _Requirements: 1.1, 1.2, 1.4, 1.7, 1.8, 3.6, 3.7_

  - [ ]* 4.2 Write property test for mode persistence round-trip
    - **Property 1: Mode Persistence Round-Trip**
    - **Validates: Requirements 1.7, 1.8**
    - For any boolean value written via `setPatientMode(v)`, assert `isPatientMode == v` on subsequent read
    - Test both `true` and `false` across 100 iterations
    - _Requirements: 1.7, 1.8_

- [x] 5. Implement PatientService
  - [x] 5.1 Create `lib/services/patient_service.dart` with `patientSupabaseClient` global reference
    - Inject `patientSupabaseClient` and `locator<LoginService>()`
    - Implement `getNextPatientCode(String hostUserId)` — query max patient_code for hostUserId, extract numeric part, increment, zero-pad to 4 digits
    - Handle retry up to 3 times on failure (Requirement 12.4)
    - Handle duplicate code conflict by incrementing to next sequential number (Requirement 12.6)
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6_

  - [x] 5.2 Implement `registerPatient(PatientRegistrationData data)` in `PatientService`
    - Validate field lengths: name ≤ 100, contact ≤ 50, notes ≤ 500, age 0–150
    - Retrieve `hostUserId` from `LoginService.getUserId()`
    - Call `getNextPatientCode(hostUserId)` to get the next code
    - Insert into `research_patients` table via `patientSupabaseClient`
    - Return the created `ResearchPatient`; on unique constraint violation, retry with next code
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10_

  - [x] 5.3 Implement `searchPatients(String query)` in `PatientService`
    - Query `research_patients` filtered by `host_user_id` (from `LoginService.getUserId()`)
    - Filter results where `patient_code` or `name` contains `query` (case-insensitive, using `ilike`)
    - Return list of `ResearchPatient`; return empty list on network failure
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.8, 8.1, 8.3_


  - [x] 5.4 Implement `getPatient(String patientId)` in `PatientService`
    - Query single patient from `research_patients` by `id` (UUID)
    - Return `ResearchPatient?` (null if not found or network error)
    - _Requirements: 3.6, 6.2_

  - [x] 5.5 Implement `saveReading(PatientReadingData data)` in `PatientService`
    - Insert into `patient_readings` table via `patientSupabaseClient`
    - On failure, throw exception to trigger retry queue in calling code
    - _Requirements: 4.2, 4.3_

  - [x] 5.6 Implement `getReadings(String patientId)` in `PatientService`
    - Query `patient_readings` filtered by `patient_id` and ordered by `created_at DESC`
    - Parse response to list of `PatientReading`
    - _Requirements: 5.2, 6.3, 6.4, 8.2, 8.4_

  - [x] 5.7 Implement retry queue mechanism in `PatientService`
    - Use `GetStorage` key `patient_readings_retry_queue` to persist queued readings as list of JSON maps
    - Implement `enqueueReading(PatientReadingData data)` — serialize and append to queue
    - Implement `processRetryQueue()` — iterate queue, attempt `saveReading()` for each, remove on success
    - Implement exponential backoff: 2s, 4s, 8s, 16s, 32s (max 5 attempts)
    - Store `enqueuedAt`, `attemptCount`, `nextRetryAt` metadata per queued item
    - Mark as permanently failed after 5th attempt, log and remove from queue
    - _Requirements: 4.5, 4.6, 11.2, 11.3, 11.4, 11.5_

  - [x] 5.8 Implement `exportCSV(String patientId)` in `PatientService`
    - Fetch patient via `getPatient(patientId)` and readings via `getReadings(patientId)`
    - Generate CSV header: `Patient_Code,Name,Age,Gender,Contact,Test_Date,Hand,Posture,Trial_1_Kg,Trial_2_Kg,Trial_3_Kg,Average_Kg`
    - Generate one data row per reading with all fields populated
    - Return CSV string; caller handles file write to downloads folder
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

  - [ ]* 5.9 Write property test for patient search filtering
    - **Property 3: Patient Search Filtering Completeness**
    - **Validates: Requirements 3.2, 3.3**
    - Generate list of `ResearchPatient` with random codes/names; for non-empty query Q, assert all returned patients contain Q in code or name (case-insensitive)
    - Minimum 100 iterations
    - _Requirements: 3.2, 3.3_

  - [ ]* 5.10 Write property test for host_user_id data isolation
    - **Property 4: Host User Id Data Isolation Invariant**
    - **Validates: Requirements 3.4, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6**
    - Mock Supabase responses with mixed `host_user_id` values; assert all returned rows have `host_user_id` matching current user
    - Minimum 100 iterations
    - _Requirements: 3.4, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_

  - [ ]* 5.11 Write property test for patient code uniqueness per host
    - **Property 6: Patient Code Uniqueness Per Host**
    - **Validates: Requirements 2.8, 12.5**
    - Generate list of patients under same hostUserId; assert all `patientCode` values are distinct
    - Test patients under different hostUserId may share codes
    - Minimum 100 iterations
    - _Requirements: 2.8, 12.5_

  - [ ]* 5.12 Write property test for retry backoff schedule
    - **Property 14: Retry Backoff Schedule**
    - **Validates: Requirements 11.4**
    - For attempt index n in [1, 5], assert delay equals 2^n seconds
    - Minimum 100 iterations
    - _Requirements: 11.4_

  - [ ]* 5.13 Write unit tests for PatientService
    - Test `registerPatient()` returns patient with correct fields
    - Test `searchPatients()` returns filtered results
    - Test `enqueueReading()` persists to GetStorage
    - Test `exportCSV()` generates correct header and row count
    - _Requirements: 2.9, 3.1, 4.5, 7.3, 7.4_


- [x] 6. Checkpoint – Core Services Complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 7. Register New Services in app.dart and Regenerate app.locator.dart
  - [x] 7.1 Add imports and registrations to `lib/app/app.dart`
    - Import `mode_service.dart` and `patient_service.dart`
    - Add `LazySingleton(classType: ModeService)` and `LazySingleton(classType: PatientService)` to `dependencies` list
    - Add new view imports: `PatientSearchView`, `PatientRegistrationView`, `PatientSessionView`, `PatientHistoryView`, `PatientEditView`
    - Add `MaterialRoute` entries for all five new views
    - _Requirements: N/A (Infrastructure)_

  - [x] 7.2 Run Stacked code generator to regenerate `app.locator.dart` and `app.router.dart`
    - Run `flutter pub run build_runner build --delete-conflicting-outputs`
    - Verify `locator<ModeService>()` and `locator<PatientService>()` resolve without errors
    - Verify all new routes appear in `Routes` class
    - _Requirements: N/A (Infrastructure)_

- [x] 8. Modify DashboardViewModel for Data Source Switching
  - [x] 8.1 Modify `lib/ui/views/dashboard/dashboard_viewmodel.dart`
    - Add `final _modeService = locator<ModeService>();` and `final _patientService = locator<PatientService>();`
    - In `refreshData()`: if `_modeService.isPatientMode && _modeService.hasActivePatient`, fetch via `_patientService.getReadings()` and convert using `toTest()` adapter; else use existing `_apiCallsService.getAllUserTests()`
    - Add a `dataSourceLabel` getter: returns patient name if Patient Mode active, else "Host"
    - _Requirements: 5.1, 5.2, 5.3, 5.5, 5.6_

  - [ ]* 8.2 Write unit tests for DashboardViewModel data source switching
    - Test Host Mode uses `ApiCallsService.getAllUserTests()`
    - Test Patient Mode with active patient uses `PatientService.getReadings()`
    - Test Patient Mode with no active patient shows prompt state
    - Test `dataSourceLabel` returns correct values
    - _Requirements: 1.3, 1.5, 1.6, 5.1, 5.2_

- [x] 9. Modify HomeTabViewModel for Data Source Switching
  - [x] 9.1 Modify `lib/ui/views/home_tab/home_tab_viewmodel.dart`
    - Add `final _modeService = locator<ModeService>();` and `final _patientService = locator<PatientService>();`
    - In `refreshData()`: if `_modeService.isPatientMode && _modeService.hasActivePatient`, fetch `userTests` via `_patientService.getReadings()` converted via `toTest()`; else use existing `_apiCallsService.getAllUserTests()`
    - _Requirements: 5.1, 5.2, 5.5, 5.6_

  - [ ]* 9.2 Write unit tests for HomeTabViewModel data source switching
    - Test Host Mode uses `ApiCallsService`
    - Test Patient Mode with active patient uses `PatientService`
    - _Requirements: 1.3, 1.5, 5.1, 5.2_

- [x] 10. Modify TestResultViewModel for Dual-Write
  - [x] 10.1 Modify `lib/ui/views/test_result/test_result_viewmodel.dart`
    - Add `final _modeService = locator<ModeService>();`, `final _patientService = locator<PatientService>();`, `final _loginService = locator<LoginService>();`
    - After the `initialise()` call retrieves the latest test (Digital Ocean already succeeded), add `_handleDualWrite(test)` call
    - Implement `_handleDualWrite(Test test)`: check `_modeService.isPatientMode && _modeService.hasActivePatient`; if yes, call `_patientService.saveReading()` with all fields; on failure, call `_patientService.enqueueReading()` and show `Fluttertoast` "Patient data queued for sync"
    - Never call `saveReading` if Digital Ocean save has already failed (guard: only called from success path)
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.7, 4.8_

  - [ ]* 10.2 Write property test for dual-write data fidelity
    - **Property 9: Dual-Write Data Fidelity**
    - **Validates: Requirements 4.2, 4.3**
    - For any test reading combination (random trial values, hand, posture, assessmentType), assert `PatientReadingData` fields exactly match the source `Test` fields
    - Minimum 100 iterations
    - _Requirements: 4.2, 4.3_

  - [ ]* 10.3 Write unit tests for dual-write logic
    - Test DO failure prevents Supabase write (Req 4.4)
    - Test Supabase failure enqueues reading (Req 4.5)
    - Test Host Mode skips Supabase write entirely (Req 4.8)
    - _Requirements: 4.4, 4.5, 4.8_


- [x] 11. Checkpoint – ViewModels Updated
  - Ensure all tests pass, ask the user if questions arise.

- [x] 12. Implement Settings Mode Toggle in AccountView
  - [x] 12.1 Modify `lib/ui/views/account/account_viewmodel.dart`
    - Add `final _modeService = locator<ModeService>();`
    - Add `bool get isPatientMode => _modeService.isPatientMode;`
    - Add `void togglePatientMode(bool value)` — call `_modeService.setPatientMode(value)`; call `notifyListeners()`
    - _Requirements: 1.1, 1.7, 1.8_

  - [x] 12.2 Modify `lib/ui/views/account/account_view.dart`
    - Add a new settings group section "Research Mode" between existing sections
    - Inside the group, add a `SwitchListTile` (or equivalent matching app style) bound to `viewModel.isPatientMode`
    - `onChanged` calls `viewModel.togglePatientMode(value)`
    - When in Patient Mode, show current active patient name below the toggle (or "No patient selected")
    - _Requirements: 1.1, 1.2, 1.4_

  - [ ]* 12.3 Write unit tests for AccountViewModel mode toggle
    - Test toggle calls `ModeService.setPatientMode()`
    - Test `isPatientMode` returns correct value from ModeService
    - Test default mode is false (Host Mode)
    - _Requirements: 1.1, 1.7, 1.8_

- [x] 13. Implement PatientSearchView
  - [x] 13.1 Create `lib/ui/views/patient_search/patient_search_viewmodel.dart`
    - Extend `BaseViewModel`; inject `ModeService`, `PatientService`, `NavigationService`
    - Maintain `searchQuery` string and `searchResults` list of `ResearchPatient`
    - Implement `onSearchChanged(String query)` — debounce 300ms, call `PatientService.searchPatients(query)`, update `searchResults`
    - Implement `selectPatient(ResearchPatient patient)` — call `ModeService.setActivePatient(...)`, navigate to `patientSessionView`
    - Implement `navigateToRegistration()` — navigate to `patientRegistrationView`
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8_

  - [x] 13.2 Create `lib/ui/views/patient_search/patient_search_view.dart`
    - Use `ViewModelBuilder.reactive<PatientSearchViewModel>`
    - Display search bar at top bound to `viewModel.onSearchChanged`
    - Display list of `searchResults` showing patient_code, name, age, gender per item
    - Tapping a result calls `viewModel.selectPatient(patient)`
    - Add FAB or action button "Register New Patient" calling `viewModel.navigateToRegistration()`
    - Match existing app visual style (colors, typography, card patterns from other views)
    - _Requirements: 3.1, 3.5_

  - [ ]* 13.3 Write property test for search result display completeness
    - **Property 15: Search Result Display Completeness**
    - **Validates: Requirements 3.5**
    - For any `ResearchPatient` in results, assert the rendered list item displays `patientCode`, `name`, `age`, and `gender`
    - Minimum 100 iterations using widget test
    - _Requirements: 3.5_

  - [ ]* 13.4 Write unit tests for PatientSearchViewModel
    - Test `onSearchChanged` calls `PatientService.searchPatients()`
    - Test `selectPatient` calls `ModeService.setActivePatient()` and navigates
    - _Requirements: 3.2, 3.6_

- [x] 14. Implement PatientRegistrationView
  - [x] 14.1 Create `lib/ui/views/patient_registration/patient_registration_viewmodel.dart`
    - Extend `BaseViewModel`; inject `PatientService`, `NavigationService`
    - Hold form field controllers/state for name, age, gender, contact, notes
    - Implement field validators: `validateName`, `validateAge`, `validateGender`, `validateContact`, `validateNotes` following design code
    - Implement `register()` — validate all fields; call `PatientService.registerPatient()`; on success navigate back to patientSearchView with refresh; on network error show error dialog and retain form data
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.9, 2.10_

  - [x] 14.2 Create `lib/ui/views/patient_registration/patient_registration_view.dart`
    - Use `ViewModelBuilder.reactive<PatientRegistrationViewModel>`
    - Form with `TextFormField` widgets for name (maxLength 100), age (numeric), gender, contact (maxLength 50), notes (maxLength 500, multi-line)
    - "Register Patient" submit button calling `viewModel.register()`
    - Show inline validation errors using existing app dialog/toast patterns
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

  - [ ]* 14.3 Write unit tests for PatientRegistrationViewModel
    - Test successful registration navigates back
    - Test network failure shows error and retains data (Req 2.10)
    - Test field validation enforces length limits
    - _Requirements: 2.9, 2.10_


- [x] 15. Implement PatientSessionView
  - [x] 15.1 Create `lib/ui/views/patient_session/patient_session_viewmodel.dart`
    - Extend `BaseViewModel`; inject `ModeService`, `PatientService`, `NavigationService`
    - In `init()`: fetch patient via `PatientService.getPatient(activePatientId)` and readings via `PatientService.getReadings(activePatientId)`
    - Maintain `ResearchPatient? patient` and `List<PatientReading> readings` (sorted by `created_at DESC` already from service)
    - Implement `exportCSV()` — call `PatientService.exportCSV(activePatientId)`, write to downloads folder, show success toast with file path
    - Implement `navigateToEdit()` — navigate to `patientEditView` with patient ID
    - Implement `navigateToHistory()` — navigate to `patientHistoryView` with patient ID
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 7.1, 7.2, 7.5, 7.6, 7.7, 7.8_

  - [x] 15.2 Create `lib/ui/views/patient_session/patient_session_view.dart`
    - Use `ViewModelBuilder.reactive<PatientSessionViewModel>`
    - Display patient profile card at top: patient_code, name, age, gender, contact, notes
    - Display list of readings (most recent first) with date, hand, posture, trial1, trial2, trial3, average
    - Add "Export CSV" button calling `viewModel.exportCSV()`
    - Add "View History" button calling `viewModel.navigateToHistory()`
    - Add "Edit Patient" button calling `viewModel.navigateToEdit()`
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 7.1_

  - [ ]* 15.3 Write property test for test session sorting invariant
    - **Property 10: Test Session Sorting Invariant**
    - **Validates: Requirements 6.3**
    - Generate list of readings with random `created_at` values; assert returned list is sorted DESC by `created_at`
    - Minimum 100 iterations
    - _Requirements: 6.3_

  - [ ]* 15.4 Write property test for CSV row completeness
    - **Property 12: CSV Row Completeness**
    - **Validates: Requirements 7.3, 7.4**
    - For list of readings, assert CSV has one data row per reading and all required columns are non-empty
    - Minimum 100 iterations
    - _Requirements: 7.3, 7.4_

  - [ ]* 15.5 Write property test for CSV filename format
    - **Property 13: CSV Filename Format**
    - **Validates: Requirements 7.5**
    - For any patient code P and date D, assert filename matches `{P}_{YYYY-MM-DD}.csv`
    - Minimum 100 iterations
    - _Requirements: 7.5_

  - [ ]* 15.6 Write unit tests for PatientSessionViewModel
    - Test `init()` loads patient and readings
    - Test `exportCSV()` writes file and shows success toast (Req 7.7)
    - Test CSV export failure shows error message (Req 7.8)
    - _Requirements: 6.2, 6.3, 6.4, 7.7, 7.8_

- [x] 16. Implement PatientHistoryView
  - [x] 16.1 Create `lib/ui/views/patient_history/patient_history_viewmodel.dart`
    - Extend `BaseViewModel`; inject `ModeService`, `PatientService`
    - In `init()`: fetch readings via `PatientService.getReadings(activePatientId)`
    - Generate chart data using `FlSpot` for left/right hand trends (reuse pattern from DashboardViewModel)
    - _Requirements: 6.3, 6.4_

  - [x] 16.2 Create `lib/ui/views/patient_history/patient_history_view.dart`
    - Use `ViewModelBuilder.reactive<PatientHistoryViewModel>`
    - Display charts (using `fl_chart`) showing trends over time for left/right hand (reuse existing app chart widgets)
    - Display full reading history list below charts
    - _Requirements: 6.3, 6.4_

  - [ ]* 16.3 Write unit tests for PatientHistoryViewModel
    - Test chart data generation matches readings count
    - _Requirements: 6.3, 6.4_

- [x] 17. Implement PatientEditView
  - [x] 17.1 Create `lib/ui/views/patient_edit/patient_edit_viewmodel.dart`
    - Extend `BaseViewModel`; inject `PatientService`, `NavigationService`
    - In `init()`: load patient via `PatientService.getPatient(patientId)`, populate form fields
    - Implement field validators (reuse from registration viewmodel)
    - Implement `saveChanges()` — update patient in Supabase via `patientSupabaseClient.from('research_patients').update(...)`; on success navigate back; on failure show error
    - _Requirements: 2.2, 2.3, 2.4, 2.5, 2.6_

  - [x] 17.2 Create `lib/ui/views/patient_edit/patient_edit_view.dart`
    - Use `ViewModelBuilder.reactive<PatientEditViewModel>`
    - Form pre-populated with existing patient data (name, age, gender, contact, notes)
    - "Save Changes" button calling `viewModel.saveChanges()`
    - Match registration form style
    - _Requirements: 2.2, 2.3, 2.4, 2.5, 2.6_

  - [ ]* 17.3 Write unit tests for PatientEditViewModel
    - Test `init()` loads existing patient data
    - Test `saveChanges()` updates Supabase and navigates back
    - _Requirements: 2.2, 2.9_


- [x] 18. Checkpoint – All Views Complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 19. Integrate Retry Queue with ConnectionManagerService
  - [x] 19.1 Modify `lib/services/connection_manager_service.dart`
    - Add `final _patientService = locator<PatientService>();`
    - Whenever connectivity is restored (status changes to connected), call `_patientService.processRetryQueue()` asynchronously
    - Add retry queue processing after successful connection establishment
    - _Requirements: 4.6, 11.3_

  - [ ]* 19.2 Write unit tests for retry queue integration
    - Test retry queue is processed when connectivity restored
    - _Requirements: 4.6, 11.3_

- [x] 20. Add Patient Mode UI Conditional Visibility
  - [x] 20.1 Modify navigation/home views to show patient management entry points
    - In `HomeTabView` or `AccountView`: add a patient search button/menu item visible only when `modeService.isPatientMode`
    - When tapped, navigate to `patientSearchView`
    - Hide these UI elements when `modeService.isHostMode`
    - _Requirements: 1.2, 1.4_

  - [x] 20.2 Add data source indicator to DashboardView header
    - Modify `lib/ui/views/dashboard/dashboard_view.dart` header to display `viewModel.dataSourceLabel` (e.g., "Host" or "Patient: John Doe")
    - Update on mode/patient change
    - _Requirements: 5.4_

  - [ ]* 20.3 Write property test for patient UI visibility invariant
    - **Property 2: Patient UI Visibility Invariant**
    - **Validates: Requirements 1.2, 1.4**
    - For any patient UI element, assert visible when `isPatientMode == true` and hidden when `isPatientMode == false`
    - Minimum 100 iterations using widget test
    - _Requirements: 1.2, 1.4_

- [x] 21. Add Error Handling and User Notifications
  - [x] 21.1 Add network status indicator in Patient Mode
    - In views where Patient Mode is active, add a small indicator (icon or text) showing Supabase connection status
    - Use `ConnectionManagerService` or a simple ping check to determine status
    - Display "Offline" warning when New Supabase is unreachable
    - _Requirements: 11.6_

  - [x] 21.2 Add persistent banner for permanently failed retry queue items
    - In Patient Mode views, check if `PatientService.retryQueue` contains permanently failed items (attemptCount >= 5)
    - Display a persistent banner (e.g., at top of screen) with count and "View Details" button
    - Show dialog listing failed operations with dates when user taps
    - _Requirements: 11.5_

  - [ ]* 21.3 Write unit tests for error handling UI
    - Test network status indicator shows "Offline" when Supabase unreachable
    - Test persistent banner appears when retry queue has failed items
    - _Requirements: 11.5, 11.6_

- [x] 22. Write Integration Tests
  - [ ]* 22.1 Write integration test for end-to-end patient registration → test → CSV export flow
    - Register patient → select patient → complete test → verify dual-write → export CSV → verify file contents
    - _Requirements: 2.9, 4.2, 7.3, 7.4_

  - [ ]* 22.2 Write integration test for mode switching
    - Start in Host Mode → verify dashboard shows DO data → switch to Patient Mode → select patient → verify dashboard shows patient data
    - _Requirements: 1.3, 1.5, 5.1, 5.2, 5.5, 5.6_

  - [ ]* 22.3 Write integration test for patient search and selection persistence
    - Search patient → select → restart app (simulate GetStorage persistence) → verify active patient retained
    - _Requirements: 3.6, 3.7_

  - [ ]* 22.4 Write integration test for retry queue processing
    - Enqueue reading → simulate network restore → verify retry queue processes and clears
    - _Requirements: 4.5, 4.6, 11.3_

- [x] 23. Final Checkpoint – Full Feature Testing
  - Ensure all tests pass, ask the user if questions arise.

- [x] 24. Update Documentation and Code Comments
  - [-] 24.1 Add code comments to all new services explaining dual-mode behavior
    - Document `ModeService` keys and persistence strategy
    - Document `PatientService` retry queue format
    - Document dual-write flow in `TestResultViewModel`
    - _Requirements: N/A (Documentation)_

  - [ ] 24.2 Add README section or developer notes about the dual Supabase client setup
    - Explain why two clients exist (kill-switch vs patient data)
    - Document `--dart-define` flags for build-time configuration
    - _Requirements: N/A (Documentation)_


## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Property tests validate universal correctness properties across random inputs
- Unit tests validate specific examples, edge cases, and integration points
- The design document provides detailed code examples for Dart/Flutter implementation
- All new services follow existing Stacked MVVM patterns from the codebase
- Dual-write logic only activates in Patient Mode with an active patient selected
- Host Mode preserves 100% backward compatibility with existing functionality
- The second Supabase client (`patientSupabaseClient`) is separate from the existing kill-switch client
- Retry queue uses exponential backoff (2s, 4s, 8s, 16s, 32s) with max 5 attempts
- CSV export generates one row per reading with all required columns
- All patient data is isolated by `host_user_id` to ensure multi-device separation
- Patient codes follow sequential format PT-0001, PT-0002, etc., unique per host
- Mode and active patient state persist across app restarts via GetStorage
- The design has 15 correctness properties; property tests cover all applicable ones
- Integration tests verify end-to-end flows including registration, dual-write, and CSV export

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1", "2.1"] },
    { "id": 1, "tasks": ["2.2", "3.1", "3.2", "3.3"] },
    { "id": 2, "tasks": ["3.4", "3.5", "3.6", "3.7", "4.1"] },
    { "id": 3, "tasks": ["4.2", "5.1", "5.2", "5.3", "5.4", "5.5"] },
    { "id": 4, "tasks": ["5.6", "5.7", "5.8", "5.9", "5.10", "5.11", "5.12", "5.13"] },
    { "id": 5, "tasks": ["7.1"] },
    { "id": 6, "tasks": ["7.2", "8.1", "9.1", "10.1", "12.1"] },
    { "id": 7, "tasks": ["8.2", "9.2", "10.2", "10.3", "12.2", "12.3"] },
    { "id": 8, "tasks": ["13.1", "14.1", "15.1", "16.1", "17.1"] },
    { "id": 9, "tasks": ["13.2", "14.2", "15.2", "16.2", "17.2"] },
    { "id": 10, "tasks": ["13.3", "13.4", "14.3", "15.3", "15.4", "15.5", "15.6", "16.3", "17.3"] },
    { "id": 11, "tasks": ["19.1", "20.1", "20.2", "21.1", "21.2"] },
    { "id": 12, "tasks": ["19.2", "20.3", "21.3", "22.1", "22.2", "22.3", "22.4"] },
    { "id": 13, "tasks": ["24.1", "24.2"] }
  ]
}
```
