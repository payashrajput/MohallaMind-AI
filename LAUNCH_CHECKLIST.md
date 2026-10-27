# Launch checklist

## Before staging deployment
- [ ] Use a managed PostgreSQL database with TLS; confirm `pgcrypto` and `pg_trgm` are available.
- [ ] Configure unique `JWT_SECRET` and `REFRESH_TOKEN_PEPPER` in Render secret settings.
- [ ] Set exact HTTPS `CORS_ORIGINS` and keep `ALLOW_ADMIN_BOOTSTRAP=false` except during one-time admin setup.
- [ ] Configure Azure Blob Storage account/container and private access; verify no anonymous blob access is possible.
- [ ] Run `npm run db:migrate`; verify `/api/health` reports PostgreSQL connected and Azure evidence storage configured.
- [ ] Register/promote one admin, then immediately disable/remove bootstrap configuration.
- [ ] Test registration, login, sign out, resident report submission, invalid input, rate limiting and role restrictions.
- [ ] Test photo upload with valid images, spoofed MIME types, oversized files and malformed images; verify metadata is stripped and SAS links expire.
- [ ] Test reviewer updates, audit history, duplicate suggestions and rollback behavior.
- [ ] Configure managed DB backups/PITR and complete a restore drill.
- [ ] Configure log/uptime monitoring, alerts, dependency scanning and rollback process.

## Before public launch (not complete in this package)
- [ ] Email verification, password reset, session revocation and account deletion/export.
- [ ] Formal privacy notice, consent, data retention/deletion, support and incident response.
- [ ] Malware scanning, least-privilege cloud identity, key rotation and retention policy.
- [ ] Real geocoding/map provider and actual municipal workflow/notification integration.
- [ ] Unit, PostgreSQL integration, Azure storage integration and browser end-to-end tests in CI.
- [ ] Accessibility, load, penetration and independent security review.
- [ ] Validate the rules on representative, anonymized local reports with human reviewers.

Do not publicly market this as a fully mature AI product or claim it automatically sends reports to authorities. It is currently a transparent rules-based civic incident workflow.
