package com.pixl.medchoice

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.location.Address
import android.location.Geocoder
import android.location.Location
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.LocationSettingsRequest
import com.google.android.gms.location.Priority
import io.flutter.plugin.common.MethodChannel
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.io.IOException
import java.util.Locale

data class LocationReq(
    val latitude: String,
    val longitude: String,
    val location: String
)


class LocationService : Service() {
    private val CHANNEL_ID = "ForegroundService Kotlin"
    private var token: String = ""
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private lateinit var locationRequest: LocationRequest
    private lateinit var mHandler: Handler
    private lateinit var mRunnable: Runnable
    private lateinit var methodChannel: MethodChannel
    lateinit var submitresponse: submitresponse
    private var sharedPreferences: SharedPreferences? = null

    companion object {
        fun startService(context: Context, message: String) {
            val startIntent = Intent(context, LocationService::class.java)
            startIntent.putExtra("inputExtra", message)
            ContextCompat.startForegroundService(context, startIntent)
        }

        fun stopService(context: Context) {
            val stopIntent = Intent(context, LocationService::class.java)
            context.stopService(stopIntent)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.e("LocationService", "Service started")
        createNotificationChannel()
        val input = intent?.getStringExtra("inputExtra") ?: "Service Running"
        showNotification(input)
        token = getAccessToken(applicationContext) ?: "default_token_value"

        mHandler = Handler(mainLooper)
        mRunnable = Runnable {
            requestLocationUpdates()
            mHandler.postDelayed(mRunnable, 10000) // Repeat every 10 seconds
        }
        mHandler.postDelayed(mRunnable, 1000) // Initial delay

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        createLocationRequest()

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                super.onLocationResult(result)
                val location = result.lastLocation
                if (location != null) {
                    Log.d("Locations", "${location.latitude},${location.longitude}")
                    val geocoder = Geocoder(applicationContext, Locale.getDefault())
                    try {
                        val addresses: List<Address>? = geocoder.getFromLocation(location.latitude, location.longitude, 1)
                        if (addresses != null && addresses.isNotEmpty()) {
                            val address = addresses[0]
                            val addressLine = address.getAddressLine(0)
                            Log.d("Address", addressLine ?: "No address found")
                            SendLocation(location.latitude.toString(),  location.longitude.toString(), addressLine ?: "No address found")
                        } else {
                            Log.d("Address", "No address found")
                            SendLocation(location.latitude.toString(),  location.longitude.toString(), "No address found")
                        }
                    } catch (e: IOException) {
                        Log.e("Geocoder", "Geocoder failed", e)
                        SendLocation(location.latitude.toString(), location.longitude.toString(), "Error retrieving address")
                    }

                }
            }
        }
        return START_NOT_STICKY
    }


    private fun handleLocationUpdate(location: Location) {
        if (::methodChannel.isInitialized) {
            methodChannel.invokeMethod("onLocationUpdate", mapOf(
                "latitude" to location.latitude,
                "longitude" to location.longitude
            ))
        } else {
            Log.e("LocationService", "MethodChannel is not initialized.")
        }
    }

    fun getAccessToken(context: Context): String? {
        // Initialize SharedPreferences
        val sharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        // Retrieve the access token
        val accessToken = sharedPreferences.getString("flutter." + "access_token", "");
        // Log the access token
        Log.d("LocationService", "Access Token Retrieved: $accessToken")

        // Show a Toast with the access token
      //  Toast.makeText(context, "Access Token: $accessToken", Toast.LENGTH_LONG).show()

        return accessToken
    }



    private fun SendLocation(lat: String, long: String,address: String) {

        val loginService = ApiClient.createService(ApiInterface::class.java)
        val locationRequest = LocationReq(lat, long, address)
        // Make the API call
        val requestCall = loginService.sendLocation("Bearer $token",locationRequest)
        requestCall.enqueue(object : Callback<submitresponse> {
            override fun onResponse(call: Call<submitresponse>, response: Response<submitresponse>) {
                if (response.isSuccessful) {
                    val apiResponse = response.body()
                    Log.d("API_CALL", "Success: ${apiResponse?.message}")
                } else {
                    Log.e("API_CALL", "Error: ${response.errorBody()?.string()}")
                }
            }

            override fun onFailure(call: Call<submitresponse>, t: Throwable) {
                Log.e("API_CALL", "Failure: ${t.message}")
            }
        })
    }
        

    private fun requestLocationUpdates() {
        if (ActivityCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return
        }
        fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, null)
    }

    private fun createLocationRequest() {
        locationRequest = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 10000)
            .setMinUpdateIntervalMillis(5000)
            .build()

        val builder = LocationSettingsRequest.Builder()
            .addLocationRequest(locationRequest)

        val client = LocationServices.getSettingsClient(this)
        client.checkLocationSettings(builder.build()).addOnSuccessListener {
            requestLocationUpdates()
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Foreground Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            serviceChannel.setSound(null, null)
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun showNotification(input: String) {
        val notificationIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE)

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Location Service")
            .setContentText(input)
            .setContentIntent(pendingIntent)
            .build()

        startForeground(1, notification)
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        fusedLocationClient.removeLocationUpdates(locationCallback)
    }
}
