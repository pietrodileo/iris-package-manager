Class PackageManager.API.Task.Interface Extends PackageManager.API.REST [Final]
{

/// This method creates a new record for the export task within the task manager
ClassMethod CreateTask() As %Status
{
    Set sc = $$$OK
    ; Ignora l'output REST per evitare di restituire all'IO di default (risposta REST) il contenuto di eventuali write inseriti nei metodi invocati
    Set %response.IgnoreRESTOutput=1
    Try {
        Set out = {}

        Set body = %request.Content.Read()
        Kill ^CacheTemp("task")  
        Set ^CacheTemp("task","body") = body
        Set json = {}.%FromJSON(body)
        Set TaskDesc = json."task_desc"
        Set TaskName = json."task_name"
        Set endDate = $SELECT(json."schedule"."endDate"="":"", 1:$ZDATEH(json."schedule"."endDate",3))
        Set runTime = $ZTIMEH(json."schedule"."runTime", 1)
        Set startDate = $ZDATEH(json."schedule"."startDate",3)
        Set type = json."schedule"."type"
        Set priority = json."schedule"."priority"

        If TaskName="" Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"TaskName is required."))

        /// 0 - DAILY<br>
        /// 		TimePeriodEvery - Run every x Days, where Days are 1-7<br>
        /// 		TimePeriodDay - Set to "", ignored<br><br>
        /// 1 - WEEKLY<br>
        /// 		TimePeriodEvery - Run every x Weeks, where weeks are 1-5<br>
        /// 		TimePeriodDay - Run on days xxxx, where Sunday=Day 1,Saturday=Day 7<br>
        /// 						(where 23456 would be Monday thru Friday)<br><br>
        /// 2 - MONTHLY<br>
        /// 		TimePeriodEvery - Run every x Months, where months are 1-12<br>
        /// 		TimePeriodDay - Run on day x, where day=1-31, where 31=last day of month<br><br>
        /// 5 - ONCE <br>
        ///         Task is not scheduled to run. Task is scheduled to run by calling the RunOnce method        
        Set TimePeriod = $SELECT(type="daily":0, type="weekly":1, type="monthly":2,type="once":5,1:"")
        Set ^CacheTemp("task","TimePeriod") = TimePeriod
        Set ^CacheTemp("task","startDate") = startDate
        Set ^CacheTemp("task","runTime") = runTime

        Set TimePeriodDay ="", TimePeriodEvery = ""
        If TimePeriod="" Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Invalid schedule type"))
        If TimePeriod = 0 {
            Set TimePeriodEvery = json."schedule"."everyNDays"
            If TimePeriodEvery > 7 Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Invalid daily schedule"))
        } ElseIf TimePeriod = 1 {
            Set TimePeriodEvery = json."schedule"."everyNWeeks"
            If TimePeriodEvery > 5 Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Invalid weekly schedule"))
            Set TimePeriodDay = $REPLACE(json."schedule"."daysOfWeek",",","")
        } ElseIf TimePeriod = 2 {
            Set TimePeriodEvery = json."schedule"."everyNMonths"
            If TimePeriodEvery > 12 Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Invalid monthly schedule"))
            Set TimePeriodDay = json."schedule"."dayOfMonth"
        }
        Set ^CacheTemp("task","TimePeriodEvery") = TimePeriodEvery
        Set ^CacheTemp("task","TimePeriod") = TimePeriod
        Set ^CacheTemp("task","TaskName") = TaskName
        Set ^CacheTemp("task","TimePeriodDay") = TimePeriodDay

        Set task=##class(%SYS.Task).%New()
        /// Name of the task must be 50 characters or less, first character must be a letter.
        /// Note that Names longer than 50 characters will be truncated.
        Set task.Name=TaskName
        Set task.Description=$SELECT(TaskDesc="":$$$defaultTaskDescription, 1:TaskDesc)
        Set task.NameSpace=$NAMESPACE
        Set task.TimePeriod=TimePeriod // If 0, runs daily, 1 runs weekly, 2 runs monthly
        Set task.TimePeriodEvery=TimePeriodEvery // Runs every n days, weeks or months
        Set task.StartDate=startDate
        Set task.Priority=priority
        If endDate'="" { Set task.EndDate=endDate } // If blank, task never expires
        If TimePeriodDay'="" { Set task.TimePeriodDay=TimePeriodDay } // If blank, task never expires

        /// Run every day<br>
        /// TimePeriod=0,TimePeriodEvery=1,TimePeriodDay=""<br><br>
        /// Run every other day<br>
        /// TimePeriod=0,TimePeriodEvery=2,TimePeriodDay=""<br><br>
        /// Run every Sunday<br>
        /// TimePeriod=1,TimePeriodEvery=1,TimePeriodDay=1<br><br>
        /// Run every Monday through Friday<br>
        /// TimePeriod=1,TimePeriodEvery=1,TimePeriodDay=23456<br><br>
        /// Run every other Saturday<br>
        /// TimePeriod=1,TimePeriodEvery=2,TimePeriodDay=7<br><br>
        /// Run the first day of every month<br>
        /// TimePeriod=2,TimePeriodEvery=1,TimePeriodDay=1<br><br>
        /// Run the last day of every month<br>
        /// TimePeriod=2,TimePeriodEvery=1,TimePeriodDay=31<br><br>
        /// Run the last day of every other month<br>
        /// TimePeriod=2,TimePeriodEvery=2,TimePeriodDay=31<br><br>
        /// Run the second Saturday of every month<br>
        /// TimePeriod=3,TimePeriodEvery=1,TimePeriodDay=2^7<br><br>
        /// Run the first Sunday of every month<br>
        /// TimePeriod=3,TimePeriodEvery=1,TimePeriodDay=1^1<br><br>


        /// 0 - ONCE - Run once on the day scheduled<br>
        /// 		DailyFrequencyTime - "", ignored<br>
        /// 		DailyIncrement - "", ignored<br>
        /// 		DailyStartTime - Time for task to run in $H format($p($h,",",2))<br>
        /// 		DailyEndTime - "",ignored<br><br>
        /// 1 - SEVERAL - Run Several times in a day<br>
        /// 		DailyFrequencyTime - 0 - Run every x minutes<br>
        /// 		DailyFrequencyTime - 1 - Run every x hours<br>
        /// 		DailyIncrement - # of minutes between runs or # of hours between runs<br>
        /// 		DailyStartTime - Time for tasks to start running in $H format($p($h,",",2))<br>
        /// 		DailyEndTime - Time for task to stop running in $H format($p($h,",",2))<br><br>
        Set task.DailyFrequency=0 // How many times a day it runs
        Set task.DailyFrequencyTime=""
        Set task.DailyIncrement=""
        Set task.DailyStartTime=runTime
        Set task.DailyEndTime=""
        Set TaskToRun = ##class(PackageManager.Task.ExportProjects).%New()
        Do task.AssignSettings(TaskToRun)
        Set task.TaskClass=$CLASSNAME(TaskToRun)

        /// A comma separated list of email addresses to send a completion notification to.
        // EmailOnCompletion
        /// A comma separated list of email addresses to send an error notification to.
        // EmailOnError
        /// A comma separated list of email addresses to send notification if the task expires.
        // EmailOnExpiration
        /// If an output directory and output file are chosen, and EmailOutput is
        /// set to 1 the output from the entry will be emailed to the email 
        /// addresses in the EmailOnCompletion property
        // EmailOutput
        /// If an output directory and output file are chosen, the output from
        /// the entry will be directed there.
        // Property OutputDirectory As %String(MAXLEN = 1024);

        Set sc = task.%Save()
        If $$$ISERR(sc) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
        }

        Set taskId = task.%Id()
        // Settings for the task properties 
        set task.Settings=$LB("TaskID",taskId) 
        Set sc = task.%Save()
        If $$$ISERR(sc) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
        }


        If TimePeriod = 5 {
            // If task should run once, schedule it now
            Set sc = task.ScheduleAt(startDate_","_runTime)
            If $$$ISERR(sc) {
                Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
            }
        }
    }
    Catch ex {
        Set sc=ex.AsStatus()
        Do ..WriteResponse(.res, sc)
    }
    Return sc
}

