Class PackageManager.Utility.Utils Extends %RegisteredObject [ Abstract ]
{

/// Verify if a directory exists at the provided path, create it if not and requested by the user <br>
/// parameters:<br>
/// path -> the path to the directory<br>
/// create -> if true, the directory will be created if it does not exist<br>
/// exists -> the output parameter that will be set to true if the directory exists<br>
/// returns: status code<br>
ClassMethod DirExists(path As %String, create As %Boolean = 0, Output exists As %Boolean) As %Status
{
    Set sc = $$$OK
    Set exists = ##class(%File).DirectoryExists(path) 
    If 'exists {
        If create {
            #; Set ret = ##class(%File).CreateDirectory(path, .returnCode)
            Set ret = ##class(%File).CreateDirectoryChain(path, .returnCode)
            If ret = 0 {
                Set sc = ($$$ERROR($$$GeneralError, "Unable to create directory "_path_". Return code: "_returnCode))
            }
            Set exists = 1
        }
    }
    Return sc
}

/// This method adapts a file path to the operating system by replacing backslashes with forward slashes or vice versa.
/// It ensures that the file paths are compatible with the underlying OS.
ClassMethod AdaptPathToOS(path As %String = "", Output separator As %String) As %String
{
    Set os = $SYSTEM.Version.GetOS()
    If $$$isWINDOWS {
        Set path = $REPLACE(path,"/","\")
        Set separator = "\"
    } ElseIf $$$isUNIX {
        Set path = $REPLACE(path,"\","/")
        Set separator = "/"
    }
    Return path
}

ClassMethod GetInstanceDetails() As %Status
{
    // Get current IRIS instance URL and port
    Set sc=##class(%RoutineMgr).GetWebServerPort(.Port,.Server,.URLPrefix,.URL)
    w !,"URL: "_URL
    w !,"Port: "_Port
    w !,"Server: "_Server
    w !,"URLPrefix: "_URLPrefix
    Return sc
}

}
