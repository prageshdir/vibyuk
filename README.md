# VIBYUK — Flutter Mobile App

**B2B Creator & Event Booking Platform**  
Package: `com.vibyuk.app` | Flutter 3.27.0 | Dart 3.x | Min Android API 21 | Min iOS 13.0

---

## Prerequisites

Install these on your development machine before anything else:

| Tool | Version | Install |
|---|---|---|
| Flutter SDK | 3.27.0 | https://docs.flutter.dev/get-started/install |
| Android Studio | Latest | For Android SDK and emulator |
| Xcode | 15+ | Mac only — for iOS builds |
| CocoaPods | Latest | `sudo gem install cocoapods` |
| Java JDK | 17 | Required by Gradle |
| make | Any | Pre-installed on Mac/Linux |

Verify your setup:
```bash
flutter doctor -v
```
All items should show a green tick before proceeding.

---

## 1. Clone and Install

```bash
git clone https://github.com/prageshdir/vibyuk.git
cd vibyuk
flutter pub get
```

---

## 2. Firebase Setup (Required — app crashes without this)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a project named **vibyuk** (or connect to the existing one)
3. **Android app** → Add app → package: `com.vibyuk.app`
   - Download `google-services.json`
   - Place at `android/app/google-services.json`
4. **iOS app** → Add app → bundle ID: `com.vibyuk.app`
   - Download `GoogleService-Info.plist`
   - Place at `ios/Runner/GoogleService-Info.plist`
5. Enable in Firebase Console:
   - Authentication → Email/Password, Google, Phone
   - Crashlytics → enable
   - Analytics → enable
   - Cloud Messaging → enable

> Both files are git-ignored. Never commit them.

---

## 3. Android Signing

A keystore has been generated at `android/app/vibyuk-upload.jks`.

Create `android/key.properties` (already git-ignored):
```properties
storePassword=Vibyuk@Upload2024!
keyPassword=Vibyuk@Upload2024!
keyAlias=upload
storeFile=vibyuk-upload.jks
```

> **Important:** Copy `vibyuk-upload.jks` to a secure location (password manager / team vault). If lost, Play Store upload key recovery requires contacting Google Support.

The keystore details:
- Alias: `upload`
- Validity: 10,000 days (until 2053)
- SHA-256: `73:14:85:03:60:26:3E:C7:AF:05:30:EB:A6:3E:6C:C3:FD:4A:8C:80:24:93:5A:87:0F:B9:83:0B:6E:89:C3:B0`

---

## 4. iOS Signing (Mac only)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** target → Signing & Capabilities
3. Set your **Team** and **Bundle Identifier** (`com.vibyuk.app`)
4. Xcode will manage provisioning profiles automatically for development
5. For release builds, create an **App Store Distribution** certificate in Apple Developer Portal

---

## 5. App Icons

Place your app icon files before building:

```
assets/icons/app_icon.png              # 1024×1024 PNG, full icon
assets/icons/app_icon_foreground.png   # 1024×1024 PNG, foreground only (transparent background)
```

Then generate all platform icon sizes:
```bash
flutter pub run flutter_launcher_icons
```

The adaptive icon background colour is brand purple `#7B2FFF` (already configured in `pubspec.yaml`).

---

## 6. Environment Configuration

The app has three flavors. Each flavor has its own entry point:

| Flavor | Entry point | API |
|---|---|---|
| dev | `lib/main_dev.dart` | `api-dev.vibyuk.com` |
| staging | `lib/main_staging.dart` | `api-staging.vibyuk.com` |
| production | `lib/main_production.dart` | `api.vibyuk.com` |

---

## 7. Running the App

```bash
# Development (default)
make run-dev
# or:
flutter run -t lib/main_dev.dart --flavor dev

# Staging
make run-staging
# or:
flutter run -t lib/main_staging.dart --flavor staging
```

---

## 8. Build Commands

