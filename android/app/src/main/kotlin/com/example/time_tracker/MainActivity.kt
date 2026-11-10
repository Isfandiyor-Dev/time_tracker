package com.example.time_tracker

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "time_tracker/foreground_timer"
        private const val NOTIFICATION_PERMISSION_REQUEST = 7231
        const val ACTION_OPEN_TIMER = "com.example.time_tracker.OPEN_TIMER"
        const val ACTION_PUNCH_OUT = "com.example.time_tracker.PUNCH_OUT_FROM_NOTIFICATION"
    }

    private var permissionResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureNotificationIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureNotificationIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler(::handleMethodCall)
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setLocale" -> {
                val languageCode = call.arguments as? String
                if (languageCode == null) {
                    result.error("invalid_arguments", "Language code is required", null)
                    return
                }
                TimerStateStore.setLanguageCode(this, languageCode)
                if (TimerStateStore.isActive(this)) {
                    startTimerService(TimerForegroundService.ACTION_REFRESH_LOCALE)
                }
                result.success(null)
            }
            "ensureNotificationPermission" -> ensureNotificationPermission(result)
            "start" -> {
                @Suppress("UNCHECKED_CAST")
                val values = call.arguments as? Map<String, Any?>
                if (values == null) {
                    result.error("invalid_arguments", "Timer values are required", null)
                    return
                }
                TimerStateStore.saveActive(this, values)
                startTimerService(TimerForegroundService.ACTION_START)
                result.success(null)
            }
            "toggleBreak" -> {
                startTimerService(TimerForegroundService.ACTION_TOGGLE_BREAK)
                result.success(null)
            }
            "stop" -> {
                startService(Intent(this, TimerForegroundService::class.java).setAction(TimerForegroundService.ACTION_STOP))
                result.success(null)
            }
            "restore" -> result.success(TimerStateStore.readActive(this))
            "consumePendingPunchOut" -> result.success(TimerStateStore.consumePending(this))
            "consumeOpenTimerRequest" -> result.success(TimerStateStore.consumeOpenTimerRequest(this))
            else -> result.notImplemented()
        }
    }

    private fun captureNotificationIntent(intent: Intent?) {
        when (intent?.action) {
            ACTION_OPEN_TIMER -> TimerStateStore.requestOpenTimer(this)
            ACTION_PUNCH_OUT -> {
                TimerStateStore.markPendingPunchOut(this)
                TimerForegroundService.dismissAfterNotificationPunchOut(this)
            }
        }
        intent?.action = null
    }

    private fun startTimerService(action: String) {
        val intent = Intent(this, TimerForegroundService::class.java).setAction(action)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) startForegroundService(intent) else startService(intent)
    }

    private fun ensureNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
            return
        }
        if (permissionResult != null) {
            result.error("permission_in_progress", "Notification permission is already being requested", null)
            return
        }
        permissionResult = result
        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), NOTIFICATION_PERMISSION_REQUEST)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == NOTIFICATION_PERMISSION_REQUEST) {
            permissionResult?.success(grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED)
            permissionResult = null
        }
    }
}
