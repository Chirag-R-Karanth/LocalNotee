# Phase 1 — Open and view PDFs

Status: IN PROGRESS
Tasks: T001–T009
Plan reference: `docs/IMPLEMENTATION_PLAN.md` (Phase 1)

## Completed

### T001 — Baseline checks and manifest settings

- Status: AWAITING HUMAN (agent)
- Commit: `243ab5d` T001: Baseline checks and manifest settings
- Baseline commit: `b35b247` baseline: scaffold Android project and agent kit

Files changed:
- `app/src/main/AndroidManifest.xml` (modified)
- `PROGRESS.md` (modified)

Change summary:
- `<application android:allowBackup="false">`
- `<activity android:name=".MainActivity">` now declares
  `android:configChanges="orientation|screenSize|screenLayout|smallestScreenSize|keyboardHidden|uiMode"`
- No `uses-permission` element added.

Verification:
```
== merged manifest check ==
no-internet check: OK
BUILD SUCCESSFUL
VERIFY: PASS
```

Environment/versions:
- agp=8.13.2
- kotlin=2.3.21
- composeBom=2025.12.01
- minSdk=26, compileSdk=36, targetSdk=36
- Gradle 8.13

Human check pending:
- Install and open the app: template screen shows.
- Rotate the device: screen stays, no restart.

## Remaining

- T002 Theme, strings, constants, app shell
- T003 Domain model and JSON codec
- T004 ProjectStore
- T005 PDF import
- T006 Library screen
- T007 Page renderer
- T008 ViewTransform and PageCanvasView
- T009 Editor screen and page navigation

Exit criterion: checklist H1–H10 passes.
