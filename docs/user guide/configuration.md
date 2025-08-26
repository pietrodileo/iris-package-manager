# Understanding Package Manager Configuration

The `PackageManager.PackageManager` routine, a type of include file (`.INC`), defines critical constants for the Package Manager. These `#define` directives make it easier to maintain and configure the application by centralizing key values.

The constants define important strings and file paths used by the application, such as the REST API endpoint and version number. The file also distinguishes between paths for different deployment environments.

```
ROUTINE PackageManager.PackageManager [Type=INC]

#define ProjectName                 "IRIS Package Manager"
#define PackageManagerVersion       "0.1.0"
#define PackageManagerAPI           "/csp/user/rest/packagemanager/"
#define PackageManagerRESTClass     "PackageManager.API.REST"
#define APIDIR                      "DIR"
#define APIPKG                      "PKG"
#define ExportProjectTaskSectionTitle        "Export Project Task"
#define ProjectContentViewerSectionTitle     "Projects Content Viewer"
#define ExportedReleaseSectionTitle      "Exported Release"
#define InstallationSectionTitle        "Install Package Manager"
#define defaultTaskDescription          "Export projects utility task"

#; --> For standard usage you can use these paths: 
#; #define tmpFilePath                $system.Util.InstallDirectory()_"tmp/packagemanager/"
#; #define exportTaskFilePath            $system.Util.InstallDirectory()_"tmp/packagemanager/task/export/

#; --> For container usage you can use these paths: 
#define tmpFilePath               "/opt/irisapp/export/packagemanager/tmp/"
#define exportTaskFilePath            "/opt/irisapp/export/packagemanager/task/"

```

Notice the commented lines for **"standard usage"** and the active lines for  **"container usage"** . This distinction is crucial:

* **Standard Usage:** These paths are commented out and use the `$system.Util.InstallDirectory()` method. This is for a non-containerized, traditional IRIS installation on a host machine, where the absolute path to the IRIS installation is required.
* **Container Usage:** These paths are specifically defined for a containerized environment (like Docker), using a fixed, known path within the container's file system, `/opt/irisapp/`. This ensures the application can find its temporary and task directories consistently, regardless of where the container is running.