```bash
# All commands are available via make:
make help

# Individual builds:
make build-dev             # Debug APK (dev flavor)
make build-staging         # Staging APK
make build-prod-android    # Release AAB (production, signed, obfuscated)
make build-prod-ios        # Release IPA (production)

# Code quality:
make analyze               # dart analyze
make format                # dart format
make test                  # flutter test
make test-ci               # flutter test --coverage (for CI)
```

**Production Android build in full:**
```bash
flutter build appbundle \
  --flavor production \
  -t lib/main_production.dart \
  --obfuscate \
  --split-debug-info=build/symbols/production
```
Output: `build/app/outputs/bundle/productionRelease/app-production-release.aab`

---

## 9. Code Generation

After changing any `@freezed`, `@injectable`, or Drift schema files, regenerate:
```bash
make generate
# or:
flutter pub run build_runner build --delete-conflicting-outputs
```

Files ending in `.g.dart`, `.freezed.dart`, and `.gen.dart` are auto-generated — do not edit them manually.

---

## 10. Project Structure

```
lib/
├── core/
│   ├── api/                   # Dio client + 6-interceptor chain
│   │   └── interceptors/      # Auth, Cache, Retry, Error, Connectivity, Logging
│   ├── auth/                  # Token management, AuthStorage
│   ├── base/                  # BaseBloc, BaseCubit, UseCase interfaces
│   ├── cache/                 # CacheManager (Hive), Drift database
│   ├── config/                # FlavorConfig, AppConfig
│   ├── di/                    # GetIt injection container + per-module registrations
│   ├── error/                 # Failures, Exceptions, ErrorHandler
│   ├── navigation/            # GoRouter, RouteNames, AuthGuard
│   ├── notifications/         # FCM, LocalNotifications, NotificationHandler
│   ├── observers/             # AppBlocObserver, AnalyticsRouteObserver
│   ├── pagination/            # Generic PaginationBloc
│   ├── services/              # Analytics, CrashReporting, DeepLink, Performance
│   ├── socket/                # SocketService (Socket.IO)
│   ├── startup/               # AppStartupService (3-stage init)
│   ├── storage/               # EncryptedStorageService
│   └── utils/                 # compute_utils (background isolates)
│
├── features/
│   ├── auth/                  # Login, Register, OTP, Biometric, Role selection
│   ├── creator/               # Portfolio, Reviews, KYC, Dashboard
│   ├── business/              # Discover, Campaigns, Team, Analytics
│   ├── bookings/              # Full booking engine lifecycle
│   ├── chat/                  # Real-time messaging (Socket.IO)
│   ├── payments/              # Razorpay, Escrow, Invoices, Transactions
│   ├── notifications/         # Notification centre, Badge, Preferences
│   ├── events/                # Event CRUD, Ticketing, QR Scanner
│   ├── wedding/               # Wedding planning marketplace
│   ├── tourism/               # Tourism campaigns, FAM trips, Destinations
│   ├── ai/                    # Smart match, Campaign planner, Pricing, Chat
│   └── admin/                 # Moderation, Disputes, Verifications, Reports
│
├── l10n/                      # ARB localisation files (en, es, fr, de)
├── main_dev.dart
├── main_staging.dart
└── main_production.dart

test/
├── helpers/                   # test_helpers.dart — fakes and matchers
├── core/
│   ├── api/interceptors/      # RetryInterceptor, CacheInterceptor tests
│   ├── cache/                 # CacheManager tests
│   ├── error/                 # ErrorHandler tests
│   ├── pagination/            # PaginationBloc tests
│   ├── services/              # Analytics, CrashReporting tests
│   ├── storage/               # EncryptedStorageService tests
│   └── utils/                 # compute_utils tests
└── features/
    ├── auth/                  # AuthBloc tests (14 scenarios)
    └── notifications/         # NotificationBadgeCubit tests
```

---

## 11. Deployment to Google Play Store

