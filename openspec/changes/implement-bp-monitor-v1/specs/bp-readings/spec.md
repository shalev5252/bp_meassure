# Capability: Blood Pressure Readings

## ADDED Requirements

### Requirement: Manual Reading Entry
The system SHALL allow users to manually enter blood pressure readings with systolic (required), diastolic (required), pulse (optional), taken_at datetime (required, defaults to now), context_tags (optional), measurement_quality (optional), and notes (optional).

#### Scenario: Enter basic reading
- **WHEN** user enters systolic=120 and diastolic=80
- **THEN** a reading is created with taken_at set to current time
- **AND** a unique reading_id is assigned

#### Scenario: Enter reading with all fields
- **WHEN** user enters systolic=135, diastolic=88, pulse=72, context tags ["morning", "after_rest"], quality="valid", and notes
- **THEN** all fields are stored with the reading

### Requirement: Reading Validation
The system SHALL validate that systolic is between 60-300 mmHg and diastolic is between 30-200 mmHg.

#### Scenario: Reject invalid systolic
- **WHEN** user enters systolic=350
- **THEN** the entry is rejected with validation error

#### Scenario: Accept edge case values
- **WHEN** user enters systolic=180 and diastolic=120
- **THEN** the reading is accepted (though safety flags will trigger)

### Requirement: Blood Pressure Classification
The system SHALL classify each reading according to Israel-aligned thresholds:
- Normal: SYS ≤130 AND DIA ≤85
- High-Normal/Borderline: SYS 130-139 OR DIA 85-89
- Hypertension Grade 1: SYS 140-159 OR DIA 90-99
- Hypertension Grade 2: SYS 160-179 OR DIA 100-109
- Hypertension Grade 3: SYS ≥180 OR DIA ≥110
- Severe/Crisis: SYS ≥180 AND/OR DIA ≥120

#### Scenario: Classify normal reading
- **WHEN** reading has systolic=118 and diastolic=76
- **THEN** classification is "Normal"

#### Scenario: Classify hypertension grade 1
- **WHEN** reading has systolic=145 and diastolic=92
- **THEN** classification is "Hypertension Grade 1"

#### Scenario: Higher category takes precedence
- **WHEN** reading has systolic=165 and diastolic=88
- **THEN** classification is "Hypertension Grade 2" (based on systolic)

### Requirement: Context Tags
The system SHALL support predefined context tags: morning, evening, after_rest, after_exercise, after_meal, stressed, at_doctor.

#### Scenario: Apply multiple context tags
- **WHEN** user selects "morning" and "after_rest"
- **THEN** both tags are stored as JSON array

### Requirement: Measurement Quality
The system SHALL allow marking readings as valid, invalid, or unsure.

#### Scenario: Mark reading as invalid
- **WHEN** user marks a reading as invalid
- **THEN** measurement_quality is set to "invalid"
- **AND** reading is excluded from analytics calculations

### Requirement: Reading History
The system SHALL display reading history in reverse chronological order with classification badges and the ability to filter by date range.

#### Scenario: View reading history
- **WHEN** user opens reading history
- **THEN** readings are shown newest first
- **AND** each reading displays classification color badge

#### Scenario: Filter by date range
- **WHEN** user selects last 7 days
- **THEN** only readings from the past 7 days are shown

### Requirement: Reading Editing
The system SHALL allow users to edit readings after creation.

#### Scenario: Edit reading values
- **WHEN** user changes systolic from 140 to 138
- **THEN** the reading is updated
- **AND** updated_at timestamp is refreshed
- **AND** classification is recalculated

### Requirement: Reading Deletion
The system SHALL allow users to delete readings with confirmation.

#### Scenario: Delete reading
- **WHEN** user confirms reading deletion
- **THEN** the reading is permanently removed
