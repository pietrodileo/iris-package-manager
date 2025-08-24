Include PackageManager.PackageManager

Class PackageManager.API.REST Extends %CSP.REST [ Abstract ]
{

XData UrlMap
{
<Routes>
    <!-- Project related calls -->
    <Route Url="/project/create" Method="POST" Call="PackageManager.API.Projects.Interface:CreateProject"/>
    <Route Url="/projects" Method="GET" Call="PackageManager.API.Projects.Interface:GetProjects"/>
    <Route Url="/projects/" Method="GET" Call="PackageManager.API.Projects.Interface:GetProjects"/>
    <Route Url="/project/export/:projectId" Method="GET" Call="PackageManager.API.Projects.Interface:ExportProject"/>
    <Route Url="/project/content/:projectId" Method="GET" Call="PackageManager.API.Projects.Interface:GetProjectContent"/>
    <Route Url="/project/content/" Method="GET" Call="PackageManager.API.Projects.Interface:GetProjectContent"/>
    <Route Url="/project/content" Method="GET" Call="PackageManager.API.Projects.Interface:GetProjectContent"/>
    <Route Url="/project/update/:projectId" Method="POST" Call="PackageManager.API.Projects.Interface:UpdateProjectDesc"/>
    <Route Url="/project/delete/:projectId" Method="DELETE" Call="PackageManager.API.Projects.Interface:DeleteProject"/>
    <Route Url="/project/add/:projectId" Method="POST" Call="PackageManager.API.Projects.Interface:AddClassesToProject"/>
    <Route Url="/project/remove/:projectId" Method="PUT" Call="PackageManager.API.Projects.Interface:RemoveClassesToProject"/>
    <!-- Export classes calls -->
    <Route Url="/classes/export/" Method="POST" Call="PackageManager.API.Classes.Interface:ExportClasses"/>
    <Route Url="/classes/export" Method="POST" Call="PackageManager.API.Classes.Interface:ExportClasses"/>
    <!-- Namespace content calls -->
    <Route Url="/namespace/content/:type" Method="GET" Call="PackageManager.API.Namespace.Interface:GetAllNamespaceFiles"/>
    <Route Url="/namespace/content/" Method="GET" Call="PackageManager.API.Namespace.Interface:GetAllNamespaceFiles"/>
    <Route Url="/namespace/content" Method="GET" Call="PackageManager.API.Namespace.Interface:GetAllNamespaceFiles"/>
    <!-- Tasks related calls -->
    <Route Url="/task/create" Method="POST" Call="PackageManager.API.Task.Interface:CreateTask"/>
    <Route Url="/task/create/" Method="POST" Call="PackageManager.API.Task.Interface:CreateTask"/>
    <Route Url="/task/existing" Method="GET" Call="PackageManager.API.Task.Interface:CheckExistingTasks"/>
    <Route Url="/task/existing/" Method="GET" Call="PackageManager.API.Task.Interface:CheckExistingTasks"/>
    <Route Url="/task/delete/:taskId" Method="DELETE" Call="PackageManager.API.Task.Interface:DeleteTask"/>
    <Route Url="/task/run/:taskId" Method="GET" Call="PackageManager.API.Task.Interface:RunTask"/>
    <Route Url="/task/:taskId" Method="GET" Call="PackageManager.API.Task.Interface:GetTaskInfo"/>
    <Route Url="/task/update/:taskId" Method="POST" Call="PackageManager.API.Task.Interface:UpdateTask"/>
    <Route Url="/task/updateclasses/:taskId" Method="POST" Call="PackageManager.API.Task.Interface:UpdateAssociatedClasses"/>
    <Route Url="/task/releases" Method="GET" Call="PackageManager.API.Task.Interface:GetReleases"/>
    <Route Url="/task/releases/" Method="GET" Call="PackageManager.API.Task.Interface:GetReleases"/>
    <Route Url="/task/release/download" Method="POST" Call="PackageManager.API.Task.Interface:DownloadRelease"/>
    <Route Url="/task/release/download/" Method="POST" Call="PackageManager.API.Task.Interface:DownloadRelease"/>
    <!-- Ping to test API reachability -->
    <Route Url="/api/ping" Method="GET" Call="Ping"/>
    <Route Url="/api/ping/" Method="GET" Call="Ping"/>
    <!-- Swagger specs -->
    <Route Url="/_spec" Method="GET" Call="SwaggerSpec" />
    <!-- Server Info -->
    <Route Url="/" Method="GET" Call="GetInfo" Cors="true"/>
</Routes>
}

Parameter HandleCorsRequest = 1;

Parameter CHARSET = "utf-8";

ClassMethod GetInfo() As %Status
{
    Set info = {
    "version": ($$$PackageManagerVersion)
    }
    Return ..WriteResponse(.info,$$$OK)
}

ClassMethod Ping() As %Status
{
    Set sc = $$$OK
    Set %response.IgnoreRESTOutput=1
    Set res = {
        "timestamp":($ZDATETIME($HOROLOG,3)),
        "message":"Package Manager API is correctly installed and working properly"
    }
    Set %response.ContentType = "application/json" 
    Do ..WriteResponse(.res,sc)
    Return sc
}

/// This method returns the url to be called to access this page
ClassMethod GetAPIEndpoint() As %Status
{
    Set namespace = $NAMESPACE
    Set className = $THIS
    // Build URL dynamically
    Set sc=##class(%RoutineMgr).GetWebServerPort(.Port,.Server,.URLPrefix,.URL)
    Set URL = URL_$$$PackageManagerAPI
    If URL [ "//" {
        Set URL = $REPLACE(URL,"//","/")
    }
    //Write URL,!
    Return URL
}

/// This method is used to add a new project to the export task.
ClassMethod AddNewProjectToExportTask() As %Status
{
    Set sc = $$$OK
    Try {
        Set %response.ContentType = "application/json"
        Set projectName = $GET(%request.Data("project_name",1))
        Set dateFrom = $GET(%request.Data("date_from",1))
        Set dateTo = $GET(%request.Data("date_to",1))

        If dateFrom = "" {
            Set dateFrom = $ZDATE($HOROLOG, 3)  // Default to current date
        }

        If projectName'="" {
            &SQL( SELECT ID INTO :projectId FROM %Studio.Project WHERE Name = :projectName)
            If SQLCODE '= 0 {
                Set sc = $$$ERROR($$$GeneralError, "Project "_projectName_" does not exist.")
                Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
            }
            Set proj = ##class(PackageManager.Task.ProjectToExport).%New()
            Set proj.ProjectId = projectId
            Set proj.DateFrom = dateFrom
            Set proj.DateTo = dateTo
            Set sc = proj.%Save()
            If $$$ISERR(sc) { Throw ##class(%Exception.StatusException).CreateFromStatus(sc) }
        } Else {
            Set sc = $$$ERROR($$$GeneralError, "Project name is required.")
        }
    }
    Catch ex {
        Set sc=ex.AsStatus()
    }
    Return sc
}

ClassMethod WriteResponse(ByRef response As %DynamicObject = "", sc As %Status) As %Status
{
    If '$ISOBJECT(response) {
        Set response = {}
    }
    Set %response.ContentType = ..#CONTENTTYPEJSON
    ; Ripristina l'output REST per restituire all'IO di default (risposta REST) il contenuto dell'oggetto response
    Set %response.IgnoreRESTOutput=0
    If $$$ISERR(sc) {
        Set response = {"error": ("Error: "_$SYSTEM.Status.GetErrorText(sc))}
        Do ..ReportHttpStatusCode(..#HTTP500INTERNALSERVERERROR)
    }
    // Return the response as a JSON
    If $ISOBJECT(response) {
        If response.%IsA("%DynamicAbstractObject") {
            Do response.%ToJSON()
        } Else {
            Do response.OutputToDevice()
        }
    } Else {
        Write response 
    }
    Return sc
}

ClassMethod SwaggerSpec() As %Status
{
  Do ##class(%REST.API).GetWebRESTApplication($NAMESPACE, %request.Application, .swagger)
  Do swagger.info.%Remove("x-ISC_Namespace")
  Set swagger.basePath = $$$PackageManagerAPI
  Set swagger.info.title = $$$ProjectName
  Set swagger.info.version = $$$PackageManagerVersion
  Set swagger.host = "localhost:52773"
  Return ..%ProcessResult($$$OK, swagger)
}

ClassMethod %ProcessResult(pStatus As %Status = {$$$OK}, pResult As %DynamicObject = "") As %Status [ Internal ]
{
  #dim %response As %CSP.Response
  Set tSC = $$$OK
  If $$$ISERR(pStatus) {
    Set %response.Status = 500
    Set tSC = ..StatusToJSON(pStatus, .tJSON)
    If $ISOBJECT(tJSON) {
      Set pResult = tJSON
    } Else {
      Set pResult = { "errors": [ { "error": "Unknown error parsing status code" } ] }
    }
  } 
  ElseIf pStatus=1 {
    If '$ISOBJECT(pResult){
      Set pResult = {
      }
    }
  }
  Else {
    Set %response.Status = pStatus
    Set error = $PIECE(pStatus, " ", 2, *)
    Set pResult = {
      "error": (error)
    }
  }
  
  If pResult.%Extends("%Library.DynamicAbstractObject") {
    Write pResult.%ToJSON()
  }
  ElseIf pResult.%Extends("%JSON.Adaptor") {
    Do pResult.%JSONExport()
  }
  ElseIf pResult.%Extends("%Stream.Object") {
    Do pResult.OutputToDevice()
  }
  
  Quit tSC
}

ClassMethod ReportHttpStatusCode(pHttpStatus, pSC As %Status = {$$$OK}) As %Status
{
  Set %response.Status=pHttpStatus
  
  If $$$ISERR(pSC) Do ..outputStatus(pSC)
  /*
  If (+pHttpStatus>=400) {
    Set %response.ContentType = "application/json"
    SET pResult = {
      "error": ($PIECE(pHttpStatus, " ", 2, *))
    }
    Return ..%ProcessResult($$$OK, pResult)
  }*/
      
  Return $$$OK
}

}
