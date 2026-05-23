#!/usr/bin/env bash
# Build release APK/IPA for production
flutter build apk \
  --flavor production \
  --target lib/main_production.dart \
  --dart-define=FLAVOR=production \
  --release \
  "$@"
