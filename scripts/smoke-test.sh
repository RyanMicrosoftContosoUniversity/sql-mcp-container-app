#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf '[smoke] FAIL: %s\n' "$1" >&2
  exit 1
}

for tool in curl jq mktemp; do
  command -v "$tool" >/dev/null 2>&1 \
    || fail "Required tool missing: $tool"
done

response_file="$(mktemp)"
trap 'rm -f "$response_file"' EXIT

printf '[smoke] Checking REST database read...\n'

if ! curl \
  --silent \
  --show-error \
  --fail \
  --connect-timeout 5 \
  --max-time 30 \
  --output "$response_file" \
  'http://localhost:5000/api/Products?$first=1'; then
  fail 'REST request failed'
fi

if ! jq -e \
  'type == "object" and (.value | type == "array")' \
  "$response_file" >/dev/null 2>&1; then
  fail 'REST response is not valid JSON with a value array'
fi

printf '[smoke] PASS: REST database read\n'