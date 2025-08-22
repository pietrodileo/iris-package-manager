Class PackageManager.UI.Screens.ContentViewerSection.JavaScript Extends PackageManager.UI.Screens.Abstract
{

/*
    JAVASCRIPT
*/
/// Render JavaScript code for the page
/// 
/// This method generates the necessary JavaScript code for the page
/// 
/// # Notes
/// This method is responsible for rendering the JavaScript code that is used
/// to interact with the Content Viewer and Project List Section page UI components.
ClassMethod RenderJavaScript() As %Status
{
    Set sc = $$$OK

    // JavaScript
    Do ..EditProject()
    Do ..ExportProject()
    Do ..IconsHandler()
    Do ..AddClassesModal()
    Do ..NewProjectModal()
    Do ..ContentViewer()
    Do ..ProjectList()

    Return sc
}

/* 

    SCREENS JAVASCRIPT 

*/
ClassMethod EditProject() As %Status
{
    Set sc = $$$OK
    &html<<script language="javascript"> 
        async function editProject(el) {
            const row = el.closest("tr");
            if (!row) return;

            const nameCell = row.children[1];
            const descCell = row.children[2];
            const actionsCell = row.children[4];

            const currentName = nameCell.textContent.trim();
            const currentDesc = descCell.textContent.trim();

            // Name must not be modified since it is equal to the id by default
            //nameCell.innerHTML = `<input type="text" value="${currentName}" />`;
            descCell.innerHTML = `<input class='edit-input' type="text" id="edit-desc-${currentName}" name="desc" placeholder="${currentDesc}" value="${currentDesc}" />`; // Description become modifiable

            // Modify fields as input fields to modify them and modify actions in order to save the modifications
            actionsCell.innerHTML = `
                <div class="actions">
                    <button title="Save" type="button" class="btn-icon" onclick="saveEditedProject(this, '${currentName}')">💾</button>
                    <button title="Cancel Operation" type="button" class="btn-icon" onclick="restoreRecord(this, '${currentDesc}')">❌</button>
                </div>
            `;
        }

        async function restoreRecord(el, NewDesc) {
            const row = el.closest("tr");
            if (!row) return;

            const nameCell = row.children[1];
            const descCell = row.children[2];
            const actionsCell = row.children[4];
            const projectName = nameCell.textContent.trim();

            // Set the new description
            descCell.innerHTML = `<td>${NewDesc}</td>`;

            // Ripristina icone azioni
            actionsCell.innerHTML = `
                <div class="actions">
                    <button title="Edit Description" type="button" class="btn-icon" onclick="editProject(this)">✏️</button>
                    <button title="Add Classes To Project" type="button" class="btn-icon" onclick="addClasses(this)">➕</button>
                    <button title="Delete" type="button" class="btn-icon" onclick="confirmDeleteProject('${projectName}')">🗑️</button>
                </div>
            `;
        }

        async function saveEditedProject(el, originalName) {
            const row = el.closest("tr");
            const name = row.children[1].innerHTML;
            const desc = row.children[2].querySelector("input").value;

            fetch("/csp/user/rest/packagemanager/project/update/" + encodeURIComponent(name), {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(
                    { 
                        "originalName":originalName, // Non permetti la modifica del name
                        "desc":desc
                    })
            })
            .then(res => {
                if (!res.ok) throw new Error("Update failed");
                alert("Project '"+name+"' updated successfully");
                loadProjects();
            })
            .catch(err => {
                alert("Error updating project: '"+err.message+"'");
            });
        }

        async function confirmDeleteProject(name) {
            if (confirm('Are you sure you want to delete project "'+name+'" (project content will not be deleted)?')) {
                deleteProject(name);
            }
        }

        async function deleteProject(name) {
            const res = await fetch('/csp/user/rest/packagemanager/project/delete/' + encodeURIComponent(name), {
                method: "DELETE"
            })
            .then(res => {
                if (!res.ok) throw new Error("Delete failed");
                alert("Project '"+name+"' has been deleted");
                loadProjects();
            })
            .catch(err => {
                alert("Error deleting project: '"+ err.message+"'");
            });
        }
    </script>>

    Return sc
}

ClassMethod ExportProject() As %Status
{
    Set sc = $$$OK
    &html<<script language="javascript"> 
        async function exportSelectedProject() {
            const selected = document.querySelector("input[name='projCheckbox']:checked");
            if (!selected) {
                alert("Please select a project to export.");
                return;
            }

            const projectId = selected.value;
            const downloadUrl = "/csp/user/rest/packagemanager/project/export/" + projectId;
            
            const res = await fetch(downloadUrl, {
                method: "GET"
            });
            if (res.ok) {
                const data = await res.text(); // const data = await res.json();

                // Create a Blob from the XML string
                const blob = new Blob([data], { type: "application/xml" });

                // Create a hidden download link and trigger it silently
                const url = URL.createObjectURL(blob);

                const a = document.createElement("a");
                a.style.display = "none";
                a.href = url;

                // Current date time
                const now = new Date();
                const year = now.getFullYear();
                const month = String(now.getMonth() + 1).padStart(2, '0');
                const day = String(now.getDate()).padStart(2, '0');
                const hours = String(now.getHours()).padStart(2, '0');
                const minutes = String(now.getMinutes()).padStart(2, '0');
                const seconds = String(now.getSeconds()).padStart(2, '0');

                const timestamp = year + month + day + '_' + hours + ':' + minutes + ':' + seconds;

                a.download = projectId + '_' + timestamp + '.xml' || "project_export.xml";

                // Append to DOM, trigger click, then remove
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);

                // Clean up blob URL
                URL.revokeObjectURL(url);
            } else {
                const div = document.getElementById("exportResult");
                const text = await res.text();
                div.innerHTML = `<p class='error'>Export failed: ${text}</p>`;
            }
        }
    </script>>
    Return sc
}

ClassMethod IconsHandler() As %Status
{
    Set sc = $$$OK
    &html<<script language="javascript"> 
            function getIcon(type) {
                const icons = {
                    'CLS': '📘','cls': '📘', 'MAC': '📜', 'mac': '📜', 
                    'INC': '📝','inc': '📝', 'CSP': '🧩', 'csp': '🧩',
                    'CSS': '🎨', 'css': '🎨', 'JS': '💻', 'js': '💻',
                    'JSON': '🧾', 'json': '🧾', 'PNG': '🖼️', 'png': '🖼️',
                    'HTML': '🌐', 'html': '🌐', 'PKG': '📦', 'DIR': '📁',
                    'ico': '🖼️', 'JPG': '🖼️', 'jpg': '🖼️'
                };
                return icons[type] || '📄';
            }
            /*
            Eventual Material Icons support
            function getIcon(type) {
                const icons = {
                    'CLS': 'book',
                    'MAC': 'description',
                    'INC': 'note',
                    'CSP': 'extension',
                    'CSS': 'palette',
                    'JS': 'Javascript',
                    'JSON': 'receipt',
                    'PNG': 'image',
                    'HTML': 'language',
                    'PKG': 'inventory',
                    'DIR': 'folder',
                    'TXT': 'article',
                    'XML': 'code',
                    'PDF': 'picture_as_pdf',
                    'MD': 'notes',
                    'YAML': 'data_object'
                };
                return icons[type.toUpperCase()] || 'insert_drive_file';
            }*/
    </script>>
    Return sc
}

