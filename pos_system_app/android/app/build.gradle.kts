plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")

    // 🔥 ADD THIS LINE (Firebase)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.pos_system_app"
    compileSdk = flutter.compileSdkVersion

    // Recommended fixed NDK version
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.pos_system_app"

        // Firebase requires minimum 23
        minSdk = 23

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
