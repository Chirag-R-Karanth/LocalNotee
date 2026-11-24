# TROUBLESHOOTING (error -> only allowed fix)

| Error text contains | Cause | Allowed fix |
|---|---|---|
| `Unresolved reference: json` in a unit test | org.json is stubbed on JVM | Ensure `testImplementation("org.json:json:20240303")` exists (T003 adds it). Nothing else. |
| `Method ... not mocked` / `RuntimeException: Stub!` in a unit test | pure code imported `android.*` | Remove the `android.*` import from the pure class; use the injected interface (ARCHITECTURE 1). |
| `Unresolved reference` for an Android/Compose class | missing import | Add the import. If the class is not in any dependency already used, STOP. |
| `Unresolved reference: viewModel` / `hiltViewModel` / `navigation` | forbidden library | Do not add. Use AppState (D09). |
| `Unresolved reference` for an icon (e.g. `Icons.Default.Undo`, `ChevronLeft`, `Description`) | extended icons not available | Use the text glyphs in DECISIONS D30. |
| `Duplicate class` / `Execution failed for task ':app:mergeDebugResources'` after adding strings | duplicate string key | Remove the duplicate key; keys are unique per DESIGN_SPEC section 6. |
| `Only one page may be open at a time` / `IllegalStateException: Current page not closed` | PdfRenderer page leak | Wrap `openPage` in try/finally with `page.close()`; ensure single executor (API_CHEATSHEET B). |
| Black/transparent PDF page | bitmap not cleared | `bmp.eraseColor(Color.WHITE)` before render. |
| `OutOfMemoryError` while rendering | bitmap too large | Cap widthPx per ARCHITECTURE 6 (2 x view width). |
| `lint` error `MissingPermission`/`ExportedActivity` etc. on template code | baseline issue | STOP; human runs `updateLintBaseline`. |
| `Gradle sync failed`, `Could not resolve` | environment/network/version | STOP. Do not edit Gradle files. Report exact error. |
| Test hangs | waiting on executor | Use `flushBlocking()` in tests; no sleeps. |
| `renameTo` returns false | target dir mismatch | Ensure tmp and target are in the same directory (F). |
