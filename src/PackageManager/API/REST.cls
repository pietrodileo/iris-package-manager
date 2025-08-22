Include PackageManager.PackageManager

Class PackageManager.API.REST Extends %CSP.REST
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
  SET info = {
    "version": ($$$PackageManagerVersion)
  }
  RETURN ..%ProcessResult($$$OK, info)
}

ClassMethod Ping() As %Status
{
    Set sc = $$$OK
    Set %response.IgnoreRESTOutput=1
    Set res = {
        "timestamp":($ZDATETIME($H,3)),
        "message":"Package Manager API is correctly installed and working properly"
    }
    Set %response.ContentType = "application/json" 
    Do ..WriteResponse(.res,sc)
    Return sc
}

/// ////// METODI DA SPOSTARE IN UTILITY
/// "PackageManager.API.REST", "CLS", "BAO"
ClassMethod CreateNestedObject(item As %String, type As %String, currProject As %String, ByRef result As %DynamicObject, Separator As %String = ".", CSPExtension As %String = "") As %Status
{
    Set sc = $$$OK
    Try {
        If '$ISOBJECT($GET(result)) Set result = {}
        // Extract base name without suffix if provided
        Set baseName = item
        Set parts = $LISTFROMSTRING(baseName, Separator)

        // Ensure the project node exists
        If '$ISOBJECT(result.%Get(currProject)) {
            Do result.%Set(currProject, ##class(%DynamicObject).%New())
        }
        Set element = result.%Get(currProject)
        If ($ZCONVERT(type,"L") = "csp") {
            Set rootNode = $$$APIDIR
            // In case of CSP files, we may have a more proper extension than .csp passed as additional argument
            If CSPExtension '= "" {
                Set type = CSPExtension
            }
        } Else {
            Set rootNode = $$$APIPKG
        }
        If '$ISOBJECT(element.%Get(rootNode)) {
            Do element.%Set(rootNode, ##class(%DynamicObject).%New())
        }
        Set element = element.%Get(rootNode)

        Set ptr = 0
        Set depth = $LISTLENGTH(parts)
        Set count = 0
        Set currElement = element
        While $LISTNEXT(parts, ptr, part) {
            Set count = count + 1
            Set isLast = (count = depth)
            If isLast {
                // Leaf node with metadata
                Do currElement.%Set(part, {
                    "name": (part),
                    "type": (type)
                })
            } Else {
                // Create or get nested container
                If '$ISOBJECT(currElement.%Get(part)) {
                    Do currElement.%Set(part, ##class(%DynamicObject).%New())
                }
            }
            Set currElement = currElement.%Get(part)
        }
        //Do result.%Get(currProject).%Push(element)
        //w !,result.%ToJSON(),!
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Quit sc
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

/// Creates a nested JSON structure of all files and subdirectories under a given installation-relative directory.
/// The tree is returned as a %DynamicObject passed by reference (`result`), with the top-level key being `currProject`.
/// This is particularly useful for inspecting CSP directories like `csp\user\`, including subfolders and file types.
/// 
/// - Files are inserted as objects with `name` and `type` (based on file extension).
/// - Subdirectories are represented as nested `%DynamicObject` nodes.
/// - The method does NOT use recursion but instead uses an explicit directory stack for traversal.
/// 
/// Parameters:
/// - `directory`: A relative path inside the IRIS installation dir (default: `"csp\user\"`)
/// - `currProject`: The project name to serve as root key of the resulting object (default: `"test"`)
/// - `result`: A dynamic object passed by reference to hold the structured output
/// 
/// Example output:
/// ```json
/// {
///   "test": {
///     "subdir": {
///       "file1": { "name": "file1", "type": "css" }
///     },
///     "file2": { "name": "file2", "type": "js" }
///   }
/// }
/// ```
ClassMethod JSONFolderTree(directory As %String, currProject As %String, ByRef result As %DynamicObject = "", verbose As %Boolean = 0, separator As %String = "\") As %Status
{
    Set sc = $$$OK
    Try {
        // Initialize result object if not already provided
        If '$ISOBJECT(result) Set result = {}

        // if the directory contains both slashes and backslashes, replace them with the separator
        If directory [ "/" {
            Set directory = $REPLACE(directory, "/", separator) 
        }

        // Ensure project root exists in result
        If '$ISOBJECT(result.%Get(currProject)) {
            Do result.%Set(currProject, ##class(%DynamicObject).%New())
        }
        Set rootElement = result.%Get(currProject)
        If '$ISOBJECT(rootElement.%Get($$$APIDIR)) {
            Do rootElement.%Set($$$APIDIR, ##class(%DynamicObject).%New())
        }
        // Set the directory root as a specific node of the stack
        Set rootElement = rootElement.%Get($$$APIDIR)
        
        // Create a node for the current root directory
        Set ptr = 0
        While $LISTNEXT($LISTFROMSTRING(directory, separator),ptr,element){
            If '$ISOBJECT(rootElement.%Get(element)) {
                Do rootElement.%Set(element, ##class(%DynamicObject).%New())
            }
            Set rootElement = rootElement.%Get(element)
        }

        // Define base path and initialize stack for directories
        Kill FILES
        Set basePath = $SYSTEM.Util.InstallDirectory()_directory
        Set FILES($INCREMENT(FILES)) = basePath

        // Main loop to scan each directory in stack
        Set key = ""
        For {
            Set key = $ORDER(FILES(key), 1, searchdir)
            Quit:key=""

            Set filepath = $ZSEARCH(searchdir_"*")
            While filepath'="" {
                Set filename = ##class(%File).GetFilename(filepath)

                // Skip special entries
                If (filename'=".") && (filename'="..") {
                    If verbose { Write "file: "_filepath_" " }
                    // If it is a directory, add it to the stack for further inspection
                    If ##class(%File).DirectoryExists(filepath) {
                        If verbose { Write "is a directory",! }
                        Set FILES($INCREMENT(FILES)) = filepath_separator  // Add subdir to stack

                        // If it's a subdirectory, create corresponding node in the object tree
                        If $ZCONVERT(filepath, "L")'=$ZCONVERT(basePath, "L") {
                            Set relativePath = $PIECE($ZCONVERT(filepath, "L"), $ZCONVERT(basePath, "L"), 2)
                            Set ptr = 0
                            Set element = rootElement
                            While $LISTNEXT($LISTFROMSTRING(relativePath, separator), ptr, elementName) {
                                Continue:elementName=""
                                If '$ISOBJECT(element.%Get(elementName)) {
                                    Do element.%Set(elementName, ##class(%DynamicObject).%New())
                                }
                                Set element = element.%Get(elementName)
                            }
                        }
                    // If it is a file, insert it into the directory node
                    } Else {
                        If verbose { Write "is a file",! }
                        // Check if we're under a subdirectory and move pointer to the correct nested node
                        Set isSubDir = ($ZCONVERT(searchdir, "L")'=$ZCONVERT(basePath, "L"))
                        If isSubDir {
                            Set relativeDirPath = $PIECE($ZCONVERT(searchdir, "L"), $ZCONVERT(basePath, "L"), 2)
                            Set ptr = 0
                            Set element = rootElement
                            While $LISTNEXT($LISTFROMSTRING(relativeDirPath, separator), ptr, dirPath) {
                                Continue:dirPath=""
                                Set element = element.%Get(dirPath)
                            }
                        } Else {
                            Set element = rootElement
                        }

                        // Insert file node
                        Set name = $PIECE(filename, ".", 1)
                        Set fileformat = $PIECE(filename, ".", 2)
                        Do element.%Set(name, {
                            "name": (name),
                            "type": (fileformat)
                        })
                    }
                }

                Set filepath = $ZSEARCH("")  // Next entry
            }
        }
        If verbose { Write result.%ToJSON() }
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Return sc
}

/// This create a nested object structure from a csp file name
ClassMethod DefineObjFromCSP(ByRef rootElement As %DynamicObject, Name As %String, separator As %String) As %Status
{
    Set sc = $$$OK
    Try {        
        // For csp files, we need to create a nested object for each package
        Set parts = $LISTFROMSTRING(Name, separator)
        Set ptr = 0
        Set depth = $LISTLENGTH(parts)
        Set count = 0
        Set filename = "", extension = ""
        While $LISTNEXT(parts,ptr,part) {
            Set count = count + 1
            If part="" { Continue } // Skip empty parts
            If count = depth {
                Set filename = part
                Set part = $PIECE(filename, ".", 1) // Remove file extension for the last part
                Set extension = $PIECE(filename, ".", 2)
                // Leaf node with metadata
                Do rootElement.%Set(part, {
                    "name": (part),
                    "type": (extension)
                })
            } Else {
                If '$ISOBJECT(rootElement.%Get(part)) {
                    Do rootElement.%Set(part, ##class(%DynamicObject).%New())
                }
                Set rootElement = rootElement.%Get(part)
            }
        }
    }
    Catch ex {
        Set sc=ex.AsStatus()
    }
    Return sc
}

/// This create a nested object structure from a class or routine file
ClassMethod DefineObjFromCLSOrRoutine(ByRef rootElement As %DynamicObject, Name As %String, separator As %String) As %Status
{
    Set sc = $$$OK
    Try {        
        // For csp files, we need to create a nested object for each package
        Set parts = $LISTFROMSTRING(Name, separator)
        Set $LIST(parts,*-1,*)=$LISTBUILD("",$LIST(parts,*-1)_"."_$LIST(parts,*)) // Remove the last two elements from the list and join them into a single last element
        Set ptr = 0
        Set depth = $LISTLENGTH(parts)
        Set count = 0
        Set filename = "", extension = ""
        While $LISTNEXT(parts,ptr,part) {
            Set count = count + 1
            If part="" { Continue } // Skip empty parts
            If count = depth {
                Set filename = part
                Set part = $PIECE(filename, ".", 1) // Remove file extension for the last part
                Set extension = $PIECE(filename, ".", 2)
                // Leaf node with metadata
                Do rootElement.%Set(part, {
                    "name": (part),
                    "type": (extension)
                })
            } Else {
                If '$ISOBJECT(rootElement.%Get(part)) {
                    Do rootElement.%Set(part, ##class(%DynamicObject).%New())
                }
                Set rootElement = rootElement.%Get(part)
            }
        }
    }
    Catch ex {
        Set sc=ex.AsStatus()
    }
    Return sc
}

/// This transcodes the type integer to a string description
/// Following the conventions detailed in:
/// https://docs.intersystems.com/irislatest/csp/documatic/%25CSP.Documatic.cls?LIBRARY=%25SYS&CLASSNAME=%25Library.RoutineMgr#anchor_queries
ClassMethod TranscodeType(Type As %Integer) As %String
{
    Set TypeDesc = ""
    Try {
        Set TypeDesc = $CASE(Type,
            0: "MAC",  // Macro
            1: "INT",  // Standard Routine
            2: "INC",  // Include file
            3: "BAS",  // Cache Basic Routine
            4: "CLS",  // Class
            5: "CSP",  // Cache Server Page or a file in this directory
            7: "GBL",  // Global
            8: "PRJ",  // Project
            9: "PKG",  // Package
            10: "APP", // CSP Application
            11: "MVB", // MultiValue Basic macro routine
            12: "MVI", // MultiValue Basic routine
            13: "OBJ", // Object code
            100: "ABS" // A document defined by a subclass of %Studio.AbstractDocument
        )
    }
    Catch ex {
        Set TypeDesc = ""
        Set sc=ex.AsStatus()
    }
    Return TypeDesc
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
  Set swagger.info.title = "Package Manager API"
  Set swagger.info.version = $$$PackageManagerVersion
  Set swagger.host = "localhost:52773"
  Return ..%ProcessResult($$$OK, swagger)
}

ClassMethod %ProcessResult(pStatus As %Status = {$$$OK}, pResult As %DynamicObject = "") As %Status [ Internal ]
{
  #dim %response As %CSP.Response
  SET tSC = $$$OK
  IF $$$ISERR(pStatus) {
    SET %response.Status = 500
    SET tSC = ..StatusToJSON(pStatus, .tJSON)
    IF $isobject(tJSON) {
      SET pResult = tJSON
    } ELSE {
      SET pResult = { "errors": [ { "error": "Unknown error parsing status code" } ] }
    }
  } 
  ELSEIF pStatus=1 {
    IF '$isobject(pResult){
      SET pResult = {
      }
    }
  }
  ELSE {
    SET %response.Status = pStatus
    SET error = $PIECE(pStatus, " ", 2, *)
    SET pResult = {
      "error": (error)
    }
  }
  
  IF pResult.%Extends("%Library.DynamicAbstractObject") {
    WRITE pResult.%ToJSON()
  }
  ELSEIF pResult.%Extends("%JSON.Adaptor") {
    DO pResult.%JSONExport()
  }
  ELSEIF pResult.%Extends("%Stream.Object") {
    DO pResult.OutputToDevice()
  }
  
  QUIT tSC
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
