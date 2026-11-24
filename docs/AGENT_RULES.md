# AGENT RULES

You are an executor. A human and these documents make every decision. Your value is precision, not creativity.

## 1. The five iron laws

1. **Do only the current task.** Nothing before it, nothing after it, nothing "while I'm here".
2. **Touch only listed files.** The task's FILES section is a whitelist. A file not listed is forbidden, including Gradle files, manifests, and docs, unless the task says so.
3. **Never guess.** If a name, signature, behavior, path, version, or API is not written in the task, `docs/ARCHITECTURE.md`, or `docs/API_CHEATSHEET.md`, STOP with `BLOCKED: <question>`.
4. **No claim without evidence.** "Done", "works", and "passes" are allowed only with pasted command output.
5. **When stuck, stop.** Looping on failures is the worst outcome. Follow the failure protocol.

## 2. Forbidden actions

- Adding, removing, or changing any dependency, plugin, or version (exception: the exact lines a task tells you to add).
- Editing `build.gradle.kts`, `settings.gradle.kts`, `libs.versions.toml`, `gradle.properties`, `AndroidManifest.xml` unless the task lists that file and the exact change.
- Adding the `INTERNET` permission, or any networking, analytics, or crash-reporting library.
- Refactoring, renaming, reformatting, or reorganizing existing code not named in the task.
- Creating files or packages not listed in the task.
- Deleting, skipping, or weakening a test. No `@Ignore`. No loosened assertions. No `@Suppress` to silence warnings. No disabling lint.
- Stubs that pretend to work (`return true`, empty bodies, hardcoded results) unless the task explicitly says `STUB`.
- Using any Android or Kotlin API whose exact signature you are not certain of. Use `docs/API_CHEATSHEET.md` patterns. If not covered and not already used in the repo, STOP.
- Network access other than what Gradle needs to build.
- `git push`, `git push --force`, `git rebase`, branch creation, amending previous commits.
- Running destructive commands outside the repo.

## 3. Code rules

- Language: Kotlin. Style and naming: `docs/DECISIONS.md` section "Code style".
- Pure logic goes in files that import nothing from `android.*`. Those files must have JVM unit tests.
- Every public class and function gets a one-line KDoc.
- Never swallow exceptions silently. Catch, log with `Log.e("LocalNote", msg, e)` (or the injected logger in pure code), and surface per DECISIONS.
- Never block the main thread with file or PDF work.
- No magic numbers. Constants live in `Constants.kt` (create/extend only if the task lists it).

## 4. Failure protocol

When `bash tools/verify.sh` prints `VERIFY: FAIL`:

1. Read the FIRST error message only (not the cascade).
2. Search `docs/TROUBLESHOOTING.md` for the error text. If a matching entry exists, apply only its listed fix.
3. If no entry matches, fix the error using only files on the task whitelist.
4. Re-run verify. You get **3 fix attempts total**.
5. After 3 failed attempts: run `git checkout -- . && git clean -fd` (reverts uncommitted work), then print the report with `STATUS: BLOCKED` including the first error and what you tried. STOP.

A failing test is never fixed by changing the test to match wrong behavior. Fix the code, unless the task text itself contradicts the test; then STOP and report the contradiction.

## 5. PROGRESS.md update

On finishing, edit only these lines in `PROGRESS.md`:
- In the task table: set the current task's status to `AWAITING HUMAN`.
- Append one line to `LOG`: `YYYY-MM-DD Txxx implemented, verify PASS`.
Do not touch CURRENT TASK. Do not mark DONE. Only the human does.

## 6. Final report format (print exactly this, fill in)

```
REPORT
TASK: Txxx <title>
STATUS: COMPLETE | BLOCKED
FILES CHANGED:
- path (created|modified)
TESTS ADDED:
- ClassName.testName
VERIFY OUTPUT (last 30 lines):
<paste>
HUMAN CHECK TO RUN:
<copy from task file>
DEVIATIONS FROM TASK: none | <list each, with reason>
BLOCKERS/QUESTIONS: none | <list>
```

If DEVIATIONS is not "none", you violated law 1 or 2 and must explain why. The human will probably reject it.
