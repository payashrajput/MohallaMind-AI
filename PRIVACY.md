# Privacy notice template — customize before any pilot

This document is a template, not legal advice or a published notice. Before collecting real reports, the operator must identify itself and publish a jurisdiction-appropriate privacy notice and contact details.

MohallaMind may process incident descriptions, selected locations/wards, optional evidence images, submission times, status changes, audit events, and account email/name data. Photos and locations can reveal identities or sensitive patterns. Do not upload faces, vehicle plates, private interiors, children's images, or precise home locations unless necessary and lawfully justified.

The current production path stores account/incident/report metadata in PostgreSQL. Optional photos are re-encoded to JPEG by the server (which strips common EXIF metadata) and stored in a private Azure Blob container. Authorized reviewers/admins can request a short-lived, two-minute signed evidence URL. Do not log or share these URLs. The visual map remains illustrative and must not be treated as precise location data.

Before a pilot, the operator must define purpose and lawful basis, consent where required, service providers/subprocessors, retention periods, access/correction/deletion/export processes, a support contact, a security incident process, and a way to report accidental disclosure. Configure Azure/PostgreSQL retention and backups to match those policies. Account deletion, self-service export, and automated retention enforcement are not yet implemented.

Do not collect real resident data until this notice is reviewed, service settings are configured, access roles are approved, backups are tested, and security/legal review is complete. Use fictional or appropriately anonymized data during development and testing.
