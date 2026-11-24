# DECISIONS (locked)

Every row is final. The agent must not reopen any of them. A human changes a row only by editing this file.

## Platform and build

| ID | Decision |
|---|---|
| D01 | Language Kotlin. UI Jetpack Compose + Material 3, except the page canvas (D10). |
| D02 | Single Gradle module `:app`. Package root `com.localnote.app`. No feature modules. |
| D03 | minSdk, compileSdk, targetSdk, AGP, Kotlin, Compose BOM versions: whatever the baseline template has. Never change them. |
| D04 | No DI framework, no Room, no Navigation library, no kotlinx.serialization, no Coil, no Hilt, no androidx.ink in Phases 1-6. |
| D05 | No INTERNET permission, ever. `tools/check_no_internet.sh` enforces it. |
| D06 | `android:allowBackup="false"`. |
| D07 | Activity handles config changes itself: `android:configChanges="orientation|screenSize|screenLayout|smallestScreenSize|keyboardHidden|uiMode"`. The Activity is never recreated on rotation. |
| D08 | Orientation: unlocked. |

## Architecture

| ID | Decision |
|---|---|
| D09 | State holders are plain Kotlin classes using Compose `mutableStateOf`, held in `AppState` created in `LocalNoteApp : Application` and accessed via `(application as LocalNoteApp).appState`. No ViewModel library. |
| D10 | The page canvas is a custom Android `View` (`PageCanvasView`) embedded with `AndroidView`. Reason: raw `MotionEvent` access (tool type, pressure, cancel flags). |
| D11 | MVP editor shows ONE page at a time with prev/next navigation. Continuous scroll is out of scope. |
| D12 | PDF rendering: `android.graphics.pdf.PdfRenderer`. One page open at a time, accessed only from one single-thread executor. |
| D13 | On PDF import, the file is COPIED to `projects/<id>/source.pdf` in app-private storage. The original URI is not retained in Phases 1-6. |
| D14 | Serialization: `org.json` (Android built-in). JVM tests use `testImplementation("org.json:json:20240303")`. |
| D15 | Coordinates: PDF points (1 pt = 1/72 inch), origin top-left of the page, x right, y down. Stored coordinates are NEVER screen pixels. |
| D16 | All IDs are `UUID.randomUUID().toString()`. |
| D17 | Models are immutable Kotlin `data class`es. Edits produce copies. |
| D18 | Every project mutation is a `Command`. Undo/redo stacks are in memory only (cleared when a project is closed). |
| D19 | Every state change, including undo and redo, is journaled as a FORWARD op (`add_stroke` or `remove_elements` in Phase 2). Ops are idempotent. |
| D20 | Disk I/O only on `Services.io` or the `ProjectWriter`/`PageRenderer` executors. Never on main (sole exception: `flushBlocking` in `saveNow` and `shutdown`). App logic uses executors + `Handler`, NOT coroutines. The only coroutine use allowed is `rememberCoroutineScope` for Snackbars and `LaunchedEffect`. |
| D21 | Errors never crash the app. Show a Snackbar with the text from DESIGN_SPEC strings and log with `Log.e`. |
| D22 | Blank page default size 595 x 842 pt (A4). |
| D23 | Zoom limits: min = fit-to-width scale, max = 8 x fit-to-width scale. |
| D24 | Input mapping (Phase 2): `TOOL_TYPE_STYLUS` and `TOOL_TYPE_MOUSE` draw/erase. `TOOL_TYPE_FINGER` pans (1 finger) and pinch-zooms (2 fingers). The "finger draws" toggle arrives in Phase 3. |
| D25 | Pressure to width: `width = baseWidth * (0.4 + 0.6 * pressure)`. If the device reports pressure of exactly 1.0 for every event, that yields constant width. Correct. |
| D26 | Stroke smoothing: none at capture; renderer draws segment by segment with round caps. |
| D27 | Point decimation: drop a point if it is closer than 0.5 pt (page space) to the previous kept point. Always keep the first and last point. |
| D28 | Compaction (snapshot rewrite + journal truncate): every 50 journaled ops, on `onStop`, and when closing a project. |
| D29 | PDF export design (Phase 7, not before): working state stays in app storage. Export writes a temp file, verifies, then copies to the user-chosen destination. Standard PDF annotations plus a private data stream. |

| D30 | Icons: only icons from `androidx.compose.material.icons` CORE set (e.g. `Icons.Default.Add`, `Icons.AutoMirrored.Filled.ArrowBack`). No `material-icons-extended` dependency. Where no core icon exists use these text glyphs: pen `✎`, highlighter `▮`, eraser `⌫`, undo `↶`, redo `↷`, prev `‹`, next `›`. |

## Code style

- Files: one top-level public class per file, file named after it.
- Classes `PascalCase`, functions/properties `camelCase`, constants `SCREAMING_SNAKE_CASE`, packages lowercase.
- Max function length ~40 lines. Max file ~300 lines. If a task needs more, STOP.
- 4-space indent, no wildcard imports, no unused imports.
- Log tag is always the constant `LocalNote`.
- Strings shown to users go in `res/values/strings.xml`; keys listed in DESIGN_SPEC.
- Test classes: `<ClassName>Test` in the same package under `app/src/test/java/...`. Test names: backtick sentences, e.g. `` `erase removes only intersected strokes` ``.
