Class PackageManager.UI.APIClient Extends PackageManager.UI.Screens.Abstract
{

/*
    JAVASCRIPT
*/
/// JavaScript API client 
/// 
/// This script provides a client-side interface to interact with the Package Manager REST API.
/// It defines functions to perform various operations such as creating projects, managing tasks, and exporting classes
/// 
/// The API client can be accessed globally via the `PackageManagerAPI` or `pmAPI` object.
/// Requests can be made with different caching strategies: no-cache, short-cache (5 minutes), and long-cache (1 hour).
/// 
/// Example usage:
/// PackageManagerAPI.ping()
///     .then(function(response) { // This returns a JSON, not a promise
///         console.log('API is running:', response.message);
///     });
/// 
/// Example usage with catch block:
///     const cacheStrategy = 'noCache';
///     PackageManagerAPI.getProjects(cacheStrategy)
///         .then(function(response) {
///             console.log('API is running:', response.message);
///             allProjects = response;
///             renderProjects(response);
///          })
///          .catch(function(err) {
///             const table_body = document.getElementById('projectTableBody');
///             table_body.innerHTML = `
///                 <tr>
///                     <td colspan="3" style="color:red; text-align:center;">
///                          Error loading projects from database<br>
///                             ${err.message}
///                     </td>
///                 </tr>
///             `;
///             console.error("Error while fetching projects:", err);
///         });        
///     }
/// 
ClassMethod APIClient() As %Status
{
    Set sc = $$$OK
    
    Set packagemanagerAPIendpoint = $$$PackageManagerAPI
    If (($EXTRACT(packagemanagerAPIendpoint,*) = "/") || ($EXTRACT(packagemanagerAPIendpoint,*) = "\")) {
        Set packagemanagerAPIendpoint = $EXTRACT(packagemanagerAPIendpoint,1,*-1)
    }
    &html<<script type="text/javascript">                       

        // Package Manager API Service - ES5 Compatible
        (function() {
            'use strict';
            
            // Configuration
            var API_CONFIG = {
                baseURL: '#(packagemanagerAPIendpoint)#', 
                defaultHeaders: {
                    'Content-Type': 'application/json'
                },
                cacheHeaders: {
                    noCache: {
                        'Cache-Control': 'no-cache, no-store, must-revalidate',
                        'Pragma': 'no-cache',
                        'Expires': '0'
                    },
                    shortCache: {
                        'Cache-Control': 'max-age=300' // 5 minutes
                    },
                    longCache: {
                        'Cache-Control': 'max-age=3600' // 1 hour
                    }
                }
            };

            // Helper function to merge headers
            function mergeHeaders() {
                var result = {};
                for (var i = 0; i < arguments.length; i++) {
                    var headers = arguments[i];
                    if (headers) {
                        for (var key in headers) {
                            if (headers.hasOwnProperty(key)) {
                                result[key] = headers[key];
                            }
                        }
                    }
                }
                return result;
            }

            // Generic request method
            async function request(endpoint, options, cacheStrategy = 'shortCache') {
                options = options || {};
                var url = API_CONFIG.baseURL + endpoint;
                
                var headers = mergeHeaders(
                    API_CONFIG.defaultHeaders,
                    API_CONFIG.cacheHeaders[cacheStrategy],
                    options.headers
                );

                var config = {
                    method: options.method || 'GET',
                    headers: headers
                };

                if (options.body) {
                    config.body = options.body;
                }

                return fetch(url, config)
                    .then(async function(response) {

                        if (!response.ok) {
                            // return the error content as text if returned
                            const errorText = await response.text();
                            throw new Error(
                                `HTTP error - status: ${response.status} - ${response.statusText} - details: ${errorText}`
                            );
                        }
                        
                        var contentType = response.headers.get('content-type');
                        if (contentType && contentType.indexOf('application/json') !== -1) {
                            return response.json(); // Return the promise
                        } else if (contentType && contentType.indexOf('application/octet-stream') !== -1) {
                            return response.blob(); // Return the promise
                        }
                        return response.text(); // Return the promise
                    })
                    .catch(function(error) {
                        console.error('API request failed: ' + endpoint, error);
                        throw error;
                    });
            }

            // Create the API service object
            var PackageManagerAPI = {
                // Project methods
                createProject: function(projectData) {
                    return request('/project/create', {
                        method: 'POST',
                        body: JSON.stringify(projectData)
                    });
                },

                getProjects: function(cacheStrategy) {
                    return request('/projects', { method: 'GET' }, cacheStrategy);
                },

                getProjectContent: function(projectId) {
                    var endpoint = projectId ? '/project/content/' + projectId : '/project/content';
                    return request(endpoint, { method: 'GET' });
                },

                updateProject: function(projectId, updateData) {
                    return request('/project/update/' + projectId, {
                        method: 'POST',
                        body: JSON.stringify(updateData)
                    });
                },

                deleteProject: function(projectId) {
                    return request('/project/delete/' + projectId, { method: 'DELETE' }, 'noCache');
                },

                addClassesToProject: function(projectId, classes) {
                    return request('/project/add/' + projectId, {
                        method: 'POST',
                        body: JSON.stringify(classes)
                    });
                },

                removeClassesFromProject: function(projectId, classes) {
                    return request('/project/remove/' + projectId, {
                        method: 'PUT',
                        body: JSON.stringify(classes)
                    });
                },

                exportProject: function(projectId) {
                    return request('/project/export/' + projectId, { method: 'GET' });
                },

                // Classes methods
                exportClasses: function(classData) {
                    return request('/classes/export', {
                        method: 'POST',
                        body: JSON.stringify(classData)
                    });
                },

                // Namespace methods
                getNamespaceContent: function(type, lookInto, excludeSystemClasses = false) {
                    const lookIntoKey = 'PackageName';
                    const excludeSystemKey = 'ExcludeSystemClasses';
                    var endpoint = type ? '/namespace/content/' + type : '/namespace/content';

                    // Build query parameters
                    const params = [];
                    
                    // Add excludeSystemClasses parameter
                    params.push(excludeSystemKey + '=' + excludeSystemClasses);

                    // If not empty, add a parameter to look into specific packages
                    if (lookInto && lookInto.length > 0) { 
                        params.push(lookIntoKey + '=' + encodeURIComponent(lookInto));
                    }
                    
                    // Append parameters to endpoint if any exist
                    if (params.length > 0) {
                        endpoint += '?' + params.join('&');
                    }

                    return request(endpoint, { method: 'GET' });
                },

                // Task methods
                createTask: function(taskData, cacheStrategy) {
                    return request('/task/create', {
                        method: 'POST',
                        body: JSON.stringify(taskData)
                    },
                    cacheStrategy);
                },

                checkExistingTasks: function(cacheStrategy) {
                    // Force no-cache for dynamic task status
                    return request('/task/existing', { 
                        method: 'GET',
                        headers: API_CONFIG.cacheHeaders.noCache
                    },
                    cacheStrategy);
                },

                deleteTask: function(taskId) {
                    return request('/task/delete/' + taskId, { method: 'DELETE' });
                },

                runTask: function(taskId) {
                    // Force no-cache for task execution
                    return request('/task/run/' + taskId, { 
                        method: 'GET',
                        headers: API_CONFIG.cacheHeaders.noCache
                    });
                },

                getTaskInfo: function(taskId) {
                    // Force no-cache for current task state
                    return request('/task/' + taskId, { 
                        method: 'GET',
                        headers: API_CONFIG.cacheHeaders.noCache
                    });
                },

                updateTask: function(taskId, taskData, cacheStrategy) {
                    return request('/task/update/' + taskId, {
                        method: 'POST',
                        body: JSON.stringify(taskData)
                    },
                    cacheStrategy);
                },

                updateTaskClasses: function(taskId, classes) {
                    return request('/task/updateclasses/' + taskId, {
                        method: 'POST',
                        body: JSON.stringify(classes)
                    });
                },

                getReleases: function(cacheStrategy) {
                    return request('/task/releases/', { method: 'GET' }, cacheStrategy);
                },

                downloadRelease: function(releaseData, cacheStrategy) {
                    return request('/task/release/download', {
                        method: 'POST',
                        body: JSON.stringify(releaseData)
                    },
                    cacheStrategy);
                },

                // Utility methods
                ping: function() {
                    return request('/api/ping', { method: 'GET' }, 'noCache');
                },

                getInfo: function() {
                    return request('/', { method: 'GET' });
                }
            };

            // Make it globally available
            window.PackageManagerAPI = PackageManagerAPI;
            
            // Also create a shorter alias
            window.pmAPI = PackageManagerAPI;

        })();

    </script>>
    Return sc
}

}
