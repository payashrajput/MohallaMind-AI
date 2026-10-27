# MohallaMind API reference (PostgreSQL production path)

Base URL: `http://localhost:4020` locally; use HTTPS in deployment. Errors return JSON `{ "error": "..." }`. Never send secrets from browser code.

## Authentication

- `POST /api/auth/register` with `{ "email":"resident@example.com", "password":"at-least-12-characters", "fullName":"Resident Name" }`. Returns a user and short-lived bearer access token. Passwords are bcrypt-hashed.
- `POST /api/auth/login` with email/password.
- `GET /api/auth/me` requires `Authorization: Bearer <accessToken>`.
- `POST /api/auth/refresh` rotates a 30-day HttpOnly refresh cookie and returns a new short-lived access token. The browser retries one failed authorized request after refresh.
- `POST /api/auth/logout` revokes the current refresh token and clears its cookie.
- New accounts are `resident`. Reviewer/admin roles must be assigned through a controlled admin workflow. One-time admin promotion is documented in `docs/PRODUCTION_READINESS.md`.

## Incidents

- `GET /api/reports?status=Under%20review&category=Drainage&ward=Ward%2008&q=pothole&limit=50&offset=0` — public incident list.
- `GET /api/reports/MM-123` — public incident details.
- `POST /api/reports` — submit incident with JSON or multipart fields `title`, `category`, `location`, `ward`, `description`, `severity`, optional `latitude`, `longitude`, and optional `photo`. JPEG/PNG/WebP files up to 5 MB are decoded/re-encoded; Azure storage must be configured.
- `PATCH /api/reports/MM-123` — reviewer/admin only. Supported fields: `status`, `severity`, `title`, `description`, `location`, `ward`, `assignedTo`, `resolutionNote`.
- `GET /api/events` and `GET /api/insights` — reviewer/admin only.
- `GET /api/admin/users` — admin only; lists accounts without password hashes.
- `PATCH /api/admin/users/:id/role` — admin only; body `{"role":"reviewer","isActive":true}`. Role changes are audit logged.
- `GET /api/evidence/<blob-key>` — reviewer/admin only; returns a short-lived private Azure SAS URL as JSON.
- `GET /api/health` — checks database connectivity and reports whether Azure evidence storage is configured.

## Triage behavior

Priority scoring is rule-based and explainable. Duplicate candidates are linked heuristically by category/location/title similarity; they are not automatically declared duplicates. Human review is required.
