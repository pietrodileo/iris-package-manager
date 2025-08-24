Class PackageManager.API.Namespace.Interface Extends PackageManager.API.REST [Final]
{

/// This method retrieves all files in the current namespace, including classes, routines, and CSP files.
/// It returns a list of JSON objects, each representing a file or directory.
/// It uses the %Library.RoutineMgr_StudioOpenDialog function to query the files.
/// It can filter by type if specified.
/// If no type is specified, it retrieves all files.
/// The result is a JSON object with nested objects for each file type.
/// It supports any kind of ObjectScript file, including classes, routines, and CSP files, and JavaScript, HTML, CSS, and all other file types usable in csp pages as well.
ClassMethod GetAllNamespaceFiles(type As %String = "") As %Status
{
    Set sc = $$$OK
    Try {        
        Set packageName = $GET(%request.Data("PackageName",1))
        Set result = {}
        Set sql = "SELECT Name, Type FROM %Library.RoutineMgr_StudioOpenDialog(?,?,?,?,?,?,?)"
        // Define arguments
        Set spec = ""
        If packageName'="" {
            Set spec = packageName
        }
        If type="" {
            Set spec = spec_"*"
        } Else {
            Set spec = spec_"*."_type
        }
        Set dir = 1
        Set orderBy = 1 // 1 for name, 2 for date, 3 for size, 4 for type, 5 for name of the file sorted case sensitively
        Set systemFiles = 0 // 1 to include system files, 0 to exclude them
        Set flat = 1 // If Flat is true then it does not display directories but displays everything at the root level.
        Set notstudio = 0 // If NotStudio is true then it will display globals and OBJ routines as well, for Studio we exclude these types.
        Set showGenerated = 0 // The ShowGenerated argument controls if this query includes items that are generated from another item, such as INT code that is generated from a class compilation.        
        Set tStatement = ##class(%SQL.Statement).%New()
        Set sc = tStatement.%Prepare(sql)
        If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
        Set tResult = tStatement.%Execute(spec,dir,orderBy,systemFiles,flat,notstudio,showGenerated)
        Set filesFormats = $LISTBUILD("CSP","MAC","INC","INT","CLS")
        While tResult.%Next() {
            Set Name = tResult.%Get("Name")
            Set Type = ##class(PackageManager.Utility.Utils).TranscodeType(tResult.%Get("Type"))
            // Create a JSON object containing nested objects for the packages and csp files
            #; w Name," - ",Type,!
            If $LISTFIND(filesFormats, Type)'=0 {
                Set rootType = Type
            } Else {
                Set rootType = "Other"
            }
            // Ensure project root exists in result
            If '$ISOBJECT(result.%Get(rootType)) {
                Do result.%Set(rootType, ##class(%DynamicObject).%New())
            }
            Set rootElement = result.%Get(rootType)
            If rootType = "CSP" {
                Set sc = ##class(PackageManager.Utility.Utils).DefineObjFromCSP(.rootElement, Name, "/")  
            } ElseIf $LISTFIND(filesFormats, Type)'=0 {
                Set sc = ##class(PackageManager.Utility.Utils).DefineObjFromCLSOrRoutine(.rootElement, Name, ".")  
            } ElseIf rootType = "Other" {
                // For other types, we can just add them directly
                If '$ISOBJECT(rootElement.%Get(Name)) {
                    Do rootElement.%Set(Name, {
                        "name": (Name),
                        "type": (Type)
                    })
                }
            }
        }
        // Write the result as JSON
        #; Set %response.ContentType = "application/json"
        #; Write result.%ToJSON()
        Do ..WriteResponse(.result, sc) 
    } Catch ex {
        Set sc = ex.AsStatus()   
        Do ..WriteResponse(.out, sc) 
    }
    Return sc
}

}