ClassMethod CheckExistingTasks() As %Status
{
    Set sc = $$$OK
    Try {
        Set %response.IgnoreRESTOutput=1
        Set res = {}
        Set sql = "SELECT ID,Name,Description,NameSpace,Priority,Suspended,"
	            _" DisplayRun,DisplayInterval,DisplayDayNextScheduled,TimeNextScheduled,"
                _" DisplayStartDate,DisplayEndDate,DisplayStarted,DisplayFinished,"
                _" DisplayStatus,Error,DisplayErrorDate,DisplayErrorNumber" 
	            _" FROM %SYS.Task "
	            _" WHERE TaskClass=? "
        //w sql,!
        Set tStatement = ##class(%SQL.Statement).%New()
        Set sc = tStatement.%Prepare(sql)
        If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
        // Define the query to get the projects associated with a task
        Set getPrjSQL = "SELECT ProjectId " 
            _" FROM PackageManager_Task.ProjectToExport"
            _" WHERE TaskID = ? "
            _" AND Active = 1 "
        Set prjTStatement = ##class(%SQL.Statement).%New()
        Set sc = prjTStatement.%Prepare(getPrjSQL)
        If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
        // Execute the first query to get the task data
        Set tResult = tStatement.%Execute(##class(PackageManager.Task.ExportProjects).GetClassName())
        Set elements = []
        While tResult.%Next() {
            If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
            Set prjTResult = prjTStatement.%Execute(tResult.%Get("ID"))
            Set projects = []
            While prjTResult.%Next() {
                // Get the projects associated with the task
                Do projects.%Push({
                    "ProjectId":(prjTResult.%Get("ProjectId"))
                })
            }
            Do elements.%Push({
                "ID":(tResult.%Get("ID")),
                "Name":(tResult.%Get("Name")),
                "Description":(tResult.%Get("Description")),
                "NameSpace":(tResult.%Get("NameSpace")),
                "Priority":(tResult.%Get("Priority")),
                "Suspended":(tResult.%Get("Suspended")), // Suspended: 1 or 0
                "DisplayStarted":(tResult.%Get("DisplayStarted")), // Last time started
                "DisplayFinished":(tResult.%Get("DisplayFinished")), // Last time finished
                "DisplayStatus":(tResult.%Get("DisplayStatus")), // Task status (1 or Error)
                "DisplayRun":(tResult.%Get("DisplayRun")), // How many times it runs
                "DisplayInterval":(tResult.%Get("DisplayInterval")), // How many minutes between runs
                "DisplayDayNextScheduled":(tResult.%Get("DisplayDayNextScheduled")), // Next day the task runs
                "TimeNextScheduled": ($ZTIME((tResult.%Get("TimeNextScheduled")))), // Next time the task runs
                "DisplayStartDate":(tResult.%Get("DisplayStartDate")), // Overall start date of the task (before it task won't run)
                "DisplayEndDate":(tResult.%Get("DisplayEndDate")), // Overall end date of the task (after it task won't run anymore)
                "Projects": (projects) // List of projects associated with the current task
            })            
        }
        Do res.%Set("tasks", elements)
        //w res.%ToJSON(),!
    }
    Catch ex {
        Set sc=ex.AsStatus()
    }
    Do ..WriteResponse(.res, sc)
    Return sc
}

ClassMethod DeleteTask(taskId As %String) As %Status
{
    Set sc = $$$OK
    Try {
        If taskId = "" {
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"TaskId è un campo obbligatorio")) 
        }
        Set sc = ##class(%SYS.Task).%DeleteId(taskId)
        If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
    } Catch ex {
        Set sc=ex.AsStatus()
        Do ..WriteResponse(.res,sc)
    }
    Return sc
}

