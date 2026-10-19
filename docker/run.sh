#!/usr/bin/env bash
# Runs inside the app container on every start:
#   1. npm ci          when package-lock.json changed (first run: ~2 min)
#   2. npm run setup   first run only, or after reset (fills all 3 databases)
#   3. checks          typecheck + tests + graph:verify, after each setup
#   4. npm run dev     the website on port 3000
# Everything is also written to logs/ in the repo folder.
set -o pipefail
cd /app
mkdir -p logs .cache
log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a logs/app.log; }

log "waiting for Qdrant"
until (echo > /dev/tcp/qdrant/6333) 2>/dev/null; do sleep 1; done

if [ ! -f node_modules/.installed ] || [ package-lock.json -nt node_modules/.installed ]; then
  log "installing packages (npm ci)"
  if ! npm ci --no-audit --no-fund 2>&1 | tee logs/npm-install.log; then
    log "npm ci FAILED, see logs/npm-install.log"
    sleep infinity
  fi
  touch node_modules/.installed
fi

if [ ! -f .cache/.setup-done ]; then
  log "first run: npm run setup (schema, seed data, graph, vectors, complaints)"
  if npm run setup 2>&1 | tee logs/setup.log; then
    touch .cache/.setup-done
    log "setup OK"
  else
    log "setup FAILED, see logs/setup.log"
  fi
  log "running checks: typecheck, tests, graph:verify"
  {
    echo "=== typecheck ==="; npm run typecheck; echo "EXIT $?"
    echo "=== test (own database: veritrace_test) ==="; bash docker/test.sh; echo "EXIT $?"
    echo "=== graph:verify ==="; npm run graph:verify; echo "EXIT $?"
  } > logs/checks.log 2>&1
  log "checks finished, see logs/checks.log"
fi

# Start from an empty .next every time. After a container restart, Turbopack's
# saved dev cache answered every nested route (/api/batches/58/provenance,
# /exposure, /compare) with 404 even though the files were there; clearing it
# fixed that. The cost is a few seconds of compiling on the first page view.
rm -rf .next/* .next/.[!.]* 2>/dev/null || true

log "website starting on http://localhost:3000"
exec npm run dev -- -H 0.0.0.0 -p 3000
