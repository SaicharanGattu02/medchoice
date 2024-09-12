package com.pixl.medchoice

import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.pixl/location"
    private lateinit var methodChannel: MethodChannel
    private val PERMISSION_REQUEST_CODE = 1001

    @RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    val message = call.argument<String>("message")
                    if (arePermissionsGranted()) {
                        LocationService.startService(this, message ?: "Service Running")
                        result.success(null)
                    } else {
                        requestPermissions()
                        result.error("PERMISSION_DENIED", "Permissions are required to start the service", null)
                    }
                }

                "stopService" -> {
                    LocationService.stopService(this)
                    result.success(null)
                }

                "locationUpdate" -> {
                    // Example: Simulate receiving location updates and sending them to Dart
                    val latitude = call.argument<Double>("latitude") ?: 0.0
                    val longitude = call.argument<Double>("longitude") ?: 0.0
                    sendLocationUpdateToDart(latitude, longitude)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED ||
                ContextCompat.checkSelfPermission(this, android.Manifest.permission.FOREGROUND_SERVICE_LOCATION) != PackageManager.PERMISSION_GRANTED) {

                ActivityCompat.requestPermissions(this, arrayOf(
                    android.Manifest.permission.ACCESS_FINE_LOCATION,
                    android.Manifest.permission.FOREGROUND_SERVICE_LOCATION
                ), PERMISSION_REQUEST_CODE)
            }
        } else {
            if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, arrayOf(
                    android.Manifest.permission.ACCESS_FINE_LOCATION
                ), PERMISSION_REQUEST_CODE)
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    private fun arePermissionsGranted(): Boolean {
        val fineLocationGranted = ContextCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        val foregroundServiceGranted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ContextCompat.checkSelfPermission(this, android.Manifest.permission.FOREGROUND_SERVICE_LOCATION) == PackageManager.PERMISSION_GRANTED
        } else {
            true // This permission doesn't exist on older versions
        }
        return fineLocationGranted || foregroundServiceGranted
    }

    @RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            LocationService.startService(this, "Service Running")
//            if (arePermissionsGranted()) {
//                Log.d("Permissions", "Permissions granted.")
//
//            } else {
//                Log.d("Permissions", "Permissions not granted.")
//                Toast.makeText(this, "Permissions required to start the service", Toast.LENGTH_SHORT).show()
//            }
        }
    }

    fun sendLocationUpdateToDart(latitude: Double, longitude: Double) {
        methodChannel.invokeMethod("onLocationUpdate", mapOf(
            "latitude" to latitude,
            "longitude" to longitude
        ))
    }
}
