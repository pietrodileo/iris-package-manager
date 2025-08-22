Class PackageManager.UI.Screens.InstallSection.CSP.UninstallCSP Extends PackageManager.UI.Screens.Abstract
{

ClassMethod OnPage() As %Status
{
    Set ret = ""
    Set execute = $GET(%request.Data("execute",1))
    If execute = 1 {
        Try {
            Set sc = ##class(PackageManager.Installer.WebApplication).DeleteWebApplication()    
            If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
            Set ret = "ok"
            w ret,!
        }
        Catch ex {
            Set sc=ex.AsStatus()
            Set ret = $SYSTEM.Status.GetErrorText(sc)
        }
    }
    Return $$$OK
}

}
