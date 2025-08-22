Class PackageManager.Task.ProjectToExport Extends %Persistent
{

/// Project name - Contains the ID property of table %Studio.Project to recognize projects to export
Property ProjectId As %String;

/// ID of the %SYS.Task record which is linked to the export of the current element
Property TaskID As %String;

Index ProjectIdIndex On (ProjectId, TaskID) [ Unique ];

/// Date from which the project is exported
/// If not inserted, is the date when the project is created
/// If the date is future, the project will not be exported
/// 
/// [not used yet]
/// 
Property DateFrom As %Date;

/// Date to which the project is exported
/// If the date is not set, the project will be exported 
/// If the date is past, the project will not be exported
/// 
/// [not used yet]
/// 
Property DateTo As %Date;

/// Property to determine if the project export is active or not, by default it is active
/// If the project export is not active, it will not be exported even if the export date range is valid
Property Active As %Boolean [ InitialExpression = 1 ];

/// Insert time of the project export
Property InsertTimestamp As %TimeStamp [ SqlComputeCode = { set {insertTimestamp} = $ZDATETIME($NOW(),3,1,5) }, SqlComputed, SqlComputeOnChange = %%INSERT ];

/// Integer to distinguish versions (number of times the project is exported through a given task)
Property Version As %Integer [ InitialExpression = 1 ];

/// This method is called to disable the object 
Method Disable() As %Status
{
    Set sc = $$$OK
    Set ..Active = 0
    Set sc = ..%Save()
    Return sc
}

/// This method is called to enable the object 
Method Enable() As %Status
{
    Set sc = $$$OK
    Set ..Active = 1
    Set sc = ..%Save()
    Return sc
}

/// This method increment the version of the record
Method IncrementVersion() As %Status
{
    Set sc = $$$OK
    Set ..Version = ..Version + 1
    Set sc = ..%Save()
    Return sc
}

Storage Default
{
<Data name="ProjectToExportDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ProjectId</Value>
</Value>
<Value name="3">
<Value>TaskID</Value>
</Value>
<Value name="4">
<Value>DateFrom</Value>
</Value>
<Value name="5">
<Value>DateTo</Value>
</Value>
<Value name="6">
<Value>Active</Value>
</Value>
<Value name="7">
<Value>InsertTimestamp</Value>
</Value>
<Value name="8">
<Value>Version</Value>
</Value>
</Data>
<DataLocation>^PackageManD007.ProjectToExpB5FD</DataLocation>
<DefaultData>ProjectToExportDefaultData</DefaultData>
<ExtentSize>2</ExtentSize>
<IdLocation>^PackageManD007.ProjectToExpB5FD</IdLocation>
<IndexLocation>^PackageManD007.ProjectToExpB5FI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<OutlierSelectivity>.999999:</OutlierSelectivity>
<Selectivity>0.0001%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Active">
<AverageFieldSize>3</AverageFieldSize>
<OutlierSelectivity>.999999:1</OutlierSelectivity>
<Selectivity>0.0001%</Selectivity>
</Property>
<Property name="DateFrom">
<AverageFieldSize>2</AverageFieldSize>
<OutlierSelectivity>.999999:</OutlierSelectivity>
<Selectivity>0.0001%</Selectivity>
</Property>
<Property name="DateTo">
<AverageFieldSize>2</AverageFieldSize>
<OutlierSelectivity>.999999:</OutlierSelectivity>
<Selectivity>0.0001%</Selectivity>
</Property>
<Property name="InsertTimestamp">
<AverageFieldSize>27</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="ProjectId">
<AverageFieldSize>11.5</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="TaskID">
<AverageFieldSize>6</AverageFieldSize>
<OutlierSelectivity>.999999:1020</OutlierSelectivity>
<Selectivity>0.0001%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="ProjectIdIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^PackageManD007.ProjectToExpB5FS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
