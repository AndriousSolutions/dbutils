# This is a configuration file for ProGuard.
# https://www.guardsquare.com/en/proguard/manual/introduction

# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in C:\Programs\Tools\AndroidSDK/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, jsee
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

#-keep class com.gtfp.errorhandler.** { *; }

# 27 warnings seemed to be ignored ok.
-dontwarn com.google.common.cache.**
-dontwarn com.google.common.primitives.UnsignedBytes$**

#Proguard can rename the `BuildConfig` Java class in the minification process
# and prevent React Native Config from referencing it. To avoid this:
-keep class com.gtfp.workingmemory.BuildConfig { *; }

## Try a little more passes for kicks.
-optimizationpasses 5

# Keep everything written in the app.
#-keep class com.gtfp.** { *; }

# use this option to remove logging code.
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# It's being sought but doesn't need to be.
-dontwarn org.joda.convert.**

# It's included as a jar file so don't worry, right?
#-dontwarn com.example.exceptionhandler.**

# Necessary since adding compile files('../../../libs/opencsv/opencsv-3.3.jar')
-dontwarn org.apache.commons.collections.BeanMap
-dontwarn java.beans.**

##---------------Begin: proguard configuration common for all Android apps ----------
-dontskipnonpubliclibraryclassmembers

-dump class_files.txt
-printseeds seeds.txt
-printusage unused.txt
-printmapping mapping.txt

## Removes package names making the code even smaller and less comprehensible.
-repackageclasses ''


##------------- Lets obfuscated code produce stack traces that can still be deciphered later on
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable


# Keep because these classes can be declared in the AndrodiManifest.xml.
#-keep public class * extends android.app.Activity
#-keep public class * extends android.app.Application
#-keep public class * extends android.app.Service
#-keep public class * extends android.content.BroadcastReceiver

#-keep public class * extends android.content.ContentProvider
#-keep public class * extends android.app.backup.BackupAgent
#-keep public class * extends android.app.backup.BackupAgentHelper

#-keep public class * extends android.preference.Preference

#-keep public class * extends android.support.v4.app.Fragment
#-keep public class * extends android.support.v4.app.DialogFragment

#-keep class com.google.android.gms.internal.*
#-keep class com.google.android.gms.maps.** { *; }
#-keep interface com.google.android.gms.maps.** { *; }

# Explicitly preserve all serialization members. The Serializable interface
# is only a marker interface, so it wouldn't save them.
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    static final java.io.ObjectStreamField[] serialPersistentFields;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

### Keep custom views  since they are probably referenced only from layout XML instead of application code
#-keepclassmembers !abstract class !com.google.ads.** extends android.view.View {
#    public <init>(android.content.Context);
#    public <init>(android.content.Context, android.util.AttributeSet);
#    public <init>(android.content.Context, android.util.AttributeSet, int);
#    public void set*(...);
#}
#
#-keepclassmembers !abstract class * {
#    public <init>(android.content.Context, android.util.AttributeSet);
#    public <init>(android.content.Context, android.util.AttributeSet, int);
#}
#
#-keepclassmembers class * extends android.content.Context {
#   public void *(android.view.View);
#}
###-----------------  End of Keep Custom Views


## Saves any public class    YOU THEN DON'T OBFUSCATE ANYTHING??
#-keep public class * {
#    public protected *;
#}


#-keepclassmembers class * implements android.os.Parcelable {
#    static *** CREATOR;
#    }


 ##---------------End: proguard configuration common for all Android apps

##---------------Begin: proguard configuration for support library
#-keep class android.support.v4.app.** { *; }
#-keep interface android.support.v4.app.** { *; }
#-keep class com.actionbarsherlock.** { *; }
#-keep interface com.actionbarsherlock.** { *; }
#
## The support library contains references to newer platform versions.
## Don't warn about those in case this app is linking against an older
## platform version. We know about them, and they are safe.
#-dontwarn android.support.**
#-dontwarn com.google.ads.**
###---------------End: proguard configuration for support library


###---------------Begin: proguard configuration for Gson
## Gson uses generic type information stored in a class file when working with fields. Proguard
## removes such information by default, so configure it to keep all of it.
#-keepattributes Signature
#
## For using GSON @Expose annotation
## Gson specific classes
#-keep class sun.misc.Unsafe { *; }
#-keep class com.google.gson.stream.** { *; }
#
## Application classes that will be serialized/deserialized over Gson
#-keep class com.example.model.** { *; }
# ##---------------End: proguard configuration for Gson  ----------

# If your project uses WebView with JS, uncomment the following
 #and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}
