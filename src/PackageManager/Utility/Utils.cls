Include PackageManager.PackageManager

/// This class provides utility methods for working with file systems, CSP directories, and JSON data structures.
/// It includes methods for creating nested JSON structures from file systems, defining objects from CSP file names,
/// and registering web applications.
/// 
/// The class is designed to be used in the context of the InterSystems IRIS platform and provides functionality
/// for working with CSP directories, file systems, and JSON data.
Class PackageManager.Utility.Utils [ Final ]
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
    // Switch to %SYS namespace to get more privileges
    New $NAMESPACE
    Set $NAMESPACE = "%SYS"
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

/// This print the current IRIS instance URL, Server and Port
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

/**
 * Creates a nested object structure within the provided result object.
 * 
 * @param {string} item - The base name of the object to create.
 * @param {string} type - The type of object to create (e.g. "csp" or other).
 * @param {string} currProject - The current project name.
 * @param {object} result - The object to create the nested structure within.
 * @param {string} [Separator="."] - The separator to use when splitting the item name.
 * @param {string} [CSPExtension=""] - An optional extension to use for CSP files.
 * 
 * @returns {status} - The status of the operation.
 * 
 * @description
 * This method creates a nested object structure within the provided result object.
 * It extracts the base name from the item parameter, and then creates a nested object
 * structure based on the type and project name. If the type is "csp", it uses a
 * specific root node, otherwise it uses a different root node. It then creates or
 * gets the nested container and sets the metadata for the leaf node.
 */
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

/// Creates a nested object structure from a CSP file name.
/// This method takes a CSP file name and creates a nested object structure 
/// representing the package hierarchy. The resulting object is stored in 
/// the rootElement parameter. 
/// 
/// Parameters: 
///     - rootElement: The root element of the object structure to be created. 
///     - Name: The CSP file name to be processed. 
///     - separator: The separator character used in the file name. 
/// 
/// Returns: 
///     - A status code indicating success or failure. 
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

/// Creates a nested object structure from a class or routine file name.
/// This method takes a class or routine file name and creates a nested object structure 
/// representing the package hierarchy. The resulting object is stored in 
/// the rootElement parameter.
/// 
/// Note that this method is similar to DefineObjFromCSP, but it handles 
/// class and routine files differently by removing the last two elements
/// from the file name and joining them into a single last element
/// 
/// Parameters: 
///     - rootElement: The root element of the object structure to be created. 
///     - Name: The class or routine file name to be processed. 
///     - separator: The separator character used in the file name. 
/// 
/// Returns: 
///     - A status code indicating success or failure. 
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

}
