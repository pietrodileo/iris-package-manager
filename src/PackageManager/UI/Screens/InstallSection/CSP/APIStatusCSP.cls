Class PackageManager.UI.Screens.InstallSection.CSP.APIStatusCSP Extends PackageManager.UI.Screens.Abstract
{

ClassMethod OnPage() As %Status
{
    Set ret = ""
    Set WebAppExists = 0
    Set execute = $GET(%request.Data("execute",1))
    If execute = 1 {
        Try {
            Set namespace = $Namespace
            Set apiEndpoint = $$$PackageManagerAPI 
            Set sc = ##class(PackageManager.Utility.WebApplication).WebApplicationExists(namespace, apiEndpoint, .WebAppExists)
            If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
        }
        Catch ex {
            Set sc=ex.AsStatus()
            Set ret = $SYSTEM.Status.GetErrorText(sc)
        }
    }
    If WebAppExists {
        Set ret = {
            "installed":true
        }
    } else {
        Set ret = {
            "installed":false
        }
    }
    w !,ret.%ToJSON(),!
    Return $$$OK
}

}
