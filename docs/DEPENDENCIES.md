# DEPENDENCIES

## Rules
1. The agent NEVER chooses versions. Versions come from the baseline template or from this file.
2. Only the lines marked ALLOWED below may be added, and only in the task that names them.
3. Anything else: STOP with BLOCKED.

## Phase 1-2 allowed additions

| Where | Line | Task |
|---|---|---|
| `app/build.gradle.kts` dependencies | `testImplementation("org.json:json:20240303")` | T003 |

Everything else (Compose, Material 3, activity-compose, lifecycle, JUnit 4) already exists in the baseline template. Do not add `material-icons-extended` (D30) or coroutines libraries (D20).

## Later phases (human supplies versions at that time)
- Phase 7 PDF writing: a PDF library (candidates: PdfBox-Android). Human verifies license, maintenance, and version; task file will contain the exact line.
- Phase 8 search: none planned (plain SQL via `android.database.sqlite` or in-memory index).
- Never: AGPL libraries (e.g. MuPDF), networking libraries, analytics.

## If a version problem appears
Do not "fix" by bumping versions. STOP and report the exact Gradle error. The human resolves it.
