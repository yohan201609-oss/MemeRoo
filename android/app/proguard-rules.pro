# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep audio players
-keep class xyz.luan.audioplayers.** { *; }

# Keep shared preferences
-keep class android.content.SharedPreferences { *; }

# Google Play Core (para Flutter deferred components - ignorar si no se usa)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Google Play Core (para Flutter deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
