# Capability: Internationalization (i18n)

## ADDED Requirements

### Requirement: Supported Languages
The system SHALL support English (en) and Hebrew (he) languages.

#### Scenario: Language options
- **WHEN** user opens language settings
- **THEN** English and Hebrew are available as options

### Requirement: Runtime Language Switching
The system SHALL allow users to switch languages at runtime without restarting the app.

#### Scenario: Switch to Hebrew
- **WHEN** user selects Hebrew from settings
- **THEN** UI immediately updates to Hebrew
- **AND** layout direction changes to RTL

#### Scenario: Switch to English
- **WHEN** user selects English from settings
- **THEN** UI immediately updates to English
- **AND** layout direction changes to LTR

### Requirement: Language Preference Persistence
The system SHALL persist the selected language preference locally.

#### Scenario: Remember language choice
- **WHEN** user closes and reopens the app
- **THEN** the previously selected language is applied

### Requirement: Hebrew RTL Layout
The system SHALL render all UI elements right-to-left when Hebrew is selected.

#### Scenario: RTL text alignment
- **WHEN** Hebrew is active
- **THEN** text is right-aligned
- **AND** reading direction is RTL

#### Scenario: RTL navigation
- **WHEN** Hebrew is active
- **THEN** back buttons appear on the right
- **AND** navigation gestures are mirrored

### Requirement: English LTR Layout
The system SHALL render all UI elements left-to-right when English is selected.

#### Scenario: LTR text alignment
- **WHEN** English is active
- **THEN** text is left-aligned
- **AND** reading direction is LTR

### Requirement: Localized Dates
The system SHALL format dates according to the selected locale.

#### Scenario: English date format
- **WHEN** English is active
- **THEN** dates display as "Feb 8, 2026" or similar

#### Scenario: Hebrew date format
- **WHEN** Hebrew is active
- **THEN** dates display in Hebrew locale format

### Requirement: Localized Numbers
The system SHALL format numbers according to the selected locale.

#### Scenario: Number formatting
- **WHEN** displaying blood pressure values
- **THEN** numbers use locale-appropriate formatting

### Requirement: No Hardcoded UI Strings
The system SHALL externalize all user-visible strings to localization files.

#### Scenario: All strings localized
- **WHEN** any UI screen is displayed
- **THEN** all visible text comes from localization files
- **AND** no hardcoded English strings are displayed in Hebrew mode

### Requirement: Localized AI Responses
The system SHALL request AI responses in the currently selected UI language.

#### Scenario: Hebrew AI response
- **WHEN** Hebrew is selected and AI insight is requested
- **THEN** ui_locale="he" is sent to backend
- **AND** AI responds in Hebrew

### Requirement: Onboarding Language Selection
The system SHALL prompt for language selection during onboarding.

#### Scenario: Initial language choice
- **WHEN** user opens app for first time
- **THEN** language selection is the first onboarding step