ClassMethod ProjectList() As %Status
{
    Set sc = $$$OK
    &html<<script language="javascript"> 

        // Additional project management functions from your code
        let allProjects = [];

        async function loadProjects() {
            try {
                const res = await fetch("/csp/user/rest/packagemanager/projects", { method: "GET" });
                if (!res.ok) {
                    alert("Failed to load projects");
                    return;
                }
                allProjects = await res.json();
                renderProjects(allProjects);
            } catch (err) {
                alert("Error loading projects: " + err.message);
            }
        }

        async function renderProjects(projects) {
            const table = document.getElementById("projectTableBody");
            if (!table) {
                alert("Table does not exist")   
                return;
            }
            table.innerHTML = "";
            projects.forEach((project, index) => {
                const row = `<tr>
                    <td><input type="checkbox" name="projCheckbox" value="${project.name}" onclick="selectOnlyOne(this)"></td>
                    <td>${project.name}</td>
                    <td>${project.description}</td>
                    <td>${project.last_modified}</td>
                    <td>
                    <div class="actions">
                        <button title="Edit Description" type="button" class="btn-icon" onclick="editProject(this)">✏️</button>
                        <button title="Add Classes To Project" type="button" class="btn-icon" onclick="addClasses(this)">➕</button>
                        <button title="Delete" type="button" class="btn-icon" onclick="confirmDeleteProject('${project.name}')">🗑️</button>
                    </div>
                    </td>
                </tr>`;
                table.innerHTML += row;
            });
        }

        function selectOnlyOne(checkbox) {
            document.querySelectorAll("input[name='projCheckbox']").forEach(cb => {
                if (cb !== checkbox) cb.checked = false;
            });
        }

        async function filterProjects() {
             const term = document.getElementById("searchInput").value.toLowerCase();
            const filtered = allProjects.filter(p =>
                p.name.toLowerCase().includes(term) ||
                p.description.toLowerCase().includes(term)
            );
            renderProjects(filtered);
        }

    </script>>
    Return sc
}

