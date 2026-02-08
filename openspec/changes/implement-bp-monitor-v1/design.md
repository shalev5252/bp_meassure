# Design: Blood Pressure Monitoring Application v1.0

## Context

This is a greenfield mobile health application targeting users who need to monitor blood pressure readings. The application must be privacy-first (local data storage), support bilingual users (English/Hebrew), and provide AI-assisted insights while strictly avoiding medical diagnosis or treatment advice.

### Stakeholders
- End users (patients self-monitoring)
- Healthcare providers (receiving exported reports)
- Regulatory considerations (not a medical device, no diagnosis)

### Constraints
- Must comply with Israel hypertension classification (≥140/90 mmHg)
- AI cannot provide diagnosis, medication adjustments, or emergency protocols
- No persistent server-side storage of patient data in MVP
- RTL layout required for Hebrew

## Goals / Non-Goals

### Goals
- Privacy-first local data storage with encryption
- Clean architecture with clear separation of concerns
- Stateless backend for AI processing only
- Full i18n support with runtime language switching
- Safety-first design with red flag detection

### Non-Goals
- Cloud synchronization (Phase 2)
- Bluetooth device integration (Phase 2)
- Medical device certification
- Real-time physician communication

## Architecture Decisions

### Decision 1: Flutter for Mobile
**Choice**: Flutter with Dart
**Rationale**:
- Cross-platform (iOS/Android) from single codebase
- Excellent RTL support built-in
- Strong typing and null safety
- Active ecosystem for health apps

### Decision 2: Clean Architecture Pattern
**Choice**: Domain-driven layers (presentation → domain → data)
**Rationale**:
- Clear separation enables testability
- Domain logic isolated from framework
- Easier to swap data sources (local → cloud in Phase 2)

**Structure**:
```
lib/
  core/           # Shared utilities, constants, errors
  data/           # Repositories, DAOs, mappers
  domain/         # Entities, use cases, services
  presentation/   # Screens, state, routing, theme
  infra/          # HTTP, secure storage, preferences
  l10n/           # Localization files
```

### Decision 3: SQLite with Drift (Moor)
**Choice**: Drift ORM for local database
**Rationale**:
- Type-safe database queries
- Migration support built-in
- Encryption via SQLCipher integration
- Reactive streams for UI updates

### Decision 4: Riverpod for State Management
**Choice**: Riverpod (not Provider)
**Rationale**:
- Compile-time safety
- Testable without widget tree
- Supports async state
- No BuildContext dependency

### Decision 5: Firebase Authentication
**Choice**: Firebase Auth for user accounts
**Rationale**:
- Industry-standard auth with email/password
- Easy integration with Flutter (`firebase_auth` package)
- Prepares for Phase 2 cloud sync (Firebase ecosystem)
- Handles password reset, email verification
- Free tier sufficient for MVP

**Flow**:
```
First Launch → Language Selection → Sign Up/Login → Onboarding → App
Return Visit → Auto-login (cached credentials) → App
```

### Decision 6: FastAPI Backend
**Choice**: Python FastAPI for AI gateway
**Rationale**:
- Async-first design
- Automatic OpenAPI documentation
- Pydantic validation
- Easy OpenAI SDK integration

### Decision 7: GPT-4o-mini for AI
**Choice**: OpenAI GPT-4o-mini
**Rationale**:
- Latest model with lowest cost ($0.15/1M input, $0.60/1M output)
- Sufficient quality for structured health insights
- Fast response times (<3s typical)
- Easy upgrade path to GPT-4o if needed

### Decision 8: Device Keychain for Encryption Key
**Choice**: iOS Keychain / Android Keystore for SQLCipher key
**Rationale**:
- Hardware-backed security
- Seamless UX (no password to remember)
- Industry standard for local-first apps
- Phase 2 cloud sync will provide cross-device recovery

**Implementation**:
- Generate random 256-bit key on first launch
- Store in `flutter_secure_storage` (wraps native keychain)
- Key never leaves device

### Decision 9: Safety-First AI Design
**Choice**: Safety engine runs BEFORE AI processing
**Rationale**:
- Blood pressure red flags (SYS ≥180 OR DIA ≥120) must block AI responses
- Pulse warnings (<50 bpm OR >100 bpm) trigger alerts
- Prevents AI from commenting on emergency situations
- Clear medical consultation message shown instead

**Flow**:
```
Reading Entry → Safety Check → If RED FLAG (BP):
  → Show safety warning
  → Block AI for session
  → Advise medical consultation

Reading Entry → Safety Check → If PULSE WARNING:
  → Show pulse warning
  → AI still allowed
  → Suggest discussing with doctor
```

**Thresholds**:
- BP Red Flag: SYS ≥180 OR DIA ≥120 → Blocks AI
- Pulse Warning: <50 bpm OR >100 bpm → Warning only

### Decision 10: Offline AI Behavior
**Choice**: Hide AI feature when offline
**Rationale**:
- Cleaner UX than showing error messages
- Analytics remain fully functional offline
- Clear visual indicator that AI requires connectivity

### Decision 11: Localization Strategy
**Choice**: ARB files with `flutter_localizations`
**Rationale**:
- Flutter's native i18n approach
- Supports plurals, dates, numbers
- IDE tooling support
- Easy to add languages later

**RTL Handling**:
- `Directionality` widget wraps app
- `textDirection` set per locale
- All layouts use `start`/`end` instead of `left`/`right`

### Decision 12: Minimum Readings for Analytics
**Choice**: Require 3 valid readings before showing analytics
**Rationale**:
- Statistical minimum for meaningful averages
- Prevents misleading single-reading "trends"
- Show "Add more readings" prompt instead of empty charts