ClassMethod RunTask(taskId As %String) As %Status
{
    Set sc = $$$OK
    Try {
        If taskId = "" {
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"TaskId è un campo obbligatorio")) 
        }
        Set Task = ##class(%SYS.Task).%OpenId(taskId)
        If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
        Set sc = Task.RunTask()
        If $$$ISERR(sc) { 
            // Try by creating a task schedule for now. This could be a delay of 60 seconds
            Set tSc = Task.ScheduleAt($H)
            If $$$ISERR(tSc) { 
                // Throw both errors
                Throw ##class(%Exception.StatusException).CreateFromStatus($$$ADDSC(sc,tSc)) 
            } Else {
                // If the task has been scheduled correctly, return the status
                Set sc = tSc
            }
        }
    } Catch ex {
        Set sc=ex.AsStatus()
        Do ..WriteResponse(.res,sc)
    }
    Return sc
}

ClassMethod GetTaskInfo(taskId As %String) As %Status
{
    Set sc = $$$OK
    ; Ignora l'output REST per evitare di restituire all'IO di default (risposta REST) il contenuto di eventuali write inseriti nei metodi invocati
    Set %response.IgnoreRESTOutput=1
    Try {
        If taskId=""{
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Task Id is required."))
        }  
        If '##class(%SYS.Task).%ExistsId(taskId) { 
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Task not found.")) 
        }
        // Get task info
        Set out = {}
        Set Task = ##class(%SYS.Task).%OpenId(taskId)
        Set out.Name = Task.Name
        Set out.Description = Task.Description
        Set out.NameSpace = Task.NameSpace
        Set out.TimePeriod = Task.TimePeriod
        Set out.TimePeriodEvery = Task.TimePeriodEvery
        Set out.StartDate = $ZDATE(Task.StartDate,3)
        Set out.Priority = Task.Priority
        Set out.EndDate = $SELECT(Task.EndDate="":"", 1:$ZDATE(Task.EndDate,3))
        Set out.TimePeriodDay = Task.TimePeriodDay
        Set out.Suspended = Task.Suspended
        Set out.DisplayRun = Task.DisplayRun
        Set out.DisplayInterval = Task.DisplayInterval
        Set out.DisplayDayNextScheduled = Task.DisplayDayNextScheduled
        Set out.TimeNextScheduled = $SELECT(Task.TimeNextScheduled="":"", 1:$ZTIME(Task.TimeNextScheduled))
        Set out.DisplayStartDate = Task.DisplayStartDate
        Set out.DisplayEndDate = Task.DisplayEndDate
        Set out.DisplayStarted = Task.DisplayStarted
        Set out.DisplayFinished = Task.DisplayFinished
        Set out.DisplayStatus = Task.DisplayStatus
        Set out.Error = Task.Error
        Set out.DisplayErrorDate = $SELECT(Task.DisplayErrorDate="":"", 1:$ZDATE(Task.DisplayErrorDate,3))
        Set out.DisplayErrorNumber = Task.DisplayErrorNumber
        Set out.DailyFrequency = Task.DailyFrequency
        Set out.DailyFrequencyTime = Task.DailyFrequencyTime
        Set out.DailyIncrement = Task.DailyIncrement
        Set out.DailyStartTime = $SELECT(Task.DailyStartTime="":"", 1:$ZTIME(Task.DailyStartTime))
        Set out.DailyEndTime = Task.DailyEndTime
        Set out.TaskClass = Task.TaskClass
        Set out.Settings = Task.Settings
        #; Set out.EmailOnCompletion = $LISTTOSTRING(Task.EmailOnCompletion,",") 
        #; Set out.EmailOnError = Task.EmailOnError
        #; Set out.EmailOnExpiration = Task.EmailOnExpiration
        #; Set out.EmailOutput = Task.EmailOutput
        Set out.OutputDirectory = Task.OutputDirectory
        Do ..WriteResponse(.out, sc)}
    Catch ex {
        Set sc=ex.AsStatus()
        Do ..WriteResponse(.res, sc)
    }
    Return sc
}