ClassMethod ContentViewer() As %Status
{
    Set sc = $$$OK
    &html<<script language="javascript"> 
        async function showSelectedProjectContent(showAll = false, projectId = null) {
            let url = "/csp/user/rest/packagemanager/project/content/";
            if (!showAll) {
                if (projectId) {
                    // If passed as an argument, show the content of the specified project
                    url += projectId;
                } else {      
                    // otherwise get it from the table              
                    const selected = document.querySelector("input[name='projCheckbox']:checked");
                    if (!selected) {
                        alert("Please select a project.");
                        return;
                    }
                    url += selected.value;
                }
            }
            try {
                const res = await fetch(url, { method: "GET" });
                if (!res.ok) {
                    const text = await res.text();
                    alert("Failed to load project content. Details: " + text);
                    return;
                }
                const json = await res.json();
                
                // Store the original data for filtering
                window.originalProjectData = json;
                window.currentProjectData = json;
                
                // Clear any existing search
                const searchInput = document.getElementById('treeSearchInput');
                if (searchInput) {
                    searchInput.value = '';
                }
                
                // Render the new tree
                renderFolderTree(json, "container");
                
                //console.log("Project content loaded successfully:", json);
                
                // Set a global variable to indicate that elements have been exported
                window.exported = 1;

            } catch (err) {
                alert("Error loading project content: " + err.message);
                //console.error("API Error:", err);
            }
        }

        // Global array to track selected items persistently
        window.persistentTreeSelectedItems = [];

        function renderFolderTree(data, containerId = "container") {
            const container = document.getElementById(containerId);
            if (!container) {
                alert("Container not found:", containerId);
                return;
            }
            
            // Store current data globally
            window.currentProjectData = data;
            
            container.innerHTML = '';

            function isLeafNode(node) {
                return node && typeof node === 'object' && 'name' in node && 'type' in node;
            }

            function createTreeItem(key, value, path = '') {
                const fullPath = path ? `${path}.${key}` : key;
                const li = document.createElement('li');
                li.className = 'tree-item';
                li.title = fullPath;

                const itemContent = document.createElement('div');
                itemContent.className = 'tree-item-content';

                // Folder toggle arrow
                const toggle = document.createElement('span');
                toggle.className = 'tree-toggle';
                toggle.textContent = '▶';
                itemContent.appendChild(toggle);
                toggle.title = fullPath;

                // Checkbox
                const checkbox = document.createElement('input');
                checkbox.type = 'checkbox';
                checkbox.className = 'tree-checkbox';
                checkbox.value = fullPath;
                checkbox.placeholder = false;
                checkbox.id = 'tree-checkbox-'+fullPath;

                // Add leaf count as data attribute for folders
                if (!isLeafNode(value)) {
                    checkbox.setAttribute('data-leaf', 'false');
                } else {
                    checkbox.setAttribute('data-leaf', 'true');
                    if (checkbox.checked) {
                        // Sync with persistent array
                        if (!window.persistentTreeSelectedItems.includes(fullPath)) {
                            window.persistentTreeSelectedItems.push(fullPath);
                        }                        
                    }
                }

                checkbox.addEventListener('change', (e) => {
                    e.stopPropagation();
                    
                    if (checkbox.checked) {
                        // If this is a folder, select all its children (visible and hidden)
                        if (!isLeafNode(value)) {
                            if (li.classList.contains('expanded')) {
                                // If expanded, select visible children
                                selectAllChildren(li, true);
                            } else {
                                // If collapsed, select all hidden children from data
                                selectAllHiddenChildren(value, fullPath, true);
                            }
                        } 
                        // if the object is a leaf, add it to the global selected items
                        if (isLeafNode(value) && !window.persistentTreeSelectedItems.includes(fullPath)) {
                            window.persistentTreeSelectedItems.push(fullPath);                   
                        }                       
                    } else {
                        // If this is a folder, unselect all its children (visible and hidden)
                        if (!isLeafNode(value)) {
                            if (li.classList.contains('expanded')) {
                                // If expanded, unselect visible children
                                selectAllChildren(li, false);
                            } else {
                                // If collapsed, unselect all hidden children from data
                                selectAllHiddenChildren(value, fullPath, false);
                            }
                        }
                        // Remove from persistentSelectedItems if present
                        const idx = window.persistentTreeSelectedItems.indexOf(fullPath);
                        if (idx !== -1) {
                            window.persistentTreeSelectedItems.splice(idx, 1);
                        }
                    }
                    updateSelectedCount();
                });                
                
                itemContent.appendChild(checkbox);

                if (isLeafNode(value)) {
                    // File node
                    li.classList.add('file');
                    toggle.style.visibility = 'hidden';
                    
                    const icon = document.createElement('span');
                    icon.className = "tree-icon";
                    icon.textContent = getIcon(value.type);
                    itemContent.appendChild(icon);

                    const label = document.createElement('span');
                    label.className = 'tree-label';
                    label.textContent = value.name;
                    itemContent.appendChild(label);

                    const type = document.createElement('span');
                    type.className = 'tree-type';
                    type.textContent = value.type.toLowerCase();
                    itemContent.appendChild(type);

                    li.appendChild(itemContent);
                } else {
                    // Folder node
                    li.classList.add('folder');
                    
                    const icon = document.createElement('span');
                    icon.className = "tree-icon";
                    // If the icon is related to the project name (not a folder) use a different icon
                    let curr_icon = '📂'
                    if (!path) {
                        curr_icon = '🗂️'
                    } 
                    if (key === 'DIR') {
                        curr_icon = '📁'
                    } 
                    if (key === 'PKG') {
                        curr_icon = '📦'
                    } 
                    icon.textContent = curr_icon;
                    itemContent.appendChild(icon);

                    const label = document.createElement('span');
                    label.className = 'tree-label';
                    label.textContent = key;
                    itemContent.appendChild(label);

                    // Click handler for folder expansion
                    itemContent.addEventListener('click', (e) => {
                        if (e.target === checkbox) return;
                        e.preventDefault();
                        e.stopPropagation();
                        
                        const wasExpanded = li.classList.contains('expanded');
                        if (wasExpanded) {
                            li.classList.remove('expanded');
                        } else {
                            li.classList.add('expanded');
                            // NEW: If folder gets expanded and is selected, select all its children
                            //if (checkbox.checked) {
                            //    selectAllChildren(li, true);
                            //}
                        }
                    });

                    // Create children
                    const childrenContainer = document.createElement('ul');
                    childrenContainer.className = 'tree-children';

                    for (const childKey in value) {
                        if (value[childKey]) {
                            const childItem = createTreeItem(childKey, value[childKey], fullPath);
                            childrenContainer.appendChild(childItem);
                        }
                    }

                    li.appendChild(itemContent);
                    li.appendChild(childrenContainer);
                }

                return li;
            }

            function updateSelectedCount() {
                let totalLeafCount = window.persistentTreeSelectedItems.length;                
                const countElement = document.getElementById('selectedCount');
                if (countElement) {
                    countElement.textContent = `${totalLeafCount} Selected`;
                }
            }

            // Global functions accessible from buttons
            window.expandAllTree = function() {
                if (!window.exported) {
                    alert('Show at least a project before');
                    return;
                }
                container.querySelectorAll('.tree-item.folder').forEach(item => {
                    item.classList.add('expanded');
                });
            };

            window.collapseAllTree = function() {
                if (!window.exported) {
                    alert('Show at least a project before');
                    return;
                }
                container.querySelectorAll('.tree-item.folder').forEach(item => {
                    item.classList.remove('expanded');
                });
            };

            // Function to ask API to export an xml with the selected classes or packages
            window.getSelectedProjectItems = async function() {
                const expandedSelection = [];
                
                if (window.persistentTreeSelectedItems.length == 0) {
                    alert("Please select at least an element to export");
                    return;
                }

                // Get the export button and save original text
                const exportButton = document.getElementById('tree-export-btn');
                const originalText = exportButton.textContent;
                
                // Set loading state
                exportButton.textContent = 'Exporting...';
                exportButton.disabled = true;

                try {
                    window.persistentTreeSelectedItems.forEach(path => {
                        const item = findItemByPath(window.currentProjectData, path);
                        if (item && isLeafNode(item)) {
                            expandedSelection.push({
                                path: path,
                                name: item.name,
                                type: item.type,
                                isLeaf: true
                            });
                        }                     
                        // Skip folder selections - only export explicitly selected leaf nodes
                    });

                    /*
                    console.log('=== SELECTED PROJECT ITEMS ===');
                    console.log(`Total selections: ${selected.length}`);
                    console.log(`Expanded to ${expandedSelection.length} leaf items:`);
                    */

                    class_array = []
                    expandedSelection.forEach(item => {
                        // Check if current item is a class (PKG) or a file (DIR)
                        // Rendered items are always separated by a point ('.')
                        let item_parts = item.path.split(".");
                        if (item_parts[1]=='DIR'){ 
                            item_parts.splice(0, 2); // Remove the first two elements
                            // Directory files should be sent to the API separated by a slash
                            item.path = item_parts.join('/')
                        } else if (item_parts[1]=='PKG') {
                            item_parts.splice(0, 2); // Removes the first two elements
                            // Package items should be sent to the API separated by a point
                            item.path = item_parts.join('.')
                        }
                        const item_fullname = item.path+'.'+item.type.toLowerCase();
                        // Push the current item within the array
                        class_array.push({
                            "name": item_fullname
                        })
                        //console.log(`📄 ${item.path} [${item.type}] - ${item.name}`);
                    });

                    const response = await fetch("/csp/user/rest/packagemanager/classes/export/", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json"
                        },
                        body: JSON.stringify(
                            {
                                "elements": class_array
                            }
                        )
                    });

                    if (response.ok) {
                        //const data = await response.json();
                        // Create a Blob from the XML string
                        //const blob = new Blob([data.stream], { type: "application/xml" });

                        const data = await response.text(); // const data = await res.json();

                        // Create a Blob from the XML string
                        const blob = new Blob([data], { type: "application/xml" });

                        // Create a hidden download link and trigger it silently
                        const url = URL.createObjectURL(blob);
                        const a = document.createElement("a");
                        a.style.display = "none";
                        a.href = url;

                        // Current date time
                        const now = new Date();
                        const year = now.getFullYear();
                        const month = String(now.getMonth() + 1).padStart(2, '0');
                        const day = String(now.getDate()).padStart(2, '0');
                        const hours = String(now.getHours()).padStart(2, '0');
                        const minutes = String(now.getMinutes()).padStart(2, '0');
                        const seconds = String(now.getSeconds()).padStart(2, '0');

                        const timestamp = year + month + day + '_' + hours + ':' + minutes + ':' + seconds;

                        a.download = 'class_export_' + timestamp + '.xml';

                        // Append to DOM, trigger click, then remove
                        document.body.appendChild(a);
                        a.click();
                        document.body.removeChild(a);

                        // Clean up blob URL
                        URL.revokeObjectURL(url);
                    } else {
                        //const div = document.getElementById("exportResult");
                        const text = await response.text();
                        //div.innerHTML = `<p class='error'>Export failed: ${text}</p>`;
                        alert(`"Export failed: ${text}"`);
                    }
                    
                    return expandedSelection;
                    
                } catch (error) {
                    // Handle any errors that might occur
                    console.error('Export error:', error);
                    alert('Export failed: ' + error.message);
                } finally {
                    // Always restore the button state, even if an error occurs
                    exportButton.textContent = originalText;
                    exportButton.disabled = false;
                }
            };

            // Function to ask API to remove the selected classes or packages from the project
            window.removeSelectedProjectItems = async function() {
                const expandedSelection = [];
                
                if (window.persistentTreeSelectedItems.length == 0) {
                    alert("Please select at least an element to remove");
                    return;
                }

                const projectId = getCommonPrefix(window.persistentTreeSelectedItems)
                if (projectId === null) {
                    alert("Please remove one item at time from a project.");
                    return;
                }

                if (!confirm("Do you really want to remove " + window.persistentTreeSelectedItems.length + " elements from project '" + projectId + "'?")) {
                    return;
                }

                window.persistentTreeSelectedItems.forEach(path => {
                    const item = findItemByPath(window.currentProjectData, path);
                    if (item && isLeafNode(item)) {
                        expandedSelection.push({
                            path: path,
                            name: item.name,
                            type: item.type,
                            isLeaf: true
                        });
                    }                     
                    // Skip folder selections - only export explicitly selected leaf nodes
                });

                class_array = []
                expandedSelection.forEach(item => {
                    // Check if current item is a class (PKG) or a file (DIR)
                    // Rendered items are always separated by a point ('.')
                    let item_parts = item.path.split(".");
                    if (item_parts[1]=='DIR'){ 
                        item_parts.splice(0, 2); // Remove the first two elements
                        // Directory files should be sent to the API separated by a slash
                        item.path = item_parts.join('/')
                    } else if (item_parts[1]=='PKG') {
                        item_parts.splice(0, 2); // Removes the first two elements
                        // Package items should be sent to the API separated by a point
                        item.path = item_parts.join('.')
                    }
                    const item_fullname = item.path+'.'+item.type.toLowerCase();
                    // Push the current item within the array
                    class_array.push({
                        "name": item_fullname
                    })
                });

                const response = await fetch("/csp/user/rest/packagemanager/project/remove/" + encodeURIComponent(projectId), {
                    method: "PUT",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(
                        {
                            "elements": class_array
                        }
                    )
                });

                if (response.ok) {
                    alert("Elements have been successfully removed from the project");
                    // Reload table to show the updated project content
                    showSelectedProjectContent(false, projectId);
                } else {
                    const errorText = await response.text();
                    const status = await response.status;
                    const statusText = await response.statusText;
                    alert(`Failed to add items to project: ${status}-${statusText} ${errorText}`);
                }

                // Initialize the array of the selected items
                window.persistentTreeSelectedItems = [];
                updateSelectedCount();
            };

            // Get project name from item node name
            function getCommonPrefix(arr) {
                const prefixes = new Set();

                for (const item of arr) {
                    const prefix = item.split('.')[0];
                    prefixes.add(prefix);
                }

                if (prefixes.size === 1) {
                    return [...prefixes][0];  // The only unique prefix
                } else {
                    return null;  // Multiple different prefixes
                }
            }

            // Helper function to select/unselect all children of a folder
            function selectAllChildren(folderElement, select) {
                const childrenContainer = folderElement.querySelector('.tree-children');
                if (!childrenContainer) return;
                
                // Find all checkboxes in the children container
                const childCheckboxes = childrenContainer.querySelectorAll('input[type="checkbox"]');
                
                childCheckboxes.forEach(childCheckbox => {
                    const childPath = childCheckbox.value;
                    
                    if (select) {
                        childCheckbox.checked = true;
                        
                        // If this child is also a folder and is expanded, recursively select its children
                        const childItem = childCheckbox.closest('.tree-item');
                        if (childItem && childItem.classList.contains('folder') && childItem.classList.contains('expanded')) {
                            selectAllChildren(childItem, true);
                        } else {
                            // if the child is not a folder, so if it is a leaf, add it to the global array
                            if (!window.persistentTreeSelectedItems.includes(childPath)) {
                                window.persistentTreeSelectedItems.push(childPath);                   
                            }                       
                        }
                    } else {
                        childCheckbox.checked = false;
                        
                        // If this child is also a folder, recursively unselect its children
                        const childItem = childCheckbox.closest('.tree-item');
                        if (childItem && childItem.classList.contains('folder')) {
                            selectAllChildren(childItem, false);
                        } else {
                            // if the child is not a folder, so if it is a leaf, remove it to the global array
                            if (window.persistentTreeSelectedItems.includes(childPath)) {
                                // Remove from persistentSelectedItems if present
                                const idx = window.persistentTreeSelectedItems.indexOf(childPath);
                                if (idx !== -1) {
                                    window.persistentTreeSelectedItems.splice(idx, 1);
                                }
                            }                       
                        }
                    }
                });
            }

            // Helper functions for selection
            function findItemByPath(data, path) {
                const pathParts = path.split('.');
                let current = data;
                
                for (const part of pathParts) {
                    if (current && current[part]) {
                        current = current[part];
                    } else {
                        return null;
                    }
                }
                
                return current;
            }

            // Function to select/unselect all hidden children from data structure
            function selectAllHiddenChildren(nodeData, basePath, select) {
                if (!nodeData || typeof nodeData !== 'object') return;
                
                function traverseAndSelect(obj, currentPath) {
                    for (const key in obj) {
                        const value = obj[key];
                        if (!value) continue;
                        
                        const fullPath = currentPath ? `${currentPath}.${key}` : key;
                        
                        if (isLeafNode(value)) {
                            // This is a leaf node - add/remove from selection
                            if (select) {
                                if (!window.persistentTreeSelectedItems.includes(fullPath)) {
                                    window.persistentTreeSelectedItems.push(fullPath);
                                }
                                // Also check the checkbox if it exists in the DOM
                                const checkbox = document.querySelector(`input[value="${fullPath}"]`);
                                if (checkbox) {
                                    checkbox.checked = true;
                                }
                            } else {
                                const idx = window.persistentTreeSelectedItems.indexOf(fullPath);
                                if (idx !== -1) {
                                    window.persistentTreeSelectedItems.splice(idx, 1);
                                }
                                // Also uncheck the checkbox if it exists in the DOM
                                const checkbox = document.querySelector(`input[value="${fullPath}"]`);
                                if (checkbox) {
                                    checkbox.checked = false;
                                }
                            }
                        } else {
                            // This is a folder - recursively traverse
                            traverseAndSelect(value, fullPath);
                        }
                    }
                }
                
                // Start traversing from the node's children
                traverseAndSelect(nodeData, basePath);
            }

            function getAllLeafNodes(node, basePath = '') {
                const leafNodes = [];
                
                function traverse(obj, currentPath) {
                    for (const key in obj) {
                        const value = obj[key];
                        if (!value) continue;
                        
                        const fullPath = currentPath ? `${currentPath}.${key}` : key;
                        
                        if (isLeafNode(value)) {
                            leafNodes.push({
                                path: fullPath,
                                name: value.name,
                                type: value.type,
                                isLeaf: true
                            });
                        } else {
                            traverse(value, fullPath);
                        }
                    }
                }
                
                traverse(node, basePath);
                return leafNodes;
            }
            
            // Search/filter functionality
            window.filterProjectTree = function() {
                const searchInput = document.getElementById('treeSearchInput');
                if (!searchInput) return;
                
                const searchTerm = searchInput.value.toLowerCase().trim();
                
                if (!searchTerm) {
                    renderFolderTree(window.originalProjectData, containerId);
                } else {
                    const filteredData = filterProjectData(window.originalProjectData, searchTerm);
                    renderFolderTree(filteredData, containerId);
                    setTimeout(() => { window.expandAllTree(); }, 100);
                }
                
                // Restore selections after re-rendering
                setTimeout(() => {
                    restoreSelectionsFromPersistent();
                }, 200);
            };

            // Helper function to restore selections from persistent array
            function restoreSelectionsFromPersistent() {
                const container = document.getElementById(containerId || "container");
                if (!container) return;
                                
                // Restore each selection from persistent array
                window.persistentTreeSelectedItems.forEach(path => {
                    // Try multiple selectors to find the checkbox
                    let checkbox = container.querySelector(`#tree-checkbox-${CSS.escape(path)}`);
                    if (!checkbox) {
                        checkbox = container.querySelector(`input[value="${path}"]`);
                    }
                    
                    if (checkbox) {
                        checkbox.checked = true;
                    }
                });
                
                // Update the selection counter
                updateSelectedCount();
            }

            // Update the clear selection function to also clear persistent array
            window.clearTreeSelection = function() {
                window.persistentTreeSelectedItems = []; // Clear persistent array too
                const container = document.getElementById(containerId || "container");
                if (container) {
                    container.querySelectorAll('input[type="checkbox"]').forEach(cb => {
                        cb.checked = false;
                    });
                }
                updateSelectedCount();
            };

            function filterProjectData(data, searchTerm) {
                function nodeMatches(node, key) {
                    if (isLeafNode(node)) {
                        return node.name.toLowerCase().includes(searchTerm) || 
                            node.type.toLowerCase().includes(searchTerm) ||
                            key.toLowerCase().includes(searchTerm);
                    } else {
                        return key.toLowerCase().includes(searchTerm);
                    }
                }

                function findMatchingPaths(node, key, currentPath = []) {
                    const fullPath = [...currentPath, key];
                    const matches = [];

                    if (nodeMatches(node, key)) {
                        matches.push({
                            path: fullPath,
                            node: node,
                            isDirectMatch: true
                        });
                    }

                    if (!isLeafNode(node)) {
                        for (const childKey in node) {
                            if (node[childKey]) {
                                const childMatches = findMatchingPaths(node[childKey], childKey, fullPath);
                                matches.push(...childMatches);
                            }
                        }
                    }

                    return matches;
                }

                function buildFilteredTree(matches) {
                    const tree = {};

                    matches.forEach(match => {
                        let current = tree;
                        
                        for (let i = 0; i < match.path.length; i++) {
                            const pathSegment = match.path[i];
                            
                            if (i === match.path.length - 1) {
                                current[pathSegment] = match.node;
                            } else {
                                if (!current[pathSegment]) {
                                    current[pathSegment] = {};
                                }
                                current = current[pathSegment];
                            }
                        }
                    });

                    return tree;
                }

                const allMatches = [];
                for (const key in data) {
                    if (data[key]) {
                        const matches = findMatchingPaths(data[key], key);
                        allMatches.push(...matches);
                    }
                }

                const filteredTree = buildFilteredTree(allMatches);

                allMatches.forEach(match => {
                    if (match.isDirectMatch && !isLeafNode(match.node)) {
                        let current = filteredTree;
                        for (let i = 0; i < match.path.length - 1; i++) {
                            current = current[match.path[i]];
                        }
                        const lastSegment = match.path[match.path.length - 1];
                        current[lastSegment] = match.node;
                    }
                });

                return filteredTree;
            }

            // Render the tree
            const ul = document.createElement('ul');
            ul.className = 'tree-list';

            for (const key in data) {
                if (data[key]) {
                    const item = createTreeItem(key, data[key]);
                    ul.appendChild(item);
                }
            }

            container.appendChild(ul);            
        }

    </script>>

    Return sc
}

