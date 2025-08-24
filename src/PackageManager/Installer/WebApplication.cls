Include PackageManager.PackageManager

Class PackageManager.Installer.WebApplication
{

/// This is the installer class for the PackageManager application.
ClassMethod CreateWebApplication() As %Status
{
    Set sc = $$$OK

    Set namespace = $Namespace
    Set apiEndpoint = $$$PackageManagerAPI 
    Set dispatchClass = $$$PackageManagerRESTClass 
    Set description = "Package Manager REST API"
    Try {
        Set sc = ##class(PackageManager.Utility.WebApplication).RegisterWebApplication(namespace,apiEndpoint,dispatchClass,description)
    } Catch ex {
        Set sc=ex.AsStatus()
    }

    Return sc
}

/// This is the installer class for the PackageManager application.
ClassMethod DeleteWebApplication() As %Status
{
    Set sc = $$$OK

    Set namespace = $Namespace
    Set apiEndpoint = $$$PackageManagerAPI 
    Set dispatchClass = $$$PackageManagerRESTClass 
    Try {
        Set sc = ##class(PackageManager.Utility.WebApplication).RemoveWebApplication(apiEndpoint,dispatchClass)
    } Catch ex {
        Set sc=ex.AsStatus()
    }

    Return sc
}

}