### Decision 13: Reading Timestamps
**Choice**: Allow backdating with device local timezone
**Rationale**:
- Users may forget to log readings immediately
- Store as UTC internally, display in local timezone
- `taken_at` is user-editable, `created_at` is system-set

### Decision 14: Context Tags
**Choice**: Fixed predefined list (no custom tags)
**Rationale**:
- Consistent data for analytics and AI
- Simpler UI
- Tags: morning, evening, after_rest, after_exercise, after_meal, stressed, at_doctor

## Data Model

### Users Table (Firebase-managed, local cache)
```sql
CREATE TABLE users (
  user_id TEXT PRIMARY KEY,  -- Firebase UID
  email TEXT NOT NULL,
  created_at TEXT NOT NULL,
  last_login_at TEXT NOT NULL
);
```

### Patients Table
```sql
CREATE TABLE patients (
  patient_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,  -- FK to users (Firebase UID)
  display_name TEXT NOT NULL,
  date_of_birth TEXT,
  sex TEXT CHECK(sex IN ('male', 'female', 'other', 'unspecified')),
  height_cm REAL,
  weight_kg REAL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

### Risk Factors Table
```sql
CREATE TABLE patient_risk_factors (
  patient_id TEXT NOT NULL,
  risk_code TEXT NOT NULL,
  is_present INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  updated_at TEXT NOT NULL,
  PRIMARY KEY (patient_id, risk_code),
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);
```

### Medications Table
```sql
CREATE TABLE patient_medications (
  medication_id TEXT PRIMARY KEY,
  patient_id TEXT NOT NULL,
  name TEXT NOT NULL,
  dose_text TEXT,
  frequency_text TEXT,
  is_active INTEGER NOT NULL DEFAULT 1,
  started_on TEXT,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);
```

### Readings Table
```sql
CREATE TABLE readings (
  reading_id TEXT PRIMARY KEY,
  patient_id TEXT NOT NULL,
  systolic INTEGER NOT NULL,
  diastolic INTEGER NOT NULL,
  pulse INTEGER,
  taken_at TEXT NOT NULL,
  context_tags TEXT, -- JSON array
  measurement_quality TEXT CHECK(quality IN ('valid', 'invalid', 'unsure')),
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);
```

## API Design

### AI Analyze Request
```json
POST /v1/ai/analyze
{
  "patient": {
    "display_name": "...",
    "sex": "...",
    "age_years": 45
  },
  "risk_factors": {
    "diabetes_type2": true,
    "smoker_current": false
  },
  "medications": [...],
  "readings": [...],
  "computed_metrics": {
    "avg_7d_systolic": 135,
    "avg_7d_diastolic": 88,
    "trend_slope": 0.5,
    "pct_above_140_90": 25
  },
  "safety_flags": {
    "has_red_flag": false,
    "highest_systolic": 155,
    "highest_diastolic": 95
  },
  "ui_locale": "en",
  "user_question": "Why are my evening readings higher?"
}
```

### AI Analyze Response
```json
{
  "summary": "...",
  "pattern_analysis": "...",
  "contributing_factors": "...",
  "lifestyle_guidance": "...",
  "consult_recommendation": "...",
  "doctor_questions": ["..."],
  "disclaimer": "This is not medical advice...",
  "safety_override_applied": false,
  "request_id": "uuid"
}
```

## Risks / Trade-offs

### Risk: AI Providing Medical Advice
**Mitigation**:
- Strict prompt engineering with prohibitions
- Response parsing to filter diagnostic language
- Safety engine override blocks AI entirely for red flags
- Mandatory disclaimer in every response

### Risk: Data Loss
**Mitigation**:
- SQLCipher encryption at rest
- Regular backup prompts to user
- Export functionality for data portability

### Risk: RTL Layout Bugs
**Mitigation**:
- Use semantic layout properties (`start`/`end`)
- Test extensively in Hebrew mode
- Separate locale-specific visual tests

### Trade-off: Local-Only Storage (MVP)
**Accepted**: No cloud sync means no multi-device access
**Future**: Phase 2 will add optional cloud sync

### Trade-off: No Bluetooth Integration (MVP)
**Accepted**: Manual entry only
**Future**: Phase 2 will add device pairing

## Dependencies

### Flutter Packages (Recommended)
- `firebase_core` + `firebase_auth` - Authentication
- `drift` + `drift_flutter` + `sqlcipher_flutter_libs` - Encrypted database
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `flutter_localizations` - i18n
- `intl` - Date/number formatting
- `pdf` - PDF generation
- `csv` - CSV export
- `flutter_secure_storage` - Encryption key storage
- `dio` - API client
- `connectivity_plus` - Network status detection

### Backend Packages (Python)
- `fastapi` - Web framework
- `uvicorn` - ASGI server
- `pydantic` - Validation
- `openai` - LLM client (GPT-4o-mini)
- `firebase-admin` - Token verification
- `slowapi` - Rate limiting

## Migration Plan

Not applicable - greenfield project.

## Resolved Questions

| Question | Decision |
|----------|----------|
| Onboarding flow | Required: Language → Account → Profile → Risk Factors → Medications |
| Multi-patient support | No for MVP; Phase 2 with cloud accounts |
| Offline AI behavior | Hide AI feature entirely |
| Encryption key | Device keychain (auto-generated) |
| Backdating readings | Allowed, local timezone |
| Custom context tags | No, fixed predefined list |
| Min readings for analytics | 3 |
| Pulse alerts | Yes, <50 or >100 bpm |
| AI model | GPT-4o-mini |
| Auth provider | Firebase Auth |
| Reading reminders | Defer to Phase 2 |
