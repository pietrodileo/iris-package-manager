Class PackageManager.UI.Screens.ReleaseSection.HTML Extends PackageManager.UI.Screens.Abstract
{

/*
    HTML Rendering
*/
ClassMethod renderExportedRelease() As %Status
{
    Set sc = $$$OK
    // CSS
    Do ##class(PackageManager.UI.Screens.ReleaseSection.CSS).RenderStyles()
    // JS 
    Do ##class(PackageManager.UI.Screens.ReleaseSection.JavaScript).RenderJavaScript()
    
    &html<<script language='javascript'>
        function renderExportedRelease() {
            return `
                <h2><span class='icon-folder-books'></span> #($$$ExportedReleaseSectionTitle)#</h2>
                <p>This lists all the exported versions created by export tasks..</p>
                <div class="exported-releases-container">
                    <div class="exported-releases-header">
                        <h3>Exported Releases</h3>
                        <div class="exported-releases-controls">
                            <button id="refreshBtn" onclick="loadExportedReleases()"><span class="icon-refresh"></span> Refresh</button>
                            <button id="expandBtn" onclick="expandAllReleases()"><span class='icon-folder-open'></span> Expand All</button>
                            <button id="collapseBtn" onclick="collapseAllReleases()"><span class="icon-folder"></span> Collapse All</button>
                            <button id="clearBtn" onclick="clearReleaseSelection()"><span class="icon-cancel"></span> Clear Selection</button>
                            <button id="downloadBtn" onclick="downloadSelectedReleases()" disabled><span class="icon-download"> Download Selected</button>
                        </div>
                    </div>
                    
                    <div class="exported-releases-selection-info">
                        <span>Select XML releases to download</span>
                        <span class="exported-releases-selected-count" id="selectedCount">0 Selected</span>
                    </div>
                    
                    <div class="exported-releases-search-container">
                        <input type="text" id="searchInput" class="exported-releases-search-input" 
                            placeholder="Search projects and releases..." oninput="filterExportedReleases()">
                    </div>
                    
                    <div class="exported-releases-tree-container">
                        <div id="releasesContainer">
                        </div>
                    </div>
                    
                    <div id="exported-releases-messageContainer"></div>
                </div>
            `;
        }
    </script>>
    Return sc
}

}
