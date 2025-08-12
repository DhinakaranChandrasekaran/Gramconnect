allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Set a new root build directory to avoid conflicts
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// Configure subproject build directories
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Ensure app module is evaluated first (needed for Flutter)
    project.evaluationDependsOn(":app")
}

// Define the `clean` task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
