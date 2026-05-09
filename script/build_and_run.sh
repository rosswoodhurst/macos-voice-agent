#!/usr/bin/env bash
set -euo pipefail

APP_NAME="Verba"
SCHEME="Verba"
PROJECT="Verba.xcodeproj"
CONFIGURATION="Debug"
DERIVED_DATA_PATH="${PWD}/build/DerivedData"
MODE="${1:-run}"

if pgrep -x "${APP_NAME}" >/dev/null; then
  pkill -x "${APP_NAME}"
fi

xcodegen generate

xcodebuild \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -configuration "${CONFIGURATION}" \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  build

APP_PATH="${DERIVED_DATA_PATH}/Build/Products/${CONFIGURATION}/${APP_NAME}.app"

case "${MODE}" in
  run)
    /usr/bin/open -n "${APP_PATH}"
    ;;
  --debug|debug)
    lldb -- "${APP_PATH}/Contents/MacOS/${APP_NAME}"
    ;;
  --logs|logs)
    /usr/bin/open -n "${APP_PATH}"
    /usr/bin/log stream --info --style compact --predicate "process == \"${APP_NAME}\""
    ;;
  --telemetry|telemetry)
    /usr/bin/open -n "${APP_PATH}"
    /usr/bin/log stream --info --style compact --predicate "subsystem == \"${APP_NAME}\""
    ;;
  --verify|verify)
    /usr/bin/open -n "${APP_PATH}"
    sleep 2
    pgrep -x "${APP_NAME}" >/dev/null
    ;;
  *)
    echo "usage: $0 [run|--debug|--logs|--telemetry|--verify]" >&2
    exit 2
    ;;
esac
