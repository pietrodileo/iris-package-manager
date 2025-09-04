Include PackageManager.PackageManager

Class PackageManager.Task.ExportProjects Extends %SYS.Task.Definition
{

/// Task Name
Parameter TaskName = "Export Projects Utility";

/// ID of the related %SYS.Task definition
Property TaskID As %String;

/// Enable automatic purge of old exported files
/// If enabled, old exported files will be automatically deleted based on the retention policy
/// defined by the user. If disabled, old exported files will be kept indefinitely.
Property EnablePurge As %Boolean [ InitialExpression = 0 ];

/// Number of days after which exported files are considered old and eligible for deletion
Property PurgeAfterNDays As %Integer [ InitialExpression = 60 ];

/// As a security measure, the task will always keep a minimum number of recent exported files 
/// even if they are older than the retention period.
Property MinimumNumberOfFilesToKeep As %Integer [ InitialExpression = 5 ];

/// The path where the exported files will be stored.
/// If empty, the default path will be used (##class(PackageManager.Config).#EXPPATH)
Property ExportDirectory As %String;

Parameter releasePrefix = "taskId_";

Parameter exportFormat = ".xml";

/// Workaround to test the task using the debugger
ClassMethod TestTask() As %Status
{
    Set sc = $$$OK
    Set task = ..%New()
    Set sc = task.OnTask()  
    Return sc
}

Method OnTask() As %Status
{
	Set sc = $$$OK
	Try {
		Set Today = $zdate($h,4)		
        // set the export path or use the default
        Set ExportDirectory = $SELECT(..ExportDirectory'="":..ExportDirectory,1:##class(PackageManager.Config).#EXPPATH) 
		Set sql = "SELECT ProjectId FROM PackageManager_Task.ProjectToExport "
            _" WHERE Active = 1 "
            _" AND TaskID = ? "
            //_" AND CURRENT_DATE >= DateFrom "
            //_" AND ( DateTo IS NULL OR CURRENT_DATE <= DateTo ) "
        Set tStatement = ##class(%SQL.Statement).%New()
        Set sc = tStatement.%Prepare(sql)
        If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
        Set tResult = tStatement.%Execute(..TaskID) 
        While tResult.%Next() {
            Set ProjectId = tResult.%Get("ProjectId")
            Set sc = ..ExportProject(ProjectId, ..TaskID, ExportDirectory) 
            If $$$ISERR(sc) { Throw ##class(%Exception.StatusException).CreateFromStatus(sc) }

            // If the export has been completed successfully, eventually purge old files
            If ..EnablePurge {
                Set sc = ..PurgeOldFiles(ProjectId, ..TaskID, ..PurgeAfterNDays, ..MinimumNumberOfFilesToKeep)
                If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
            }
        }
    } Catch ex {
        Set sc=ex.AsStatus()
    }
    Return sc
}

/// This method exports a project by its ID.
/// It checks if the project exists, creates a file name, and exports the project to a file.
ClassMethod ExportProject(ProjectId As %String, TaskID As %String, ExportDirectory As %String) As %Status
{
    Set sc = $$$OK
    Try {
        If ProjectId = "" { 
            Set sc = $$$ERROR($$$GeneralError,"ProjectId is required.")
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
        }
        If TaskID = "" { 
            Set sc = $$$ERROR($$$GeneralError,"TaskID is required.")
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
        }

        // Check if the export directory exists, create it if not
        Set basePath = ##class(PackageManager.Utility.Utils).AdaptPathToOS(ExportDirectory, .osSeparator)
        // Check if the last char is a separator, if not add it
        If $EXTRACT(basePath,$LENGTH(basePath)) '= osSeparator {
            Set basePath = basePath_osSeparator
        }
        Set prjFilePath = basePath_ProjectId_osSeparator
        Set sc = ##class(PackageManager.Utility.Utils).DirExists(prjFilePath,1,.exists)
        If $$$ISERR(sc) { Throw ##class(%Exception.StatusException).CreateFromStatus(sc) }
        If 'exists { 
            Set sc = $$$ERROR($$$GeneralError,"The directory "_prjFilePath_" does not exist.")
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
        }

        // Get file version
        If '##class(PackageManager.Task.ProjectToExport).ProjectIdIndexExists(ProjectId,TaskID) {
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"No project associated to the task "_TaskID_" found for the given project ID: "_ProjectId))
        }
        Set prjRecord = ##class(PackageManager.Task.ProjectToExport).ProjectIdIndexOpen(ProjectId,TaskID)
        Set version = prjRecord.Version

        Set sc = prjRecord.IncrementVersion()
        If $$$ISERR(sc) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
        }

        // Generate a temporary file name
        Set release = ..#releasePrefix_TaskID
        Set format = ..#exportFormat
        Set datetime = $TRANSLATE($ZDATE($PIECE($H,",",1),3),"-","")_"_"_$TRANSLATE($ZTIME($PIECE($H,",",2),1),":","")
        Set fileName = ProjectId_"_"_release_"_V"_version_"_"_datetime_format
        
        Set filePath = prjFilePath_fileName

        Set project = ##class(%Studio.Project).%OpenId(ProjectId)
        If '$ISOBJECT(project) {
            Set sc = $$$ERROR($$$GeneralError, "Project with ID "_ProjectId_" does not exist.")
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
        }
        // Export project, compile, keep source, and include dependencies
        Set sc = project.Export(.filePath, "cuk", 0, .err)
        If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
    } Catch ex {
        Set sc=ex.AsStatus()
        w $SYSTEM.Status.GetErrorText(sc),!
    }
    Return sc
}

