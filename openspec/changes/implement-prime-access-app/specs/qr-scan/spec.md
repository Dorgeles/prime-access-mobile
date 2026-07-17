# QR Scan

## ADDED Requirements

### Requirement: Camera permission request
The system SHALL request camera permission before displaying the QR scanner view.

#### Scenario: Permission granted
- **WHEN** the user navigates to the scanner and camera permission is not yet granted
- **THEN** the system shows the permission dialog. Upon user granting permission, the camera opens.

#### Scenario: Permission denied
- **WHEN** the user denies the camera permission
- **THEN** the system displays a message explaining that camera access is required for QR scanning, with a button to open device settings

#### Scenario: Permission already granted
- **WHEN** the user navigates to the scanner and camera permission is already granted
- **THEN** the system opens the camera immediately

### Requirement: Location permission request
The system SHALL request GPS location permission when a QR code is detected, before recording the movement.

#### Scenario: Permission granted
- **WHEN** a QR code is detected and location permission is not yet granted
- **THEN** the system requests location permission. Upon user granting permission, the system fetches the current position.

#### Scenario: Permission denied
- **WHEN** the user denies or has permanently denied location permission
- **THEN** the system shows a dialog explaining that GPS access is required for recording movements correctly, with a button to open device settings. The scan is not finalized.

#### Scenario: GPS service disabled
- **WHEN** location permission is granted but the GPS service is turned off
- **THEN** the system shows a dialog prompting the user to enable GPS, with a button to open location settings.

### Requirement: GPS coordinate capture
The system SHALL capture the user's GPS coordinates (latitude, longitude) at the moment a QR code is detected.

#### Scenario: Position captured successfully
- **WHEN** the user scans a QR code and GPS is available
- **THEN** the system retrieves latitude and longitude with high accuracy and passes them to the confirmation screen.

#### Scenario: Position unavailable
- **WHEN** GPS coordinates cannot be retrieved (timeout, weak signal)
- **THEN** the system falls back to latitude="0.0" and longitude="0.0" and proceeds to the confirmation screen.

### Requirement: QR code detection
The system SHALL detect and decode QR codes in real-time from the camera feed.

#### Scenario: Valid QR code detected
- **WHEN** the camera detects a QR code with valid format
- **THEN** the system stops scanning, shows a loading overlay while fetching GPS position, then navigates to the confirmation screen with the QR data and coordinates.

#### Scenario: Invalid QR code detected
- **WHEN** the camera detects a QR code that does not match the expected format
- **THEN** the system displays an error message "QR code non valide" and allows the user to continue scanning

### Requirement: Movement confirmation
The system SHALL present a confirmation screen after a valid QR code is scanned before recording the movement.

#### Scenario: User confirms the movement — sync success
- **WHEN** the user taps "Confirmer" and the API call succeeds (hasError=false)
- **THEN** the system records the movement locally in Hive with synced status, and navigates back to the dashboard with a green success message.

#### Scenario: User confirms the movement — API error with code 800
- **WHEN** the user taps "Confirmer" and the API responds with hasError=false but status.code="800"
- **THEN** the system treats this as success (operation accepted by server). The movement is saved locally with synced status.

#### Scenario: User confirms the movement — API rejection
- **WHEN** the user taps "Confirmer" and the API responds with hasError=true and a non-800 status code
- **THEN** the system does NOT save the movement locally, displays the error message from status.message, and navigates to the dashboard with a red rejection message.

#### Scenario: User confirms the movement — network error
- **WHEN** the user taps "Confirmer" and the API is unreachable
- **THEN** the system saves the movement locally in Hive with a pending sync flag, and navigates to the dashboard with an orange warning message.

#### Scenario: User cancels the movement
- **WHEN** the user taps "Annuler" on the confirmation screen
- **THEN** the system discards the scanned data and returns to the scanner view

#### Scenario: Movement type determination for entry
- **WHEN** the user scans a QR code at a place where their last movement for that place was an exit (or no previous movement exists)
- **THEN** the system infers the movement type as "Entrée" and displays it on the confirmation screen

#### Scenario: Movement type determination for exit
- **WHEN** the user scans a QR code at a place where their last movement for that place was an entry
- **THEN** the system infers the movement type as "Sortie" and displays it on the confirmation screen

### Requirement: Offline recording
The system SHALL save the movement locally in Hive even when the API is unavailable.

#### Scenario: Movement recorded while offline
- **WHEN** the user confirms a movement and the API is unreachable
- **THEN** the system saves the movement in Hive with a pending sync flag and navigates back to the dashboard
