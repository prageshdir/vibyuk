#!/usr/bin/env bash
# Run the app in dev flavor
flutter run \
  --flavor dev \
  --target lib/main_dev.dart \
  --dart-define=FLAVOR=dev \
  "$@"
