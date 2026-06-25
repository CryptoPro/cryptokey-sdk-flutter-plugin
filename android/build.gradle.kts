group = "ru.cryptopro.cpkey"
version = "1.0-SNAPSHOT"

buildscript {
    val kotlinVersion = "2.3.20"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:9.0.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
    id("kotlin-android")
    id("org.jetbrains.kotlin.plugin.serialization") version "2.4.0"
}

android {
    namespace = "ru.cryptopro.cpkey"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 26
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.useJUnitPlatform()

                it.outputs.upToDateWhen { false }

                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    val dss_sdk_remote_version = "1.0.1.+"
    val csp_version = "5.0.52800-rc-1"
    /**
     * Набор библиотек от Крипто-Про
     */
    implementation("ru.cprocsp:csp-base:$csp_version")
    implementation("ru.cprocsp:csp-gui:$csp_version")
    implementation("ru.cprocsp:JInitCSP:$csp_version")
    implementation("ru.cprocsp:SharedLibrary:$csp_version")
    implementation("ru.cryptopro:dssclient-token:${dss_sdk_remote_version}")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.11.0")
}
