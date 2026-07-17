# Authentication

## ADDED Requirements

### Requirement: User registration
The system SHALL allow a new user to create an account by providing email, password, and name.

#### Scenario: Successful registration
- **WHEN** the user fills all required fields with valid data and submits the registration form
- **THEN** the system creates the account, stores the session token, and redirects to the dashboard

#### Scenario: Registration with invalid email
- **WHEN** the user submits a registration form with an invalid email format
- **THEN** the system displays a validation error "Format d'email invalide" and does not submit the form

#### Scenario: Registration with weak password
- **WHEN** the user submits a registration form with a password shorter than 6 characters
- **THEN** the system displays a validation error "Le mot de passe doit contenir au moins 6 caractères" and does not submit the form

#### Scenario: Registration with existing email
- **WHEN** the user submits a registration form with an email already in use
- **THEN** the system displays an error message from the API "Cet email est déjà utilisé"

#### Scenario: Registration form empty fields
- **WHEN** the user submits the registration form with one or more empty required fields
- **THEN** the system displays a validation error for each empty field

### Requirement: User login
The system SHALL allow an existing user to authenticate with email and password.

#### Scenario: Successful login
- **WHEN** the user enters valid credentials and submits the login form
- **THEN** the system authenticates the user, stores the session token, and redirects to the dashboard

#### Scenario: Login with wrong credentials
- **WHEN** the user submits incorrect email or password
- **THEN** the system displays an error message "Email ou mot de passe incorrect"

#### Scenario: Login with empty fields
- **WHEN** the user submits the login form with empty email or password fields
- **THEN** the system displays validation errors for each empty field

### Requirement: Session persistence
The system SHALL persist the authentication token locally and restore the session on app restart.

#### Scenario: App restart with valid session
- **WHEN** the user reopens the app after a previous successful authentication
- **THEN** the system restores the session and redirects directly to the dashboard

#### Scenario: App restart with expired session
- **WHEN** the user reopens the app and the stored token is expired or invalid
- **THEN** the system redirects to the login screen

### Requirement: Logout
The system SHALL allow the authenticated user to log out and clear their session.

#### Scenario: User logs out
- **WHEN** the user taps the logout button from the profile screen
- **THEN** the system clears the stored token, resets all local data, and redirects to the login screen
