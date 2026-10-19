#!/usr/bin/env bash
# Veritrace on macOS / Linux: same as start.bat. Needs Docker running.
set -euo pipefail
cd "$(dirname "$0")"
if [ ! -f .env.docker ]; then
  h() { openssl rand -hex "$1"; }
  printf 'PG_PASSWORD=%s\nNEO4J_PASSWORD=%s\nQDRANT_API_KEY=%s\nSESSION_SECRET=%s\nSEED_MANUFACTURER_PASSWORD=maker-%s\nSEED_REGULATOR_PASSWORD=inspector-%s\n' \
    "$(h 12)" "$(h 12)" "$(h 16)" "$(h 32)" "$(h 4)" "$(h 4)" > .env.docker
fi
set -a; . ./.env.docker; set +a
cat > LOGIN-INFO.txt <<INFO
Website http://localhost:3000
  maker / $SEED_MANUFACTURER_PASSWORD      inspector / $SEED_REGULATOR_PASSWORD
Neo4j Browser http://localhost:7474  neo4j / $NEO4J_PASSWORD
PostgreSQL localhost:5433  veritrace / $PG_PASSWORD
INFO
mkdir -p logs
docker compose --env-file .env.docker up -d --build
echo "Waiting for http://localhost:3000 (first run: 10-20 min) ..."
until curl -fs -o /dev/null http://localhost:3000/login; do sleep 5; tail -n 1 logs/app.log 2>/dev/null || true; done
echo "Veritrace is running at http://localhost:3000 (logins in LOGIN-INFO.txt). Stop with ./stop.sh"
