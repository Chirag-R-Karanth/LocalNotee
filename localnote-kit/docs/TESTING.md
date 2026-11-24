# TESTING

## 1. Levels

| Level | Who runs | What | Command |
|---|---|---|---|
| L1 JVM unit tests | agent + human | pure logic (model, commands, input math, store on temp dirs) | `./gradlew :app:testDebugUnitTest` |
| L2 build + lint + manifest | agent + human | compiles, lint clean, no INTERNET | `bash tools/verify.sh` |
| L3 device checklist | HUMAN ONLY | anything with a screen, pen, PDF, process kill | checklists below |

The agent MUST NOT claim an L3 item passed. It only copies the checklist into its report.

## 2. Rules

1. Every pure-logic class has tests written in the same task that creates it.
2. Tests use `kotlin.test` or JUnit 4 assertions already available in the template (JUnit 4 is). Do not add test libraries other than the `org.json` line in DEPENDENCIES.
3. File-system tests use `java.nio.file.Files.createTempDirectory` and delete it afterwards.
4. Tests are deterministic: no sleeps, no randomness (inject ids and time where needed), no network.
5. Names are backtick sentences describing behavior.
6. A test is never modified to make it pass. See AGENT_RULES.
7. Coverage expectation per pure class: every public function has at least one normal-case test and one edge-case test (empty, single element, boundary).

## 3. Required test cases by component (the task files reference these)

**ProjectJson**: round trip of a project with a PDF page and a blank page; stroke points preserve all four fields; negative ARGB color survives; unknown page op ignored.
**ProjectStore**: create then load equals original; load replays journal ops; torn last line ignored; snapshot write leaves no `.tmp` behind; list returns newest first; corrupt `project.json` throws `ProjectCorruptException`.
**ProjectWriter / journal**: append then load replays ops; torn last line ignored; duplicate `add_stroke` ignored; compaction empties journal and load still returns same project; compaction every 50 ops.
**ViewTransform**: `screenToPage(pageToScreen(p)) == p`; zoomAround keeps focus point fixed; clamp centers small pages; clamp prevents gaps on large pages; zoom limits respected.
**StrokeBuilder**: decimation drops near points; first and last always kept; single tap yields 1-point stroke; pressure copied.
**EraserHitTest**: hit on segment interior; miss beyond radius; single-point stroke; width counted.
**Commands/UndoStack**: apply then inverse equals original project (for AddStroke and RemoveElements, including multi-element removal with indices); redo after undo; push clears redo; undo on empty returns false from `canUndo`.

## 4. Device checklists (HUMAN)

Run the listed ones after the matching task. Write results in the PR/commit message or PROGRESS LOG.

### After T005-T006 (import and library)
- H1: Tap + > Import PDF, choose a 10+ page PDF. A card appears with the right title and page count.
- H2: Kill the app from recents, reopen: the card is still there.
- H3: Long-press card > Delete > the card disappears.
- H4: Choose a non-PDF/corrupt file: Snackbar `Couldn't import that PDF.`, no crash.

### After T007-T009 (viewer)
- H5: Open the PDF: page 1 is visible, sharp, white background, fits width.
- H6: Pinch zoom: the point between your fingers stays put. Max zoom is reasonable, min stops at fit-to-width.
- H7: Drag with one finger pans. Page cannot be dragged out of sight.
- H8: Next/prev buttons work. Page indicator is correct. Go-to-page dialog jumps correctly. Page 1 prev is disabled; last page next is disabled.
- H9: Open a 300+ page PDF, flip 50 pages quickly: no crash, no blank page lasting more than 1 s.
- H10: Rotate the device: same page and zoom stay, no restart.

### After T011-T014 (ink)
- H11: With stylus, draw: ink appears under the tip, no visible lag.
- H12: Pressure changes line width (if the stylus supports it).
- H13: Finger never draws; finger pans and pinches.
- H14: Switch color and width: new strokes use them; old strokes unchanged.
- H15: Highlighter is translucent and does not hide text underneath.
- H16: Eraser removes whole strokes it touches, nothing else. Undo restores them in the original stacking order.
- H17: Undo/redo buttons enable/disable correctly. 20 undos then 20 redos returns the exact drawing.
- H18: Zoom in and draw: strokes land exactly where the pen is. Zoom out: they stay on the same page spot.

### After T015-T016 (persistence)
- H19: Draw 10 strokes, immediately run `adb shell am kill com.localnote.app`, reopen: all 10 strokes present.
- H20: Draw, press Home, reopen after a minute: intact.
- H21: Draw on page 1 and page 3, reopen: each stroke on the right page.
- H22: "Saved" label appears after drawing and fades.

## 5. Bug report template (human fills when a check fails)
```
Task: Txxx   Check: Hnn
Device/OS:
Steps:
Expected:
Actual:
logcat (adb logcat -s LocalNote):
```
Then edit the task file to remove the cause and retry.
