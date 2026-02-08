# Capability: AI Insights

## ADDED Requirements

### Requirement: AI Analysis Request
The system SHALL send structured analysis requests to the AI backend including patient demographics, risk factors, medications, readings, computed metrics, safety flags, UI locale, and optional user question.

#### Scenario: Send AI analysis request
- **WHEN** user requests AI insights
- **THEN** a POST request is sent to /v1/ai/analyze
- **AND** request includes all required context fields

#### Scenario: Include user question
- **WHEN** user enters "Why are my evening readings higher?"
- **THEN** user_question field is included in the request

### Requirement: AI Response Display
The system SHALL display AI responses in structured sections: summary, pattern_analysis, contributing_factors, lifestyle_guidance, consult_recommendation, and doctor_questions.

#### Scenario: Display AI response
- **WHEN** AI response is received
- **THEN** each section is displayed with appropriate heading
- **AND** doctor_questions are displayed as a bulleted list

### Requirement: Mandatory Disclaimer
The system SHALL display a disclaimer with every AI response stating that the content is not medical advice.

#### Scenario: Show disclaimer
- **WHEN** AI response is displayed
- **THEN** disclaimer text is prominently shown
- **AND** disclaimer is localized to the current UI language

### Requirement: AI Consent Flow
The system SHALL require user consent before first AI analysis, explaining that data will be sent to external AI service.

#### Scenario: First-time AI use
- **WHEN** user attempts AI analysis for the first time
- **THEN** consent dialog is displayed
- **AND** user must accept before proceeding

#### Scenario: Consent persisted
- **WHEN** user has previously consented
- **THEN** consent dialog is not shown again

### Requirement: No Diagnosis
The AI system SHALL NOT provide diagnoses or definitive clinical statements.

#### Scenario: AI avoids diagnosis
- **WHEN** AI generates a response
- **THEN** response uses hedging language ("may indicate", "consider discussing")
- **AND** response does NOT state "you have hypertension" or similar

### Requirement: No Medication Advice
The AI system SHALL NOT provide medication adjustments, dosage recommendations, or suggest new medications.

#### Scenario: AI avoids medication advice
- **WHEN** patient has medications in profile
- **THEN** AI may acknowledge medications exist
- **BUT** AI does NOT suggest changes, dosage adjustments, or new medications

### Requirement: No Emergency Protocols
The AI system SHALL NOT provide emergency protocols or immediate treatment instructions.

#### Scenario: AI avoids emergency instructions
- **WHEN** readings approach dangerous levels (but below red flag)
- **THEN** AI may recommend consulting a doctor
- **BUT** AI does NOT provide emergency action steps

### Requirement: Localized AI Responses
The AI system SHALL respond in the language specified by ui_locale (en or he).

#### Scenario: Hebrew response
- **WHEN** ui_locale is "he"
- **THEN** AI response is in Hebrew
- **AND** disclaimer is in Hebrew

### Requirement: AI Loading State
The system SHALL display a loading indicator during AI processing with expected wait time (up to 6 seconds).

#### Scenario: Show loading state
- **WHEN** AI request is in progress
- **THEN** loading indicator is displayed
- **AND** user can cancel the request

### Requirement: AI Offline Behavior
The system SHALL hide the AI insights feature when the device is offline.

#### Scenario: Hide AI when offline
- **WHEN** device has no network connection
- **THEN** AI insights button/section is hidden from the UI
- **AND** no error message is shown (clean hiding)

#### Scenario: Show AI when online
- **WHEN** device regains network connection
- **THEN** AI insights button/section becomes visible again

### Requirement: AI Error Handling
The system SHALL display appropriate error messages when AI service fails during a request.

#### Scenario: Handle timeout
- **WHEN** AI request exceeds 6 seconds
- **THEN** error message is displayed
- **AND** user can retry

#### Scenario: Handle server error
- **WHEN** AI backend returns an error
- **THEN** user-friendly error message is displayed
- **AND** user can retry
