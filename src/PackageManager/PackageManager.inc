ROUTINE PackageManager.PackageManager [Type=INC]

#define ProjectName			 "IRIS Package Manager"
#define PackageManagerVersion			 "0.1.0"
#define PackageManagerAPI			 "/csp/user/rest/packagemanager/"
#define PackageManagerRESTClass			 "PackageManager.API.REST"
#define APIDIR             "DIR"
#define APIPKG            "PKG"
#define ExportProjectTaskSectionTitle			 "Export Project Task"
#define ProjectContentViewerSectionTitle			 "Projects Content Viewer"
#define ExportedReleaseSectionTitle			 "Exported Release"
#define InstallationSectionTitle			 "Install Package Manager"
#define defaultTaskDescription			 "Export projects utility task"

#; --> For standard usage you can use these paths: 
#; #define tmpFilePath			 $system.Util.InstallDirectory()_"tmp/packagemanager/"
#; #define exportTaskFilePath			 $system.Util.InstallDirectory()_"tmp/packagemanager/task/export/

#; --> For container usage you can use these paths: 
#define tmpFilePath			"opt/irisapp/packagemanager/"
#define exportTaskFilePath			 "opt/irisapp/packagemanager/task/export/"