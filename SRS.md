# Software Requirements Specification
## VIBYUK — B2B Creator & Event Booking Platform
**Version:** 1.0.0  
**Date:** May 2026  
**Platform:** Flutter (Android + iOS)  
**Package:** `com.vibyuk.app`

---

## 1. Introduction

### 1.1 Purpose
VIBYUK is a B2B marketplace that connects creators (DJs, photographers, musicians, performers, influencers) with businesses (event planners, venues, hospitality brands, tourism boards) for bookings, events, and collaborative campaigns. This document specifies all functional and non-functional requirements for the 1.0.0 release.

### 1.2 Scope
The mobile application covers:
- Dual-role user onboarding (Creator / Business)
- Creator discovery and booking
- Full booking lifecycle with contract, negotiation, milestones, and escrow
- Real-time chat (Socket.IO)
- Event creation, ticketing, and QR scanning
- Wedding planning marketplace
- Tourism campaign collaboration
- AI-powered recommendations, campaign planner, and pricing engine
- Admin moderation portal
- Firebase push notifications
- Analytics and reporting

### 1.3 Definitions

| Term | Meaning |
|---|---|
| Creator | A talent/professional offering services (DJ, photographer, etc.) |
| Business | A company or individual hiring creators |
| Booking | A confirmed service agreement between Creator and Business |
| Escrow | Funds held in trust until booking milestones are completed |
| FAM Trip | Familiarisation trip offered by tourism boards to creators |
| KYC | Know Your Customer — identity verification |

---

## 2. System Architecture

### 2.1 Architectural Pattern
**Clean Architecture** with three strict layers:

```
Presentation  →  Domain  →  Data
(BLoC/Cubit)     (UseCases, Entities, Repository interfaces)
                            (Repository implementations, DTOs, DataSources)
```

- Presentation layer depends only on Domain
- Domain has zero dependencies on Flutter or external packages
- Data layer implements Domain repository interfaces

### 2.2 State Management
- **BLoC / Cubit** (`flutter_bloc ^8.1.3`)
- All BLoCs extend `BaseBloc<Event, State>` with automatic logging
- All Cubits extend `BaseCubit<State>`
- Error handling via `Either<Failure, T>` (dartz)

### 2.3 Navigation
- **GoRouter ^13.2.0** — URL-based routing
- `AuthGuard` redirects unauthenticated users to `/auth/login`
- `AnalyticsRouteObserver` logs every screen transition to Firebase Analytics
- Deep links: `vibyuk://` and `https://vibyuk.com` (Universal Links / App Links)

### 2.4 Dependency Injection
- **GetIt + injectable** — all services registered as `LazySingleton`; BLoCs as `Factory`
- Module registration order: core → cache → api → services → features

### 2.5 API Communication
- **Dio ^5.4.0** with a 6-interceptor chain:
  1. ConnectivityInterceptor — fails fast with no connection
  2. AuthInterceptor — injects Bearer token, handles 401 refresh
  3. CacheInterceptor — serves GET responses from Hive cache
  4. ErrorInterceptor — maps HTTP errors to typed `AppException`
  5. RetryInterceptor — exponential backoff with full jitter (3 retries, 429/5xx/connection)
  6. LoggingInterceptor — disabled in production

### 2.6 Flavors / Environments

| Flavor | Package suffix | API Base URL | Analytics | Crashlytics |
|---|---|---|---|---|
| dev | `.dev` | `https://api-dev.vibyuk.com/v1` | Off | Off |
| staging | `.staging` | `https://api-staging.vibyuk.com/v1` | Off | On |
| production | (none) | `https://api.vibyuk.com/v1` | On | On |

---

## 3. Feature Modules

### 3.1 Authentication (`/features/auth`)

| Screen | Route | Description |
|---|---|---|
| Splash | `/splash` | Session check on cold start |
| Onboarding | `/onboarding` | First-launch walkthrough |
| Login | `/auth/login` | Email + password, Google SSO, Face ID / biometric |
| Register | `/auth/register` | Email + phone registration |
| Verify Email | `/auth/verify-email` | OTP confirmation |
| Phone OTP | `/auth/phone-otp` | SMS OTP verification |
| Forgot Password | `/auth/forgot-password` | Email-based reset |
| Reset Password | `/auth/reset-password` | Token-based new password |
| Role Selection | `/auth/role-selection` | Creator or Business selection (one-time) |

