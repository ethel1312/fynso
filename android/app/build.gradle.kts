import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 🔐 Cargamos las propiedades del keystore desde android/key.properties
val keystoreProperties: Properties = Properties().apply {
    // 👇 OJO: aquí estaba el error, DEBE ser "key.properties", no "android/key.properties"
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (!keystorePropertiesFile.exists()) {
        throw GradleException(
            "key.properties no encontrado en: ${keystorePropertiesFile.absolutePath}"
        )
    }
    load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "app.fynso.fynso"
    //compileSdk = flutter.compileSdkVersion
    compileSdk = 36
    ndkVersion = "29.0.14033849"
    //ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true   // sigues teniendo desugaring
    }

    kotlinOptions {
        jvmTarget = "1.8"   // usar 1.8 para compatibilidad
    }

    // 🔐 Configuración de firma
    signingConfigs {
        create("release") {
            val storeFilePath =
                keystoreProperties["storeFile"]?.toString()
                    ?: throw GradleException("Falta 'storeFile' en key.properties")

            storeFile = file(storeFilePath)
            storePassword =
                keystoreProperties["storePassword"]?.toString()
                    ?: throw GradleException("Falta 'storePassword' en key.properties")
            keyAlias =
                keystoreProperties["keyAlias"]?.toString()
                    ?: throw GradleException("Falta 'keyAlias' en key.properties")
            keyPassword =
                keystoreProperties["keyPassword"]?.toString()
                    ?: throw GradleException("Falta 'keyPassword' en key.properties")
        }
    }

    defaultConfig {
        applicationId = "app.fynso.fynso"

        //minSdk = flutter.minSdkVersion
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        // 👇 Se leen de pubspec.yaml → version: 1.1.0+2
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("debug") {
            // firma debug por defecto
        }

        getByName("release") {
            // 👉 Usamos la firma de release que definimos arriba
            signingConfig = signingConfigs.getByName("release")

            // Si quisieras ofuscar y reducir tamaño:
            // isMinifyEnabled = true
            // isShrinkResources = true
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}
