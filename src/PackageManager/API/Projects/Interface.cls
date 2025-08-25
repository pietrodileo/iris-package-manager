Class PackageManager.API.Projects.Interface Extends PackageManager.API.REST [ Final ]
{

ClassMethod CreateProject() As %Status
{
    Set sc = $$$OK
    Try {
        Set body = %request.Content.Read()
        Set json = {}.%FromJSON(body)
        Set name = json."name"
        Set desc = json."desc"
        If name'="" {
            If ##class(%Studio.Project).NameIdxExists(name) {
                Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Un progetto con lo stesso nome è già presente. Non è possibile creare progetti con lo stesso nome!")) 
            } 
            Set proj = ##class(%Studio.Project).%New()
            Set proj.Name = name
            Set proj.Description = desc
            Set sc = proj.%Save()
            If $$$ISERR(sc) {
                Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
            }
        } Else {
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Name è un campo obbligatorio")) 
        }
    } Catch ex {
        Set sc=ex.AsStatus()
        Do ..WriteResponse(.res,sc)
    }
    Return sc
}

ClassMethod GetProjects() As %Status
{
    Set sc = $$$OK
    Try {        
        Set %response.ContentType = "application/json"
        Set result = []
        Set sql = "SELECT Name, Description, LastModified FROM %Studio.Project ORDER BY Name"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set sc = tStatement.%Prepare(sql)
        If $$$ISERR(sc) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
        }
        Set tResult = tStatement.%Execute()
        While tResult.%Next() {
            Do result.%Push(
                {
                    "name": (tResult.%Get("Name")),
                    "description": (tResult.%Get("Description")),
                    "last_modified": (tResult.%Get("LastModified"))
                }
            )
        }
        Write result.%ToJSON()
    } Catch ex {
        Set sc=ex.AsStatus()
    }
    Return sc
}

ClassMethod ExportProject(ProjectId As %String) As %Status
{
    Set sc = $$$OK
    ; Ignora l'output REST per evitare di restituire all'IO di default (risposta REST) il contenuto di eventuali write inseriti nei metodi invocati
    Set %response.IgnoreRESTOutput=1
    Try {
        If ProjectId = "" { 
            Set sc = $$$ERROR($$$GeneralError,"ProjectId is required.")
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
        }

        #; Set out = {}

        // Check if the TEMPFILEPATH directory exists, create it if not
        Set path = ##class(PackageManager.Utility.Utils).AdaptPathToOS($$$tmpFilePath)
        Set sc = ##class(PackageManager.Utility.Utils).DirExists(path,1,.exists)
        If $$$ISERR(sc) { Throw ##class(%Exception.StatusException).CreateFromStatus(sc) }
        If 'exists { 
            Set sc = $$$ERROR($$$GeneralError,"The directory "_path_" does not exist.")
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
        }

        // Generate a temporary file name
        Set now = $NOW()
        Set release = "release"
        Set format = ".xml"
        Set datetime = $TRANSLATE($ZDATE(now,3),"-","")_"_"_$TRANSLATE($ZTIME(now,1),":","")
        Set fileName = ProjectId_"_"_release_"_"_datetime_format
        Set filePath = path_fileName

        Set project = ##class(%Studio.Project).%OpenId(ProjectId)
        If '$ISOBJECT(project) {
            Set sc = $$$ERROR($$$GeneralError, "Project with ID "_ProjectId_" does not exist.")
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
        }
        // Export project, compile, keep source, and include dependencies
        Set sc = project.Export(.filePath, "cuk", 0, .err)
        If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc)

        // Open the f xml file as a stream and return it within the JSON response
        Set xmlFile = ##class(%Stream.FileCharacter).%New()
        Set outputStream = ##class(%Stream.GlobalCharacter).%New()
        Set sc=xmlFile.LinkToFile(filePath)
        While 'xmlFile.AtEnd {
            Set line=xmlFile.Read()
            Do outputStream.Write(line)
        }

        // Delete the log file and the temporary csv file to save space
        Do ##class(%File).Delete(filePath)

        Set %response.ContentType = ..#CONTENTTYPETEXT
        ; Ripristina l'output REST per restituire all'IO di default (risposta REST) il contenuto dell'oggetto response
        Set %response.IgnoreRESTOutput=0
        Do outputStream.Rewind()
        Do outputStream.OutputToDevice()
        #; Set out.stream = outputStream.Read()
        #; Set out.fileName = fileName
        #; Set out.createdTime = $ZDATETIME($HOROLOG,3,5)
        #; Set out.filePath = filePath
        #; Do ..WriteResponse(.out, sc)
        
    } Catch ex {
        Set sc=ex.AsStatus()
        Do ..WriteResponse(.out, sc)
    }
    Return sc
}

