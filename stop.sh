#!/usr/bin/env bash
# Stops the Veritrace containers; data is kept. Quit Docker Desktop yourself if you like.
cd "$(dirname "$0")"
docker compose --env-file .env.docker stop
