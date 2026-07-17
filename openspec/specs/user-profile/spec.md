# User Profile

## Purpose

Display and edit user profile information, with logout capability.

## Requirements

### Requirement: Display user profile
The system SHALL display the current user's profile information.

#### Scenario: View profile
- **WHEN** the user navigates to the profile tab
- **THEN** the system displays the user's avatar (or placeholder), name, and email

### Requirement: Edit profile information
The system SHALL allow the user to modify their name and email.

#### Scenario: Successful profile update
- **WHEN** the user changes their name and email with valid values and submits the form
- **THEN** the system updates the user information via API, updates local state, and returns to the profile view with updated data

#### Scenario: Edit with invalid email
- **WHEN** the user submits the edit form with an invalid email format
- **THEN** the system displays a validation error and does not submit the form

#### Scenario: Edit with empty name
- **WHEN** the user submits the edit form with an empty name field
- **THEN** the system displays a validation error "Le nom est requis"

### Requirement: Logout from profile
The system SHALL provide a logout action from the profile screen.

#### Scenario: Logout from profile
- **WHEN** the user taps the logout button
- **THEN** the system displays a confirmation dialog. Upon confirmation, the session is cleared and the user is redirected to the login screen.