ClassMethod GetProjectContent(ProjectId As %String = "") As %Status
{
    Set sc = $$$OK
    Try {    
        Set result = {}  // This will be a JSON object
        Set Args = 0
        Set sql = "SELECT Project, Name, Type FROM %Studio.ProjectItem "
        If ProjectId'="" {
            Set sql = sql_" WHERE Project = ?"
            Set Args($INCREMENT(Args)) = ProjectId
        }
        Set sql = sql_" ORDER BY Project, Name"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set sc = tStatement.%Prepare(sql)
        If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc)

        Set tResult = tStatement.%Execute(Args...)
        While tResult.%Next() {
            Set currProject = tResult.%Get("Project")
            Set item = tResult.%Get("Name")
            Set type = tResult.%Get("Type")

            // Make sure project array exists
            If '$ISOBJECT(result.%Get(currProject)) {
                Do result.%Set(currProject, {})
            }

            If type = "PKG" {
                // Expand package to classes
                Set sc = $SYSTEM.OBJ.GetPackageList(.pkgItems, item, "/mapped/includesubpackages")
                Set childName = ""
                For {
                    Set childName = $ORDER(pkgItems(childName))
                    Quit:childName=""
                    // Determine type (CLS or MAC/INC)
                    If ##class(%Dictionary.CompiledClass).%ExistsId(childName) {
                        Set childType = "CLS"
                    } Else {
                        Set childType = "MAC"
                        Set extension = $EXTRACT(childName, *-3, *)
                        If extension = ".MAC" {
                            Set childType = "MAC"
                        } ElseIf extension = ".INC" {
                            Set childType = "INC"
                        } Else {
                            // For uncompiled classes 
                            Set childType = "CLS"
                        }
                    }
                    Set sc = ##class(PackageManager.Utility.Utils).CreateNestedObject(childName, childType, currProject, .result)
                }
            } ElseIf type = "MAC" {
                Set extension = $EXTRACT(item, *-3, *)
                If extension = ".MAC" {
                    Set childType = "MAC"
                } ElseIf extension = ".INC" {
                    Set childType = "INC"
                }
                Set childName = $PIECE(item, "."_childType, 1)
                Set sc = ##class(PackageManager.Utility.Utils).CreateNestedObject(childName, childType, currProject, .result)
            } ElseIf type = "DIR" {
                Set childName = item, childType = type
                Set sc = ##class(PackageManager.Utility.Utils).JSONFolderTree(item,currProject,.result)
            } ElseIf type = "CLS" {
                Set extension = $EXTRACT(item, *-3, *)
                Set childType = type
                Set childName = $PIECE(item, "."_childType, 1)
                Set sc = ##class(PackageManager.Utility.Utils).CreateNestedObject(childName, childType, currProject, .result)
            } ElseIf type = "CSP" {
                Set extension = $PIECE(item, ".", 2)
                Set childType = type
                Set childName = $PIECE(item, "."_childType, 1)
                If $ZCONVERT(extension,"L") '= "csp" {
                    Set childName = $PIECE(item, "."_extension, 1)
                }
                Set sc = ##class(PackageManager.Utility.Utils).CreateNestedObject(childName, childType, currProject, .result, "/", extension)
            } Else {
                Set extension = $EXTRACT(item, *-3, *)
                Set childType = type
                Set childName = $PIECE(item, "."_childType, 1)
                Set sc = ##class(PackageManager.Utility.Utils).CreateNestedObject(childName, childType, currProject, .result)
            }
        }

        //Set %response.ContentType = "application/json"
        Write result.%ToJSON()
    } Catch ex {
        Set sc = ex.AsStatus()
        Set %response.Status = 500
        Write "Error: "_$SYSTEM.Status.GetErrorText(sc)
    }

    Return sc
}

