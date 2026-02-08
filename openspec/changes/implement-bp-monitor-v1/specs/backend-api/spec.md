# Capability: Backend API

## ADDED Requirements

### Requirement: Health Endpoint
The backend SHALL provide GET /health returning status and version.

#### Scenario: Health check
- **WHEN** GET /health is called
- **THEN** response is {"status": "ok", "version": "2.0.0"}
- **AND** status code is 200

### Requirement: Supported Locales Endpoint
The backend SHALL provide GET /meta/supported-locales returning available languages.

#### Scenario: Get supported locales
- **WHEN** GET /meta/supported-locales is called
- **THEN** response is {"supported_locales": ["en", "he"]}
- **AND** status code is 200

### Requirement: AI Analyze Endpoint
The backend SHALL provide POST /v1/ai/analyze accepting patient context and returning structured AI insights.

#### Scenario: Successful AI analysis
- **WHEN** valid request is sent with patient, readings, and metrics
- **THEN** response includes summary, pattern_analysis, contributing_factors, lifestyle_guidance, consult_recommendation, doctor_questions, disclaimer
- **AND** request_id is included
- **AND** status code is 200

#### Scenario: Request validation
- **WHEN** request is missing required fields
- **THEN** status code is 422
- **AND** validation errors are returned

### Requirement: Authentication
The backend SHALL require Bearer token authentication for /v1/ai/analyze.

#### Scenario: Missing auth token
- **WHEN** request lacks Authorization header
- **THEN** status code is 401

#### Scenario: Invalid auth token
- **WHEN** request has invalid Bearer token
- **THEN** status code is 401

### Requirement: Rate Limiting
The backend SHALL enforce rate limiting on /v1/ai/analyze endpoint.

#### Scenario: Rate limit exceeded
- **WHEN** client exceeds rate limit
- **THEN** status code is 429
- **AND** Retry-After header is included

### Requirement: CORS Configuration
The backend SHALL configure CORS to allow requests from mobile app origins.

#### Scenario: CORS preflight
- **WHEN** OPTIONS request is sent
- **THEN** appropriate CORS headers are returned

### Requirement: Request ID Tracking
The backend SHALL generate and return a unique request_id for each /v1/ai/analyze request.

#### Scenario: Request tracking
- **WHEN** AI analyze request is processed
- **THEN** response includes request_id field
- **AND** request_id is logged (without PII)

### Requirement: No PII Logging
The backend SHALL NOT log raw personally identifiable information in logs.

#### Scenario: Redacted logging
- **WHEN** request is logged
- **THEN** patient names and notes are redacted or omitted
- **AND** only non-PII metrics are logged

### Requirement: HTTPS Enforcement
The backend SHALL require HTTPS for all endpoints in production.

#### Scenario: HTTP rejection
- **WHEN** HTTP request is made in production
- **THEN** request is rejected or redirected to HTTPS

### Requirement: Safety Override Response
The backend SHALL return a safety override response when has_red_flag is true.

#### Scenario: Red flag override
- **WHEN** request includes safety_flags.has_red_flag=true
- **THEN** response includes safety_override_applied=true
- **AND** only disclaimer and consult_recommendation are populated
- **AND** no AI-generated analysis is included

### Requirement: Localized Disclaimers
The backend SHALL return disclaimers in the language specified by ui_locale.

#### Scenario: Hebrew disclaimer
- **WHEN** ui_locale="he"
- **THEN** disclaimer text is in Hebrew

#### Scenario: English disclaimer
- **WHEN** ui_locale="en"
- **THEN** disclaimer text is in English

### Requirement: AI Response Timeout
The backend SHALL timeout AI requests after 10 seconds and return an error.

#### Scenario: AI timeout
- **WHEN** AI provider takes longer than 10 seconds
- **THEN** status code is 504
- **AND** error message indicates timeout
