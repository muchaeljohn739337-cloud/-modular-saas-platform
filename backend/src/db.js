import dotenv from "dotenv";
import pg from "pg";
dotenv.config();

const { Pool } = pg;

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

export async function query(sql, params) {
  const client = await pool.connect();
  try {
    const res = await client.query(sql, params);
    return res;
  } finally {
    client.release();
  }
}

export async function runMigrations() {
  const fs = await import("fs");
  const path = await import("path");
  const dir = path.resolve("migrations");
  const files = fs
    .readdirSync(dir)
    .filter((f) => f.endsWith(".sql"))
    .sort();

  for (const file of files) {
    const sql = fs.readFileSync(path.join(dir, file), "utf8");
    console.log(`Running migration: ${file}`);
    await query(sql);
  }
  console.log("Migrations complete");
}
