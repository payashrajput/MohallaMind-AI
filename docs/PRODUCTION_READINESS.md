# Production readiness and honest scope

The production path is `server/production.js`; it uses PostgreSQL, bcrypt password hashing, short-lived JWT access tokens, rotating database-backed refresh tokens in HttpOnly cookies, database-backed role checks, parameterized SQL, Zod input validation, rate limits, Helmet security headers, audit events, and private Azure Blob Storage for evidence images. The React UI has registration/login, session-scoped access tokens, role-aware status updates, and authorized evidence opening. Triage and duplicate matching are deterministic rules, not a trained AI model.

## Architecture

- React/Vite frontend served from the same Render service as the Express API.
- PostgreSQL is the source of truth. `server/db/migrations/001_initial.sql` defines users, incidents, resident submissions, audit events, token table and migration tracking.
- Azure Blob container is private; images are normalized by Sharp, EXIF metadata is stripped, and only a generated blob key is stored in PostgreSQL. Staff get a two-minute SAS URL after an authenticated/authorized API request.
- No secrets belong in the frontend. `VITE_*` variables are public at build time.

## Required before any real public launch

1. **Identity lifecycle:** email verification, password reset, account deletion, abuse detection, support process and documented role approval. Access tokens are held in `sessionStorage`; rotating refresh tokens use HttpOnly SameSite cookies. A full session-management screen and forced sign-out-all-devices workflow are not implemented.
2. **Privacy governance:** publish jurisdiction-appropriate notice, consent, retention schedule, deletion/export procedures, data controller/contact details and incident response plan. Establish lawful handling for location and image data.
3. **Evidence security:** malware scanning/quarantine, retention/lifecycle policy, audit access, periodic key rotation, least-privilege storage credentials, and tests against malformed/oversized image payloads.
4. **Operations:** managed PostgreSQL backups/PITR, successful restore drills, uptime/error monitoring, alerts, structured log redaction, secret rotation, dependency scanning, CI/CD and rollback.
5. **Security quality:** penetration test, rate-limit tuning behind Render proxy, account abuse protections, authorization review, accessibility checks and load testing.
6. **Product readiness:** actual map/geocoding, incident service-level workflows, municipal notification integrations, resident status updates, verified address/ward data and human evaluation of duplicate suggestions.
7. **Testing:** unit tests are included, but run full integration tests against disposable PostgreSQL and Azure test storage and perform browser-based end-to-end tests against a staging deployment before launch.

## PostgreSQL and migrations

- PostgreSQL 14+ recommended; `pgcrypto` and `pg_trgm` extensions are used. Confirm your managed database allows these extensions.
- `npm run db:migrate` applies ordered migrations in `server/db/migrations`.
- Never expose connection strings to the browser or commit `.env`. Keep TLS certificate validation enabled unless the database provider requires a documented alternative.
- For production systems with multiple instances, run migrations once in a dedicated release job rather than from every instance's start command.

## Azure setup

Set `AZURE_STORAGE_ACCOUNT_NAME`, `AZURE_STORAGE_ACCOUNT_KEY`, and `AZURE_STORAGE_CONTAINER` only in Render's private environment settings. Keep public blob access disabled. The account key grants broad account access; for a more mature deployment, replace shared-key access with managed identity/workload identity and a least-privilege Azure role where hosting topology supports it. Enable storage diagnostics and configure lifecycle retention.

## Administrator bootstrap

Register the account first. Temporarily set `ALLOW_ADMIN_BOOTSTRAP=true` and `ADMIN_BOOTSTRAP_KEY` to a random secret (24+ chars). Call `POST /api/auth/promote-admin` with `email` and `bootstrapKey`, then immediately disable the flag and remove the key. Never leave bootstrap enabled.

## Launch decision

This is a deployable **pilot candidate**, not a certified or fully market-ready commercial service until external services are configured and the listed controls are tested. A code package cannot create cloud accounts, supply credentials, set a legal privacy policy, conduct a penetration test or verify the real municipal workflow by itself.
