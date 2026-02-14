package com.example.mudanza_inventario

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "printer_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "printLabel") {
                val text = call.argument<String>("text")
                if (text != null) {
                    imprimirSticker(text)
                    result.success("Impresión enviada")
                } else {
                    result.error("ERROR", "Texto vacío", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun imprimirSticker(text: String) {
        // Aquí puedes agregar la lógica real de Brother después
        println("Imprimiendo desde Kotlin: $text")
    }
}