Include PackageManager.PackageManager

/// This class defines the configuration for for the Package Manager export folders.
/// Two parameters are defined: tmpFilePath and exportTaskFilePath
/// The users can modify this parameters according to their needs.
/// The code MUST instead use the other parameters: TMPPATH and EXPPATH, that are defined as cosexpression and computed at runtime
/// This allows to use the configuration values at runtime, without the need to compile the whole project everytime
Class PackageManager.Config
{

/// --> For standard usage you can use this path: 
///      tmpFilePath = {$system.Util.InstallDirectory()_"tmp/packagemanager/"}
/// --> For container usage you can use this path: 
///     Set tmpFilePath = "/opt/irisapp/export/packagemanager/tmp/"
Parameter tmpFilePath = "/opt/irisapp/export/packagemanager/tmp/";

/// --> For standard usage you can use this path: 
///      exportTaskFilePath = {$system.Util.InstallDirectory()_"tmp/packagemanager/task/export/"}
/// --> For container usage you can use this path: 
///     Set exportTaskFilePath = "/opt/irisapp/export/packagemanager/task/"
Parameter exportTaskFilePath = "/opt/irisapp/export/packagemanager/task/";

/// This is used to get the parameter value of tmpFilePath at runtime (as cosexpression)
Parameter TMPPATH As COSEXPRESSION = "..GetTmpFilePath()";

/// This is used to get the parameter value of exportTaskFilePath at runtime (as cosexpression)
Parameter EXPPATH As COSEXPRESSION = "..GetExportTaskFilePath()";

/// Get the temporary file path
/// Use write ##class(PackageManager.Config).#TMPPATH
ClassMethod GetTmpFilePath() As %String
{
    Return ..#tmpFilePath
}

/// Get the path for the export task
/// Use write ##class(PackageManager.Config).#EXPPATH
ClassMethod GetExportTaskFilePath() As %String
{
    Return ..#exportTaskFilePath
}

}
