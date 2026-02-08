# Capability: Risk Factors Management

## ADDED Requirements

### Requirement: Chronic Risk Factor Tracking
The system SHALL allow users to record chronic medical conditions as risk factors including: diabetes_type2, chronic_kidney_disease, coronary_artery_disease, heart_failure, stroke_tia_history, sleep_apnea, thyroid_disorder, hyperlipidemia.

#### Scenario: Mark chronic condition as present
- **WHEN** user enables diabetes_type2 risk factor
- **THEN** the risk factor is recorded as is_present=true for the patient
- **AND** updated_at timestamp is set

#### Scenario: Add notes to risk factor
- **WHEN** user adds notes to a risk factor
- **THEN** the notes are stored with the risk factor record

### Requirement: Lifestyle Risk Factor Tracking
The system SHALL allow users to record lifestyle factors including: smoker_current, alcohol_high_intake, high_salt_diet, sedentary_lifestyle, obesity, chronic_stress.

#### Scenario: Toggle lifestyle factor
- **WHEN** user marks smoker_current as present
- **THEN** the lifestyle factor is recorded
- **AND** this data is included in AI analysis context

### Requirement: Family History Tracking
The system SHALL allow users to record family_history_hypertension as a risk factor.

#### Scenario: Record family history
- **WHEN** user indicates family history of hypertension
- **THEN** the family_history_hypertension factor is marked as present

### Requirement: Risk Factor Persistence
The system SHALL persist risk factors locally per patient and include them in analytics and AI context.

#### Scenario: Risk factors included in AI request
- **WHEN** AI analysis is requested
- **THEN** all present risk factors are included in the request payload

### Requirement: Risk Factor UI
The system SHALL display risk factors as a checklist grouped by category (Chronic, Lifestyle, Family).

#### Scenario: View risk factors by category
- **WHEN** user opens risk factors screen
- **THEN** factors are grouped under Chronic, Lifestyle, and Family headers
- **AND** each factor shows present/not present state
