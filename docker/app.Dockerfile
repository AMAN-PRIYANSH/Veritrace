# The app container: Node 22 plus the psql client (npm run db:queries needs it).
FROM node:22-bookworm
RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-client \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