**Auth flows:**
- JWT access + refresh token pair
- Tokens stored in encrypted Keychain (iOS) / EncryptedSharedPreferences (Android)
- Biometric re-auth using `local_auth`
- Google Sign-In via `google_sign_in` package
- Token auto-refresh: `AuthInterceptor` retries once on 401 then logs out

---

### 3.2 Creator Module (`/features/creator`)

| Screen | Route |
|---|---|
| Creator Dashboard | `/creator/dashboard` |
| Creator Portfolio | `/creator/portfolio` |
| Add Portfolio Item | `/creator/portfolio/add` |
| Creator Reviews | `/creator/reviews` |
| Creator KYC | `/creator/kyc` |
| Public Profile Preview | `/creators/:id/preview` |

**Capabilities:** Manage availability calendar, portfolio media, service packages, pricing, KYC document upload, review responses.

---

### 3.3 Business Module (`/features/business`)

| Screen | Route |
|---|---|
| Discover Creators | `/discover` |
| Saved Creators | `/discover/saved` |
| Campaigns | `/campaigns` |
| Team Management | `/team` |
| Analytics Dashboard | `/analytics` |

**Capabilities:** Search and filter creators by category/location/price, save shortlists, manage team members, view campaign performance.

---

### 3.4 Booking Engine (`/features/bookings`)

Full booking lifecycle:

| Stage | Description |
|---|---|
| Initiate | Business sends booking request with brief + budget |
| Negotiation | Counter-offers, requirement adjustments |
| Contract | Digital contract generated and signed |
| Milestones | Work broken into trackable deliverable stages |
| Timeline | Visual project timeline |
| Escrow | Funds locked at confirmation, released on milestone approval |
| Invoice | GST-compliant invoice PDF generated |
| Dispute | Raise and resolve booking disputes |
| Reschedule | Request and respond to reschedule |

**Routes:** `/booking-engine/bookings/:id` + sub-routes for each stage

---

### 3.5 Chat (`/features/chat`)

- Real-time messaging via **Socket.IO** (`socket_io_client ^2.0.3`)
- Conversation list at `/messages`
- Message thread at `/messages/:id`
- File attachments (via `file_picker`)
- Voice messages (record via `record`, playback via `just_audio`)
- Read receipts, typing indicators
- Unread count badge powered by `NotificationBadgeCubit` → `WatchUnreadCountUseCase` → Drift stream

---

### 3.6 Payments (`/features/payments`)

| Screen | Route |
|---|---|
| Payment Overview | `/payments` |
| Payment Detail | `/payments/detail` |
| Transaction History | `/payments/transactions` |
| Payment Analytics | `/payments/analytics` |
| Invoice | `/payments/invoice/:bookingId` |

**Payment gateway:** Razorpay (Android: `FlutterFragmentActivity` required for bottom sheet)  
**Escrow:** Funds locked at booking confirmation, released via milestone approval or admin override  
**Invoices:** GST-compliant PDF generated server-side, downloadable via `url_launcher`

---

### 3.7 Notifications (`/features/notifications`)

- Firebase Cloud Messaging (FCM) for push delivery
- Local notifications via `flutter_local_notifications`
- In-app notification centre at `/notifications`
- Per-type preference management
- Unread count badge: live `Stream<int>` from Drift local database
- Notification types: booking updates, chat messages, payment events, admin alerts

---

### 3.8 Events (`/features/events`)

| Screen | Route |
|---|---|
| Event List | `/events` |
| Event Detail | `/events/:id` |
| Create Event | `/events/create` |
| Edit Event | `/events/:id/edit` |
| Purchase Tickets | `/events/:id/purchase` |
| Event Dashboard | `/events/:id/dashboard` |
| My Tickets | `/tickets` |
| Ticket Detail | `/tickets/:id` |
| QR Scanner | `/scanner` |

**Ticket features:** Multiple ticket types per event, QR code generation, on-site scanning via `mobile_scanner`, check-in confirmation, refund requests.

---

### 3.9 Wedding Module (`/features/wedding`)

| Screen | Route |
|---|---|
| Wedding Dashboard | `/wedding` |
| Marketplace | `/wedding/marketplace` |
| Vendor Detail | `/wedding/vendors/:id` |
| Venue Listing | `/wedding/venues` |
| Venue Detail | `/wedding/venues/:id` |
| Package Builder | `/wedding/packages/build` |
| Budget Tracker | `/wedding/budget` |
| Timeline | `/wedding/timeline` |
| Analytics | `/wedding/analytics` |