/* 

    MODALS JAVASCRIPT 

*/
/// Add Classes Modal JavaScript 
ClassMethod AddClassesModal() As %Status
{
    Set sc = $$$OK
    &html<<script language="javascript"> 
        // Global variables for Add Classes Modal (separate from existing project tree)
        let currentAddProjectName = '';
        let originalNamespaceData = null;
        let currentNamespaceData = null;
        // KEY FIX: Use array instead of Set for consistent behavior like working version
        window.persistentNamespaceSelectedItems = [];

        // Main function to open the Add Classes modal
        function addClasses(element) {
            const row = element.closest("tr");
            if (!row) return;
            
            const projectName = row.children[1].textContent.trim();
            currentAddProjectName = projectName;
            
            document.getElementById('modalProjectName').textContent = projectName;
            document.getElementById('addClassesModal').style.display = 'block';
            
            // Reset the modal state
            resetAddClassesModalState();
        }

        function closeAddClassesModal() {
            document.getElementById('addClassesModal').style.display = 'none';
        }

        function resetAddClassesModalState() {
            document.getElementById('fileTypeSelector').value = '';
            document.getElementById('packageSearchInput').value = '';
            document.getElementById('namespaceSearchInput').value = '';
            document.getElementById('namespaceContainer').innerHTML = '<div class="add-classes-loading-message">Select a file type and click "Load Content" to begin</div>';
            window.persistentNamespaceSelectedItems = [];
            updateNamespaceSelectedCount();
            originalNamespaceData = null;
            currentNamespaceData = null;
        }

        // Load namespace content based on selected type
        async function loadNamespaceContent() {
            let fileType = document.getElementById('fileTypeSelector').value;
            const container = document.getElementById('namespaceContainer');
            const lookInto = document.getElementById('packageSearchInput').value;
            const lookIntoKey = 'PackageName';

            container.innerHTML = '<div class="add-classes-loading-message">⏳Loading namespace content...</div>';
            
            try {
                let url = `/csp/user/rest/packagemanager/namespace/content${fileType ? '/' + fileType : '/'}`;

                // If not empty, add a parameter to look into specific packages
                if (lookInto && lookInto.length > 0) { 
                    url += (url.includes('?') ? '&' : '?') + (lookIntoKey+'='+lookInto); 
                }

                const response = await fetch(url, { method: 'GET' });
                
                if (!response.ok) {
                    throw new Error(`Failed to load content: ${response.status} ${response.statusText}`);
                }
                
                const data = await response.json();
                
                // Store the data
                originalNamespaceData = data;
                currentNamespaceData = data;
                
                // Clear search
                document.getElementById('namespaceSearchInput').value = '';
                
                // Clear previous selections
                window.persistentNamespaceSelectedItems = [];
                
                // Render the tree
                renderNamespaceTree(data, 'namespaceContainer');
                
            } catch (error) {
                console.error('Error loading namespace content:', error);
                container.innerHTML = `<div class="add-classes-error-message">Error loading content: ${error.message}</div>`;
            }
        }

        // Render the namespace tree (adapted from existing tree but for modal)
        function renderNamespaceTree(data, containerId) {
            const container = document.getElementById(containerId);
            if (!container) return;
            
            container.innerHTML = '';
            currentNamespaceData = data;

            function isLeafNodeNamespace(node) {
                return node && typeof node === 'object' && 'name' in node && 'type' in node;
            }

            function createNamespaceTreeItem(key, value, path = '') {
                const fullPath = path ? `${path}.${key}` : key;
                const li = document.createElement('li');
                li.className = 'add-classes-tree-item';
                li.title = fullPath;

                const itemContent = document.createElement('div');
                itemContent.className = 'add-classes-tree-item-content';

                // Folder toggle arrow
                const toggle = document.createElement('span');
                toggle.className = 'add-classes-tree-toggle';
                toggle.textContent = '▶';
                itemContent.appendChild(toggle);
                toggle.title = fullPath;

                // Checkbox
                const checkbox = document.createElement('input');
                checkbox.type = 'checkbox';
                checkbox.className = 'add-classes-tree-checkbox';
                checkbox.value = fullPath;
                checkbox.id = 'namespace-checkbox-' + fullPath;

                // Add leaf detection for proper handling
                if (!isLeafNodeNamespace(value)) {
                    checkbox.setAttribute('data-leaf', 'false');
                } else {
                    checkbox.setAttribute('data-leaf', 'true');
                }

                checkbox.addEventListener('change', (e) => {
                    e.stopPropagation();
                    
                    if (checkbox.checked) {
                        // If this is a folder, select all its children (visible and hidden)
                        if (!isLeafNodeNamespace(value)) {
                            if (li.classList.contains('expanded')) {
                                // If expanded, select visible children
                                selectAllNamespaceChildren(li, true);
                            } else {
                                // If collapsed, select all hidden children from data
                                selectAllNamespaceHiddenChildren(value, fullPath, true);
                            }
                        } 
                        // If the object is a leaf, add it to the global selected items
                        if (isLeafNodeNamespace(value) && !window.persistentNamespaceSelectedItems.includes(fullPath)) {
                            window.persistentNamespaceSelectedItems.push(fullPath);                   
                        }                       
                    } else {
                        // If this is a folder, unselect all its children (visible and hidden)
                        if (!isLeafNodeNamespace(value)) {
                            if (li.classList.contains('expanded')) {
                                // If expanded, unselect visible children
                                selectAllNamespaceChildren(li, false);
                            } else {
                                // If collapsed, unselect all hidden children from data
                                selectAllNamespaceHiddenChildren(value, fullPath, false);
                            }
                        }
                        // Remove from persistentSelectedItems if present
                        const idx = window.persistentNamespaceSelectedItems.indexOf(fullPath);
                        if (idx !== -1) {
                            window.persistentNamespaceSelectedItems.splice(idx, 1);
                        }
                    }
                    updateNamespaceSelectedCount();
                });
                
                itemContent.appendChild(checkbox);

                if (isLeafNodeNamespace(value)) {
                    // File node
                    li.classList.add('file');
                    toggle.style.visibility = 'hidden';
                    
                    const icon = document.createElement('span');
                    icon.className = 'add-classes-tree-icon';
                    icon.textContent = getIcon(value.type);
                    itemContent.appendChild(icon);

                    const label = document.createElement('span');
                    label.className = 'add-classes-tree-label';
                    label.textContent = value.name;
                    itemContent.appendChild(label);

                    const type = document.createElement('span');
                    type.className = 'add-classes-tree-type';
                    type.textContent = value.type.toLowerCase();
                    itemContent.appendChild(type);

                    li.appendChild(itemContent);
                } else {
                    // Folder node
                    li.classList.add('folder');
                    
                    const icon = document.createElement('span');
                    icon.className = 'add-classes-tree-icon';
                    let icon_emoji = '📁'
                    if (key == 'CSP') {
                        icon_emoji = '🧩'
                    } else if (key == 'CLS') {
                        icon_emoji = '📘'
                    } else if (key == 'INC') {
                        icon_emoji = '📝'
                    } else if (key == 'MAC') {
                        icon_emoji = '📜'
                    } else if (key == 'Other') {
                        icon_emoji = '⚙️'
                    }
                    icon.textContent = icon_emoji;
                    itemContent.appendChild(icon);

                    const label = document.createElement('span');
                    label.className = 'add-classes-tree-label';
                    label.textContent = key;
                    itemContent.appendChild(label);

                    // FIXED: Click handler for folder expansion (like working version)
                    itemContent.addEventListener('click', (e) => {
                        if (e.target === checkbox) return;
                        e.preventDefault();
                        e.stopPropagation();
                        
                        const wasExpanded = li.classList.contains('expanded');
                        if (wasExpanded) {
                            li.classList.remove('expanded');
                        } else {
                            li.classList.add('expanded');
                        }
                    });

                    // Create children
                    const childrenContainer = document.createElement('ul');
                    childrenContainer.className = 'add-classes-tree-children';

                    for (const childKey in value) {
                        if (value[childKey]) {
                            const childItem = createNamespaceTreeItem(childKey, value[childKey], fullPath);
                            childrenContainer.appendChild(childItem);
                        }
                    }

                    li.appendChild(itemContent);
                    li.appendChild(childrenContainer);
                }

                return li;
            }

            // FIXED: Helper function to select/unselect all children (like working version)
            function selectAllNamespaceChildren(folderElement, select) {
                const childrenContainer = folderElement.querySelector('.add-classes-tree-children');
                if (!childrenContainer) return;
                
                // Find all checkboxes in the children container
                const childCheckboxes = childrenContainer.querySelectorAll('input[type="checkbox"]');
                
                childCheckboxes.forEach(childCheckbox => {
                    const childPath = childCheckbox.value;
                    
                    if (select) {
                        childCheckbox.checked = true;
                        
                        // If this child is also a folder and is expanded, recursively select its children
                        const childItem = childCheckbox.closest('.add-classes-tree-item');
                        if (childItem && childItem.classList.contains('folder') && childItem.classList.contains('expanded')) {
                            selectAllNamespaceChildren(childItem, true);
                        } else {
                            // If the child is not a folder, so if it is a leaf, add it to the global array
                            if (!window.persistentNamespaceSelectedItems.includes(childPath)) {
                                window.persistentNamespaceSelectedItems.push(childPath);                   
                            }                       
                        }
                    } else {
                        childCheckbox.checked = false;
                        
                        // If this child is also a folder, recursively unselect its children
                        const childItem = childCheckbox.closest('.add-classes-tree-item');
                        if (childItem && childItem.classList.contains('folder')) {
                            selectAllNamespaceChildren(childItem, false);
                        } else {
                            // If the child is not a folder, so if it is a leaf, remove it from the global array
                            if (window.persistentNamespaceSelectedItems.includes(childPath)) {
                                const idx = window.persistentNamespaceSelectedItems.indexOf(childPath);
                                if (idx !== -1) {
                                    window.persistentNamespaceSelectedItems.splice(idx, 1);
                                }
                            }                       
                        }
                    }
                });
            }

            // Function to select/unselect all hidden children from data structure
            function selectAllNamespaceHiddenChildren(nodeData, basePath, select) {
                if (!nodeData || typeof nodeData !== 'object') return;
                
                function traverseAndSelect(obj, currentPath) {
                    for (const key in obj) {
                        const value = obj[key];
                        if (!value) continue;
                        
                        const fullPath = currentPath ? `${currentPath}.${key}` : key;
                        
                        if (isLeafNodeNamespace(value)) {
                            // This is a leaf node - add/remove from selection
                            if (select) {
                                if (!window.persistentNamespaceSelectedItems.includes(fullPath)) {
                                    window.persistentNamespaceSelectedItems.push(fullPath);
                                }
                                // Also check the checkbox if it exists in the DOM
                                const checkbox = document.querySelector(`input[value="${fullPath}"]`);
                                if (checkbox) {
                                    checkbox.checked = true;
                                }
                            } else {
                                const idx = window.persistentNamespaceSelectedItems.indexOf(fullPath);
                                if (idx !== -1) {
                                    window.persistentNamespaceSelectedItems.splice(idx, 1);
                                }
                                // Also uncheck the checkbox if it exists in the DOM
                                const checkbox = document.querySelector(`input[value="${fullPath}"]`);
                                if (checkbox) {
                                    checkbox.checked = false;
                                }
                            }
                        } else {
                            // This is a folder - recursively traverse
                            traverseAndSelect(value, fullPath);
                        }
                    }
                }
                
                // Start traversing from the node's children
                traverseAndSelect(nodeData, basePath);
            }

            // Render the tree
            const ul = document.createElement('ul');
            ul.className = 'add-classes-tree-list';

            if (Object.keys(data).length === 0 ) {
                container.innerHTML = '<div class="add-classes-error-message">Research did not return any results, please try again. Note that "Look Into" search is case-sensitive.</div>';
            }

            for (const key in data) {
                if (data[key]) {
                    const item = createNamespaceTreeItem(key, data[key]);
                    ul.appendChild(item);
                }
            }

            container.appendChild(ul);
            updateNamespaceSelectedCount();

            // FIXED: Restore selections after rendering (like working version)
            setTimeout(() => {
                restoreNamespaceSelectionsFromPersistent();
            }, 200);
        }

        // FIXED: Helper function to restore selections from persistent array (like working version)
        function restoreNamespaceSelectionsFromPersistent() {
            const container = document.getElementById('namespaceContainer');
            if (!container) return;
                            
            // Restore each selection from persistent array
            window.persistentNamespaceSelectedItems.forEach(path => {
                // Try multiple selectors to find the checkbox
                let checkbox = container.querySelector(`#namespace-checkbox-${CSS.escape(path)}`);
                if (!checkbox) {
                    checkbox = container.querySelector(`input[value="${path}"]`);
                }
                
                if (checkbox) {
                    checkbox.checked = true;
                }
            });
            
            // Update the selection counter
            updateNamespaceSelectedCount();
        }

        function updateNamespaceSelectedCount() {
            const count = window.persistentNamespaceSelectedItems.length;
            const countElement = document.getElementById('namespaceSelectedCount');
            if (countElement) {
                countElement.textContent = `${count} Selected`;
            }
        }

        // FIXED: Tree control functions for Add Classes Modal (like working version)
        function expandAllNamespaceTree() {
            const container = document.getElementById('namespaceContainer');
            if (!currentNamespaceData) {
                alert('Load content first');
                return;
            }
            container.querySelectorAll('.add-classes-tree-item.folder').forEach(item => {
                item.classList.add('expanded');
            });
        }

        function collapseAllNamespaceTree() {
            const container = document.getElementById('namespaceContainer');
            if (!currentNamespaceData) {
                alert('Load content first');
                return;
            }
            container.querySelectorAll('.add-classes-tree-item.folder').forEach(item => {
                item.classList.remove('expanded');
            });
        }

        function clearNamespaceSelection() {
            window.persistentNamespaceSelectedItems = []; // Clear persistent array too
            const container = document.getElementById('namespaceContainer');
            if (container) {
                container.querySelectorAll('input[type="checkbox"]').forEach(cb => {
                    cb.checked = false;
                });
            }
            updateNamespaceSelectedCount();
        }

        // FIXED: Search/filter functionality for namespace tree (like working version)
        function filterNamespaceTree() {
            const searchInput = document.getElementById('namespaceSearchInput');
            if (!searchInput || !originalNamespaceData) return;
            
            const searchTerm = searchInput.value.toLowerCase().trim();
            
            if (!searchTerm) {
                renderNamespaceTree(originalNamespaceData, 'namespaceContainer');
            } else {
                const filteredData = filterNamespaceData(originalNamespaceData, searchTerm);
                renderNamespaceTree(filteredData, 'namespaceContainer');
                setTimeout(() => { expandAllNamespaceTree(); }, 100);
            }
            
            // Restore selections after re-rendering
            setTimeout(() => {
                restoreNamespaceSelectionsFromPersistent();
            }, 200);
        }

        function filterNamespaceData(data, searchTerm) {
            function isLeafNodeNamespace(node) {
                return node && typeof node === 'object' && 'name' in node && 'type' in node;
            }

            function nodeMatches(node, key) {
                if (isLeafNodeNamespace(node)) {
                    return node.name.toLowerCase().includes(searchTerm) || 
                        node.type.toLowerCase().includes(searchTerm) ||
                        key.toLowerCase().includes(searchTerm);
                } else {
                    return key.toLowerCase().includes(searchTerm);
                }
            }

            function findMatchingPaths(node, key, currentPath = []) {
                const fullPath = [...currentPath, key];
                const matches = [];

                if (nodeMatches(node, key)) {
                    matches.push({
                        path: fullPath,
                        node: node,
                        isDirectMatch: true
                    });
                }

                if (!isLeafNodeNamespace(node)) {
                    for (const childKey in node) {
                        if (node[childKey]) {
                            const childMatches = findMatchingPaths(node[childKey], childKey, fullPath);
                            matches.push(...childMatches);
                        }
                    }
                }

                return matches;
            }

            function buildFilteredTree(matches) {
                const tree = {};

                matches.forEach(match => {
                    let current = tree;
                    
                    for (let i = 0; i < match.path.length; i++) {
                        const pathSegment = match.path[i];
                        
                        if (i === match.path.length - 1) {
                            current[pathSegment] = match.node;
                        } else {
                            if (!current[pathSegment]) {
                                current[pathSegment] = {};
                            }
                            current = current[pathSegment];
                        }
                    }
                });

                return tree;
            }

            const allMatches = [];
            for (const key in data) {
                if (data[key]) {
                    const matches = findMatchingPaths(data[key], key);
                    allMatches.push(...matches);
                }
            }

            const filteredTree = buildFilteredTree(allMatches);

            allMatches.forEach(match => {
                if (match.isDirectMatch && !isLeafNodeNamespace(match.node)) {
                    let current = filteredTree;
                    for (let i = 0; i < match.path.length - 1; i++) {
                        current = current[match.path[i]];
                    }
                    const lastSegment = match.path[match.path.length - 1];
                    current[lastSegment] = match.node;
                }
            });

            return filteredTree;
        }

        // Add selected items to project
        async function addSelectedToProject() {
            const selected = window.persistentNamespaceSelectedItems;
            const projId = document.getElementById('modalProjectName').innerHTML;

            if (selected.length === 0) {
                alert("Please select at least one element to add to the project");
                return;
            }

            const expandedSelection = [];
            
            // Process selected items
            selected.forEach(path => {
                const item = findNamespaceItemByPath(currentNamespaceData, path);
                if (item && isLeafNodeForAdd(item)) {
                    expandedSelection.push({
                        path: path,
                        name: item.name,
                        type: item.type,
                        isLeaf: true
                    });
                }
            });

            // Build the request payload
            const classArray = [];
            expandedSelection.forEach(item => {
                let itemParts = item.path.split(".");
                // Always remove the first element (it is just a placeholder)
                const itemType = itemParts[0];
                itemParts.slice(1);
                if (itemType === 'CSP') { 
                    item.path = itemParts.slice(1).join('/');
                } else if (['CLS', 'INC', 'MAC'].includes(itemType)) {
                    item.path = itemParts.slice(1).join('.');
                } else if (itemType === 'Other') {
                    item.path = itemParts.slice(1).join('.');
                    item.type = '';
                }
                const itemFullname = (item.type === '') ?  item.path : (item.path + '.' + item.type.toLowerCase()); 
                classArray.push({
                    "name": itemFullname
                });
            });

            try {
                // API call to add elements to project
                const response = await fetch("/csp/user/rest/packagemanager/project/add/" + encodeURIComponent(projId), {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({
                        "projectName": currentAddProjectName,
                        "elements": classArray
                    })
                });

                if (response.ok) {
                    alert(`Successfully added ${classArray.length} items to project "${currentAddProjectName}"`);
                    //closeAddClassesModal();
                } else {
                    const errorText = await response.text();
                    const status = await response.status;
                    const statusText = await response.statusText;
                    alert(`Failed to add items to project: ${status}-${statusText} ${errorText}`);
                }

            } catch (error) {
                console.error('Error adding items to project:', error);
                alert(`Error adding items to project: ${error.message}`);
            } 
        }

        // Helper functions for Add Classes Modal
        function isLeafNodeForAdd(node) {
            return node && typeof node === 'object' && 'name' in node && 'type' in node;
        }

        function findNamespaceItemByPath(data, path) {
            let pathParts = path.split('.');
            let current = data;
            
            const type = pathParts[0];
            if (type === 'Other') {
                const otherEl = pathParts.slice(1).join('.');
                pathParts = [type, otherEl]; 
            }

            for (const part of pathParts) {
                if (current && current[part]) {
                    current = current[part];
                } else {
                    return null;
                }
            }
            
            return current;
        }

        // Close modal when clicking outside
        document.addEventListener('DOMContentLoaded', function() {
            const modal = document.getElementById('addClassesModal');
            if (modal) {
                modal.addEventListener('click', function(e) {
                    if (e.target === this) {
                        closeAddClassesModal();
                    }
                });
            }
        });

        // Close modal with Escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && document.getElementById('addClassesModal').style.display === 'block') {
                closeAddClassesModal();
            }
        });

    </script>>
    Return sc
}

