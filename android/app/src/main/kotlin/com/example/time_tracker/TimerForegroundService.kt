package com.example.time_tracker

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.content.res.Configuration
import android.graphics.Color
import android.os.Build
import android.os.IBinder
import android.os.SystemClock
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject
import java.util.Locale
import kotlin.math.max

object TimerStateStore {
    private const val PREFS = "time_tracker_timer"
    private const val ACTIVE = "active"
    private const val PENDING = "pending"
    private const val PROJECT_ID = "project_id"
    private const val PROJECT_NAME = "project_name"
    private const val CURRENCY = "currency"
    private const val RATE = "rate"
    private const val STARTED_AT = "started_at"
    private const val BREAK_STARTED_AT = "break_started_at"
    private const val STOPPED_AT = "stopped_at"
    private const val BREAKS = "breaks"
    private const val OPEN_TIMER_REQUESTED = "open_timer_requested"
    private const val LANGUAGE_CODE = "language_code"

    private fun prefs(context: Context) = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun saveActive(context: Context, values: Map<String, Any?>) {
        val breaks = JSONArray()
        @Suppress("UNCHECKED_CAST")
        (values["breaks"] as? List<Map<String, Any?>>).orEmpty().forEach { item ->
            breaks.put(JSONObject().put("start", (item["start"] as Number).toLong()).put("end", (item["end"] as Number).toLong()))
        }
        prefs(context).edit()
            .putBoolean(ACTIVE, true)
            .putBoolean(PENDING, false)
            .putLong(PROJECT_ID, (values["projectId"] as Number).toLong())
            .putString(PROJECT_NAME, values["projectName"] as String)
            .putString(CURRENCY, values["currency"] as String)
            .putString(RATE, (values["hourlyRate"] as Number).toDouble().toString())
            .putLong(STARTED_AT, (values["startedAt"] as Number).toLong())
            .putLong(BREAK_STARTED_AT, (values["breakStartedAt"] as? Number)?.toLong() ?: 0L)
            .putLong(STOPPED_AT, 0L)
            .putString(BREAKS, breaks.toString())
            .commit()
    }

    fun isActive(context: Context): Boolean = prefs(context).getBoolean(ACTIVE, false)

    fun setLanguageCode(context: Context, languageCode: String) {
        val supportedCode = languageCode.takeIf { it in setOf("en", "uz", "ru") } ?: "en"
        prefs(context).edit().putString(LANGUAGE_CODE, supportedCode).apply()
    }

    fun languageCode(context: Context): String =
        prefs(context).getString(LANGUAGE_CODE, "en") ?: "en"

    fun toggleBreak(context: Context) {
        val store = prefs(context)
        if (!store.getBoolean(ACTIVE, false)) return
        val current = store.getLong(BREAK_STARTED_AT, 0L)
        val now = System.currentTimeMillis()
        val editor = store.edit()
        if (current == 0L) {
            editor.putLong(BREAK_STARTED_AT, now)
        } else {
            val breaks = parseBreaks(store.getString(BREAKS, "[]"))
            breaks.put(JSONObject().put("start", current).put("end", now))
            editor.putString(BREAKS, breaks.toString()).putLong(BREAK_STARTED_AT, 0L)
        }
        editor.apply()
    }

    fun markPendingPunchOut(context: Context) {
        prefs(context).edit()
            .putBoolean(ACTIVE, false)
            .putBoolean(PENDING, true)
            .putLong(STOPPED_AT, System.currentTimeMillis())
            .apply()
    }

    fun clearActive(context: Context) {
        prefs(context).edit().putBoolean(ACTIVE, false).putBoolean(PENDING, false).apply()
    }

    fun readActive(context: Context): Map<String, Any?>? {
        val store = prefs(context)
        return if (store.getBoolean(ACTIVE, false)) readMap(context) else null
    }

    fun consumePending(context: Context): Map<String, Any?>? {
        val store = prefs(context)
        if (!store.getBoolean(PENDING, false)) return null
        val value = readMap(context)
        store.edit().putBoolean(PENDING, false).apply()
        return value
    }

    fun requestOpenTimer(context: Context) {
        prefs(context).edit().putBoolean(OPEN_TIMER_REQUESTED, true).apply()
    }

    fun consumeOpenTimerRequest(context: Context): Boolean {
        val store = prefs(context)
        val requested = store.getBoolean(OPEN_TIMER_REQUESTED, false)
        if (requested) store.edit().putBoolean(OPEN_TIMER_REQUESTED, false).apply()
        return requested
    }

