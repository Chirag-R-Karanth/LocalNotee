# API CHEATSHEET (known-good patterns)

Use these patterns verbatim. If you need an API that is neither here nor already used in the repo, STOP with BLOCKED.

## A. Pick a PDF (Storage Access Framework)
```kotlin
val picker = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocument()) { uri: Uri? ->
    if (uri != null) { /* hand to PdfImporter on a background thread */ }
}
// launch:
picker.launch(arrayOf("application/pdf"))
```
Copy bytes:
```kotlin
context.contentResolver.openInputStream(uri)?.use { input ->
    FileOutputStream(destFile).use { out -> input.copyTo(out) }
} ?: throw IOException("openInputStream returned null")
```

## B. PdfRenderer
```kotlin
val pfd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
val renderer = PdfRenderer(pfd)               // renderer.close() also closes pfd
val count = renderer.pageCount
val page = renderer.openPage(index)           // ONLY ONE page may be open at a time
val wPt = page.width.toFloat()                // size in points (1/72 in)
val hPt = page.height.toFloat()
val bmp = Bitmap.createBitmap(wPx, hPx, Bitmap.Config.ARGB_8888)
bmp.eraseColor(Color.WHITE)                   // REQUIRED, otherwise transparent background
page.render(bmp, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
page.close()                                  // ALWAYS, use try/finally
```
`PdfRenderer` is not thread-safe. All calls go through ONE single-thread executor.

## C. Embed a custom View in Compose
```kotlin
AndroidView(
    modifier = Modifier.fillMaxSize(),
    factory = { ctx -> PageCanvasView(ctx) },
    update = { view -> view.setPage(/* ... */) },
)
```

## D. MotionEvent essentials (inside `override fun onTouchEvent(e: MotionEvent): Boolean`)
```kotlin
val toolType = e.getToolType(0)               // MotionEvent.TOOL_TYPE_STYLUS / _FINGER / _MOUSE / _ERASER
val action = e.actionMasked                   // ACTION_DOWN, ACTION_MOVE, ACTION_UP, ACTION_CANCEL, ACTION_POINTER_DOWN, ACTION_POINTER_UP
val x = e.getX(0); val y = e.getY(0); val p = e.getPressure(0); val t = e.eventTime
// historical samples (between frames) for smooth ink:
for (h in 0 until e.historySize) {
    val hx = e.getHistoricalX(0, h); val hy = e.getHistoricalY(0, h)
    val hp = e.getHistoricalPressure(0, h); val ht = e.getHistoricalEventTime(h)
}
// cancel flag exists only on API 33+:
val canceled = Build.VERSION.SDK_INT >= 33 && (e.flags and MotionEvent.FLAG_CANCELED) != 0
```
Call `invalidate()` after changing anything drawn. `requestDisallowInterceptTouchEvent(true)` on ACTION_DOWN.

## E. Pinch zoom
Use `android.view.ScaleGestureDetector(context, listener)`; in listener `onScale(d)` use `d.focusX`, `d.focusY`, `d.scaleFactor` and return true.

## F. Atomic file write
```kotlin
fun writeAtomic(target: File, bytes: ByteArray) {
    val tmp = File(target.parentFile, target.name + ".tmp")
    FileOutputStream(tmp).use { it.write(bytes); it.flush(); it.fd.sync() }
    if (!tmp.renameTo(target)) throw IOException("rename failed: $tmp -> $target")
}
```
Append a line durably:
```kotlin
FileOutputStream(journalFile, true).use { it.write((line + "\n").toByteArray(Charsets.UTF_8)); it.flush(); it.fd.sync() }
```

## G. org.json
```kotlin
val o = JSONObject().put("x", 1.5)            // Float must be converted: .put("x", f.toDouble())
val a = JSONArray().put(1.0).put(2.0)
val s = o.toString()
val back = JSONObject(s); val f = back.getDouble("x").toFloat()
val i = back.getInt("color")                  // ARGB Int may be negative: fine
```
Parsing errors throw `org.json.JSONException`.

## H. Back handling and Snackbar in Compose
```kotlin
BackHandler(enabled = true) { /* go back */ }
val snackbarHost = remember { SnackbarHostState() }
Scaffold(snackbarHost = { SnackbarHost(snackbarHost) }) { padding -> /* ... */ }
scope.launch { snackbarHost.showSnackbar(message) }   // scope = rememberCoroutineScope()
```

## I. Main-thread handoff without coroutines
```kotlin
private val main = Handler(Looper.getMainLooper())
executor.execute { val r = work(); main.post { callback(r) } }
```

## J. Log
`Log.e("LocalNote", "message", throwable)`; `Log.d("LocalNote", "message")`.
