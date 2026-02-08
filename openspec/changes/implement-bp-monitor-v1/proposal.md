# Change: Implement Blood Pressure Monitoring Application v1.0

## Why

Users need a privacy-first, local-first mobile application to track blood pressure readings, manage patient profiles with risk factors, view analytics and trends, and receive AI-assisted contextual insights. The application must support English (LTR) and Hebrew (RTL) languages and follow the Israel-aligned hypertension classification standard (≥140/90 mmHg threshold).

This is a greenfield implementation replacing the default Flutter boilerplate with a fully-featured health monitoring application.

## What Changes

### Flutter Mobile Application
- **User Authentication**: Firebase Auth integration (email/password signup/login)
- **Onboarding Flow**: Language → Account creation → Patient profile → Risk factors → Medications → Ready
- **Patient Management**: Create and manage single patient profile with demographics (multi-patient in Phase 2)
- **Risk Factors**: Track chronic, lifestyle, and family medical risk factors (required review during onboarding)
- **Medications**: Manage active and historical medications (no dosage advice)
- **BP Readings**: Manual entry with context tags, quality marking, notes, and backdating support
- **Analytics Engine**: 7/30-day averages, standard deviation, trends, threshold percentages (min 3 readings required)
- **Safety Engine**: Red flag detection (BP: SYS ≥180 or DIA ≥120; Pulse: <50 or >100 bpm) with warning screens
- **AI Insights**: Non-diagnostic contextual analysis with strict medical guardrails (hidden when offline)
- **i18n**: English/Hebrew with runtime switching and RTL support
- **Export**: PDF and CSV report generation

### FastAPI Backend
- **Health Endpoint**: Service status and version
- **Meta Endpoint**: Supported locales
- **AI Analyze Endpoint**: Stateless AI processing with safety overrides (GPT-4o-mini)

### Data Layer
- Local encrypted SQLite database with tables for patients, risk_factors, medications, readings
- Encryption key stored in device keychain (iOS Keychain / Android Keystore)
- Repository pattern with clean architecture separation

### Security & Privacy
- Firebase Auth for user accounts
- No server-side persistence of patient data (MVP)
- No raw PII logging
- Rate limiting and HTTPS enforcement
- AI consent requirement

## Impact

- **Affected specs**: All new capabilities (11 spec files including user-auth)
- **Affected code**: Complete rewrite of `lib/` directory structure, new `backend/` directory
- **Breaking changes**: None (greenfield project)

## Non-Goals (Phase 2)

- Cloud sync (user data to Firebase/cloud database)
- Multi-patient per device (enabled via cloud accounts)
- Caregiver accounts
- Bluetooth device integration
- Physician report (FHIR format)
- AI citation references

## Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Auth Provider | Firebase Auth | Reliable, scales to Phase 2 cloud sync |
| Encryption Key | Device Keychain | Seamless UX, hardware-backed security |
| AI Model | GPT-4o-mini | Latest, cheapest, sufficient quality |
| Offline AI | Hidden | Cleaner UX than error messages |
| Min Analytics | 3 readings | Statistical minimum for meaningful averages |
| Context Tags | Fixed list | Simplicity, consistent data |
| Backdating | Allowed | Users may forget to log readings |
| Pulse Alerts | Yes | <50 or >100 bpm triggers warning |

## Clinical Standard Reference

| Category | Systolic (SYS) | Diastolic (DIA) |
|----------|----------------|-----------------|
| Normal | ≤130 | ≤85 |
| High-Normal / Borderline | 130–139 | 85–89 |
| Hypertension Grade 1 | 140–159 | 90–99 |
| Hypertension Grade 2 | 160–179 | 100–109 |
| Hypertension Grade 3 | ≥180 | ≥110 |
| Severe / Crisis | ≥180 and/or ≥120 | |

## Performance Targets

- Reading entry: <100ms
- Graph render: <300ms
- AI response: <6s
- App cold start: <2s
