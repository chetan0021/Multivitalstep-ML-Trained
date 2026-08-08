# Implementation Plan: Device Selection Enhancement

## Overview

This implementation plan adds minimal device selection functionality to the existing Flutter app. The enhancement transforms the current read-only device list into an interactive selection interface with radio buttons, allowing users to select one device at a time for clarity about which device is active.

The approach focuses on minimal architectural changes while adding essential selection state management and visual indicators.

## Tasks

- [x] 1. Create device selection service for state management
  - Create `DeviceSelectionService` class with selection state management
  - Implement device selection persistence using GetStorage
  - Add service registration to app locator
  - _Requirements: 1.4, 4.3, 5.1, 5.5_

- [ ]* 1.1 Write property test for device selection service
  - **Property 1: Single Device Selection Invariant**
  - **Validates: Requirements 1.4**

- [x] 2. Enhance Device model with selection state
  - Add extension methods to Device model for selection state
  - Create selection state data models (DeviceSelectionState, ConnectionStatus)
  - Implement JSON serialization for persistence
  - _Requirements: 1.2, 1.3, 2.4_

- [ ]* 2.1 Write unit tests for Device model extensions
  - Test selection state methods and serialization
  - _Requirements: 1.2, 1.3_

- [x] 3. Update DeviceViewModel with selection logic
  - Add device selection methods to DeviceViewModel
  - Integrate DeviceSelectionService into existing ViewModel
  - Add selection state reactive properties
  - Implement device selection persistence and restoration
  - _Requirements: 1.2, 1.4, 5.1, 5.2, 5.3_

- [ ]* 3.1 Write property test for selection persistence
  - **Property 5: Device Selection Persistence**
  - **Validates: Requirements 4.3, 5.1, 5.5**

- [ ]* 3.2 Write property test for selection restoration
  - **Property 6: Selection Restoration Behavior**
  - **Validates: Requirements 5.2, 5.3, 5.4**

- [x] 4. Checkpoint - Ensure core selection logic works
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Update DeviceView with selection UI components
  - Modify `_buildDeviceCard` method to include radio button selection
  - Add visual selection indicators and highlighting
  - Implement haptic feedback for device selection
  - Update device card styling for selected/unselected states
  - _Requirements: 1.1, 1.3, 6.1, 6.2, 6.4_

- [ ]* 5.1 Write unit tests for device card interactions
  - Test radio button selection and visual feedback
  - _Requirements: 1.1, 6.1, 6.2_

- [x] 6. Add connection status indicators
  - Create ConnectionStatusIndicator widget
  - Add connection status display to device cards
  - Implement status-based styling (Connected, Available, Offline)
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ]* 6.1 Write unit tests for connection status display
  - Test status indicator rendering and styling
  - _Requirements: 3.1, 3.2, 3.3_

- [x] 7. Implement "Continue with Selected Device" functionality
  - Add continue button that enables only when device is selected
  - Implement navigation to dashboard with selected device context
  - Pass device configuration to subsequent screens
  - _Requirements: 4.1, 4.2, 4.4_

- [ ]* 7.1 Write integration tests for continue functionality
  - Test complete selection-to-navigation flow
  - _Requirements: 4.1, 4.2, 4.4_

- [x] 8. Checkpoint - Ensure UI components work correctly
  - Ensure all tests pass, ask the user if questions arise.

- [x] 9. Add basic connection management (minimal implementation)
  - Create simple ConnectionManagerService for connection status tracking
  - Implement basic connection state management (connected/available/offline)
  - Add connection status updates to selected devices
  - _Requirements: 2.1, 2.2, 2.4, 2.5_

- [ ]* 9.1 Write property test for connection behavior
  - **Property 2: Successful Connection Behavior**
  - **Validates: Requirements 2.2**

- [ ]* 9.2 Write property test for connection failure handling
  - **Property 3: Connection Failure State Preservation**
  - **Validates: Requirements 2.3**

- [x] 10. Enhance skip functionality
  - Update skip button to clearly indicate running without device
  - Add option to return to device selection from dashboard
  - Maintain skip option visibility regardless of device availability
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ]* 10.1 Write unit tests for enhanced skip functionality
  - Test skip navigation and state management
  - _Requirements: 8.1, 8.2, 8.3_

- [x] 11. Add basic error handling for device operations
  - Implement error dialogs for connection failures
  - Add retry options for failed connections
  - Handle device unavailability scenarios
  - _Requirements: 7.1, 7.2, 7.4_

- [ ]* 11.1 Write property test for error handling
  - **Property 7: Connection Error Handling**
  - **Validates: Requirements 7.1, 7.2**

- [ ]* 11.2 Write property test for device unavailability
  - **Property 8: Device Unavailability Handling**
  - **Validates: Requirements 7.4**

- [x] 12. Final integration and testing
  - [x] 12.1 Wire all components together
    - Ensure DeviceView, DeviceViewModel, and services work cohesively
    - Test complete user flow from device list to dashboard
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 4.1, 4.2_
  
  - [ ]* 12.2 Write integration tests for complete flow
    - Test end-to-end device selection and navigation
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 4.1, 4.2_

- [x] 13. Final checkpoint - Ensure complete functionality
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at key milestones
- Property tests validate universal correctness properties from the design
- Unit tests validate specific examples and edge cases
- Focus is on minimal changes to existing architecture while adding essential selection functionality
- Connection management is kept simple to avoid major architectural changes
- Visual indicators provide clear feedback about device selection state