ClassMethod NewProjectModal() As %Status
{
    Set sc = $$$OK
    &html<<script language="javascript"> 
        // New Project Modal Functions

        function openNewProjectModal() {
            const modal = document.getElementById('newProjectModal');
            if (modal) {
                modal.classList.add('show');
                // Focus on the project name input
                setTimeout(() => {
                    const nameInput = document.getElementById('projectName');
                    if (nameInput) nameInput.focus();
                }, 100);
                
                // Prevent body scrolling when modal is open
                document.body.style.overflow = 'hidden';
            } else {
                console.error('Modal element not found: newProjectModal');
            }
        }

        function closeNewProjectModal() {
            const modal = document.getElementById('newProjectModal');
            if (modal) {
                modal.classList.remove('show');
                // Reset form
                const form = document.getElementById('newProjectForm');
                if (form) form.reset();
                
                // Restore body scrolling
                document.body.style.overflow = 'auto';
            }
        }

        async function createNewProject(event) {
            event.preventDefault();
            
            // Get form data
            const form = event.target;
            const formData = new FormData(form);
            
            const projectData = {
                name: formData.get('projectName').trim(),
                description: formData.get('projectDescription').trim()
            };
            
            // Basic validation
            if (!projectData.name) {
                alert('Project name is required');
                return;
            }
            
            if (projectData.name.length < 3) {
                alert('Project name must be at least 3 characters long');
                return;
            }

            if (projectData.name.length > 64) {
                alert('Project name cannot be longer than 64 characters');
                return;
            }
            
            // Show loading state
            const submitBtn = form.querySelector('button[type="submit"]');
            const originalText = submitBtn.innerHTML;
            submitBtn.innerHTML = '<span class="plus-icon">⏳</span> Creating...';
            submitBtn.disabled = true;
            
            try {
                const response = await fetch("/csp/user/rest/packagemanager/project/create", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({
                        'name': projectData.name,
                        'desc': projectData.description
                    })
                });

                const now = new Date();
                const formatted_date_time = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
                
                if (response.ok) {
                    // Show success message
                    alert(`${formatted_date_time} - Project "${projectData.name}" has been created successfully!`);
                    
                    // Close modal
                    closeNewProjectModal();
                    
                    // Optionally refresh the project list
                    if (typeof loadProjects === 'function') {
                        loadProjects();
                    }
                } else {
                    const errorData = await response.text();
                    // Handle error - Fixed template literal
                    alert(`${formatted_date_time} - Failed to create project: ${errorData}`);
                }
            } catch (error) {
                console.error('Error creating project:', error);
                const now = new Date();
                const formatted_date_time = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
                alert(`${formatted_date_time} - Network error: Failed to create project. Please try again.`);
            }
            
            // Restore button state
            submitBtn.innerHTML = originalText;
            submitBtn.disabled = false;
        }

        function pad(n) {
            return n.toString().padStart(2, '0');
        }

        // Close modal when clicking outside of it
        document.addEventListener('click', function(event) {
            const modal = document.getElementById('newProjectModal');
            if (modal && event.target === modal) {
                closeNewProjectModal();
            }
        });

        // Close modal with Escape key
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                const modal = document.getElementById('newProjectModal');
                if (modal && modal.classList.contains('show')) {
                    closeNewProjectModal();
                }
            }
        });
    </script>>

    Return sc
}

}
