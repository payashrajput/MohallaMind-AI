import pg from 'pg';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import 'dotenv/config';
import * as fs from 'node:fs/promises';
const { Pool } = pg;
if (!process.env.DATABASE_URL) throw new Error('DATABASE_URL is required. Configure PostgreSQL before running migrations.');
const pool = new Pool({ connectionString: process.env.DATABASE_URL, ssl: process.env.DATABASE_SSL === 'true'
  ? {
      ca: fs.readFileSync(
        new URL('./certs/prod-ca-2021.crt', import.meta.url),
        'utf8'
      ),
      rejectUnauthorized: true
    }
  : undefined,
max: 3 });
const dir = path.join(path.dirname(fileURLToPath(import.meta.url)), 'db', 'migrations');
try {
  await pool.query('CREATE TABLE IF NOT EXISTS schema_migrations (version TEXT PRIMARY KEY, applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW())');
  const files = (await fs.readdir(dir)).filter(f => f.endsWith('.sql')).sort();
  for (const file of files) {
    const already = await pool.query('SELECT 1 FROM schema_migrations WHERE version=$1', [file]);
    if (already.rowCount) { console.log(`skip ${file}`); continue; }
    const sql = await fs.readFile(path.join(dir, file), 'utf8');
    const client = await pool.connect();
    try { await client.query('BEGIN'); await client.query(sql); await client.query('INSERT INTO schema_migrations(version) VALUES($1)', [file]); await client.query('COMMIT'); console.log(`applied ${file}`); }
    catch (e) { await client.query('ROLLBACK'); throw e; }
    finally { client.release(); }
  }
} finally { await pool.end(); }
