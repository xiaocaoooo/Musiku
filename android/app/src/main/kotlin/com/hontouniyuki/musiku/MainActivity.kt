package com.hontouniyuki.musiku

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import cn.lyric.getter.api.API
import cn.lyric.getter.api.data.ExtraData
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import cn.lyric.getter.api.tools.Tools

class MainActivity : FlutterActivity() {
    private val CHANNEL = "lyric_sender"
    private val lga by lazy { API() }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendLyric" -> {
                    val lyric = call.argument<String>("lyric") ?: ""
//                    val appName = call.argument<String>("appName") ?: ""
//                    val iconBytes = call.argument<ByteArray>("iconBytes") ?: byteArrayOf()

//                    API.sendLyric(
//                        context = this,
//                        lyricData = LyricData(
//                            lyric = lyric,
//                            appName = appName,
//                            appIcon = iconBytes
//                        )
//                    )
                    lga.sendLyric(lyric, extra = ExtraData().apply {
                        packageName = "com.hontouniyuki.musiku"
//                        customIcon = true
//                        base64Icon = Tools.drawableToBase64(getDrawable(R.mipmap.ic_launcher)!!)
                        useOwnMusicController = false
                        delay = 0
                    })
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}