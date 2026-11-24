# DESIGN SPEC: how it looks and feels

## 1. Feel (priorities in order)

1. Ink appears under the pen with no visible lag and never disappears.
2. The page never jumps: zoom keeps the point under the fingers fixed.
3. Nothing asks for confirmation except destructive actions (delete notebook, delete page).
4. Saving is invisible. There is no Save button in the editor. A small "Saved" label confirms.
5. Calm, paper-like, quiet. No gradients, no decorative animation.

## 2. Tokens

### Colors
| Token | Light | Dark |
|---|---|---|
| background | #FAFAF7 | #121214 |
| surface | #FFFFFF | #1C1C1F |
| onSurface | #1B1B1F | #E6E6EA |
| onSurfaceVariant | #5B5B63 | #A8A8B3 |
| primary | #3355FF | #8EA2FF |
| onPrimary | #FFFFFF | #0B1233 |
| error | #D32F2F | #FF8A80 |
| desk (editor backdrop) | #D9D9DE | #1C1C1F |
| pageShadow | #00000040 | #00000080 |
| toolbarSelected | primary at 16% alpha | primary at 24% alpha |

Page content is always white background (PDF pages render white; blank pages are white even in dark mode). Do not invert pages.

### Ink palette (8, in this order)
`#111111`, `#1E5BFF`, `#E53935`, `#2E9E5B`, `#FB8C00`, `#8E44AD`, `#6B7280`, `#FFD600`.
Default color: first. Default tool: pen.

### Widths (page points)
Pen presets: 1.5, 3, 6, 12. Default 3. Highlighter presets: 10, 14, 20, 28. Default 14. Highlighter alpha: 0.35 (applied at draw time to the color). Eraser radius: 6 pt (constant in Phase 2).

### Typography
Use `MaterialTheme.typography` defaults. No custom fonts.

### Spacing and shape
4 dp grid. Card radius 12 dp. Toolbar radius 28 dp. Minimum touch target 48 dp x 48 dp. Elevation: toolbar 6 dp, cards 1 dp.

### Icons and glyphs
Core Material icons only. Text glyphs where noted (DECISIONS D30): pen `✎`, highlighter `▮`, eraser `⌫`, undo `↶`, redo `↷`, prev `‹`, next `›`. Back arrow `Icons.AutoMirrored.Filled.ArrowBack`, add `Icons.Default.Add`. Library card art: the title's first letter, uppercase, on a `surfaceVariant` tile. Real icon art is a Phase 9 task.

## 3. Screens

### 3.1 Library
```
+--------------------------------------+
| LocalNote                       [ ⋮ ]|   top bar 56dp (title, overflow later)
+--------------------------------------+
| +--------+ +--------+                |   grid: 2 columns <600dp wide, 4 columns >=600dp
| | [icon] | | [icon] |                |   card: 3:4 area with PDF/notebook icon (no thumbnails yet)
| |        | |        |                |   under icon: title (1 line, ellipsis), "12 pages · 2 h ago"
| +--------+ +--------+                |
|                              ( + )   |   FAB bottom-right: opens menu "Import PDF" / "New notebook"
+--------------------------------------+
```
- Empty state: centered text `library_empty_title` and under it `library_empty_hint`.
- Tap card: open editor. Long-press: dialog `delete_title`/`delete_message` with buttons Cancel, Delete.
- Order: most recently updated first.

### 3.2 Editor
```
+--------------------------------------------+
| ←  Title…            ↶  ↷   3 / 120   ⋮   |  top bar 56dp
+--------------------------------------------+
|                                            |
|         ┌────────────────────┐             |  desk color; page centered with shadow
|         │       page         │             |
|         └────────────────────┘             |
|                                            |
|        ┌──────────────────────────┐        |  floating toolbar, bottom center, 12dp from bottom
|        │ ✎  ▮  ⌫  │ ● │ ━ │       │        |  pen, highlighter, eraser | color | width
|        └──────────────────────────┘        |
+--------------------------------------------+
|  ‹ prev                          next ›    |  (T009) small buttons at the left/right edge, vertically centered, 40dp circle, alpha 0.6
```
- Top bar items left to right: back arrow, title (1 line), undo, redo, page indicator, overflow (empty placeholder in Phase 2: not shown).
- Undo/redo icons are disabled (alpha 0.38) when unavailable.
- Page indicator text `3 / 120`; tap opens "Go to page" dialog (number field, OK/Cancel).
- Toolbar: pill, surface color, elevation 6 dp. Selected tool has `toolbarSelected` background circle 40 dp. Color item shows a 24 dp filled circle in the current color; tap opens a popup row of the 8 colors (selected one gets a 2 dp primary ring). Width item shows a horizontal line sample at current width; tap opens a popup row of 4 presets.
- Popups close on selection or outside tap. Popup animation: none (instant).
- "Saved" label: small text in the top bar under the title (labelSmall, onSurfaceVariant). Appears when a journal flush completes, fades out after 2 s (alpha animation 300 ms).

### 3.3 Dialogs and messages
Material 3 `AlertDialog`, `Snackbar` at the bottom above the toolbar. Errors use the Snackbar, never a dialog.

## 4. Motion
- Tool selection highlight: 120 ms fade.
- Popups: none. Page flip: none (instant swap). Everything else: none.
- Zoom and pan follow the fingers 1:1, no inertia in Phase 1-2.

## 5. Ink feel
- Pen: round caps and joins, color as chosen, width per D25.
- Highlighter: width fixed (no pressure), alpha 0.35, round caps, drawn above the page, below nothing else.
- Eraser: no visible cursor in Phase 2.
- Stylus hovering shows nothing.

## 6. Strings (put in `res/values/strings.xml`; keys exact)

| key | text |
|---|---|
| app_name | LocalNote |
| library_title | LocalNote |
| library_empty_title | No notebooks yet |
| library_empty_hint | Import a PDF or start a new notebook. |
| action_import_pdf | Import PDF |
| action_new_notebook | New notebook |
| default_notebook_title | Untitled notebook |
| pages_count | plurals: one `%1$d page`, other `%1$d pages` |
| page_indicator | %1$d / %2$d |
| goto_page_title | Go to page |
| goto_page_hint | Page number |
| action_ok | OK |
| action_cancel | Cancel |
| action_delete | Delete |
| delete_title | Delete notebook? |
| delete_message | This permanently deletes "%1$s" from this device. |
| tool_pen | Pen |
| tool_highlighter | Highlighter |
| tool_eraser | Eraser |
| action_undo | Undo |
| action_redo | Redo |
| status_saved | Saved |
| error_import_failed | Couldn't import that PDF. |
| error_open_failed | Couldn't open this notebook. |
| error_save_failed | Couldn't save changes. |
| error_render_failed | Couldn't draw this page. |
