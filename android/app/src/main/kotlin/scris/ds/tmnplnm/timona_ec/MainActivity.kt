package scris.ds.tmnplnm.timona_ec

import android.annotation.SuppressLint
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.TextView
import androidx.core.net.ParseException
import com.yy.floatserver.FloatClient
import com.yy.floatserver.FloatHelper
import com.yy.floatserver.IFloatPermissionCallback
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Timer
import java.util.TimerTask

class MainActivity: FlutterActivity() {

    companion object {
        private const val CHANNEL = "scris.plnm/alarm"
    }

    private var channel: MethodChannel? = null
    private var textView: TextView? = null
    private var floatHelper: FloatHelper? = null
    private var timer: Timer? = null
    private var handler: Handler? = null
    private var timeAtEnd: Date? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel!!.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            println(call.method)
            when (call.method) {
                "showOverlay" -> {
                    try {
                        showOverlay(
                            call.argument("time")!!,
                            call.argument("countdown")!!,
                            call.argument("name")!!
                        )
                    } catch (e: ParseException) {
                        e.printStackTrace()
                    }
                    result.success(0)
                }
                "hideOverlay" -> {
                    hideOverlay()
                    result.success(0)
                }
                else -> {
                    result.success(0)
                }
            }
        }
    }

    @SuppressLint("SimpleDateFormat")
    @Throws(ParseException::class)
    private fun initOverlay(time: String) {
        timeAtEnd = SimpleDateFormat("yyyy-MM-dd-HH-mm-ss").parse(time)
        Log.i("plnmovl", "initOverlay: $timeAtEnd")
        textView = TextView(applicationContext)
        textView!!.setTextColor(0xFF1A837B.toInt())
        textView!!.typeface = Typeface.DEFAULT_BOLD
        textView!!.text = timeClarify(timeAtEnd)
        val drawable = GradientDrawable()
        drawable.setStroke(4, 0xFF1A837B.toInt())
        drawable.setColor(0xFFEBF6F5.toInt())
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            drawable.setPadding(8, 5, 8, 5)
        }
        drawable.cornerRadius = 4F
        textView!!.background = drawable
        val builder: FloatClient.Builder = FloatClient.Builder()
        builder.with(this)
        builder.addView(textView!!)
        builder.enableDefaultPermissionDialog(false)
        builder.setClickTarget(MainActivity::class.java)
        builder.addPermissionCallback(object : IFloatPermissionCallback {
            override fun onPermissionResult(granted: Boolean) {
                if (!granted) {
                    floatHelper?.requestPermission()
                }
            }
        })
        floatHelper = builder.build()
    }

    @SuppressLint("SimpleDateFormat")
    @Throws(ParseException::class)
    private fun showOverlay(time: String, countDown: Boolean, name: String) {
        if (floatHelper == null) initOverlay(time)
        floatHelper!!.show()
        timeAtEnd = SimpleDateFormat("yyyy-MM-dd-HH-mm-ss").parse(time)
        if (timer == null) {
            timer = Timer()
            handler = Handler(Looper.getMainLooper())
            if (countDown) {
                timer!!.schedule(object : TimerTask() {
                    override fun run() {
                        handler!!.post { textView!!.text = timeClarify(timeAtEnd) }
                    }
                }, 0, 1000)
            } else {
                timer!!.schedule(object : TimerTask() {
                    override fun run() {
                        handler!!.post { textView!!.text = timeClarifyReverse(timeAtEnd) }
                    }
                }, 0, 1000)
            }
        }
    }

    private fun hideOverlay() {
        if (timer != null) {
            timer!!.cancel()
            timer = null
        }
        floatHelper!!.dismiss()
    }

    private fun tow(original: String): String {
        return if (original.length == 1) {
            "0$original"
        } else {
            original
        }
    }

    private fun timeClarify(date: Date?): String {
        val dateNum = date!!.time
        val nowNum = Date().time
        var duration = (dateNum - nowNum) / 1000
        return if (duration >= 0) {
            val minute = duration / 60
            val second = duration % 60
            minute.toString() + ":" + tow(second.toString() + "")
        } else {
            duration = -duration
            val minute = duration / 60
            val second = duration % 60
            "-" + minute + ":" + tow(second.toString() + "")
        }
    }


    private fun timeClarifyReverse(date: Date?): String {
        val dateNum = date!!.time
        val nowNum = Date().time
        var duration = -((dateNum - nowNum) / 1000)
        return if (duration >= 0) {
            val minute = duration / 60
            val second = duration % 60
            minute.toString() + ":" + tow(second.toString() + "")
        } else {
            duration = -duration
            val minute = duration / 60
            val second = duration % 60
            "-" + minute + ":" + tow(second.toString() + "")
        }
    }
}