/// This method updates an existing record
ClassMethod UpdateTask(taskId As %String) As %Status
{
    Set sc = $$$OK
    ; Ignora l'output REST per evitare di restituire all'IO di default (risposta REST) il contenuto di eventuali write inseriti nei metodi invocati
    Set %response.IgnoreRESTOutput=1
    Try {
        Set out = {}

        If '##class(%SYS.Task).%ExistsId(taskId) {
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"No task found for the given ID: "_taskId))
        }

        Set body = %request.Content.Read()
        Set json = {}.%FromJSON(body)
        Set TaskDesc = json."task_desc"
        Set TaskName = json."task_name"
        Set TaskSuspended = json."task_suspended"
        Set endDate = $SELECT(json."schedule"."endDate"="":"", 1:$ZDATEH(json."schedule"."endDate",3))
        Set runTime = $ZTIMEH(json."schedule"."runTime", 1)
        Set startDate = $SELECT(json."schedule"."startDate"="":"", 1:$ZDATEH(json."schedule"."startDate",3))
        Set type = json."schedule"."type"
        Set priority = json."schedule"."priority"
        If TaskName="" { 
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"TaskName is required."))
        }

        /// 0 - DAILY<br>
        /// 		TimePeriodEvery - Run every x Days, where Days are 1-7<br>
        /// 		TimePeriodDay - Set to "", ignored<br><br>
        /// 1 - WEEKLY<br>
        /// 		TimePeriodEvery - Run every x Weeks, where weeks are 1-5<br>
        /// 		TimePeriodDay - Run on days xxxx, where Sunday=Day 1,Saturday=Day 7<br>
        /// 						(where 23456 would be Monday thru Friday)<br><br>
        /// 2 - MONTHLY<br>
        /// 		TimePeriodEvery - Run every x Months, where months are 1-12<br>
        /// 		TimePeriodDay - Run on day x, where day=1-31, where 31=last day of month<br><br>
        /// 5 - ONCE <br>
        ///         Task is not scheduled to run. Task is scheduled to run by calling the RunOnce method        
        Set TimePeriod = $SELECT(type="daily":0, type="weekly":1, type="monthly":2,type="once":5,1:"")
        Set TimePeriodDay ="", TimePeriodEvery = ""
        If TimePeriod="" {
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Invalid schedule type"))
        }
        If TimePeriod = 0 {
            Set TimePeriodEvery = json."schedule"."everyNDays"
            If TimePeriodEvery > 7 Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Invalid daily schedule"))
        } ElseIf TimePeriod = 1 {
            Set TimePeriodEvery = json."schedule"."everyNWeeks"
            If TimePeriodEvery > 5 Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Invalid weekly schedule"))
            Set TimePeriodDay = $REPLACE(json."schedule"."daysOfWeek",",","")
        } ElseIf TimePeriod = 2 {
            Set TimePeriodEvery = json."schedule"."everyNMonths"
            If TimePeriodEvery > 12 Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Invalid monthly schedule"))
            Set TimePeriodDay = json."schedule"."dayOfMonth"
        }

        /// Name of the task must be 50 characters or less, first character must be a letter.
        /// Note that Names longer than 50 characters will be truncated.
        Set task=##class(%SYS.Task).%OpenId(taskId)
        Set task.Name=TaskName
        Set task.Suspended=TaskSuspended
        Set task.Description=$SELECT(TaskDesc="":"", 1:TaskDesc)
        Set task.NameSpace=$NAMESPACE
        Set task.TimePeriod=TimePeriod // If 0, runs daily, 1 runs weekly, 2 runs monthly
        Set task.TimePeriodEvery=TimePeriodEvery // Runs every n days, weeks or months
        If startDate '= "" {
            Set task.StartDate=startDate 
        } else {
            Set startDate = task.StartDate
        }
        Set task.Priority=priority
        If endDate'="" { 
            Set task.EndDate=endDate // If blank, task never expires
        } 
        If TimePeriodDay'="" { 
            Set task.TimePeriodDay=TimePeriodDay // If blank, task never expires
        }

        /// Run every day<br>
        /// TimePeriod=0,TimePeriodEvery=1,TimePeriodDay=""<br><br>
        /// Run every other day<br>
        /// TimePeriod=0,TimePeriodEvery=2,TimePeriodDay=""<br><br>
        /// Run every Sunday<br>
        /// TimePeriod=1,TimePeriodEvery=1,TimePeriodDay=1<br><br>
        /// Run every Monday through Friday<br>
        /// TimePeriod=1,TimePeriodEvery=1,TimePeriodDay=23456<br><br>
        /// Run every other Saturday<br>
        /// TimePeriod=1,TimePeriodEvery=2,TimePeriodDay=7<br><br>
        /// Run the first day of every month<br>
        /// TimePeriod=2,TimePeriodEvery=1,TimePeriodDay=1<br><br>
        /// Run the last day of every month<br>
        /// TimePeriod=2,TimePeriodEvery=1,TimePeriodDay=31<br><br>
        /// Run the last day of every other month<br>
        /// TimePeriod=2,TimePeriodEvery=2,TimePeriodDay=31<br><br>
        /// Run the second Saturday of every month<br>
        /// TimePeriod=3,TimePeriodEvery=1,TimePeriodDay=2^7<br><br>
        /// Run the first Sunday of every month<br>
        /// TimePeriod=3,TimePeriodEvery=1,TimePeriodDay=1^1<br><br>


        /// 0 - ONCE - Run once on the day scheduled<br>
        /// 		DailyFrequencyTime - "", ignored<br>
        /// 		DailyIncrement - "", ignored<br>
        /// 		DailyStartTime - Time for task to run in $H format($p($h,",",2))<br>
        /// 		DailyEndTime - "",ignored<br><br>
        /// 1 - SEVERAL - Run Several times in a day<br>
        /// 		DailyFrequencyTime - 0 - Run every x minutes<br>
        /// 		DailyFrequencyTime - 1 - Run every x hours<br>
        /// 		DailyIncrement - # of minutes between runs or # of hours between runs<br>
        /// 		DailyStartTime - Time for tasks to start running in $H format($p($h,",",2))<br>
        /// 		DailyEndTime - Time for task to stop running in $H format($p($h,",",2))<br><br>
        
        #; Set task.DailyFrequency=0 // How many times a day it runs
        #; Set task.DailyFrequencyTime=""
        #; Set task.DailyIncrement=""
        Set task.DailyStartTime=runTime
        #; Set task.DailyEndTime=""
        #; Set TaskToRun = ##class(PackageManager.Task.ExportProjects).%New()
        #; Do task.AssignSettings(TaskToRun)
        #; Set task.TaskClass=$CLASSNAME(TaskToRun)
        //set task.Settings=$LB("","") // Settings for the task properties 

        /// A comma separated list of email addresses to send a completion notification to.
        // EmailOnCompletion
        /// A comma separated list of email addresses to send an error notification to.
        // EmailOnError
        /// A comma separated list of email addresses to send notification if the task expires.
        // EmailOnExpiration
        /// If an output directory and output file are chosen, and EmailOutput is
        /// set to 1 the output from the entry will be emailed to the email 
        /// addresses in the EmailOnCompletion property
        // EmailOutput
        /// If an output directory and output file are chosen, the output from
        /// the entry will be directed there.
        // Property OutputDirectory As %String(MAXLEN = 1024);

        Set sc = task.%Save()
        If $$$ISERR(sc) {
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
        }

        If TimePeriod = 5 {
            // If task should run once, schedule it now
            Set sc = task.ScheduleAt(startDate_","_runTime)
            If $$$ISERR(sc) {
                Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
            }
        }
    }
    Catch ex {
        Set sc=ex.AsStatus()
        Do ..WriteResponse(.res, sc)
    }
    Return sc
}