**Capabilities:** End-to-end wedding project management — vendor discovery, multi-vendor booking, package bundling, budget tracking with category breakdown, visual timeline.

---

### 3.10 Tourism Module (`/features/tourism`)

| Screen | Route |
|---|---|
| Tourism Hub | `/tourism` |
| Destinations | `/tourism/destinations` |
| Destination Detail | `/tourism/destinations/:id` |
| Destination Gallery | `/tourism/destinations/:id/gallery` |
| Campaigns | `/tourism/campaigns` |
| FAM Trips | `/tourism/fam-trips` |
| FAM Trip Detail | `/tourism/fam-trips/:id` |
| Collaborations | `/tourism/collaborations` |
| Analytics | `/tourism/analytics` |

**Capabilities:** Tourism boards post destinations and campaign briefs; creators apply for FAM trips and collaboration opportunities; engagement analytics.

---

### 3.11 AI Features (`/features/ai`)

| Feature | Route | Description |
|---|---|---|
| AI Hub | `/ai` | Feature entry point |
| Smart Match | `/ai/recommendations` | AI-powered creator recommendations for a brief |
| Campaign Planner | `/ai/campaign-planner` | Multi-step AI-generated campaign briefs |
| Pricing Engine | `/ai/pricing` | Market-rate pricing suggestions for creators |
| AI Analytics | `/ai/analytics` | AI-generated performance insights |
| AI Chat | `/ai/chat` | Conversational AI assistant |

**Backend:** Server-side LLM; Flutter side sends context and receives structured responses.

---

### 3.12 Admin Module (`/features/admin`)

| Screen | Route | Access |
|---|---|---|
| Admin Dashboard | `/admin` | Admin role only |
| User Moderation | `/admin/moderation` | Ban, warn, suspend users |
| Dispute Centre | `/admin/disputes` | Assign and resolve booking disputes |
| Verifications | `/admin/verifications` | Approve/reject KYC submissions |
| Reports | `/admin/reports` | Handle content reports |
| Analytics | `/admin/analytics` | Platform-wide metrics |

**Route guard:** Admin routes redirect non-admin users to `/home`.

---

## 4. Data Storage

| Store | Technology | What lives there |
|---|---|---|
| Encrypted keychain | `flutter_secure_storage` | JWT tokens, biometric flag, user role |
| HTTP cache | Hive `Box<String>` | GET response bodies, TTL metadata |
| Local database | Drift (SQLite) | Notifications, unread counts |
| In-memory | BLoC state | Active UI state (resets on restart) |

**Cache TTL defaults:**
- `shortCacheDuration` = 15 minutes (discovery lists, search results)
- `defaultCacheDuration` = 1 hour (creator profiles, event details)
- `longCacheDuration` = 24 hours (static reference data)

**Never cached:** `/auth/*`, `/notifications/*`, `/admin/*`

---

## 5. Security Requirements

| Requirement | Implementation |
|---|---|
| Token storage | iOS Keychain (`first_unlock_this_device`) / Android `EncryptedSharedPreferences` |
| Token versioning | Keys prefixed `v{N}_` — bump `schemaVersion` to evict old tokens on upgrade |
| Network | HTTPS enforced; cleartext disabled (`NSAllowsArbitraryLoads: false`, `android:usesCleartextTraffic: false`) |
| Auth refresh | Single retry on 401 via `AuthInterceptor`; concurrent requests queued and replayed |
| Biometric | `local_auth` with `stickyAuth: true` |
| ProGuard / R8 | Enabled on release: minify + shrinkResources; mapping files uploaded to Crashlytics |
| Obfuscation | `--obfuscate --split-debug-info` on production AAB |
| No secrets in code | All keys in `key.properties` (git-ignored) and CI secrets |

---

## 6. Non-Functional Requirements

### 6.1 Performance
- Cold start < 3 seconds (3-stage `AppStartupService`)
- Infinite scroll with `Timer` debounce — no redundant page requests
- Heavy JSON parsing offloaded to isolates via `compute_utils.dart`
- Images: `CachedNetworkImage` + `RepaintBoundary` + shimmer placeholders
- `BackgroundWorker` persistent isolate for sustained workloads

