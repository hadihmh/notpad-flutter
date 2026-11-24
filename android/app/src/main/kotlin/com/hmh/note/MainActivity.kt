package com.hmh.note

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** Share sheet and file save/open via the system file picker (no storage permission needed). */
class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null
    private var pendingText: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.hmh.note/platform")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "share" -> {
                        val send = Intent(Intent.ACTION_SEND).apply {
                            type = "text/plain"
                            putExtra(Intent.EXTRA_TEXT, call.argument<String>("text"))
                        }
                        startActivity(Intent.createChooser(send, null))
                        result.success(null)
                    }
                    "saveFile", "openFile" -> {
                        if (pending != null) return@setMethodCallHandler result.error("busy", null, null)
                        pending = result
                        if (call.method == "saveFile") {
                            pendingText = call.argument<String>("text")
                            startActivityForResult(Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                                addCategory(Intent.CATEGORY_OPENABLE)
                                type = "application/json"
                                putExtra(Intent.EXTRA_TITLE, call.argument<String>("name"))
                            }, SAVE)
                        } else {
                            startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                                addCategory(Intent.CATEGORY_OPENABLE)
                                type = "*/*" // some devices don't know the JSON mime type
                            }, OPEN)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != SAVE && requestCode != OPEN) return
        val result = pending ?: return
        pending = null
        val uri = data?.data
        if (resultCode != RESULT_OK || uri == null) return result.success(null) // user cancelled
        try {
            if (requestCode == SAVE) {
                contentResolver.openOutputStream(uri, "wt")!!.use { it.write(pendingText!!.toByteArray()) }
                result.success(true)
            } else {
                result.success(contentResolver.openInputStream(uri)!!.bufferedReader().use { it.readText() })
            }
        } catch (e: Exception) {
            result.error("io", e.message, null)
        } finally {
            pendingText = null
        }
    }

    companion object {
        private const val SAVE = 41
        private const val OPEN = 42
    }
}
