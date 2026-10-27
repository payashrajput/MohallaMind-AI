# MohallaMind AI

MohallaMind AI turns community reports about road damage, drainage, waste, water supply and streetlights into a shared incident desk. The production path uses PostgreSQL, role-based accounts, auditable status changes, private Azure Blob evidence, and transparent rule-based triage. It is designed as a pilot foundation; a public commercial launch still requires the launch gates below.

## Runtime modes

- **Full-stack development:** `npm run dev` runs the PostgreSQL-backed API and Vite frontend. Requires a configured PostgreSQL database and `.env`.
- **Production build:** `npm run build`; production server: `npm start`. Render uses this single-service setup and serves the built frontend and API from one HTTPS origin.
- **Visual demo only:** `npm run dev:demo` runs the legacy sample-data server. Do not expose it publicly; it has no production authentication and uses local JSON files.

## Local setup on macOS

1. Install Node.js LTS (Node 20 or 22 recommended).
2. Create a PostgreSQL database, e.g. `mohallamind`, with PostgreSQL 14+ and `pgcrypto`/`pg_trgm` extension support.
3. Copy `.env.example` to `.env`; set `DATABASE_URL`, unique local JWT secrets, and optionally Azure Blob Storage credentials.
4. Run `npm install`.
5. Run `npm run db:migrate`.
6. Run `npm run dev` and open `http://127.0.0.1:5173`. API health: `http://127.0.0.1:4020/api/health`.

## Render deployment (single web service)

The included `render.yaml` builds the React frontend and starts the PostgreSQL API in the same Render web service.

1. Push the project to a Git repository you control and create a Render Blueprint from `render.yaml`.
2. Create a managed PostgreSQL database (Render Postgres or compatible) and set `DATABASE_URL` to its **internal** connection URL where available. Enable TLS with `DATABASE_SSL=true`; verify the provider's certificate behavior rather than disabling validation casually.
3. Set `CORS_ORIGINS` to the exact deployed service origin, e.g. `https://your-service.onrender.com` (no trailing slash). If frontend and API are served by the same service, do not set `VITE_API_BASE_URL`; relative `/api` requests are used.
4. Set Azure storage secrets as described below.
5. Run `npm run db:migrate` once as a release/deploy step; the blueprint start command runs migrations before starting the app, which is convenient for a single instance. For multi-instance/zero-downtime deployments, use a separate one-off release job so two instances never run migrations concurrently.
6. Verify `https://your-service.onrender.com/api/health`, then test registration, login, incident submission, reviewer status changes, and private evidence access.

### Required Render environment variables

- `DATABASE_URL` — managed PostgreSQL connection string (secret).
- `DATABASE_SSL=true` — TLS to managed PostgreSQL.
- `JWT_SECRET` — unique random secret of at least 32 characters.
- `REFRESH_TOKEN_PEPPER` — another independent random secret of at least 32 characters (reserved for token/security evolution; do not reuse JWT secret).
- `CORS_ORIGINS` — exact HTTPS app origin.
- `AZURE_STORAGE_ACCOUNT_NAME`, `AZURE_STORAGE_ACCOUNT_KEY`, `AZURE_STORAGE_CONTAINER` — Azure Blob configuration. Keep the account key server-side only.
- `NODE_ENV=production`, `HOST=0.0.0.0`, `ALLOW_ADMIN_BOOTSTRAP=false`.

## Azure Blob Storage setup

1. Create an Azure Storage Account and a private Blob container named `incident-evidence` (the API also attempts to create it if missing). Public blob access must remain disabled.
2. Create/rotate an account key and add the name/key/container to Render's secret environment settings. Never put these in `VITE_*` variables or frontend code.
3. The API decodes and re-encodes JPEG/PNG/WebP uploads using Sharp, strips EXIF metadata, caps the input at 5 MB and image dimensions, stores the normalized JPEG in Blob Storage, and saves only the blob key in PostgreSQL.
4. Evidence access requires a reviewer/admin bearer token and returns a short-lived (2-minute) HTTPS SAS URL. Do not log or share these URLs. Configure Azure diagnostic logging and lifecycle/retention policies according to your privacy commitments.

## First administrator

1. Register the intended admin account through the UI.
2. Temporarily set `ALLOW_ADMIN_BOOTSTRAP=true` and a unique `ADMIN_BOOTSTRAP_KEY` of at least 24 characters in Render environment settings.
3. From a trusted terminal, call `POST https://your-service.onrender.com/api/auth/promote-admin` with JSON `{"email":"admin@example.com","bootstrapKey":"YOUR_SECRET"}`. Do not share the key in chat or source control.
4. Immediately set `ALLOW_ADMIN_BOOTSTRAP=false` and remove `ADMIN_BOOTSTRAP_KEY`. Check that `/api/auth/me` reports role `admin` after signing in again.
5. Use the admin-only `GET /api/admin/users` and `PATCH /api/admin/users/:id/role` endpoints to manage reviewer roles after bootstrap. Do not grant staff roles based only on self-claimed email addresses.

## What works / current limitations

- Resident registration/login, bcrypt password hashing, short-lived bearer access token kept in `sessionStorage`, and resident/reviewer/admin role checks, rotating HttpOnly refresh cookies, and current-session logout.
- PostgreSQL persistence for users, incidents, reports, and audit events. SQL migrations are versioned.
- Public incident listing/submission; staff-only updates, insights, event history and evidence access.
- Private Azure Blob image storage, server-side image re-encoding, short-lived signed evidence URLs.
- Explainable rule-based priority scoring and heuristic possible-duplicate linking. A human must confirm matching and resolution. This is **not a trained AI model**.

Not yet complete for a public commercial launch: email verification and password recovery, session management/revocation across devices, resident data export/deletion tooling, formal retention policy enforcement, malware scanning, verified real-world maps/geocoding, authority notifications, monitoring/alerts and backup-restore drills, accessibility/load/penetration tests, and jurisdiction-specific privacy/legal review. Do not represent sample map pins as real coordinates or claim that reports automatically reach a municipal authority.

## Commands

- `npm run check` — server-side JavaScript syntax checks.
- `npm test` — unit tests for the transparent triage rules.
- `npm run build` — Vite production build.
- `npm run db:migrate` — apply versioned SQL migrations.

See `API_REFERENCE.md`, `SECURITY.md`, `PRIVACY.md`, `docs/PRODUCTION_READINESS.md`, and `LAUNCH_CHECKLIST.md`.
