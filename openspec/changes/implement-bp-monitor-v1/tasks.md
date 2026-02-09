# Tasks: Blood Pressure Monitoring Application v1.0

## 1. Project Setup & Infrastructure

- [x] 1.1 Update `pubspec.yaml` with required dependencies (firebase_core, firebase_auth, drift, sqlcipher_flutter_libs, riverpod, go_router, intl, pdf, csv, flutter_secure_storage, dio, connectivity_plus)
- [x] 1.2 Create Flutter project directory structure per architecture spec
- [x] 1.3 Configure analysis_options.yaml with strict linting rules
- [x] 1.4 Set up l10n.yaml for localization generation
- [x] 1.5 Configure Firebase project (iOS and Android)
- [x] 1.6 Create backend directory structure with FastAPI skeleton
- [x] 1.7 Configure backend requirements.txt/pyproject.toml (fastapi, uvicorn, pydantic, openai, firebase-admin, slowapi)

## 2. Core Layer (Flutter)

- [x] 2.1 Define app constants (BP thresholds, pulse thresholds, risk codes, context tags)
- [x] 2.2 Create base error types and failure handling
- [x] 2.3 Implement logging utility
- [x] 2.4 Create common widgets (loading, error, empty states)
- [x] 2.5 Implement network connectivity service (using connectivity_plus)

## 3. Firebase Authentication (Flutter)

- [x] 3.1 Initialize Firebase in app bootstrap
- [x] 3.2 Create AuthService wrapper for Firebase Auth
- [x] 3.3 Implement sign up with email/password
- [x] 3.4 Implement login with email/password
- [x] 3.5 Implement password reset flow
- [x] 3.6 Implement logout functionality
- [x] 3.7 Create AuthStateProvider with Riverpod
- [x] 3.8 Write unit tests for auth flows

## 4. Data Layer - Database (Flutter)

- [x] 4.1 Define Drift database schema (users, patients, risk_factors, medications, readings tables)
- [x] 4.2 Create DAOs for each table with CRUD operations
- [x] 4.3 Implement database encryption setup with SQLCipher (key in device keychain)
- [x] 4.4 Create database migrations strategy
- [x] 4.5 Write unit tests for DAOs

## 5. Domain Layer - Entities & Enums (Flutter)

- [ ] 5.1 Create User entity
- [ ] 5.2 Create Patient entity with validation
- [ ] 5.3 Create RiskFactor entity and RiskCode enum
- [ ] 5.4 Create Medication entity
- [ ] 5.5 Create Reading entity with BP classification method
- [ ] 5.6 Create BPCategory enum (Normal, HighNormal, Grade1, Grade2, Grade3, Crisis)
- [ ] 5.7 Create PulseStatus enum (Normal, Low, High)

## 6. Domain Layer - Services (Flutter)

- [ ] 6.1 Implement AnalyticsService (7d/30d averages, std dev, trends, threshold percentages, min 3 readings check)
- [ ] 6.2 Implement SafetyService (BP red flags: SYS≥180 or DIA≥120; Pulse warnings: <50 or >100 bpm)
- [ ] 6.3 Implement ExportService (PDF and CSV generation)
- [ ] 6.4 Write unit tests for analytics calculations
- [ ] 6.5 Write unit tests for safety detection (including pulse)

## 7. Data Layer - Repositories (Flutter)

- [ ] 7.1 Define repository interfaces in domain layer
- [ ] 7.2 Implement UserRepository (local cache of Firebase user)
- [ ] 7.3 Implement PatientRepository (CRUD for single patient per user)
- [ ] 7.4 Implement RiskFactorRepository (get/set per patient)
- [ ] 7.5 Implement MedicationRepository (CRUD, active/inactive filter)
- [ ] 7.6 Implement ReadingRepository (CRUD, date range queries, quality filter, backdating support)
- [ ] 7.7 Implement AIRepository (remote API calls with Firebase token)
- [ ] 7.8 Create mappers between database models and domain entities

## 8. Internationalization (Flutter)

- [ ] 8.1 Create ARB files for English (en) locale
- [ ] 8.2 Create ARB files for Hebrew (he) locale
- [ ] 8.3 Implement LocaleProvider with runtime switching
- [ ] 8.4 Configure MaterialApp with localization delegates
- [ ] 8.5 Verify RTL layout for Hebrew
- [ ] 8.6 Localize date and number formatting

## 9. Presentation Layer - Routing & Theme (Flutter)

- [ ] 9.1 Configure GoRouter with auth-aware routes (login, onboarding, main app)
- [ ] 9.2 Create app theme (light mode, colors for BP categories, pulse warning colors)
- [ ] 9.3 Create responsive layout utilities

## 10. Presentation Layer - Auth Screens (Flutter)

- [ ] 10.1 Create login screen (email/password)
- [ ] 10.2 Create sign up screen (email/password with validation)
- [ ] 10.3 Create password reset screen
- [ ] 10.4 Implement auth state navigation (redirect based on auth/onboarding status)

## 11. Presentation Layer - Onboarding (Flutter)

- [ ] 11.1 Create language selection screen (first step)
- [ ] 11.2 Create patient profile creation screen (name required, demographics optional)
- [ ] 11.3 Create risk factors disclosure screen (checklist by category)
- [ ] 11.4 Create medications entry screen (optional, can skip)
- [ ] 11.5 Implement onboarding flow state management
- [ ] 11.6 Track onboarding completion status

## 12. Presentation Layer - Home (Flutter)

