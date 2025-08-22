Class PackageManager.Utility.WebApplication Extends %RegisteredObject [ Abstract ]
{

/// Register a web application. It configure an unauthenticated web application.
/// <ul>
/// <li><var>pNameSpace</var> Name of the namespace when the web application.</li>
/// <li><var>pName</var> Service name to create/update.</li>
/// <li><var>pClassName</var> Name of class to run.</li>
/// <li><var>pDescription</var> Comment to include.</li>
/// <li><var>verbose</var> If true (1) enable printing logs.</li>
/// </ul>
/// <example>
/// // Add web api
/// Do myClass.RegisterWebApplication("SAMPLES","/myApp/api","Host.RS.Rest","This is my api rest")</example> 
/// 
/// Credits to Kurro Lopez: https://community.intersystems.com/post/add-web-application-code
ClassMethod RegisterWebApplication(pNameSpace As %String, pName As %String, pClassName As %String, pDescription As %String = "", verbose As %Boolean = 0) As %Status
{
    New $Namespace
    Set $Namespace = "%SYS"
    Set ret = $$$OK
    Set spec("AutheEnabled") = $$$AutheUnauthenticated
    Set spec("NameSpace") = pNameSpace
    Set spec("Description") = pDescription
    Set spec("IsNameSpaceDefault") = $$$NO
    Set spec("DispatchClass") = pClassName
    Set spec("MatchRoles")=":%All"

    If ('##class(Security.Applications).Exists(pName)) {
        If verbose Write !,"Creating Web application """_pName_"""..."
        Set ret = ##class(Security.Applications).Create(pName, .spec)
        If verbose Write !, "Web application """_pName_""" is created.",!
    }
    Else { // ensure configuration matches in case of updating from old terminal versions
        If verbose Write !, "Updating web application """_pName_"""..."
        Set ret = ##class(Security.Applications).Modify(pName, .spec)
        If verbose Write !, "Web application """_pName_""" is updated.",!
    }
    Return ret
}

/// Remove a web application
/// <ul>
/// <li><var>pName</var> Name of web application to remove.</li>
/// <li><var>pClassName</var> Name of the class linked to the web application.</li>
/// <li><var>verbose</var> If true (1) enable printing logs.</li>
/// </ul>
/// <example>
/// // Remove web api
/// Do myClass.RemoveWebApplication("/myApp/api","Host.RS.Rest")</example>
/// 
/// Credits to Kurro Lopez: https://community.intersystems.com/post/add-web-application-code
ClassMethod RemoveWebApplication(pName As %String, pClassName As %String, verbose As %Boolean = 0)
{
    New $Namespace
    Set $Namespace = "%SYS"
    Set ret = $$$OK
    If (##class(Security.Applications).Exists(pName)) {
        Do ##class(Security.Applications).Get(pName, .props)
        If (props("DispatchClass") '= pClassName) {
            If verbose Write !, "Web application doesn't refer to DispatchClass "_pClassName,!
        }
        Else {
            If verbose Write !, "Deleting Web application """_pName_"""..."
            Set ret = ##class(Security.Applications).Delete(pName)
            If verbose Write !, "Web application """_pName_""" was successfully deleted.",!
        }
    }
    Return ret
}

/// This class method verifies if a web application with a specified name exists. .
/// <ul>
/// <li><var>pNameSpace</var> Name of the namespace where the web application exists.</li>
/// <li><var>pName</var> Name to verify.</li>
/// </ul>
ClassMethod WebApplicationExists(pNameSpace As %String, pName As %String, Output WebAppExist As %Boolean, verbose As %Boolean = 0) As %Status
{
    New $Namespace
    Set $Namespace = "%SYS"

    Set WebAppExist = 0
    Set ret = $$$OK

    If ('##class(Security.Applications).Exists(pName)) {
        if verbose Write !,"Web application """_pName_""" does not exist..."
    } Else { 
        Set Properties = ""
        Set ret = ##class(Security.Applications).Get(pName, .Properties)
        if verbose Write !, "Web application """_pName_""" properties: ", Properties("NameSpace"), !
        If Properties("NameSpace") = pNameSpace {
            Set WebAppExist = 1
        }
    }
    Return ret
}

}
