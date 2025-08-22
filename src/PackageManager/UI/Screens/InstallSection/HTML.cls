Class PackageManager.UI.Screens.InstallSection.HTML Extends PackageManager.UI.Screens.Abstract
{

/*
    HTML Rendering
*/
ClassMethod renderInstallSection() As %Status
{
    Set sc = $$$OK
    // CSS
    Do ##class(PackageManager.UI.Screens.InstallSection.CSS).RenderStyles()
    // JS 
    Do ##class(PackageManager.UI.Screens.InstallSection.JavaScript).RenderJavaScript()
    
    &html<<script language='javascript'>
        function renderInstallSection() {
            return `
                <h2>🔧 #($$$InstallationSectionTitle)#</h2>
                <p>This section allows you to install and configure the Package Manager in your environment.</p>

                    <div id="api-mgr-messages"></div>

                    <!-- API Status Section -->
                    <div class="api-mgr-project-container">
                        <div class="api-mgr-project-header">
                            <div class="api-mgr-project-title">
                                <span class="api-mgr-icon">🛜</span>
                                <h3>Current API Status</h3>
                            </div>
                        </div>
                        <div class="api-mgr-project-content">
                            <div class="api-mgr-section">
                                <div class="api-mgr-status-box" id="api-mgr-api-status">
                                    <div class="api-mgr-status-content">
                                        <div class="api-mgr-status-text">Checking API status...</div>
                                    </div>
                                </div>
                                
                                <div class="api-mgr-controls">
                                    <button id="api-mgr-api-action-btn" class="api-mgr-btn" onclick="apiMgrToggleAPI()" disabled>
                                        <span id="api-mgr-api-spinner" class="api-mgr-loading-spinner" style="display: none;"></span>
                                        <span id="api-mgr-api-btn-text">Loading...</span>
                                    </button>
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
