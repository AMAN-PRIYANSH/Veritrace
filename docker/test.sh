#!/usr/bin/env bash
# Runs `npm test` inside the app container against its own database,
# veritrace_test, rebuilt from the schema files each time. The tests roll
# back their rows, but sequences still advance, so running them on the demo
# database made the next recall show up as "#11" when only 3 existed.
set -o pipefail
cd /app
SERVER_URL="${DATABASE_URL%/*}"
TEST_URL="$SERVER_URL/veritrace_test"

if ! psql "$SERVER_URL/postgres" -tAc "SELECT 1 FROM pg_database WHERE datname = 'veritrace_test'" | grep -q 1; then
  psql "$SERVER_URL/postgres" -qc "CREATE DATABASE veritrace_test" || exit 1
fi
TARGET_DATABASE_URL="$TEST_URL" npx tsx scripts/db-apply.ts 01_schema.sql 02_functions.sql || exit 1
DATABASE_URL="$TEST_URL" npm test
