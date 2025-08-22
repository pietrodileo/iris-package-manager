Class PackageManager.API.Classes.Interface Extends PackageManager.API.REST
{

ClassMethod ExportClasses() As %Status
{
    Set sc = $$$OK
    ; Ignora l'output REST per evitare di restituire all'IO di default (risposta REST) il contenuto di eventuali write inseriti nei metodi invocati
    Set %response.IgnoreRESTOutput=1
    Try {
        Set out = {}

        Set body = %request.Content.Read()
        Set json = {}.%FromJSON(body)
        Set elements = json."elements"

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
        Set format = ".xml"
        Set datetime = $TRANSLATE($ZDATE(now,3),"-","")_"_"_$TRANSLATE($ZTIME(now,1),":","")
        Set fileName = "classes_"_datetime_format
        Set filePath = path_fileName

        Set iter = elements.%GetIterator()
        While iter.%GetNext(.key, .value) { 
            If '$DATA(items(value."name")) {
                Set items(value."name") = ""
            }
        }

        ; You could define the items argument as a multidimensional array as follows:
		;   set items("PackageOne.ClassA.cls")=""
        ;   set items("PackageTwo.ClassB.cls")=""
        ;   set items("PackageThree.ClassC.cls")=""               
        ; In this case, you must pass the items argument by reference as follows:
        ;   do $system.OBJ.Export(.items,myfilename)
        Set sc = $SYSTEM.OBJ.Export(.items,filePath,"/generated=0")
        If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc)

        // Open the xml file as a stream and return it within the JSON response
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
        #; Do ..WriteResponse(out, sc)
        
    } Catch ex {
        Set sc=ex.AsStatus()
        Do ..WriteResponse(.out, sc)
    }
    Return sc
}

}