ClassMethod UpdateProjectDesc(projectId As %String) As %Status
{
    Set sc = $$$OK
    Try {
        If projectId = "" {
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"ProjectId è un campo obbligatorio")) 
        }
        Set body = %request.Content.Read()
        Set json = {}.%FromJSON(body)
        Set name = json."originalName"
        Set desc = json."desc"
        If name'="" {
            Set proj = ##class(%Studio.Project).NameIdxOpen(name)
            Set proj.Description = desc
            Set sc = proj.%Save()
            If $$$ISERR(sc) {
                Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
            }
        } Else {
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Name è un campo obbligatorio")) 
        }
    } Catch ex {
        Set sc=ex.AsStatus()
        Do ..WriteResponse(.res,sc)
    }
    Return sc
}

ClassMethod DeleteProject(projectId As %String) As %Status
{
    Set sc = $$$OK
    Try {
        If projectId = "" {
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"ProjectId è un campo obbligatorio")) 
        }
        Set sc = ##class(%Studio.Project).NameIdxDelete(projectId)
        If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 

        // Update the export task table to deactivate the deleted project
        &SQL( UPDATE PackageManager_Task.ProjectToExport SET Active = 0 WHERE ProjectId = :projectId )
        If SQLCODE < 0 {
            Set sc = $$$ERROR($$$GeneralError, "It was impossible to disable the project export for "_projectId_".")
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
        }
    } Catch ex {
        Set sc=ex.AsStatus()
        Do ..WriteResponse(.res,sc)
    }
    Return sc
}

ClassMethod AddClassesToProject(projectId As %String) As %Status
{
    Set sc = $$$OK
    ; Ignora l'output REST per evitare di restituire all'IO di default (risposta REST) il contenuto di eventuali write inseriti nei metodi invocati
    Set %response.IgnoreRESTOutput=1
    Try {
        Set body = %request.Content.Read()
        Set json = {}.%FromJSON(body)
        Set elements = json."elements"

        If '##class(%Studio.Project).NameIdxExists(projectId) {
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Project with ID "_projectId_" does not exist!")) 
        } 
        Set proj = ##class(%Studio.Project).NameIdxOpen(projectId)

        Set iter = elements.%GetIterator()
        While iter.%GetNext(.key, .value) { 
            Set element = value."name"
            Set sc = proj.AddItem(element)
            If $$$ISERR(sc) {
                Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
            }
        }
        Set sc = proj.%Save()        
    } Catch ex {
        Set sc=ex.AsStatus()
        Do ..WriteResponse(.out, sc)
    }
    Return sc
}

ClassMethod RemoveClassesToProject(projectId As %String) As %Status
{
    Set sc = $$$OK
    ; Ignora l'output REST per evitare di restituire all'IO di default (risposta REST) il contenuto di eventuali write inseriti nei metodi invocati
    Set %response.IgnoreRESTOutput=1
    Try {
        Set body = %request.Content.Read()
        Set json = {}.%FromJSON(body)
        Set elements = json."elements"

        If '##class(%Studio.Project).NameIdxExists(projectId) {
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Project with ID "_projectId_" does not exist!")) 
        } 
        Set proj = ##class(%Studio.Project).NameIdxOpen(projectId)

        Set iter = elements.%GetIterator()
        While iter.%GetNext(.key, .value) { 
            Set element = value."name"
            Set ^CacheTemp("RemoveClassesToProject",element) = ""
            Set sc = proj.RemoveItem(element)
            If $$$ISERR(sc) {
                Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
            }
        }
        Set sc = proj.%Save()        
    } Catch ex {
        Set sc=ex.AsStatus()
        Do ..WriteResponse(.out, sc)
    }
    Return sc
}

}
