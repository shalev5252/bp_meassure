# Capability: Medications Management

## ADDED Requirements

### Requirement: Medication Recording
The system SHALL allow users to record medications with name (required), dose_text (optional), frequency_text (optional), is_active status, and started_on date (optional).

#### Scenario: Add active medication
- **WHEN** user adds a medication with name "Lisinopril" and dose "10mg"
- **THEN** the medication is created with is_active=true
- **AND** a unique medication_id is assigned

#### Scenario: Add medication with frequency
- **WHEN** user specifies frequency_text as "once daily"
- **THEN** the frequency is stored with the medication record

### Requirement: Medication Status Toggle
The system SHALL allow users to mark medications as active or inactive.

#### Scenario: Deactivate medication
- **WHEN** user marks a medication as inactive
- **THEN** is_active is set to false
- **AND** the medication remains in history

#### Scenario: Reactivate medication
- **WHEN** user marks an inactive medication as active
- **THEN** is_active is set to true

### Requirement: Medication Editing
The system SHALL allow users to edit medication details after creation.

#### Scenario: Update medication dose
- **WHEN** user changes dose_text from "10mg" to "20mg"
- **THEN** the dose is updated
- **AND** updated_at timestamp is refreshed

### Requirement: Medication Deletion
The system SHALL allow users to delete medications with confirmation.

#### Scenario: Delete medication
- **WHEN** user confirms medication deletion
- **THEN** the medication record is removed

### Requirement: Medication List Display
The system SHALL display medications with active medications shown first, followed by inactive.

#### Scenario: View medication list
- **WHEN** user opens medications screen
- **THEN** active medications appear at the top
- **AND** inactive medications appear below with visual distinction

### Requirement: No Medication Dosage Advice
The system SHALL NOT provide any medication dosage advice or recommendations through AI or any other means.

#### Scenario: AI response about medications
- **WHEN** AI analyzes readings for a patient with medications
- **THEN** AI may mention that medications are present
- **BUT** AI SHALL NOT suggest dosage changes or new medications
