# ARCHITECTURE

Sections are numbered. Task files cite them (e.g. "read ARCHITECTURE section 3").

## 1. Package layout (all under `com.localnote.app`)

```
LocalNoteApp.kt              Application; owns AppState
MainActivity.kt              single Activity, sets Compose content
AppState.kt                  top-level state holder + Screen navigation
Services.kt                  logger, ProjectStore, PdfImporter, shared io executor
Constants.kt                 shared constants
model/                       PURE Kotlin. No android.* imports.
  Ids.kt  InkPoint.kt  Element.kt  Page.kt  Project.kt  Template.kt
  ProjectJson.kt             JSON encode/decode (org.json)
command/                     PURE Kotlin
  Command.kt  AddStroke.kt  RemoveElements.kt  InsertElements.kt  UndoStack.kt  (journal ops live in ProjectJson.kt)
input/                       PURE Kotlin
  StrokeConfig.kt  StrokeBuilder.kt  EraserHitTest.kt  (Phase 3: PalmFilter.kt)
store/
  Logger.kt  FileUtil.kt
  ProjectStore.kt            filesystem layout, snapshot, list (takes root File; JVM testable)
  ProjectWriter.kt           single-thread journal appender + compaction (JVM testable)
  PdfImporter.kt             Android: ContentResolver copy + PdfRenderer info
render/
  PageRenderer.kt            Android: PdfRenderer + blank templates -> Bitmap, LRU cache
  StrokeRenderer.kt          Android: draws Stroke on Canvas
ui/
  theme/ Color.kt Theme.kt Type.kt
  library/ LibraryScreen.kt
  editor/
    EditorScreen.kt          Compose: top bar, toolbar, hosts canvas
  EditorToolbar.kt  Tool.kt
    EditorState.kt           Compose state: project, pageIndex, tool, color, width, undo
    PageCanvasView.kt        custom View
    ViewTransform.kt         PURE zoom/pan math
```

Rule: files in `model/`, `command/`, `input/`, `ui/editor/ViewTransform.kt`, `store/ProjectStore.kt`, `store/ProjectWriter.kt` MUST NOT import `android.*` (except `store/*` may use `android.util.Log` via an injected `Logger` interface instead; use `fun interface Logger { fun e(msg: String, t: Throwable?) }`).

## 2. Data model (copy exactly)

```kotlin
package com.localnote.app.model

/** One sampled pen point in page space (PDF points). */
data class InkPoint(val x: Float, val y: Float, val pressure: Float, val tMs: Long)

enum class Template { PLAIN, RULED, DOT, GRAPH }

sealed interface PageKind {
    val widthPt: Float
    val heightPt: Float
    data class Pdf(val sourceIndex: Int, override val widthPt: Float, override val heightPt: Float) : PageKind
    data class Blank(val template: Template, override val widthPt: Float, override val heightPt: Float) : PageKind
}

sealed interface Element { val id: String }

data class Stroke(
    override val id: String,
    val points: List<InkPoint>,
    val colorArgb: Int,
    val widthPt: Float,
    val isHighlighter: Boolean,
) : Element

data class Page(val id: String, val kind: PageKind, val elements: List<Element>)

data class Project(
    val id: String,
    val title: String,
    val createdAt: Long,
    val updatedAt: Long,
    val hasSourcePdf: Boolean,
    val pages: List<Page>,
)
```

Later phases add `Shape`, `TextBox`, `ImageElement`, `StudyTape` to `Element`. Do not add them early.

## 3. Disk layout and formats

Root: `context.filesDir/projects/`.

```
projects/<projectId>/
  meta.json          {"id","title","pageCount","updatedAt"}     small, for Library
  project.json       snapshot (below)
  journal.jsonl      one JSON op per line, appended
  source.pdf         present only if hasSourcePdf
  assets/            images (Phase 5)
```

### project.json
```json
{"v":1,"id":"..","title":"..","createdAt":0,"updatedAt":0,"hasSourcePdf":true,
 "pages":[
  {"id":"..","kind":{"type":"pdf","sourceIndex":0,"w":595.0,"h":842.0},
   "elements":[
    {"type":"stroke","id":"..","color":-16777216,"width":3.0,"hl":false,
     "pts":[[x,y,pressure,tMs],[x,y,pressure,tMs]]}]},
  {"id":"..","kind":{"type":"blank","template":"PLAIN","w":595.0,"h":842.0},"elements":[]}
 ]}
```
Point arrays are `[x, y, pressure, tMs]`. Floats are written as JSON doubles. Reading: `getDouble(..).toFloat()`.

### journal.jsonl ops
```json
{"op":"add_stroke","page":"<pageId>","stroke":{ ...same as element JSON... }}
{"op":"remove_elements","page":"<pageId>","ids":["<id>","<id>"]}
{"op":"insert_elements","page":"<pageId>","items":[{"i":3,"e":{ ...element json... }}]}
```
Idempotence rules (needed for crash safety):
- `add_stroke`: if a stroke with that id already exists on that page, do nothing.
- `remove_elements`: ids that do not exist are ignored.
- `insert_elements`: items whose id already exists are skipped; each item is inserted ascending by index at `index.coerceAtMost(size)`.
- Ops for an unknown page id are ignored.