    fun workedMilliseconds(context: Context, now: Long = System.currentTimeMillis()): Long {
        val store = prefs(context)
        val start = store.getLong(STARTED_AT, now)
        val breakStart = store.getLong(BREAK_STARTED_AT, 0L)
        val completed = parseBreaks(store.getString(BREAKS, "[]")).let { array ->
            var total = 0L
            for (index in 0 until array.length()) {
                val item = array.getJSONObject(index)
                total += max(0L, item.getLong("end") - item.getLong("start"))
            }
            total
        }
        val activeBreak = if (breakStart == 0L) 0L else max(0L, now - breakStart)
        return max(0L, now - start - completed - activeBreak)
    }

    fun activeBreakMilliseconds(context: Context, now: Long = System.currentTimeMillis()): Long {
        val breakStart = prefs(context).getLong(BREAK_STARTED_AT, 0L)
        if (breakStart == 0L) return 0L
        return max(0L, now - breakStart)
    }

    fun isOnBreak(context: Context): Boolean = prefs(context).getLong(BREAK_STARTED_AT, 0L) != 0L
    fun projectName(context: Context): String = prefs(context).getString(PROJECT_NAME, "Time Tracker") ?: "Time Tracker"
    fun currency(context: Context): String = prefs(context).getString(CURRENCY, "UZS") ?: "UZS"
    fun rate(context: Context): Double = prefs(context).getString(RATE, "0")?.toDoubleOrNull() ?: 0.0

    private fun readMap(context: Context): Map<String, Any?> {
        val store = prefs(context)
        val breaksArray = parseBreaks(store.getString(BREAKS, "[]"))
        val breaks = mutableListOf<Map<String, Long>>()
        for (index in 0 until breaksArray.length()) {
            val item = breaksArray.getJSONObject(index)
            breaks.add(mapOf("start" to item.getLong("start"), "end" to item.getLong("end")))
        }
        return mapOf(
            "projectId" to store.getLong(PROJECT_ID, 0L),
            "projectName" to (store.getString(PROJECT_NAME, "") ?: ""),
            "currency" to (store.getString(CURRENCY, "UZS") ?: "UZS"),
            "hourlyRate" to rate(context),
            "startedAt" to store.getLong(STARTED_AT, 0L),
            "breakStartedAt" to store.getLong(BREAK_STARTED_AT, 0L).takeIf { it != 0L },
            "stoppedAt" to store.getLong(STOPPED_AT, 0L).takeIf { it != 0L },
            "breaks" to breaks,
        )
    }

    private fun parseBreaks(value: String?): JSONArray = try { JSONArray(value ?: "[]") } catch (_: Exception) { JSONArray() }
}

class TimerForegroundService : Service() {
    companion object {
        const val ACTION_START = "com.example.time_tracker.START"
        const val ACTION_TOGGLE_BREAK = "com.example.time_tracker.TOGGLE_BREAK"
        const val ACTION_PUNCH_OUT = "com.example.time_tracker.PUNCH_OUT"
        const val ACTION_STOP = "com.example.time_tracker.STOP"
        const val ACTION_REFRESH_LOCALE = "com.example.time_tracker.REFRESH_LOCALE"
        private const val ACTION_RESTORE_NOTIFICATION =
            "com.example.time_tracker.RESTORE_NOTIFICATION"
        private const val CHANNEL_ID = "active_timer"
        private const val NOTIFICATION_ID = 4812

        fun dismissAfterNotificationPunchOut(context: Context) {
            context.getSystemService(NotificationManager::class.java)
                .cancel(NOTIFICATION_ID)
            context.stopService(Intent(context, TimerForegroundService::class.java))
        }
    }

    override fun onCreate() {
        super.onCreate()
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_REFRESH_LOCALE -> createChannel()
            ACTION_TOGGLE_BREAK -> TimerStateStore.toggleBreak(this)
            ACTION_PUNCH_OUT -> {
                TimerStateStore.markPendingPunchOut(this)
                openApp()
                stopTimerService()
                return START_NOT_STICKY
            }
            ACTION_STOP -> {
                TimerStateStore.clearActive(this)
                stopTimerService()
                return START_NOT_STICKY
            }
        }
        if (!TimerStateStore.isActive(this)) {
            stopSelf()
            return START_NOT_STICKY
        }
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val localizedContext = localizedContext()
            val channel = NotificationChannel(
                CHANNEL_ID,
                localizedContext.getString(R.string.notification_channel_name),
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = localizedContext.getString(R.string.notification_channel_description)
                setShowBadge(false)
            }
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val localizedContext = localizedContext()
        val isOnBreak = TimerStateStore.isOnBreak(this)
        val stopwatchMilliseconds = if (isOnBreak) {
            TimerStateStore.activeBreakMilliseconds(this)
        } else {
            TimerStateStore.workedMilliseconds(this)
        }
        val stopwatchSeconds = stopwatchMilliseconds / 1000L
        val chronometerBase = SystemClock.elapsedRealtime() - stopwatchMilliseconds
        val hours = stopwatchSeconds / 3600
        val minutes = (stopwatchSeconds % 3600) / 60
        val secs = stopwatchSeconds % 60
        val elapsed = if (hours > 0) {
            String.format(Locale.US, "%02d:%02d:%02d", hours, minutes, secs)
        } else {
            String.format(Locale.US, "%02d:%02d", minutes, secs)
        }
        val breakLabel = localizedContext.getString(
            if (isOnBreak) R.string.notification_end_break else R.string.notification_break,
        )
        val punchOutLabel = localizedContext.getString(R.string.notification_punch_out)

