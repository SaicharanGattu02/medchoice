# Preserve all classes in the package and sub-packages
-keep class com.pixl.medchoice.** { *; }

# Keep Google Play Services location API classes
-keep class com.google.android.gms.location.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Keep WorkManager classes
-keep class androidx.work.** { *; }

# Keep Retrofit and OkHttp classes
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }