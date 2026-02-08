# Capability: Safety Engine

## ADDED Requirements

### Requirement: Red Flag Detection
The system SHALL detect red flag readings when systolic ≥180 OR diastolic ≥120.

#### Scenario: Detect systolic red flag
- **WHEN** a reading is entered with systolic=185 and diastolic=95
- **THEN** red flag is triggered due to systolic ≥180

#### Scenario: Detect diastolic red flag
- **WHEN** a reading is entered with systolic=155 and diastolic=125
- **THEN** red flag is triggered due to diastolic ≥120

#### Scenario: Detect combined red flag
- **WHEN** a reading is entered with systolic=190 and diastolic=130
- **THEN** red flag is triggered

#### Scenario: No red flag for normal reading
- **WHEN** a reading is entered with systolic=135 and diastolic=88
- **THEN** no red flag is triggered

### Requirement: Pulse Warning Detection
The system SHALL detect pulse warnings when pulse is <50 bpm OR >100 bpm.

#### Scenario: Detect low pulse warning
- **WHEN** a reading is entered with pulse=45
- **THEN** pulse warning is triggered due to pulse <50 bpm

#### Scenario: Detect high pulse warning
- **WHEN** a reading is entered with pulse=110
- **THEN** pulse warning is triggered due to pulse >100 bpm

#### Scenario: No pulse warning for normal pulse
- **WHEN** a reading is entered with pulse=72
- **THEN** no pulse warning is triggered

#### Scenario: Pulse warning does not block AI
- **WHEN** pulse warning is triggered but no BP red flag exists
- **THEN** AI insights remain available
- **AND** pulse warning is shown separately

### Requirement: Safety Warning Screen
The system SHALL display a dedicated safety warning screen when a red flag reading is entered.

#### Scenario: Show safety warning
- **WHEN** red flag is detected on reading entry
- **THEN** a safety warning screen is displayed immediately
- **AND** the screen is visually distinct (red/alert styling)

#### Scenario: Safety warning content
- **WHEN** safety warning screen is shown
- **THEN** it displays a message advising medical consultation
- **AND** it does NOT provide emergency treatment instructions

### Requirement: AI Blocking on Red Flag
The system SHALL disable AI responses for the current session when a red flag reading is present.

#### Scenario: Block AI after red flag
- **WHEN** a red flag reading exists for the patient
- **THEN** the AI insights feature is disabled
- **AND** a message explains that AI is unavailable due to safety concern

#### Scenario: AI blocked message
- **WHEN** user attempts to access AI insights with active red flag
- **THEN** message states "AI insights unavailable. Please consult a healthcare provider for readings at this level."

### Requirement: No Emergency Treatment Instructions
The system SHALL NOT provide any emergency treatment instructions or protocols under any circumstances.

#### Scenario: Safety warning limitations
- **WHEN** safety warning is displayed
- **THEN** it advises seeking medical attention
- **BUT** it does NOT instruct on taking medications, calling emergency services, or specific actions

### Requirement: Safety Flag in Analytics Context
The system SHALL include safety flags in the AI request payload indicating has_red_flag status and highest recorded values.

#### Scenario: Include safety context
- **WHEN** AI analysis payload is constructed
- **THEN** safety_flags object includes has_red_flag boolean
- **AND** highest_systolic and highest_diastolic from recent readings

### Requirement: Safety Override on Backend
The backend system SHALL apply safety override and block AI analysis when safety_flags.has_red_flag is true.

#### Scenario: Backend rejects red flag request
- **WHEN** AI analyze request includes has_red_flag=true
- **THEN** backend returns safety_override_applied=true
- **AND** response contains only disclaimer and consult_recommendation
- **AND** no AI-generated content is included
