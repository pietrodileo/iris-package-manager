Include PackageManager.PackageManager

/// Abstract class for all the UI screens
Class PackageManager.UI.Screens.Abstract Extends %CSP.Page [ Abstract ]
{

/// This method returns the endpoint to call to execute an internal call (from a CSP page to another)
ClassMethod GetPageURLForInternalCalls() As %String
{
    Set sc = $$$OK
    Try {
        Set URL = ""
        Set class = ##class(%Dictionary.CompiledClass).%OpenId(..%ClassName(1)) 
        If '$ISOBJECT(class) Throw ##class(%Exception.General).%New("Class not found")
        // Get Instance URL and Port
        Set sc=##class(%RoutineMgr).GetWebServerPort(.Port,.Server,.URLPrefix,.URL)
        // Get Default Web Application for the namespace (for csp pages)
        Set PackageManagerNamespace = $NAMESPACE
        New $Namespace
        Set $Namespace = "%SYS"
        Set sql = "SELECT ID FROM Security.Applications WHERE IsNameSpaceDefault = 1 AND NameSpace = ?"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set sc = tStatement.%Prepare(sql)
        If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
        Set tResult = tStatement.%Execute(PackageManagerNamespace)
        While tResult.%Next() {
            Set webAppID = tResult.%Get("ID")
        }
        Set URL = webAppID_"/"_class.Name_".cls"
    }
    Catch ex {
        Set sc=ex.AsStatus()
        Do ex.Log()
        Set URL = ""
    }
    Return URL
}

}
