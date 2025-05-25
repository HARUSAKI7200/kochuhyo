package com.example.kouchuhyo_app

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.OutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "save_pdf_channel"
    private val REQUEST_CODE_CREATE_DOCUMENT = 1001

    private var pendingResult: MethodChannel.Result? = null
    private var pendingBytes: ByteArray? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "savePdfToUri") {
                val fileName = call.argument<String>("fileName") ?: "document.pdf"
                val pdfBytes = call.argument<ByteArray>("pdfBytes")
                if (pdfBytes == null) {
                    result.error("INVALID_DATA", "pdfBytes is null", null)
                    return@setMethodCallHandler
                }

                pendingResult = result
                pendingBytes = pdfBytes

                val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "application/pdf"
                    putExtra(Intent.EXTRA_TITLE, fileName)
                }
                startActivityForResult(intent, REQUEST_CODE_CREATE_DOCUMENT)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == REQUEST_CODE_CREATE_DOCUMENT) {
            if (resultCode == Activity.RESULT_OK && data?.data != null) {
                val uri: Uri = data.data!!
                val outputStream: OutputStream? = contentResolver.openOutputStream(uri)
                try {
                    outputStream?.write(pendingBytes)
                    outputStream?.flush()
                    outputStream?.close()
                    pendingResult?.success(true)
                } catch (e: Exception) {
                    e.printStackTrace()
                    pendingResult?.error("SAVE_FAILED", "Failed to write PDF: ${e.message}", null)
                }
            } else {
                // ユーザーがキャンセルした場合など
                pendingResult?.success(false)
            }
            pendingResult = null
            pendingBytes = null
        } else {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }
}
