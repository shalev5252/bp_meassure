# Capability: Analytics Engine

## ADDED Requirements

### Requirement: Minimum Readings for Analytics
The system SHALL require at least 3 valid readings before displaying analytics.

#### Scenario: Insufficient readings
- **WHEN** patient has fewer than 3 valid readings total
- **THEN** analytics dashboard shows "Add more readings" message
- **AND** no averages, trends, or charts are displayed

#### Scenario: Sufficient readings
- **WHEN** patient has 3 or more valid readings
- **THEN** analytics are calculated and displayed

### Requirement: Seven-Day Average Calculation
The system SHALL calculate 7-day rolling averages for systolic and diastolic values from valid readings only.

#### Scenario: Calculate 7-day average
- **WHEN** patient has 10 valid readings in the past 7 days
- **THEN** average systolic and diastolic are computed
- **AND** invalid readings are excluded from calculation

#### Scenario: Insufficient data
- **WHEN** patient has fewer than 2 valid readings in 7 days
- **THEN** 7-day average is marked as unavailable

### Requirement: Thirty-Day Average Calculation
The system SHALL calculate 30-day rolling averages for systolic and diastolic values from valid readings only.

#### Scenario: Calculate 30-day average
- **WHEN** patient has valid readings over 30 days
- **THEN** average systolic and diastolic are computed

### Requirement: Standard Deviation Calculation
The system SHALL calculate standard deviation for both systolic and diastolic values over the selected time period.

#### Scenario: Calculate variability
- **WHEN** analytics are computed for 30 days
- **THEN** standard deviation is provided for systolic and diastolic
- **AND** high variability (std dev > 10) is flagged

### Requirement: Morning vs Evening Comparison
The system SHALL calculate separate averages for readings tagged as "morning" versus "evening".

#### Scenario: Compare time-of-day readings
- **WHEN** patient has readings with morning and evening tags
- **THEN** separate averages are computed for each time period
- **AND** the difference is displayed

#### Scenario: No evening readings
- **WHEN** patient has no evening-tagged readings
- **THEN** evening average shows as unavailable

### Requirement: Linear Trend Slope
The system SHALL calculate the linear trend slope for systolic and diastolic over the selected time period using linear regression.

#### Scenario: Detect rising trend
- **WHEN** readings show increasing systolic over 30 days
- **THEN** trend slope is positive
- **AND** trend is labeled as "Rising"

#### Scenario: Detect stable trend
- **WHEN** readings show minimal change (slope near 0)
- **THEN** trend is labeled as "Stable"

#### Scenario: Detect declining trend
- **WHEN** readings show decreasing systolic over 30 days
- **THEN** trend slope is negative
- **AND** trend is labeled as "Declining"

### Requirement: Threshold Percentage Above 140/90
The system SHALL calculate the percentage of valid readings with systolic ≥140 OR diastolic ≥90.

#### Scenario: Calculate hypertensive reading percentage
- **WHEN** patient has 20 valid readings, 5 above 140/90
- **THEN** percentage is 25%

### Requirement: Threshold Percentage Above 160/100
The system SHALL calculate the percentage of valid readings with systolic ≥160 OR diastolic ≥100.

#### Scenario: Calculate grade 2+ reading percentage
- **WHEN** patient has 20 valid readings, 2 above 160/100
- **THEN** percentage is 10%

### Requirement: Analytics Dashboard Display
The system SHALL display all computed metrics on an analytics dashboard with clear labels and time period selector.

#### Scenario: View analytics dashboard
- **WHEN** user opens analytics screen
- **THEN** 7-day and 30-day averages are displayed
- **AND** standard deviations are shown
- **AND** trend indicators are visible
- **AND** threshold percentages are displayed

### Requirement: Trend Chart Visualization
The system SHALL display a line chart showing systolic and diastolic values over time with classification threshold lines.

#### Scenario: Render trend chart
- **WHEN** patient has readings over 30 days
- **THEN** a line chart is rendered with two lines (systolic, diastolic)
- **AND** horizontal threshold lines at 140 and 90 are shown
- **AND** chart renders in under 300ms
