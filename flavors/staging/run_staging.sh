#!/usr/bin/env bash
# Run the app in staging flavor
flutter run \
  --flavor staging \
  --target lib/main_staging.dart \
  --dart-define=FLAVOR=staging \
  "$@"