/// This method updates the classes associated to the task
ClassMethod UpdateAssociatedClasses(taskId As %String) As %Status
{
    Set sc = $$$OK
    ; Ignora l'output REST per evitare di restituire all'IO di default (risposta REST) il contenuto di eventuali write inseriti nei metodi invocati
    Set %response.IgnoreRESTOutput=1
    Try {
        Set out = {}

        If '##class(%SYS.Task).%ExistsId(taskId) {
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"No task found for the given ID: "_taskId))
        }

        Set body = %request.Content.Read()
        Set json = {}.%FromJSON(body)
        Set removed = json."removed"
        Set added = json."added"

        Set iterRemoved = removed.%GetIterator()
        While iterRemoved.%GetNext(.key, .removedProjectId) { 
            If '##class(PackageManager.Task.ProjectToExport).ProjectIdIndexExists(removedProjectId,taskId) {
                Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"No project associated to the task "_taskId_" found for the given project ID: "_removedProjectId))
            }
            Set prjRecord = ##class(PackageManager.Task.ProjectToExport).ProjectIdIndexOpen(removedProjectId,taskId)
            // Removed projects are not deleted by default but just disabled
            Set sc = prjRecord.Disable()
            If $$$ISERR(sc) {
                Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
            }
        }

        Set iterAdded = added.%GetIterator()
        While iterAdded.%GetNext(.key, .addedProjectId) { 
            If '##class(%Studio.Project).NameIdxExists(addedProjectId) {
                Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"Project with ID "_addedProjectId_" does not exist!")) 
            } 
            If ##class(PackageManager.Task.ProjectToExport).ProjectIdIndexExists(addedProjectId,taskId) {
                Set prjRecord = ##class(PackageManager.Task.ProjectToExport).ProjectIdIndexOpen(addedProjectId,taskId)
                Set sc = prjRecord.Enable()
                If $$$ISERR(sc) {
                    Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
                }
            } Else {
                Set prjRecord = ##class(PackageManager.Task.ProjectToExport).%New()
                Set prjRecord.ProjectId = addedProjectId
                Set prjRecord.TaskID = taskId
            }
            Set sc = prjRecord.%Save()
            If $$$ISERR(sc) {
                Throw ##class(%Exception.StatusException).CreateFromStatus(sc) 
            }
        }
    }
    Catch ex {
        Set sc=ex.AsStatus()
        Do ..WriteResponse(.res, sc)
    }
    Return sc
}

