# Dashboard

## Purpose

Home screen displayed after authentication. Shows the most recent movement and provides quick access to the QR scanner.

## Requirements

### Requirement: Display dashboard with last movement
The system SHALL display the dashboard as the home screen after authentication, showing the most recent movement recorded by the user.

#### Scenario: Dashboard with existing movements
- **WHEN** the user navigates to the dashboard and at least one movement exists in history
- **THEN** the system displays the details of the most recent movement (place name, type, timestamp)

#### Scenario: Dashboard with no movements
- **WHEN** the user navigates to the dashboard and no movements have been recorded yet
- **THEN** the system displays a message "Aucun mouvement enregistré" prompting the user to scan a QR code

### Requirement: Quick access to QR scanner
The system SHALL provide a prominent button on the dashboard to navigate to the QR scanner screen.

#### Scenario: Navigate to scanner from dashboard
- **WHEN** the user taps the scanner button on the dashboard
- **THEN** the system navigates to the QR scanner screen

### Requirement: Dashboard pull-to-refresh
The system SHALL allow the user to refresh the dashboard data by pulling down.

#### Scenario: User pulls to refresh
- **WHEN** the user performs a pull-to-refresh gesture on the dashboard
- **THEN** the system reloads the last movement from local storage and attempts to sync with the API
