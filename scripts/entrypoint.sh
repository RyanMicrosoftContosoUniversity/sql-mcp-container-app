#!/usr/bin/env bash
set -euo pipefail

dab_pid=''

cleanup() {
  if [[ -n "$dab_pid" ]] && kill -0 "$dab_pid" 2>/dev/null; then
    printf '[startup] Stopping DAB...\n'
    kill -TERM "$dab_pid" || true
    wait "$dab_pid" || true
  fi
}

trap cleanup EXIT
trap 'exit 143' TERM
trap 'exit 130' INT

printf '[startup] Starting DAB...\n'

cd /App
dotnet /App/Azure.DataApiBuilder.Service.dll "$@" &
dab_pid=$!

deadline=$((SECONDS + 120))

while true; do
  if ! kill -0 "$dab_pid" 2>/dev/null; then
    printf '[startup] FAIL: DAB exited before accepting requests\n' >&2
    exit 1
  fi

  if curl --silent --fail \
    --connect-timeout 2 \
    --max-time 2 \
    --output /dev/null \
    'http://localhost:5000/' 2>/dev/null; then
    break
  fi

  if (( SECONDS >= deadline )); then
    printf '[startup] FAIL: DAB startup timed out\n' >&2
    exit 1
  fi

  sleep 1
done

printf '[startup] DAB is accepting HTTP requests\n'

if ! /bin/bash /App/scripts/smoke-test.sh; then
  printf '[startup] FAIL: Smoke tests failed\n' >&2
  exit 1
fi

printf '[startup] PASS: Smoke tests completed; DAB remains running\n'

if wait "$dab_pid"; then
  exit 0
else
  exit "$?"
fi