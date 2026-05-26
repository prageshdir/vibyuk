.PHONY: help setup clean get analyze format test build-dev build-staging build-prod-android build-prod-ios

FLUTTER := flutter
DART    := dart

help:
	@echo "Vibyuk Flutter Project — available targets:"
	@echo "  setup               Install dependencies and run pub get"
	@echo "  clean               Clean build artifacts"
	@echo "  get                 Run flutter pub get"
	@echo "  analyze             Run dart analyze"
	@echo "  format              Run dart format (in-place)"
	@echo "  format-check        Check formatting without modifying"
	@echo "  test                Run all unit + widget tests with coverage"
	@echo "  build-dev           Build dev APK (Android)"
	@echo "  build-staging       Build staging APK (Android)"
	@echo "  build-prod-android  Build production AAB + obfuscated"
	@echo "  build-prod-ios      Build production IPA (macOS only)"
	@echo "  run-dev             Run app with dev flavor"
	@echo "  run-staging         Run app with staging flavor"

setup: get
	@echo "Setup complete."

clean:
	$(FLUTTER) clean
	rm -rf build/

get:
	$(FLUTTER) pub get

analyze:
	$(FLUTTER) analyze --fatal-infos

format:
	$(DART) format lib/ test/

format-check:
	$(DART) format --output=none --set-exit-if-changed lib/ test/

test:
	$(FLUTTER) test --coverage --reporter expanded

test-ci:
	$(FLUTTER) test --coverage --reporter github

build-dev:
	$(FLUTTER) build apk \
		--flavor dev \
		-t lib/main_dev.dart \
		--split-per-abi

build-staging:
	$(FLUTTER) build apk \
		--flavor staging \
		-t lib/main_staging.dart \
		--release \
		--split-per-abi

build-prod-android:
	$(FLUTTER) build appbundle \
		--flavor production \
		-t lib/main_production.dart \
		--release \
		--obfuscate \
		--split-debug-info=build/debug-info

build-prod-ios:
	$(FLUTTER) build ipa \
		--flavor production \
		-t lib/main_production.dart \
		--release \
		--obfuscate \
		--split-debug-info=build/debug-info

run-dev:
	$(FLUTTER) run \
		--flavor dev \
		-t lib/main_dev.dart

run-staging:
	$(FLUTTER) run \
		--flavor staging \
		-t lib/main_staging.dart
