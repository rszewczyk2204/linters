#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

REPORT_DIR=build/reports
mkdir -p "${REPORT_DIR}"
if ! pylint --recursive yes --output-format json . >|"${REPORT_DIR}/pylint.json"; then
  cat "${REPORT_DIR}/pylint.json"
  SCRIPT_DIR=$(dirname "$0")
# Add codeclimate report conversion
  exit 1
fi