# Movement History

## ADDED Requirements

### Requirement: Display movement list
The system SHALL display a chronological list of all recorded movements, ordered by most recent first.

#### Scenario: History with movements
- **WHEN** the user navigates to the history tab
- **THEN** the system displays a list of movements with place name, movement type (Entrée/Sortie), and timestamp for each entry

#### Scenario: Empty history
- **WHEN** the user navigates to the history tab and no movements exist
- **THEN** the system displays an empty state message "Aucun historique de mouvements"

### Requirement: Filter by date
The system SHALL allow the user to filter movements by date range.

#### Scenario: Filter with date range
- **WHEN** the user selects a start date and end date and applies the filter
- **THEN** the system displays only movements whose timestamp falls within the selected range

### Requirement: Filter by place
The system SHALL allow the user to filter movements by place.

#### Scenario: Filter by selected place
- **WHEN** the user selects a place from the filter dropdown
- **THEN** the system displays only movements associated with that place

### Requirement: Filter by movement type
The system SHALL allow the user to filter movements by type (Entrée or Sortie).

#### Scenario: Filter by entry type
- **WHEN** the user selects "Entrée" in the type filter
- **THEN** the system displays only entry movements

#### Scenario: Filter by exit type
- **WHEN** the user selects "Sortie" in the type filter
- **THEN** the system displays only exit movements

### Requirement: Combined filters
The system SHALL support applying multiple filters simultaneously.

#### Scenario: All filters active
- **WHEN** the user applies a date range, a place filter, and a type filter together
- **THEN** the system displays only movements matching all selected criteria

### Requirement: Offline availability
The system SHALL serve movement history from local Hive storage when offline.

#### Scenario: Access history while offline
- **WHEN** the user opens the history tab without internet connectivity
- **THEN** the system displays the locally stored movement history without attempting API calls

### Requirement: Sync status indication
The system SHALL indicate which movements are pending synchronization with the server.

#### Scenario: Pending sync movements
- **WHEN** the history contains movements recorded offline that haven't been synced
- **THEN** the system displays a visual indicator (icon) on those movements showing pending sync status