/// If Purge is enabled, this method will be called to delete old exported files
/// Each task will delete files that he has create (they start with the project id and then the task id)
/// Files will be purged only if older than 'PurgeAfterNDays' days, otherwise they will be kept
/// 
/// A minimum number of file will be kept. 
/// If less than 'MinimumNumberOfFilesToKeep' files are found, all the files will be kept.
/// If more than 'MinimumNumberOfFilesToKeep' files are found, the oldest ones (that are older than 'PurgeAfterNDays') will be deleted until 'MinimumNumberOfFilesToKeep' is reached.
/// 
/// This method accepts the following arguments: 
///     - ProjectId of the project that has been exported 
///     - TaskID that executed the task.
///     - Number of days after which a file is considered old and should be purged
///     - Minimum number of files to keep even if they are expired
///     - An additional verbose argument (default = 0) can be passed to print information about the purge process.
ClassMethod PurgeOldFiles(ProjectId As %String, TaskID As %String, PurgeAfterNDays As %Integer, MinimumNumberOfFilesToKeep As %Integer, verbose As %Boolean = 0) As %Status
{
    Set sc = $$$OK
    Try {    
        // Check if the export directory exists, do not create it if not
        Set basePath = ##class(PackageManager.Utility.Utils).AdaptPathToOS(##class(PackageManager.Config).#EXPPATH, .separator)
        Set prjFilePath = basePath_ProjectId_separator
        Set sc = ##class(PackageManager.Utility.Utils).DirExists(prjFilePath,0,.exists)
        If $$$ISERR(sc) { Throw ##class(%Exception.StatusException).CreateFromStatus(sc) }
        If 'exists { 
            // The directory does not exist, no files to purge
            Return sc
        }
        // Look for files starting with 
        Set filenameStart = ..#releasePrefix_TaskID
        Set format = ..#exportFormat

        // Define base path and initialize stack for directories
        Kill FILES
        Set FILES($INCREMENT(FILES)) = prjFilePath

        // list of files to purge
        Kill PURGELIST

        // Scan the export directory looking for older files
        Set key = ""
        For {
            Set key = $ORDER(FILES(key), 1, searchdir)
            Quit:key=""

            Set filepath = $ZSEARCH(searchdir_"*")
            While filepath'="" {
                Set filename = ##class(%File).GetFilename(filepath)

                // Skip special entries
                If (filename'=".") && (filename'="..") {
                    If verbose Write "file: "_filepath_" " 
                    // If it is a directory, add it to the stack for further inspection
                    If ##class(%File).DirectoryExists(filepath) {
                        If verbose Write "is a directory",!
                        Set FILES($INCREMENT(FILES)) = filepath_separator  // Add subdir to stack
                    // If it is a file, insert it into the directory node
                    } Else {
                        If verbose Write "is a file",! 
                        If (filename[filenameStart)&&(filename[format) {
                            Set toPurge = 0
                            // Get file information                      
                            Set dataCreatedLogic = ##class(%File).GetFileDateCreated(filepath)
                            Set fileSize = ##class(%File).GetFileSize(filepath)
                            // Check if the files should be purged
                            Set dataCreated = $ZDATETIME(dataCreatedLogic,3)
                            Set dayCreated = $PIECE(dataCreatedLogic,",")
                            Set daysDifference = $H - dayCreated
                            If daysDifference >= PurgeAfterNDays {
                                Set toPurge = 1
                            }
                            If verbose w filename_" - data created "_dataCreated_" (diff "_daysDifference_" days)- size "_fileSize_" - Purge "_toPurge,!
                            If toPurge {
                                // Add the file to the list of the files to purge
                                Set PURGELIST($INCREMENT(PURGELIST)) = filepath
                            }
                        } Else {
                            // File does not match the pattern, skip it
                            if verbose Write "File does not match the pattern, skipping it",!
                        }
                    }
                }
                Set filepath = $ZSEARCH("")  // Next entry
            }
        }
        If ($GET(PURGELIST) = "" || ($GET(PURGELIST) = 0)) {
            If verbose Write "No file to purge",!
        } Else {
            If verbose Write "Files to purge: "_$GET(PURGELIST),!
            If ($GET(PURGELIST) < MinimumNumberOfFilesToKeep) {
                // Interrupt the process and keep all the files
                If verbose Write "Keeping all the files",!
                Return sc
            }
            // Purge the older files
            Set filesToDelete = $GET(PURGELIST) - MinimumNumberOfFilesToKeep
            If verbose Write "Deleting the oldest "_filesToDelete_" files",!
            Set deletedCount = 0
            Set key = ""
            For {
                Set key = $ORDER(PURGELIST(key))
                Quit:key=""
                Set filepath = $GET(PURGELIST(key))
                w filepath,! 
                // Older filepaths come first inside the array
                If ##class(%File).Delete(filepath) {
                    Set deletedCount = deletedCount + 1
                    If verbose Write "Deleted "_filepath,!
                } Else {
                    Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Failed to delete "_filepath)) 
                }
                If deletedCount = filesToDelete {
                    Quit
                }
            }
        }
    } Catch ex {
        Set sc=ex.AsStatus()
        If verbose Write "Error :"_$SYSTEM.Status.GetErrorText(sc),!
    }
    Return sc
}

ClassMethod GetClassName() As %String
{
    Return ..%ClassName(1)
}

}