### Atomic snapshot write
1. Write bytes to `project.json.tmp`, `fd.sync()`.
2. `renameTo(project.json)`; if it returns false: log and throw `IOException`.
3. Only after success: truncate `journal.jsonl` to 0 bytes.
4. Rewrite `meta.json` the same way.

### Load (recovery)
1. Parse `project.json` (if missing or invalid: throw `ProjectCorruptException`).
2. Read `journal.jsonl` line by line. Apply each valid line. A line that fails to parse is skipped; if it is the LAST line it is a torn write, ignore silently; if it is not last, log an error and skip.
3. Return the resulting Project. (Compaction happens later per D28.)

## 4. Commands and undo (pure Kotlin)

```kotlin
interface Command {
    /** Returns the new project after applying. */
    fun apply(p: Project): Project
    /** [before] = project state BEFORE apply. Returns the command that exactly reverses this one. */
    fun inverse(before: Project): Command
    /** Journal op for this command (forward op). */
    fun toJournalJson(): String
}
class AddStroke(val pageId: String, val stroke: Stroke) : Command
class RemoveElements(val pageId: String, val removed: List<Pair<Int, Element>>) : Command
class InsertElements(val pageId: String, val items: List<Pair<Int, Element>>) : Command
// (index, element) pairs refer to positions in page.elements.
// inverse(AddStroke) = RemoveElements(listOf(before.size to stroke)); inverse(RemoveElements) = InsertElements(sorted asc); inverse(InsertElements) = RemoveElements.

class UndoStack {
    fun push(cmd: Command, before: Project)   // stores (cmd, cmd.inverse(before)); clears redo
    fun canUndo(): Boolean
    fun canRedo(): Boolean
    fun undo(p: Project): Pair<Project, Command>   // returns new project and the FORWARD command that was journaled (the inverse)
    fun redo(p: Project): Pair<Project, Command>
}
```
Journaling rule (D19): when undo/redo runs, the command to journal is the one actually applied (the inverse for undo, the original for redo).

## 5. Threading

- Main thread: UI, MotionEvent handling, drawing.
- `ProjectWriter`: one `Executors.newSingleThreadExecutor()`. Methods: `append(opJson: String)`, `compact(project: Project)`, `flushBlocking()` (waits for queued work; used by tests and onStop).
- `PageRenderer`: one `Executors.newSingleThreadExecutor()` for all PdfRenderer access; results delivered to main via `Handler(Looper.getMainLooper())` or coroutine `withContext`.
- No coroutines for app logic (D20). `Services.io` is the shared single-thread executor for library/editor loading and import.

## 6. Rendering pipeline (editor)

Layers drawn by `PageCanvasView.onDraw`, bottom to top:
1. Desk color fill (DESIGN_SPEC).
2. Page shadow rect.
3. Page bitmap (from `PageRenderer`), drawn into the rect `pageToScreen(0,0)..pageToScreen(w,h)`.
4. Committed strokes of the current page (`StrokeRenderer`).
5. Live (in-progress) stroke.

Bitmap resolution: request `widthPx = round(pageWidthPt * transform.scale)` capped at 2 x view width, minimum 1. While a new bitmap loads, keep drawing the old bitmap scaled to the current rect (no flicker, no blank).

## 7. Coordinate math (ViewTransform)

`scale` = screen px per page point. `screen = page * scale + t`.
- `fitWidth(viewW, pageW)` -> scale = viewW / pageW, tx = 0, ty = 0 (top aligned).
- `zoomAround(fx, fy, factor, minScale, maxScale)`: newScale = clamp(scale*factor); keep the page point under (fx,fy) fixed.
- `panBy(dx,dy)`: t += (dx,dy).
- `clamped(viewW, viewH, pageW, pageH)`: for each axis, let size = pageSize*scale. If size <= viewSize: center (t = (view-size)/2). Else clamp t to [view-size, 0].
- `screenToPage` / `pageToScreen` are exact inverses (tests required).

## 8. Stroke capture (Phase 2)

`StrokeBuilder` (pure):
```kotlin
class StrokeBuilder(private val colorArgb: Int, private val widthPt: Float, private val isHighlighter: Boolean, private val minDistPt: Float = 0.5f) {
    fun begin(x: Float, y: Float, pressure: Float, tMs: Long)
    fun add(x: Float, y: Float, pressure: Float, tMs: Long)   // applies decimation (D27)
    fun end(x: Float, y: Float, pressure: Float, tMs: Long): Stroke?  // always keeps final point; returns null if fewer than 1 point
    fun snapshotPoints(): List<InkPoint>   // for live rendering
}
```
Coordinates passed in are PAGE space (the view converts using `screenToPage` first). Include `MotionEvent` historical points (`getHistoricalX/Y/Pressure/EventTime`) before the current point.

## 9. Eraser (Phase 2)

`EraserHitTest.hit(stroke, x, y, radiusPt): Boolean` true if any segment of the stroke polyline is within `radiusPt + stroke.widthPt/2` of (x,y). Use point-to-segment distance. A stroke with a single point is a segment of length 0.
Eraser radius default 6 pt. One eraser gesture (down..up) produces ONE `RemoveElements` command containing all strokes hit during the gesture. Erased strokes disappear from view immediately during the gesture (preview) but the command is applied at gesture end.

## 10. Later phases (not specified yet, do not implement)

Palm rejection, page management, text boxes, images, shapes, scratch-to-erase, study tape, PDF export, search. See IMPLEMENTATION_PLAN.md.