        val toggleIntent = Intent(this, TimerForegroundService::class.java).setAction(ACTION_TOGGLE_BREAK)
        val punchIntent = Intent(this, MainActivity::class.java)
            .setAction(MainActivity.ACTION_PUNCH_OUT)
            .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val openIntent = Intent(this, MainActivity::class.java)
            .setAction(MainActivity.ACTION_OPEN_TIMER)
            .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val restoreIntent = Intent(this, TimerForegroundService::class.java)
            .setAction(ACTION_RESTORE_NOTIFICATION)
        val immutable = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        val togglePendingIntent = PendingIntent.getService(this, 11, toggleIntent, immutable)
        val punchPendingIntent = PendingIntent.getActivity(this, 12, punchIntent, immutable)
        val openPendingIntent = PendingIntent.getActivity(this, 10, openIntent, immutable)
        val restorePendingIntent = PendingIntent.getService(this, 13, restoreIntent, immutable)

        val compactView = RemoteViews(packageName, R.layout.notification_timer_compact)
        val expandedView = RemoteViews(packageName, R.layout.notification_timer_expanded)
        listOf(compactView, expandedView).forEach { view ->
            view.setChronometer(R.id.timer_text, chronometerBase, null, true)
            view.setInt(
                R.id.status_badge,
                "setBackgroundResource",
                if (isOnBreak) R.drawable.notification_status_break else R.drawable.notification_status_work,
            )
            view.setImageViewResource(
                R.id.status_icon,
                if (isOnBreak) R.drawable.ic_notification_break else R.drawable.ic_notification_work,
            )
        }
        compactView.setImageViewResource(
            R.id.break_compact,
            if (isOnBreak) R.drawable.ic_notification_play else R.drawable.ic_notification_break,
        )
        compactView.setOnClickPendingIntent(R.id.break_compact, togglePendingIntent)
        compactView.setOnClickPendingIntent(R.id.punch_out_compact, punchPendingIntent)

        expandedView.setTextViewText(R.id.break_action_text, breakLabel)
        expandedView.setTextViewText(R.id.punch_out_action_text, punchOutLabel)
        expandedView.setTextColor(
            R.id.break_action_text,
            if (isOnBreak) Color.rgb(200, 255, 99) else Color.rgb(255, 248, 250),
        )
        expandedView.setImageViewResource(
            R.id.break_action_icon,
            if (isOnBreak) R.drawable.ic_notification_play else R.drawable.ic_notification_break,
        )
        expandedView.setOnClickPendingIntent(R.id.break_action, togglePendingIntent)
        expandedView.setOnClickPendingIntent(R.id.punch_out_action, punchPendingIntent)

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) Notification.Builder(this, CHANNEL_ID) else Notification.Builder(this)
        builder
            .setSmallIcon(R.drawable.ic_notification_small)
            .setContentTitle(getString(R.string.app_name))
            .setContentText(elapsed)
            .setContentIntent(openPendingIntent)
            .setDeleteIntent(restorePendingIntent)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setCategory(Notification.CATEGORY_STOPWATCH)
            .setColor(Color.rgb(200, 255, 99))

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder.setForegroundServiceBehavior(Notification.FOREGROUND_SERVICE_IMMEDIATE)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            builder
                .setStyle(Notification.DecoratedCustomViewStyle())
                .setCustomContentView(compactView)
                .setCustomBigContentView(expandedView)
        }
        return builder.build().also { notification ->
            notification.flags = notification.flags
                .or(Notification.FLAG_ONGOING_EVENT)
                .or(Notification.FLAG_NO_CLEAR)
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
                notification.contentView = compactView
                notification.bigContentView = expandedView
            }
        }
    }

    private fun openApp() {
        startActivity(Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        })
    }

    private fun localizedContext(): Context {
        val configuration = Configuration(resources.configuration)
        configuration.setLocale(Locale.forLanguageTag(TimerStateStore.languageCode(this)))
        return createConfigurationContext(configuration)
    }

    private fun stopTimerService() {
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }
}
