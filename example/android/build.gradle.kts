allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://repo.cryptopro.ru/repo/repository/cloud-maven-snapshot/")
            credentials {
                username = "android-release-reader"
                password = "1qaz@WSX"
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
