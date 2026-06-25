import java.util.Properties

val localProps = Properties().apply {
    val f = file("local.properties")
    if (f.isFile) {
        f.inputStream().use(::load)
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://repo.cryptopro.ru/repo/repository/cloud-maven-snapshot/")
            credentials {
                username = localProps.getProperty("cryptopro_artifactory_user", "")
                    ?: error("cryptopro_artifactory_user not found in local.properties")
                password = localProps.getProperty("cryptopro_artifactory_password", "")
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
