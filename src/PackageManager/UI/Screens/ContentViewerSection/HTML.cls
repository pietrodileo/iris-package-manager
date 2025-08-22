Class PackageManager.UI.Screens.ContentViewerSection.HTML Extends PackageManager.UI.Screens.Abstract
{

/*
    HTML Rendering
*/
ClassMethod renderContentViewer() As %Status
{
    Set sc = $$$OK

    // CSS
    Do ##class(PackageManager.UI.Screens.ContentViewerSection.CSS).RenderStyles()
    // JS 
    Do ##class(PackageManager.UI.Screens.ContentViewerSection.JavaScript).RenderJavaScript()
    // HTML Modals
    Do ##class(PackageManager.UI.Screens.ContentViewerSection.HTML).renderNewProjectModal()
    Do ##class(PackageManager.UI.Screens.ContentViewerSection.HTML).renderContentViewerTable()
    Do ##class(PackageManager.UI.Screens.ContentViewerSection.HTML).renderAddClassesToPrjModal()

    &html<<script language="javascript"> 
        function renderContentViewer() {
            // Projects List HTML with container design
            return `
                <h2>📋 Projects List</h2>
                <p>This shows the current list of all projects in the system. You can show their content and export them. </p>
                <p>You can create new projects and associate them with classes or files on the current namespace. </p>
                <div class='project-container' id ='projectContainer'>
                    <div class='project-header'>
                        <div class='project-title'>
                        <h3>🗂️ Projects List</h3>
                        </div>
                        <div class='header-controls'>
                        <input type='text' id='searchInput' placeholder='Search projects...' onkeyup='filterProjects()' />
                        <button type='button' onclick='showSelectedProjectContent()'>Show Project Content</button>
                        <button type='button' onclick='showSelectedProjectContent(true)'>Show All Projects Content</button>
                        <button type='button' onclick='exportSelectedProject()'>Export Selected Project</button>
                        <button class='new-project-btn' type='button' onclick='openNewProjectModal()' title='Add New Project'>
                            <span class='plus-icon'>+</span> New Project
                        </button>
                        </div>
                    </div>
                    <div class='project-content'>
                        <div class='project-table-wrapper'>
                            <table class='project-table'><thead>
                            </thead><tbody id='projectTableBody'></tbody></table>
                        </div>
                        <div id='msg' class='message'></div>
                        <div id='exportResult' class='message' style='margin-top: 15px;'></div>
                    </div>
                </div>

                <!-- New Project Modal HTML - to create a new project -->
                ${renderNewProjectModal()}

                <!-- Content Viewer Table -->
                ${renderContentViewerTable()}

                <!-- Add Classes Modal HTML - to add classes to a project -->
                ${renderAddClassesToPrjModal()}

            `;
        }
    </script>>

    Return sc
}

/*
    Modals and content viewer Rendering
*/
ClassMethod renderNewProjectModal() As %Status
{
    Set sc = $$$OK
    &html<<script language='javascript'>
        function renderNewProjectModal() {
            // New Project Modal HTML
            return `
                <div id='newProjectModal' class='modal-overlay'>
                    <div class='modal-container'>
                        <div class='modal-header'>
                            <h3>🆕 Create New Project</h3>
                            <button class='modal-close' onclick='closeNewProjectModal()'>&times;</button>
                        </div>
                        <div class='modal-content'>
                            <form id='newProjectForm' onsubmit='createNewProject(event)'>
                                <div class='form-group'>
                                    <label for='projectName'>Project Name *</label>
                                    <input type='text' id='projectName' name='projectName' required 
                                        placeholder='Enter project name...' maxlength='64'>
                                    <small class='form-help'>Choose a unique name for your project</small>
                                </div>
                                <div class='form-group'>
                                    <label for='projectDescription'>Description</label>
                                    <textarea id='projectDescription' name='projectDescription' 
                                            placeholder='Enter project description...' rows='4' maxlength='500'></textarea>
                                    <small class='form-help'>Optional: Describe what this project is for</small>
                                </div>
                                <div class='modal-actions'>
                                    <button type='button' class='btn-secondary' onclick='closeNewProjectModal()'>Cancel</button>
                                    <button type='submit' class='btn-primary'>
                                        <span class='plus-icon'>+</span> Create Project
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            `;
        }
    </script>>
    Return sc
}

ClassMethod renderContentViewerTable() As %Status
{
    Set sc = $$$OK
    &html<<script language='javascript'>
        function renderContentViewerTable() {
            // Content Viewer HTML
            return `
                <h2>🧩 Projects Content Viewer</h2>  
                <p>This shows the project content. 'PKG' nodes are related to classes (cls, inc, mac), while 'DIR' are related to other files (like csp, js, css, etc.). </p>
                <p>You can remove selected classes from a project (without deleting it from the namespace) or export them into an XML file. </p>              
                <body>
                    <div class='container'>
                        <div class='selection-info'>
                            Select items in project content and export classes and files
                            <span class='selected-count' id='selectedCount'>0 Selected</span>
                        </div>
                    <div class='tree-wrapper'>
                            <div class='tree-header'>
                                <h3>📂 Projects Content</h3>
                                <div class='tree-controls'>
                                    <button id='tree-expand-btn' type='button' onclick='expandAllTree()'>Expand All</button>
                                    <button id='tree-collapse-btn' type='button' onclick='collapseAllTree()'>Collapse All</button>
                                    <button id='tree-clear-btn' type='button' onclick='clearTreeSelection()'>Clear Selection</button>
                                    <button id='tree-export-btn' type='button' onclick='getSelectedProjectItems()'>Export Selected</button>
                                    <button id='tree-remove-items-btn' type='button' onclick='removeSelectedProjectItems()'>Remove Selected from Project</button>
                                </div>
                            </div>
                            <div class='search-container'>
                                <input 
                                    type='text' 
                                    id='treeSearchInput' 
                                    class='search-input'
                                    placeholder='Search files and classes...'
                                    oninput='filterProjectTree()'
                                />
                            </div>
                            <div class='tree-container'
                                <div id='container'>
                                        <!-- Tree content will be rendered here -->
                                </div>
                            </div>
                        </div>
                    </div>
            `;
        }
    </script>>
    Return sc
}

ClassMethod renderAddClassesToPrjModal() As %Status
{
    Set sc = $$$OK
    &html<<script language='javascript'>
        // Add Classes Modal HTML 
        function renderAddClassesToPrjModal() {
            return `
                <div id='addClassesModal' class='add-classes-modal-overlay'>
                    <div class='add-classes-modal-container'>
                        <div class='add-classes-modal-header'>
                            <div>
                                <h2 class='add-classes-modal-title'>Add Classes to Project</h2>
                                <div class='add-classes-project-name' id='modalProjectName'>Loading...</div>
                            </div>
                            <button class='add-classes-close-btn' onclick='closeAddClassesModal()'>&times;</button>
                        </div>
                        <div class='add-classes-control-panel'>
                            <div class='add-classes-control-group'>
                                <label for='fileTypeSelector'>File Type:</label>
                                <select id='fileTypeSelector' class='add-classes-type-selector'> // onchange='loadNamespaceContent()'>
                                    <option value=''>All Types</option>
                                    <option value='cls'>Classes (.cls)</option>
                                    <option value='inc'>Includes (.inc)</option>
                                    <option value='mac'>Macros (.mac)</option>
                                    <option value='js'>JavaScript (.js)</option>
                                    <option value='csp'>CSP Pages (.csp)</option>
                                    <option value='json'>JSON (.json)</option>
                                    <option value='abs'>Abstract (.abs)</option>
                                    <option value='dtl'>DTL (.dtl)</option>
                                    <option value='dfi'>DFI (.dfi)</option>
                                </select>
                            </div>
                            <div class='add-classes-control-group'>
                                <label for='packageSearchInput'>Look Into:</label>
                                <input type='text' id='packageSearchInput' class='add-classes-search-input' placeholder='Look into package...'>
                            </div>
                            <div class='add-classes-control-group'>
                                <label for='namespaceSearchInput'>Search:</label>
                                <input type='text' id='namespaceSearchInput' class='add-classes-search-input' placeholder='Search classes...' onkeyup='filterNamespaceTree()'>
                            </div>
                            <div class='add-classes-control-group'>
                                <button class='add-classes-btn add-classes-btn-secondary' onclick='expandAllNamespaceTree()'>Expand All</button>
                                <button class='add-classes-btn add-classes-btn-secondary' onclick='collapseAllNamespaceTree()'>Collapse All</button>
                                <button class='add-classes-btn add-classes-btn-secondary' onclick='clearNamespaceSelection()'>Clear Selection</button>
                            </div>
                        </div>
                        <div class='add-classes-tree-content'>
                            <div id='namespaceContainer'>
                                <div class='add-classes-loading-message'>Select a file type and click 'Load Content' to begin</div>
                            </div>
                        </div>
                        <div class='add-classes-modal-footer'>
                            <div class='add-classes-selection-info'>
                                <span id='namespaceSelectedCount'>0 Selected</span>
                            </div>
                            <div class='add-classes-footer-actions'>
                                <button class='add-classes-btn add-classes-btn-primary' onclick='loadNamespaceContent()'>🔄 Load Content</button>
                                <button class='add-classes-btn add-classes-btn-success' onclick='addSelectedToProject()'>➕ Add to Project</button>
                                <button class='add-classes-btn add-classes-btn-secondary' onclick='closeAddClassesModal()'>Cancel</button>
                            </div>
                        </div>
                    </div>
                </div>
            `;
        }
    </script>>
    Return sc
}

}
