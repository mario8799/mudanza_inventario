plugins {
    id("com.android.application")
    // Se recomienda usar el ID completo para evitar conflictos
    id("org.jetbrains.kotlin.android") 
    id("dev.flutter.flutter-gradle-plugin")
}

repositories {
    // ESTO ES LO QUE FALTABA: Sin estos, no se descargan las librerías de Flutter/Android
    google()
    mavenCentral()
    flatDir {
        dirs("libs")
    }
}

android {
    namespace = "com.example.mudanza_inventario"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Corrección técnica: Usar el valor de la versión directamente
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.mudanza_inventario"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Se usa la configuración de depuración para firmas en este ejemplo
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Tu librería local para la impresora Brother
    implementation(files("libs/BrotherPrintLibrary.aar"))
}

flutter {
    source = "../.."
}