/// This method gets all the exported files for a given task
ClassMethod GetReleases() As %Status
{
    Set sc = $$$OK
    Try {
        Set sc = ##class(PackageManager.API.Task.Interface).GetExportedReleases(.result)
        If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
        Do ..WriteResponse(.result, sc) 
    }
    Catch ex {
        Set sc=ex.AsStatus()
    }
    Return sc
}

/// This method gets all the exported files for a given task
ClassMethod GetExportedReleases(ByRef result As %DynamicObject = "", verbose As %Boolean = 0, separator As %String = "\") As %Status
{
    Set sc = $$$OK
    Try {
        // Initialize result object if not already provided
        If '$ISOBJECT(result) Set result = {}

        // Define base path and initialize stack for directories
        Kill FILES
        Set basePath = ##class(PackageManager.Utility.Utils).AdaptPathToOS($$$exportTaskFilePath)
        // if the directory contains both slashes and backslashes, replace them with the separator
        If basePath [ "/" {
            Set directory = $REPLACE(basePath, "/", separator) 
        }
        Set FILES($INCREMENT(FILES)) = basePath

        // Set the directory root as a specific node of the stack
        Set rootElement = result

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
                        If $ZCONVERT(filepath, "U")'=$ZCONVERT(basePath, "U") {
                            Set relativePath = $PIECE($ZCONVERT(filepath, "U"), $ZCONVERT(basePath, "U"), 2)
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
                        Set isSubDir = ($ZCONVERT(searchdir, "U")'=$ZCONVERT(basePath, "U"))
                        If isSubDir {
                            Set relativeDirPath = $PIECE($ZCONVERT(searchdir, "U"), $ZCONVERT(basePath, "U"), 2)
                            Set ptr = 0
                            Set element = rootElement
                            While $LISTNEXT($LISTFROMSTRING(relativeDirPath, separator), ptr, dirPath) {
                                Continue:dirPath=""
                                Set element = element.%Get(dirPath)
                            }
                        } Else {
                            Set element = rootElement
                        }

                        // Get file information
                        Set dataCreated = ##class(%File).GetFileDateCreated(filepath)
                        Set fileSize = ##class(%File).GetFileSize(filepath)
                        
                        // Insert file node
                        Set name = $PIECE(filename, ".", 1)
                        Set fileformat = $PIECE(filename, ".", 2)
                        Do element.%Set(name, {
                            "name": (name),
                            "type": (fileformat),
                            "data_created": ($ZDATETIME(dataCreated,3)),
                            "file_size": (fileSize),
                            "file_size_unit": "bytes",
                            "full_file_path": (filepath)
                        })
                    }
                }

                Set filepath = $ZSEARCH("")  // Next entry
            }
        }
        If verbose { Write result.%ToJSON() }
    }
    Catch ex {
        Set sc=ex.AsStatus()
    }
    Return sc
}

