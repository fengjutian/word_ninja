allprojects {
    repositories {
        google()
        mavenCentral()
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

// AGP 9+ requires every module to declare a namespace.
// Old Flutter plugins (e.g. isar_flutter_libs 3.1.0+1) only set it via the
// legacy `package` attribute in AndroidManifest.xml. Inject a fallback so
// those plugins still build against the AGP version Flutter pulls in.
// We must set it during plugin application (synchronously, no afterEvaluate)
// because AGP locks in the namespace before evaluation finishes.
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure(com.android.build.gradle.LibraryExtension::class.java) {
            if (namespace == null) {
                namespace = project.group.toString().ifEmpty { "flutter.plugin.${project.name}" }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
