# Capability: User Authentication

## ADDED Requirements

### Requirement: User Account Creation
The system SHALL allow users to create accounts using email and password via Firebase Auth.

#### Scenario: Sign up with email
- **WHEN** user enters valid email and password (min 8 characters)
- **THEN** a Firebase account is created
- **AND** user is logged in automatically
- **AND** user proceeds to onboarding

#### Scenario: Sign up with existing email
- **WHEN** user enters an email that already exists
- **THEN** an error message is displayed
- **AND** user is prompted to log in instead

#### Scenario: Password requirements
- **WHEN** user enters password shorter than 8 characters
- **THEN** validation error is shown

### Requirement: User Login
The system SHALL allow users to log in with email and password.

#### Scenario: Successful login
- **WHEN** user enters correct email and password
- **THEN** user is authenticated
- **AND** user proceeds to home screen (if onboarding complete)

#### Scenario: Failed login
- **WHEN** user enters incorrect credentials
- **THEN** error message is displayed
- **AND** user can retry

### Requirement: Persistent Session
The system SHALL maintain user session across app restarts.

#### Scenario: Auto-login on app restart
- **WHEN** user was previously logged in
- **AND** app is reopened
- **THEN** user is automatically authenticated
- **AND** user sees home screen directly

### Requirement: User Logout
The system SHALL allow users to log out from the settings screen.

#### Scenario: Logout
- **WHEN** user taps logout in settings
- **THEN** session is cleared
- **AND** user is returned to login screen

### Requirement: Password Reset
The system SHALL allow users to reset their password via email.

#### Scenario: Request password reset
- **WHEN** user requests password reset for a valid email
- **THEN** Firebase sends password reset email
- **AND** confirmation message is shown

### Requirement: Firebase Token for Backend
The system SHALL include Firebase ID token in API requests to the backend.

#### Scenario: Authenticated API request
- **WHEN** user makes request to /v1/ai/analyze
- **THEN** Firebase ID token is included in Authorization header
- **AND** backend verifies token with Firebase Admin SDK

### Requirement: Local User Cache
The system SHALL cache user information (user_id, email) locally for offline reference.

#### Scenario: Store user on login
- **WHEN** user successfully logs in
- **THEN** user_id and email are stored in local database
- **AND** last_login_at is updated

### Requirement: Onboarding State Tracking
The system SHALL track whether onboarding is complete for each user.

#### Scenario: New user onboarding
- **WHEN** new user signs up
- **THEN** onboarding flow is initiated
- **AND** user cannot access main app until onboarding is complete

#### Scenario: Returning user
- **WHEN** user with completed onboarding logs in
- **THEN** user goes directly to home screen