/// This method is used to ask the server a specific exported file
ClassMethod DownloadRelease() As %Status
{
    Set sc = $$$OK
    Try {        
        Set body = %request.Content.Read()
        Set json = {}.%FromJSON(body)
        Set filePath = json."filepath"
        If filePath="" { 
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"filepath is required."))
        }

        // Remove double slashes or backslashes
        Set filePath = $REPLACE(filePath, "//", "/")
        Set filePath = $REPLACE(filePath, "\\", "\")

        // Verify if the file exists
        If '##class(%File).Exists(filePath) { 
            Throw ##class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError,"File not found."))
        }

        // Open the xml file as a stream and return it within the JSON response
        Set xmlFile = ##class(%Stream.FileCharacter).%New()
        Set outputStream = ##class(%Stream.GlobalCharacter).%New()
        Set sc=xmlFile.LinkToFile(filePath)
        While 'xmlFile.AtEnd {
            Set line=xmlFile.Read()
            Do outputStream.Write(line)
        }
        Do outputStream.Rewind()
        Do outputStream.OutputToDevice()
        #; Set out = {}
        #; Set out.stream = outputStream.Read()
        #; Do ..WriteResponse(out, sc)
    }
    Catch ex {
        Set sc=ex.AsStatus()
    }
    Return sc
}

}
