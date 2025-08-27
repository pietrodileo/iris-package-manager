# Understanding Package Manager Configuration

The `PackageManager.PackageManager` routine, a type of include file (`.INC`), defines critical constants for the Package Manager. 

The constants define important strings and file paths used by the application, such as the REST API endpoint or files export paths.

About export file paths:

* **Standard Usage:** Recommended paths use the `$system.Util.InstallDirectory()` method. This is for a non-containerized, traditional IRIS installation on a host machine, where the absolute path to the IRIS installation is required.
* **Container Usage:** These paths are specifically defined for a containerized environment (like Docker), using a fixed, known path within the container's file system, `/opt/irisapp/`. These paths are associated with durable storage to ensure data persistence across container restarts.
