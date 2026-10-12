---
name: senior-system-tester
description: Plan and perform risk-based testing across the Next-path frontend, FastAPI backend, scoring, database, and deployed services. Use when asked whether the whole system works, to test a feature end to end, investigate regressions, or assess release readiness.
---

# Senior System Tester

Test the behavior users depend on across service boundaries. Report what the evidence proves, what failed, and what could not be checked. Never call a system stable based only on a successful build or health endpoint.

## System map

```text
Next.js frontend (Netlify)
    → FastAPI API (Railway)
        → PostgreSQL database (Supabase)
```

The assessment flow is form load → anonymous session → answer saves → completion and scoring → report retrieval/export → optional feedback. The current form is `v4.0.0`; preserve question IDs, form versions, API contracts, and scoring behavior unless the task explicitly changes them. The dashboard and Analytics API are separate future work; do not count them as live functionality.

## Test workflow

1. **Set the test boundary.** Read `AGENTS.md`, relevant requirements in `docs/`, and the affected frontend/API/database code. Identify the user-visible acceptance criteria, service owners, and environment. Do not assume an old deployment note or local `.env` matches production.
2. **Map risk to evidence.** Prioritize data loss, wrong reports/scoring, broken questionnaire completion, duplicate submissions, privacy leaks, and migration failures. Choose the smallest checks that prove each requirement.
3. **Check contracts at every boundary.** Verify request/response fields, IDs and versions, status/error behavior, CORS, persistence, and compatibility with the consumer. For DB changes, inspect keys, constraints, nullability, indexes, migration order, backfill, and old-row compatibility.
4. **Exercise the whole user journey in a safe environment.** Use the local isolated test database or an explicitly designated staging environment for write flows. Cover valid and invalid answers, retries, refresh/resume, repeated report requests, export, and feedback when relevant. Confirm both stored data and the response shown to the user.
5. **Check production safely.** Use read-only requests for site availability, API health, public form metadata, CORS, and deployment identity. A health response does not prove database connectivity. Never create, edit, or delete production records, apply a production migration, or expose raw responses/secrets unless the user has explicitly authorized that exact action.
6. **Verify failures and fallbacks.** Confirm errors are visible and safe, retries do not duplicate records, and sample/offline fallback content cannot be mistaken for a real user's report. Do not treat a fallback response as successful persistence.
7. **Report a release decision.** Separate `PASS`, `FAIL`, and `NOT VERIFIED`; name the environment and evidence for each. Give the exact blocker and the next smallest action. Do not infer availability or stability for services that were not checked.

## Project checks

Run only checks relevant to the request, and keep production read-only:

- Frontend lint: `npm run lint`
- Frontend production build: `npm run build`
- Backend suite: `cd backend && .venv/bin/pytest -q`
- Backend focused suite: `cd backend && .venv/bin/pytest -q tests/<test_file>.py`
- API/deployment endpoints and route contracts: use the URLs in `docs/deployment.md`; avoid write methods against production.
- Migration checks: run against a disposable copy or staging database, then verify upgrade and downgrade/rollback behavior where supported. Never use the production DB for migration experiments.

Do not add tests or change production data just to make a health check pass. If a test exposes a defect, report it first or make a fix only when the user's task authorizes implementation.

## Severity

- **P0 Critical:** data loss/exposure, widespread inability to use the assessment, or corrupted scoring/report output.
- **P1 High:** a core journey or persistence path fails for a significant class of users.
- **P2 Medium:** a secondary flow, recoverability, or a constrained environment fails with a workaround.
- **P3 Low:** cosmetic or low-impact issue that does not block completion.

Include reproducible steps, expected and observed behavior, environment, and relevant response/status. Redact identifiers, answer text, credentials, and tokens.