- [ ] 12.1 Create home screen (single patient, no switcher)
- [ ] 12.2 Display latest reading with classification badge
- [ ] 12.3 Show 7-day summary metrics (or "add more readings" if <3)
- [ ] 12.4 Add quick action buttons (new reading, view history, AI insights - hide AI if offline)

## 13. Presentation Layer - Readings (Flutter)

- [ ] 13.1 Create reading entry form (systolic, diastolic, pulse, taken_at with backdating, context tags, quality, notes)
- [ ] 13.2 Implement form validation (valid BP ranges, pulse range)
- [ ] 13.3 Create reading history list with filtering
- [ ] 13.4 Create reading detail view with edit/delete
- [ ] 13.5 Integrate safety warning screen for BP red flag readings
- [ ] 13.6 Integrate pulse warning display (non-blocking)

## 14. Presentation Layer - Analytics (Flutter)

- [ ] 14.1 Create analytics dashboard screen
- [ ] 14.2 Show "Add more readings" message if <3 readings
- [ ] 14.3 Implement BP trend chart (line graph)
- [ ] 14.4 Display computed metrics (averages, std dev, threshold percentages)
- [ ] 14.5 Add date range selector
- [ ] 14.6 Show morning vs evening comparison

## 15. Presentation Layer - Profile (Flutter)

- [ ] 15.1 Create patient profile view/edit screen
- [ ] 15.2 Create risk factors management screen (checklist with notes)
- [ ] 15.3 Create medications list screen
- [ ] 15.4 Create medication add/edit form

## 16. Presentation Layer - AI Insights (Flutter)

- [ ] 16.1 Hide AI section/button when offline (using connectivity service)
- [ ] 16.2 Create AI insights request screen with optional user question
- [ ] 16.3 Implement AI consent flow (first-time use)
- [ ] 16.4 Display AI response with structured sections
- [ ] 16.5 Handle loading and error states
- [ ] 16.6 Block AI access when BP safety flags are active

## 17. Presentation Layer - Export (Flutter)

- [ ] 17.1 Create export options screen (PDF/CSV selection, date range)
- [ ] 17.2 Implement PDF report generation with graphs
- [ ] 17.3 Implement CSV export
- [ ] 17.4 Integrate with device share sheet

## 18. Presentation Layer - Settings (Flutter)

- [ ] 18.1 Create settings screen (language toggle, logout, about, export all data)
- [ ] 18.2 Implement language switching with app restart if needed
- [ ] 18.3 Implement logout with confirmation

## 19. Backend - Core Setup (FastAPI)

- [ ] 19.1 Create FastAPI app with CORS, request ID middleware
- [ ] 19.2 Configure settings/environment loading (OpenAI key, Firebase project)
- [ ] 19.3 Set up structured logging (no PII)
- [ ] 19.4 Implement rate limiting middleware

## 20. Backend - Authentication (FastAPI)

- [ ] 20.1 Initialize Firebase Admin SDK
- [ ] 20.2 Create Firebase token verification middleware
- [ ] 20.3 Extract user ID from verified token

## 21. Backend - Endpoints (FastAPI)

- [ ] 21.1 Implement GET /health endpoint
- [ ] 21.2 Implement GET /meta/supported-locales endpoint
- [ ] 21.3 Implement POST /v1/ai/analyze endpoint with request validation
- [ ] 21.4 Apply authentication to /v1/ai/analyze

## 22. Backend - AI Service (FastAPI)

- [ ] 22.1 Create OpenAI client wrapper (GPT-4o-mini)
- [ ] 22.2 Implement prompt builder with safety guardrails
- [ ] 22.3 Implement response parser with content filtering
- [ ] 22.4 Add safety override logic (block AI for BP red flag cases)
- [ ] 22.5 Implement localized disclaimers (en/he)

## 23. Backend - Testing

- [ ] 23.1 Write unit tests for prompt builder
- [ ] 23.2 Write unit tests for safety rules
- [ ] 23.3 Write integration tests for /v1/ai/analyze endpoint
- [ ] 23.4 Add test fixtures with sample payloads

## 24. Integration & Polish

- [ ] 24.1 End-to-end test: sign up → onboarding → reading entry → analytics → AI insight
- [ ] 24.2 Test Hebrew RTL layout across all screens
- [ ] 24.3 Test offline behavior (AI hidden, local features work)
- [ ] 24.4 Performance testing (reading entry <100ms, graph <300ms)
- [ ] 24.5 Update README with setup and run instructions

## Dependencies

- Task 2.x depends on 1.x (project setup)
- Task 3.x depends on 1.x (Firebase config)
- Task 4.x depends on 2.x (core layer)
- Task 5.x depends on 2.x (core layer)
- Task 6.x depends on 5.x (entities)
- Task 7.x depends on 3.x (auth), 4.x (database), and 5.x (entities)
- Task 8.x can run in parallel with 3-7
- Task 9.x depends on 3.x (auth) and 8.x (i18n)
- Task 10.x depends on 3.x (auth) and 9.x (routing)
- Task 11.x depends on 7.x (repositories) and 10.x (auth screens)
- Tasks 12-18 depend on 7.x (repositories), 8.x (i18n), and 11.x (onboarding)
- Tasks 19-23 can run in parallel with Flutter tasks after 1.x
- Task 24 depends on all previous tasks

## Parallelization Opportunities

The following can be worked on concurrently:
- Firebase Auth (3) and Database setup (4)
- Flutter data layer (4, 5, 6, 7) and Flutter i18n (8)
- Flutter frontend (10-18) and Backend (19-23)
- Backend endpoints (21) and Backend AI service (22)
