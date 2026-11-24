# HOW TO BUILD (for the human)

The agent never creates the project and never picks versions. You do that once, below.

## Part A: one-time setup

1. Install the latest stable **Android Studio**.
2. File > New > New Project > **Empty Activity** (the Compose one).
   - Name: `LocalNote`
   - Package name: `com.localnote.app`
   - Save location: your repo folder
   - Minimum SDK: **API 26**
   - Build configuration language: **Kotlin DSL**
3. Wait for Gradle sync to finish with no errors.
4. Phone/tablet: Settings > About > tap Build number 7 times > Developer options > enable **USB debugging**. Plug in. Accept the RSA prompt.
5. In a terminal: `adb devices` must list your device as `device`.
6. Press the green Run button. You must see the template's "Hello Android" on the device. If not, fix this first. Nothing else matters until this works.
7. `git init` (if not already), confirm `.gitignore` contains `build/`, `.gradle/`, `local.properties`, `.idea/`. Commit: `baseline`.
8. Copy the contents of this kit into the repo root (so `docs/`, `tasks/`, `tools/`, `PROGRESS.md` sit next to `app/` and `gradlew`).
9. `chmod +x tools/*.sh`
10. Run `bash tools/verify.sh`. It must end with `VERIFY: PASS`.
    - If lint fails on the untouched template: run `./gradlew :app:updateLintBaseline`, then run verify again.
11. `git add -A && git commit -m "kit" && git tag baseline`.

## Part B: every agent session

1. Open `PROGRESS.md`. Find `CURRENT TASK`.
2. Start a **new** opencode session in the repo root. One session = one task. Never reuse a session; long context makes agents sloppy.
3. Use the strongest model your opencode setup offers.
4. Paste the entire contents of `docs/MASTER_PROMPT.md`. Send nothing else.
5. Wait. The agent must end with a report in the exact format from `docs/AGENT_RULES.md`.
6. Review:
   - `git log -1 --stat` : only the files listed in the task changed?
   - `bash tools/verify.sh` : PASS?
   - Run the task's **HUMAN CHECK** on your device.
7. Pass: set the task to DONE in `PROGRESS.md`, set CURRENT TASK to the next ID, commit.
   Fail: `git reset --hard HEAD~1`. Edit the task file to remove the ambiguity that caused the failure. Retry in a new session.

**Rule: if the agent misbehaves, fix the document, not the agent.**

## Part C: commands

```
bash tools/verify.sh                       # full check
./gradlew :app:assembleDebug               # build only
./gradlew :app:testDebugUnitTest           # unit tests only
./gradlew :app:installDebug                # install on device
adb logcat -s LocalNote                    # app log lines (tag: LocalNote)
adb shell am kill com.localnote.app        # simulate process death
```

## Part D: before each new phase

Later-phase task files are written just in time because they depend on real code. Before starting a phase with no task files: copy the output of `git ls-files` and the phase section of `docs/IMPLEMENTATION_PLAN.md` to Claude and ask it to generate tasks using `docs/TASK_TEMPLATE.md`.
