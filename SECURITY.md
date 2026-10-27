# Security and deployment notes

The production runtime is `server/production.js`; the older `server/index.js` is a local sample-data demo only and must never be exposed publicly. Deploy only the PostgreSQL production runtime through the included Render configuration.

## Implemented in the production path

- PostgreSQL persistence and parameterized queries; versioned SQL migrations.
- Bcrypt password hashes; short-lived signed access tokens; rotating database-backed refresh tokens in HttpOnly SameSite cookies; active-account and role checks.
- Resident/reviewer/admin roles; reviewer/admin-only incident updates, insights, audit events and evidence access.
- Zod request validation, API/auth rate limits, Helmet headers, exact CORS allowlist, bounded JSON and multipart request sizes.
- Azure Blob private evidence storage; Sharp decoding/re-encoding and EXIF removal; generated object keys; temporary two-minute SAS links for authorized staff.
- Audit events for incident/report changes and safe error responses that avoid returning stack traces.

## Required before public launch

- [ ] Add email verification, password reset, sign-out-all-devices, account deletion/export and stronger account abuse controls.
- [ ] Replace shared-key Azure access with managed identity/workload identity where feasible; enforce least privilege and rotate keys.
- [ ] Add malware scanning/quarantine, retention lifecycle enforcement and audit monitoring for evidence.
- [ ] Configure managed PostgreSQL backups/PITR and complete restore drills.
- [ ] Add uptime/error monitoring, alerting, structured log redaction, dependency scanning, CI/CD and rollback.
- [ ] Tune rate limits behind Render's proxy and complete penetration, authorization, accessibility and load testing.
- [ ] Publish a jurisdiction-appropriate privacy notice and retention/deletion workflow.
- [ ] Add real map/geocoding and authorized municipal integrations; do not imply current sample map pins are real or that reports notify a municipal authority.

The included code is a pilot candidate, not a guarantee of full production readiness or compliance. Security measures reduce common risks but do not replace external testing and operational controls.
