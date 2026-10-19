/*
 * npm run db:queries
 * Runs db/postgres/03_queries.sql through psql (it uses psql variables and
 * \echo headings, so it is a psql script rather than plain SQL).
 * Set PSQL to the psql binary if it is not on PATH.
 */
import "./_env";
import { spawnSync } from "node:child_process";

const psql = process.env.PSQL ?? "psql";
const result = spawnSync(psql, [process.env.DATABASE_URL ?? "", "-X", "-v", "ON_ERROR_STOP=1", "-f", "db/postgres/03_queries.sql"], {
  stdio: "inherit",
});
if (result.error) {
  console.error(
    `Could not run ${psql}: ${result.error.message}. Install the PostgreSQL client tools and set PSQL=/path/to/psql, ` +
      `or run it in Docker, where psql is installed: docker compose --env-file .env.docker exec app npm run db:queries`,
  );
  process.exitCode = 1;
} else {
  process.exitCode = result.status ?? 1;
}
