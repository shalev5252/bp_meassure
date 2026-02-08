# Capability: Patient Management

## ADDED Requirements

### Requirement: Patient Profile Creation
The system SHALL allow users to create patient profiles with display name (required), date of birth (optional), sex (optional), height in cm (optional), and weight in kg (optional).

#### Scenario: Create patient with minimal information
- **WHEN** user provides only a display name
- **THEN** a new patient profile is created with a unique UUID
- **AND** created_at and updated_at timestamps are set

#### Scenario: Create patient with full demographics
- **WHEN** user provides display name, date of birth, sex, height, and weight
- **THEN** all fields are stored in the patient profile

### Requirement: Patient Profile Editing
The system SHALL allow users to edit all patient profile fields after creation.

#### Scenario: Update patient name
- **WHEN** user changes the display name
- **THEN** the display name is updated
- **AND** updated_at timestamp is refreshed

#### Scenario: Add optional fields later
- **WHEN** user adds height and weight to an existing profile
- **THEN** the optional fields are saved

### Requirement: Patient Profile Deletion
The system SHALL allow users to delete patient profiles with confirmation.

#### Scenario: Delete patient with readings
- **WHEN** user confirms deletion of a patient
- **THEN** the patient profile is deleted
- **AND** all associated readings, risk factors, and medications are deleted

### Requirement: Multi-Patient Support
The system SHALL support multiple patient profiles within a single app instance.

#### Scenario: Switch between patients
- **WHEN** user selects a different patient from the patient list
- **THEN** all views update to show that patient's data

#### Scenario: Display patient count
- **WHEN** app has multiple patients
- **THEN** a patient selector is visible on the home screen

### Requirement: Patient Sex Options
The system SHALL provide sex options of: male, female, other, or unspecified.

#### Scenario: Select sex during profile creation
- **WHEN** user creates a profile
- **THEN** sex selection defaults to unspecified
- **AND** user may choose male, female, other, or unspecified