### 6.2 Reliability
- `RetryInterceptor`: 3 retries, full-jitter exponential backoff, capped at 30 seconds
- `RetryMixin` for non-HTTP retry logic (WebSocket reconnect, etc.)
- `AppBlocObserver` captures all BLoC errors and forwards to Crashlytics in production
- `AppErrorBoundary` catches uncaught Flutter rendering errors with user-facing fallback UI

### 6.3 Accessibility
- `SemanticsWrapper` / `AccessibilityLabel` applied to all interactive components
- `MinTouchTarget` enforces 48dp minimum tap targets
- Respects `reduceMotion`, `boldText`, `highContrast` system settings
- `accessibleDuration()` returns `Duration.zero` when reduce-motion is on

### 6.4 Localisation
- `flutter_localizations` + ARB files in `lib/l10n/`
- Supported locales: `en`, `es`, `fr`, `de`
- Default: `en`

### 6.5 Minimum OS
- Android: API 21 (Android 5.0 Lollipop)
- iOS: 13.0

---

## 7. API Contract

**Base URLs:**

| Environment | URL |
|---|---|
| Development | `https://api-dev.vibyuk.com/v1` |
| Staging | `https://api-staging.vibyuk.com/v1` |
| Production | `https://api.vibyuk.com/v1` |

**Authentication:** `Authorization: Bearer <access_token>`

**Pagination:** All list endpoints accept `?page=1&per_page=20` and return:
```json
{
  "data": [...],
  "current_page": 1,
  "total_pages": 5,
  "total_items": 94,
  "per_page": 20
}
```

**Error format:**
```json
{
  "message": "Human-readable error",
  "code": "ERROR_CODE",
  "errors": { "field": ["Validation message"] }
}
```

**Key endpoint groups:**

| Group | Prefix |
|---|---|
| Auth | `/auth/*` |
| User Profile | `/users/*` |
| Creators | `/creators/*` |
| Booking Engine | `/booking-engine/*` |
| Events & Tickets | `/events/*`, `/tickets/*` |
| Chat | `/chat/*` |
| Payments & Escrow | `/payments/*`, `/escrow/*` |
| Notifications | `/notifications/*` |
| Wedding | `/wedding/*` |
| Tourism | `/tourism/*` |
| AI | `/ai/*` |
| Admin | `/admin/*` |

**WebSocket:** `wss://ws.vibyuk.com` — chat, typing indicators, booking status events

---

## 8. Deep Linking

| Scheme | Example | Resolves to |
|---|---|---|
| `vibyuk://` | `vibyuk://creators/abc` | `/creators/abc` |
| Universal Link | `https://vibyuk.com/events/xyz` | `/events/xyz` |
| Universal Link | `https://www.vibyuk.com/bookings/123` | `/bookings/123` |

Android intent filters and iOS Associated Domains must be configured on the server (`/.well-known/assetlinks.json` and `/.well-known/apple-app-site-association`).

---

## 9. CI/CD

**Workflows (`.github/workflows/`):**

| Workflow | Trigger | Jobs |
|---|---|---|
| `ci.yml` | Every PR / push | Format check → Dart analyze → Unit tests → Build dev APK + iOS dev |
| `release.yml` | Push to `main` | Build production AAB (signed) + staging APK + production IPA |

**Required GitHub Secrets:**

| Secret | Description |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Base64 of `vibyuk-upload.jks` |
| `ANDROID_STORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_KEY_ALIAS` | `upload` |
| `IOS_CERTIFICATE_BASE64` | Base64 of Apple distribution certificate `.p12` |
| `IOS_P12_PASSWORD` | Certificate password |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64 of `.mobileprovision` |
| `KEYCHAIN_PASSWORD` | Temporary macOS keychain password (any strong string) |

---

## 10. Testing

| Layer | Coverage |
|---|---|
| Core infrastructure | `CacheManager`, `RetryInterceptor`, `CacheInterceptor`, `EncryptedStorageService`, `compute_utils` |
| Services | `AnalyticsService`, `CrashReportingService` |
| BLoC | `AuthBloc` (14 scenarios), `PaginationBloc` (6 scenarios), `NotificationBadgeCubit` |
| Error handling | `ErrorHandler` mapping |

Run tests: `make test` or `flutter test --coverage`

---

## 11. Out of Scope (v1.0)

- Web / desktop platforms
- In-app video calls
- Creator subscription tiers
- Multi-currency (GBP only at launch)
- Offline mode (cache read-only; writes require connectivity)
