#!/usr/bin/env bash
# Run the full test suite for the Breast Cancer Risk Assessment app.
#
# Usage:
#   bash test/run_tests.sh            # all unit + widget + performance tests
#   bash test/run_tests.sh --unit     # unit tests only
#   bash test/run_tests.sh --widget   # widget tests only
#   bash test/run_tests.sh --perf     # performance tests only
#   bash test/run_tests.sh --integration  # integration/system tests (device required)

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

section() { echo -e "\n${CYAN}══ $1 ══${NC}"; }
pass()    { echo -e "${GREEN}✔ $1${NC}"; }
fail()    { echo -e "${RED}✘ $1${NC}"; exit 1; }

UNIT=false
WIDGET=false
PERF=false
INTEGRATION=false
ALL=true

for arg in "$@"; do
  case $arg in
    --unit)        UNIT=true;        ALL=false ;;
    --widget)      WIDGET=true;      ALL=false ;;
    --perf)        PERF=true;        ALL=false ;;
    --integration) INTEGRATION=true; ALL=false ;;
  esac
done

section "Ensuring dependencies are up to date"
flutter pub get

# ── Unit Tests ────────────────────────────────────────────────────────────────
if $ALL || $UNIT; then
  section "Unit Tests"
  flutter test test/unit/ml_service_test.dart \
               test/unit/app_settings_test.dart \
               test/unit/risk_score_logic_test.dart \
               --reporter expanded \
    && pass "Unit tests passed" \
    || fail "Unit tests failed"
fi

# ── Widget Tests ──────────────────────────────────────────────────────────────
if $ALL || $WIDGET; then
  section "Widget Tests"
  flutter test test/widget/auth_screen_test.dart \
               test/widget/prediction_screen_test.dart \
               test/widget/result_screen_test.dart \
               --reporter expanded \
    && pass "Widget tests passed" \
    || fail "Widget tests failed"
fi

# ── Performance Tests ─────────────────────────────────────────────────────────
if $ALL || $PERF; then
  section "Performance Tests"
  flutter test test/performance/ml_performance_test.dart \
               --reporter expanded \
    && pass "Performance tests passed" \
    || fail "Performance tests failed"
fi

# ── Integration / System Tests ────────────────────────────────────────────────
if $INTEGRATION; then
  section "Integration / System Tests (requires connected device)"
  flutter test integration_test/app_flow_test.dart \
               --reporter expanded \
    && pass "Integration tests passed" \
    || fail "Integration tests failed"
fi

if $ALL; then
  section "Full test run complete"
  pass "All test suites passed"
fi
