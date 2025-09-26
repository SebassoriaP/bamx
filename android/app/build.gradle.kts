plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Aplica plugin de Firebase
}

android {
    namespace = "com.example.bamx"
    compileSdk = 34 // O flutter.compileSdkVersion si quieres automático

    defaultConfig {
        applicationId = "com.example.bamx"
        minSdk = flutter.minSdkVersion // O flutter.minSdkVersion
        targetSdk = 34 // O flutter.targetSdkVersion
        versionCode = 1
        versionName = "1.0.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
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
