Class PackageManager.UI.Screens.InstallSection.JavaScript Extends PackageManager.UI.Screens.Abstract
{

/*
    JAVASCRIPT
*/
/// Render JavaScript code for the page
/// 
/// This method generates the necessary JavaScript code for the page, including
/// modal JavaScript, message notification, and utility functions.
/// 
/// # Notes
/// This method is responsible for rendering the JavaScript code that is used
/// to interact with the Export Task Section page UI components.
ClassMethod RenderJavaScript() As %Status
{
    Set sc = $$$OK
    &html<<script type="text/javascript">                       
        
        let apiMgrApiInstalled = false;

        /**
        * Shows a message notification on the page.
        * 
        * @param {string} text - The text of the message.
        * @param {string} type - The type of the message (e.g. "success", "error").
        */
        function apiMgrShowMessage(text, type = 'success') {
            const messagesDiv = document.getElementById('api-mgr-messages');
            messagesDiv.innerHTML = `<div class="api-mgr-message api-mgr-message--${type}" style="display: block;">${text}</div>`;
            
            setTimeout(() => {
                messagesDiv.innerHTML = '';
            }, 5000);
        }

        /**
        * Shows or hides a spinner on the page.
        * 
        * @param {string} spinnerId - The ID of the spinner element.
        * @param {boolean} show - Whether to show or hide the spinner.
        */
        function apiMgrShowSpinner(spinnerId, show = true) {
            const spinner = document.getElementById(spinnerId);
            if (spinner) {
                spinner.style.display = show ? 'inline-block' : 'none';
            }
        }

        /**
        * Checks the status of the API and updates the page accordingly.
        * 
        * This function checks if the API is installed and running, and updates the page
        * with the status information.
        */
        async function apiMgrCheckAPIStatus() {
            apiMgrShowSpinner('api-mgr-api-spinner', true);
            
            try {
                let apiMgrApiInstalled;
                // Check if the web app exists calling an ObjectScript method 
                // (it's not possible to fetch the API since if it does not exist and won't return a response) 
                result = await apiMgrCallMethod('CheckWebAppStatus');
                if (result.statusText === "OK") {
                    let res_json = await result.json();
                    apiMgrApiInstalled = res_json.installed;
                }
                const statusBox = document.getElementById('api-mgr-api-status');
                const actionBtn = document.getElementById('api-mgr-api-action-btn');
                const btnText = document.getElementById('api-mgr-api-btn-text');
                
                if (apiMgrApiInstalled === true) {
                    // Ping the api
                    PackageManagerAPI.ping()
                        .then(function(response) {
                            statusBox.className = 'api-mgr-status-box api-mgr-status-box--success';
                            statusBox.innerHTML = `
                                <div class="api-mgr-status-text">
                                    <span class="api-mgr-status-indicator api-mgr-status-indicator--green"></span>
                                    API is installed and running
                                </div>
                                <div class="api-mgr-status-details">
                                    Last ping: ${response.timestamp}<br>
                                    Status: ${response.message}
                                </div>
                            `;
                            actionBtn.className = 'api-mgr-btn api-mgr-btn--danger';
                            btnText.textContent = 'Uninstall API';
                        })
                } else {
                    statusBox.className = 'api-mgr-status-box api-mgr-status-box--error';
                    statusBox.innerHTML = `
                        <div class="api-mgr-status-text">
                            <span class="api-mgr-status-indicator api-mgr-status-indicator--red"></span>
                            API is not installed
                        </div>
                        <div class="api-mgr-status-details">
                            The API needs to be installed before it can be used.
                        </div>
                    `;
                    actionBtn.className = 'api-mgr-btn api-mgr-btn--success';
                    btnText.textContent = 'Install API';
                }
                
                actionBtn.disabled = false;
                
            } catch (error) {
                const statusBox = document.getElementById('api-mgr-api-status');
                statusBox.className = 'api-mgr-status-box api-mgr-status-box--error';
                statusBox.innerHTML = `
                    <div class="api-mgr-status-text">
                        <span class="api-mgr-status-indicator api-mgr-status-indicator--red"></span>
                        API connection failed
                    </div>
                    <div class="api-mgr-status-details">
                        Error: ${error.message}
                    </div>
                `;
                
                const actionBtn = document.getElementById('api-mgr-api-action-btn');
                const btnText = document.getElementById('api-mgr-api-btn-text');
                actionBtn.className = 'api-mgr-btn api-mgr-btn--success';
                btnText.textContent = 'Install API';
                actionBtn.disabled = false;
                apiMgrApiInstalled = false;
            } finally {
                apiMgrShowSpinner('api-mgr-api-spinner', false);
            }
        }

        /**
        * Toggles the installation of the API.
        * 
        * This function installs or uninstalls the API, depending on its current status.
        */
        async function apiMgrToggleAPI() {
            let apiMgrApiInstalled;
            // Check if the web app exists calling an ObjectScript method 
            // (it's not possible to fetch the API since if it does not exist and won't return a response) 
            result = await apiMgrCallMethod('CheckWebAppStatus');
            if (result.statusText === "OK") {
                let res_json = await result.json();
                apiMgrApiInstalled = res_json.installed;
            }

            const action = apiMgrApiInstalled ? 'uninstall-api' : 'install-api';
            const actionText = apiMgrApiInstalled ? 'uninstall' : 'install';
            
            // Show confirmation dialog
            if (!confirm(`Are you sure you want to ${actionText} the API?`)) {
                return;
            }
            
            apiMgrShowSpinner('api-mgr-api-spinner', true);
            document.getElementById('api-mgr-api-action-btn').disabled = true;
            
            try {                
                let result;
                
                if (action === 'uninstall-api') {
                    result = await apiMgrCallMethod('UninstallWebApp');
                } else if (action === 'install-api') {
                    result = await apiMgrCallMethod('InstallWebApp');
                }

                // Check if the operation was successful
                if (result.statusText !== 'OK') {
                    throw new Error(result || `Failed to ${actionText} API`);
                }

                // Show success message
                apiMgrShowMessage(`API ${actionText}ed successfully`, 'success');

                // Refresh status after action
                setTimeout(() => {
                    apiMgrCheckAPIStatus();
                }, 1000);
                
            } catch (error) {
                apiMgrShowMessage(`Failed to ${actionText} API: ${error.message}`, 'error');
                document.getElementById('api-mgr-api-action-btn').disabled = false;
                apiMgrShowSpinner('api-mgr-api-spinner', false);
            }
        }

        /**
        * Calls an ObjectScript CSP page to execute ObjectScript code asynchronously on the server.
        * 
        * This function calls an ObjectScript method on the server, and returns the result.
        * 
        * @param {string} action - The name of the method to call.
        * @returns {Promise} A promise that resolves with the result of the method call.
        */
        async function apiMgrCallMethod(action) {  
            let url;
            if (action === 'UninstallWebApp') {
                url = "#(##class(PackageManager.UI.Screens.InstallSection.CSP.UninstallCSP).GetPageURLForInternalCalls())#"; 
            } else if (action === 'InstallWebApp') {
                url = "#(##class(PackageManager.UI.Screens.InstallSection.CSP.InstallCSP).GetPageURLForInternalCalls())#"; 
            } else if (action === 'CheckWebAppStatus') {
                url = "#(##class(PackageManager.UI.Screens.InstallSection.CSP.APIStatusCSP).GetPageURLForInternalCalls())#"; 
            }
            const response = await fetch(url + '?execute=1');
            
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }            
            return response;
        }

    </script>>
    Return sc
}

}
