/// This class provides the main functionality for the Package Manager UI. 
/// It provides methods for rendering the main page, initializing the sidebar content, and handling window load events.  
/// The class is responsible for setting up the UI components and providing the necessary functionality for the Package Manager UI.
Class PackageManager.UI.Main Extends PackageManager.UI.Screens.Abstract
{

/// This code sets the content of the #mainContent element for the welcome landing page.
ClassMethod OnPage() As %Status
{
    &html<<html>
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <title>Package Manager UI</title>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <!-- <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet"> -->
        </head>
    >

    Do ##class(PackageManager.UI.CSS).Styles()
    Do ..SectionsJS()
    Do ..WindowOnLoad()
    &html<
        <body>
            <div class="sidebar">
                <div class="sidebar-header" title="Toggle Sidebar"> 
                    <span class='sidebar-header-icon'>📦</span>
                    <span class="label">Package Manager</span>
                </div>
                <div id="sidebarList"></div>
                <!-- Version indicator at the bottom of sidebar -->
                <div class="sidebar-version" title="Package Manager Version">
                    <span class="version-text">ℹ️ v#($$$PackageManagerVersion)#</span>
                </div>
            </div>
            <div class="main-content" id="mainContent"></div>
        </body>
    </html>>
    Quit $$$OK
}

/// Initialize sidebar content on page load
/// This code is executed when the window finishes loading, and is used to initialize the page's content.
/// The loadSection function is called to fetch data from the server and dynamically generate the content for the selected section, and then inject it into the main content area. 
/// This code executes the populateSidebar function when the window finishes loading, which is responsible for populating the sidebar with its content.
/// The populateSidebar function is expected to generate the necessary HTML and populate the sidebar element with it, making it visible and interactive for the user.
ClassMethod SectionsJS() As %Status
{
    Set sc = $$$OK

    // Insert the JavaScript functions for all the sections
    Do ##class(PackageManager.UI.JavaScript).JavaScriptUtilities()
    Do ##class(PackageManager.UI.Screens.InstallSection.HTML).renderInstallSection()
    Do ##class(PackageManager.UI.Screens.ContentViewerSection.HTML).renderContentViewer()
    Do ##class(PackageManager.UI.Screens.ExportTaskSection.HTML).renderExportTask()
    Do ##class(PackageManager.UI.Screens.ReleaseSection.HTML).renderExportedRelease()

    // Main script to handle different sections
    &html<<script language="javascript"> 
    
        const sections = {
            '#($$$InstallationSectionTitle)#': renderInstallSection,
            '#($$$ProjectContentViewerSectionTitle)#': renderContentViewer,
            '#($$$ExportProjectTaskSectionTitle)#': renderExportTask,
            '#($$$ExportedReleaseSectionTitle)#': renderExportedRelease
        };

        // Function to load section content dynamically based on the title of the section
        async function loadSection(title) {
            const renderFn = sections[title];
            const contentDiv = document.getElementById("mainContent");
            if (typeof renderFn === "function") {
                contentDiv.innerHTML = renderFn();
                // After injecting Project List UI, fetch data to populate the UI
                if (title === '#($$$ProjectContentViewerSectionTitle)#') {
                    loadProjects();
                }
                if (title === '#($$$ExportProjectTaskSectionTitle)#') {
                    loadExportTasks();
                }
                if (title === '#($$$ExportedReleaseSectionTitle)#') {
                    loadExportedReleases();
                }
                if (title === '#($$$InstallationSectionTitle)#') {
                    apiMgrCheckAPIStatus();
                }
            } else {
                contentDiv.innerHTML = "<p>Section not found.</p>";
            }
        }

        // Logic for icons and sidebar population
        const icons = {
            '#($$$InstallationSectionTitle)#': "🔧",
            '#($$$ProjectContentViewerSectionTitle)#': "🧩",
            '#($$$ExportProjectTaskSectionTitle)#': "📤",
            '#($$$ExportedReleaseSectionTitle)#': "📚"
        };

        function populateSidebar() {
            const sidebar = document.getElementById("sidebarList");
            for (const title in sections) {
                const el = document.createElement("h3");
                const icon = icons[title] || "📄";
                el.innerHTML = `<span class='sidebar-icon'>${icon}</span> <span class='label'>${title}</span>`;
                el.onclick = () => loadSection(title);
                sidebar.appendChild(el);
            }
        }
    </script>>
    Return sc
}

/// Toggle collapse of the sidebar on header click
/// This code adds a click event handler to the sidebar header that toggles the "collapsed" class on the sidebar element.
/// When the sidebar header is clicked, the sidebar will toggle between its expanded and collapsed states.
/// The sidebar element will have the class "collapsed" added or removed when the header is clicked.
ClassMethod WindowOnLoad() As %Status
{
    Set sc = $$$OK
    &html<<script language="javascript"> 
        window.onload = function() {
            populateSidebar();
            document.getElementById("mainContent").innerHTML = [
                "<h1>Welcome to Package Manager</h1>",
                "<p>Select a section from the sidebar to begin.</p>"
            ].join("");
            
            // Add click event to sidebar header to toggle collapse
            document.querySelector(".sidebar-header").onclick = function () {
                document.querySelector(".sidebar").classList.toggle("collapsed");
            };

        }
    </script>>
    Return sc
}

/// Get the class name to call the correct API URL
/// 
/// This method retrieves the class name of the current page and constructs the correct API URL
/// by combining the class name with the web application ID and namespace.
/// 
/// # Parameters
/// 
/// * `URL`: Output parameter that will contain the constructed API URL
/// 
/// # Notes
/// 
/// This method uses the `%Dictionary.CompiledClass` and `%RoutineMgr` classes to retrieve the class name and web server port.
/// It also uses the `%SQL.Statement` class to execute a SQL query to retrieve the default web application ID for the namespace.
/// 
/// The constructed API URL is in the format `http(s)://webAppID/class.Name.cls`
ClassMethod GetMainPageClassName(Output URL As %String, verbose As %Boolean = 1) As %String
{
    Set sc = $$$OK
    Try {
        Set URL = ""
        Set class = ##class(%Dictionary.CompiledClass).%OpenId(..%ClassName(1)) 
        If '$ISOBJECT(class) Throw ##class(%Exception.General).%New("Class not found")
        // Get Instance URL and Port
        Set sc=##class(%RoutineMgr).GetWebServerPort(.Port,.Server,.URLPrefix,.URL)
        // Get Default Web Application for the namespace (for csp pages)
        Set PackageManagerNamespace = $NAMESPACE
        New $Namespace
        Set $Namespace = "%SYS"
        Set sql = "SELECT ID FROM Security.Applications WHERE IsNameSpaceDefault = 1 AND NameSpace = ?"
        Set tStatement = ##class(%SQL.Statement).%New()
        Set sc = tStatement.%Prepare(sql)
        If $$$ISERR(sc) Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
        Set tResult = tStatement.%Execute(PackageManagerNamespace)
        While tResult.%Next() {
            Set webAppID = tResult.%Get("ID")
        }
        Set URL = URL_webAppID_"/"_class.Name_".cls"
        // Remve double slash 
        If URL [ "//" {
            If URL [ "http://" { 
                Set prefix = "http://" 
            } ElseIf URL [ "https://"  { 
                Set prefix = "https://" 
            }
            If prefix '= "" {
                Set URL = $REPLACE(URL,prefix,"")
            }
            Set URL = $REPLACE(URL,"//","/")
            If prefix '= "" { 
                Set URL = prefix_URL
            }
        }
        If verbose w URL,!
    }
    Catch ex {
        Set sc=ex.AsStatus()
    }
    Return sc
}

}
