# IMPLEMENTATION PLAN

Tasks are small on purpose: one session each, roughly 100-300 lines of change. Order is fixed. The human may not reorder.

## Phase 1: Open and view PDFs (T001-T009)
| Task | Output |
|---|---|
| T001 | Baseline verified, manifest settings (D06, D07) |
| T002 | Theme, strings, constants, AppState, empty Library/Editor screens |
| T003 | Model classes + `ProjectJson` + tests |
| T004 | `ProjectStore` (incl. journal replay on load) + tests |
| T005 | `PdfImporter` + `Services` |
| T006 | Library screen (list, import, new notebook, delete) |
| T007 | `PageRenderer` (PDF + blank templates) |
| T008 | `ViewTransform` + `PageCanvasView` with pan/zoom |
| T009 | Editor screen, page navigation |
Exit: checklist H1-H10 passes.

## Phase 2: Ink with persistence (T010-T016)
| Task | Output |
|---|---|
| T010 | `StrokeRenderer` |
| T011 | `StrokeBuilder` + live capture (stylus/mouse draw, finger pans) |
| T012 | Tool state + floating toolbar (colors, widths) |
| T013 | Commands, `UndoStack`, `insert_elements` op |
| T014 | Eraser + undo/redo buttons |
| T015 | `ProjectWriter`, journaling, recovery |
| T016 | Autosave on stop, "Saved" label, save-error Snackbar |
Exit: H11-H22 pass.

## Phase 3: Input quality (tasks written later)
Palm rejection (`PalmFilter` pure + trace-based tests), "finger draws" toggle, stylus-eraser-button support. Exit: 20 recorded sessions with resting palm yield zero stray strokes; human checklist.

## Phase 4: Pages
Blank templates (plain/ruled/dot/graph), page grid with thumbnails, add/duplicate/reorder/delete as commands with undo. Exit: reorder + delete then reopen keeps ink on the right pages.

## Phase 5: Text and images
Select tool with handles, TextBox (rich spans, bullets, checkboxes), image import via Photo Picker, assets dir, crop/rotate. Exit: mixed page persists, undoes, exports.

## Phase 6: Smart ink
Shape snapping (hold ~400 ms; circle, ellipse, rectangle, triangle, line, arrow; optional fill), scratch-to-erase, study tape. Exit: measured on recorded gesture sets; undo reverts a snap to the raw stroke.

## Phase 7: Export into PDF
Standard annotations + private data stream, page ops, temp-verify-copy, flattened export. Human supplies PDF library version. Exit: opens correctly in Adobe/Chrome/another viewer; re-open in LocalNote restores editable objects; 50 save cycles never corrupt the file.

## Phase 8: Library extras
Tags, search over titles and text boxes, quick checklist note, thumbnails.

## Phase 9: Polish and performance
Committed-stroke bitmap cache, continuous scroll (optional), settings, accessibility, benchmarks, license audit, release build.

## Task expansion rule
Phase 3+ tasks are written by the human with Claude right before the phase starts (HOW_TO_BUILD Part D), because they depend on the real code. Every generated task must follow TASK_TEMPLATE.md.
