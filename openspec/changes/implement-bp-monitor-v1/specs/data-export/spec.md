# Capability: Data Export

## ADDED Requirements

### Requirement: PDF Export
The system SHALL generate PDF reports containing patient name, date range, averages, trend graph, and reading table.

#### Scenario: Generate PDF report
- **WHEN** user selects PDF export
- **THEN** a PDF document is generated
- **AND** document includes patient display name
- **AND** document includes selected date range
- **AND** document includes average systolic and diastolic
- **AND** document includes trend graph image
- **AND** document includes table of readings

#### Scenario: Localized PDF
- **WHEN** Hebrew is the active language
- **THEN** PDF content is in Hebrew
- **AND** PDF layout is RTL

### Requirement: CSV Export
The system SHALL generate CSV files containing all readings for the selected date range.

#### Scenario: Generate CSV file
- **WHEN** user selects CSV export
- **THEN** a CSV file is generated
- **AND** file includes headers: reading_id, taken_at, systolic, diastolic, pulse, context_tags, quality, notes

#### Scenario: CSV date range
- **WHEN** user selects last 30 days for export
- **THEN** only readings from that period are included

### Requirement: Export Date Range Selection
The system SHALL allow users to select a date range for export (7 days, 30 days, all time, or custom).

#### Scenario: Select export range
- **WHEN** user opens export screen
- **THEN** date range options are presented
- **AND** user can choose 7 days, 30 days, all time, or custom dates

### Requirement: Export Sharing
The system SHALL integrate with the device share sheet for exporting files.

#### Scenario: Share PDF
- **WHEN** PDF is generated
- **THEN** device share sheet opens
- **AND** user can share via email, messaging, or save to files

#### Scenario: Share CSV
- **WHEN** CSV is generated
- **THEN** device share sheet opens
- **AND** user can share or save the file

### Requirement: Export for Healthcare Provider
The system SHALL format PDF reports in a way suitable for sharing with healthcare providers.

#### Scenario: Provider-friendly format
- **WHEN** PDF report is generated
- **THEN** it includes clear labels and units (mmHg)
- **AND** readings are in chronological order
- **AND** classification is shown for each reading

### Requirement: Export All Data
The system SHALL provide an option to export all patient data (all readings, all time).

#### Scenario: Full data export
- **WHEN** user selects "Export All Data"
- **THEN** all readings for the patient are included in CSV
- **AND** no date filtering is applied
