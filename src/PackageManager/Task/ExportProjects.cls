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
            Set sc = ..ExportProject(ProjectId, ..TaskID) 
            If $$$ISERR(sc) { Throw ##class(%Exception.StatusException).CreateFromStatus(sc) }
        }
    } Catch ex {
        Set sc=ex.AsStatus()
    }
    Return sc
}

/// This method exports a project by its ID.
/// It checks if the project exists, creates a file name, and exports the project to a file.
ClassMethod ExportProject(ProjectId As %String, TaskID As %String) As %Status
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

        // Check if the TEMPFILEPATH directory exists, create it if not
        Set basePath = ##class(PackageManager.Utility.Utils).AdaptPathToOS($$$exportTaskFilePath, .osSeparator)
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
        Set now = $NOW()
        Set release = "taskId_"_TaskID
        Set format = ".xml"
        Set datetime = $TRANSLATE($ZDATE(now,3),"-","")_"_"_$TRANSLATE($ZTIME(now,1),":","")
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
    }
    Return sc
}

ClassMethod GetClassName() As %String
{
    Return ..%ClassName(1)
}

}