### Step 1 — Internal Testing (first release)
1. Build the release AAB: `make build-prod-android`
2. Go to [Google Play Console](https://play.google.com/console)
3. Create app → App name: **VIBYUK**, Default language: **English (United Kingdom)**
4. Testing → Internal Testing → Create new release → Upload the `.aab`
5. Complete the store listing checklist (see below)

### Step 2 — Store Listing Checklist

- [ ] Short description (80 chars max)
- [ ] Full description (4000 chars max)
- [ ] App icon — 512×512 PNG
- [ ] Feature graphic — 1024×500 PNG
- [ ] Phone screenshots — minimum 2, maximum 8 (16:9 or 9:16)
- [ ] Privacy policy URL (required — host at e.g. `vibyuk.com/privacy`)
- [ ] Content rating questionnaire — complete in Play Console
- [ ] Target audience — 18+
- [ ] Data safety form — declare data collection (email, location, camera)

### Step 3 — Production Release
1. Promote from Internal Testing → Production
2. Roll out to 10% initially, monitor crash rate in Crashlytics
3. Increase to 100% if crash-free rate stays above 99%

---

## 12. Deployment to Apple App Store

1. Build: `make build-prod-ios` (requires Mac with Xcode)
2. Open Xcode → Product → Archive
3. Distribute App → App Store Connect → Upload
4. In [App Store Connect](https://appstoreconnect.apple.com):
   - Create app with bundle ID `com.vibyuk.app`
   - Add screenshots for all required device sizes
   - Submit for review

---

## 13. CI/CD

Two GitHub Actions workflows are included:

**`.github/workflows/ci.yml`** — runs on every PR:
- Format check (`dart format --set-exit-if-changed`)
- Static analysis (`dart analyze`)
- Unit tests (`flutter test --coverage`)
- Dev APK build

**`.github/workflows/release.yml`** — runs on push to `main`:
- Production AAB (signed, obfuscated)
- Staging APK
- Production IPA

### Setting up CI secrets

In GitHub → Settings → Secrets → Actions, add:

```
ANDROID_KEYSTORE_BASE64      base64 -i android/app/vibyuk-upload.jks | pbcopy
ANDROID_STORE_PASSWORD       Vibyuk@Upload2024!
ANDROID_KEY_PASSWORD         Vibyuk@Upload2024!
ANDROID_KEY_ALIAS            upload
IOS_CERTIFICATE_BASE64       base64 of your .p12 distribution certificate
IOS_P12_PASSWORD             your certificate password
IOS_PROVISIONING_PROFILE_BASE64   base64 of your .mobileprovision
KEYCHAIN_PASSWORD            any strong random string
```

Encode the keystore for CI:
```bash
base64 -i android/app/vibyuk-upload.jks | tr -d '\n'
```

---

## 14. Testing

```bash
# Run all tests
make test

# Run with coverage report
make test-ci
open coverage/lcov.info    # or use lcov to generate HTML

# Run a single test file
flutter test test/features/auth/auth_bloc_test.dart
```

Test files are in `test/` and mirror the `lib/` structure. All tests use in-memory fakes — no platform channels, Firebase SDK, or network required to run them.

---

## 15. Troubleshooting

**`firebase_core` plugin not initialized`**  
→ `google-services.json` is missing or has placeholder values. Replace with real file from Firebase Console.

**`Keystore file not found`**  
→ `android/key.properties` is missing or `storeFile` path is wrong. Verify `android/app/vibyuk-upload.jks` exists.

**`flutter_launcher_icons: image file not found`**  
→ Place `app_icon.png` at `assets/icons/app_icon.png` before running icon generation.

**`MissingPluginException` on iOS**  
→ Run `cd ios && pod install` then rebuild.

**`Gradle build fails with SDK error`**  
→ Open `android/local.properties` and set `sdk.dir` to your Android SDK path (e.g. `/Users/you/Library/Android/sdk`).

**Build runner conflicts**  
→ `flutter pub run build_runner build --delete-conflicting-outputs`

**Tests fail with `FlavorConfig not initialized`**  
→ Tests call `FlavorConfig.initialize(AppFlavor.dev)` in `setUpAll`. If adding new tests, include this in your test file.
