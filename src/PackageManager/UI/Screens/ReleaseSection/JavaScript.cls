Class PackageManager.UI.Screens.ReleaseSection.JavaScript Extends PackageManager.UI.Screens.Abstract
{

/*
    JAVASCRIPT
*/
/// Render JavaScript code for the page
ClassMethod RenderJavaScript() As %Status
{
    Set sc = $$$OK
    
    &html<<script type="text/javascript">                       

        // Global variables - using array instead of Set for consistent behavior
        let allReleases = {};
        let filteredReleases = {};
        let selectedReleases = []; // Changed from Set to Array for consistency

        // Loads the list of exported releases from the API endpoint.
        // The list of exported releases is an array of objects, where each object represents a release.
        async function loadExportedReleases() {
            PackageManagerAPI.getReleases('noCache')
                .then(function(data) {
                    allReleases = data;
                    // Make a copy of the allReleases object
                    filteredReleases = {};
                    for (const key in allReleases) {
                        if (allReleases.hasOwnProperty(key)) {
                            filteredReleases[key] = allReleases[key];
                        }
                    }
                    selectedReleases = []; // Reset selections
                    renderExportedReleases(filteredReleases);
                })
                .catch(function(err) {
                    showMessageExportedRelease('Error loading exported releases: ' + err.message, 'error');
                    console.error('Error:', err.message);
                });        
        }

        // Render the tree structure
        function renderExportedReleases(data) {
            const container = document.getElementById('releasesContainer');
            container.innerHTML = '';

            if (Object.keys(data).length === 0) {
                container.innerHTML = '<div class="exported-releases-loading">No exported releases found</div>';
                return;
            }

            const ul = document.createElement('ul');
            ul.className = 'exported-releases-tree-list';

            for (const projectName in data) {
                const projectItem = createProjectItem(projectName, data[projectName]);
                ul.appendChild(projectItem);
            }

            container.appendChild(ul);
            
            // Restore selections after rendering
            setTimeout(() => {
                restoreSelectionsFromPersistent();
                updateSelectionUI();
            }, 100);
        }

        // Creates a project folder item in the release tree.
        // The project folder item is a container element that holds the releases for the project.
        // It has a checkbox that allows the user to select or deselect the project.
        function createProjectItem(projectName, releases) {
            const li = document.createElement('li');
            li.className = 'exported-releases-tree-item folder';

            const content = document.createElement('div');
            content.className = 'exported-releases-tree-item-content';

            // Toggle arrow
            const toggle = document.createElement('span');
            toggle.className = 'exported-releases-tree-toggle icon-right-arrow';
            //toggle.textContent = '▶';
            content.appendChild(toggle);

            // Project checkbox (selects all releases in project)
            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.className = 'exported-releases-tree-checkbox';
            checkbox.value = projectName;
            checkbox.setAttribute('data-leaf', 'false'); // Mark as folder
            checkbox.addEventListener('change', (e) => {
                e.stopPropagation();
                handleProjectCheckboxChange(projectName, checkbox.checked, li);
            });
            content.appendChild(checkbox);

            // Project icon
            const icon = document.createElement('span');
            icon.className = 'exported-releases-tree-icon icon-bag';
            content.appendChild(icon);

            // Project label
            const label = document.createElement('span');
            label.className = 'exported-releases-tree-label';
            label.textContent = projectName;
            content.appendChild(label);

            // Release count
            const releaseCount = Object.keys(releases).length;
            const countInfo = document.createElement('div');
            countInfo.className = 'exported-releases-file-info';
            countInfo.innerHTML = `<span>${releaseCount} releases</span>`;
            content.appendChild(countInfo);

            // Click handler for folder expansion
            content.addEventListener('click', (e) => {
                if (e.target === checkbox) return;
                e.preventDefault();
                e.stopPropagation();
                li.classList.toggle('expanded');
            });

            // Create children container
            const childrenContainer = document.createElement('ul');
            childrenContainer.className = 'exported-releases-tree-children';

            // Add release items
            for (const releaseName in releases) {
                const releaseItem = createReleaseItem(releaseName, releases[releaseName]);
                childrenContainer.appendChild(releaseItem);
            }

            li.appendChild(content);
            li.appendChild(childrenContainer);

            return li;
        }

        // Creates a release file item in the release tree.
        // The release file item is a container element that holds the files for the release.
        // It has a checkbox that allows the user to select or deselect the release.
        function createReleaseItem(releaseName, releaseData) {
            const li = document.createElement('li');
            li.className = 'exported-releases-tree-item file';

            const content = document.createElement('div');
            content.className = 'exported-releases-tree-item-content';

            // Empty toggle space
            const toggle = document.createElement('span');
            toggle.className = 'exported-releases-tree-toggle';
            toggle.style.visibility = 'hidden';
            content.appendChild(toggle);

            // File checkbox
            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.className = 'exported-releases-tree-checkbox';
            checkbox.value = releaseData.full_file_path;
            checkbox.dataset.filename = releaseData.name + '.xml';
            checkbox.setAttribute('data-leaf', 'true'); // Mark as leaf
            checkbox.addEventListener('change', (e) => {
                e.stopPropagation();
                handleReleaseCheckboxChange(releaseData.full_file_path, checkbox.checked);
            });
            content.appendChild(checkbox);

            // File icon
            const icon = document.createElement('span');
            icon.className = 'exported-releases-tree-icon icon-document';
            content.appendChild(icon);

            // File label
            const label = document.createElement('span');
            label.className = 'exported-releases-tree-label';
            label.textContent = releaseData.name;
            content.appendChild(label);

            // File info (date and size)
            const fileInfo = document.createElement('div');
            fileInfo.className = 'exported-releases-file-info';
            
            const formattedSize = formatFileSize(releaseData.file_size);
            const formattedDate = formatDate(releaseData.data_created);
            
            fileInfo.innerHTML = `
                <span class="exported-releases-file-date">${formattedDate}</span>
                <span class="exported-releases-file-size">${formattedSize}</span>
            `;
            content.appendChild(fileInfo);

            li.appendChild(content);
            return li;
        }

        // Handle project checkbox changes (folder level)
        // When the project checkbox is checked or unchecked, this function updates the selection state of the project.
        // If the project is selected, it also selects all the releases and files within the project.
        function handleProjectCheckboxChange(projectName, isSelected, folderElement) {
            const projectReleases = filteredReleases[projectName];
            if (!projectReleases) return;

            // Get all release file paths for this project
            const projectFilePaths = Object.values(projectReleases).map(r => r.full_file_path);
            
            if (isSelected) {
                // Add all project releases to selection if not already there
                projectFilePaths.forEach(filepath => {
                    if (!selectedReleases.includes(filepath)) {
                        selectedReleases.push(filepath);
                    }
                });
                
                // If folder is expanded, check visible children
                if (folderElement.classList.contains('expanded')) {
                    selectAllVisibleChildren(folderElement, true);
                }
            } else {
                // Remove all project releases from selection
                projectFilePaths.forEach(filepath => {
                    const index = selectedReleases.indexOf(filepath);
                    if (index !== -1) {
                        selectedReleases.splice(index, 1);
                    }
                });
                
                // If folder is expanded, uncheck visible children
                if (folderElement.classList.contains('expanded')) {
                    selectAllVisibleChildren(folderElement, false);
                }
            }

            updateSelectionUI();
        }

        // Handle individual release checkbox changes (file level)
        // When the release checkbox is checked or unchecked, this function updates the selection state of the release.
        // If the release is selected, it also selects all the files within the release.
        function handleReleaseCheckboxChange(filepath, isSelected) {
            if (isSelected) {
                if (!selectedReleases.includes(filepath)) {
                    selectedReleases.push(filepath);
                }
            } else {
                const index = selectedReleases.indexOf(filepath);
                if (index !== -1) {
                    selectedReleases.splice(index, 1);
                }
            }

            updateSelectionUI();
        }

        // Helper function to select/unselect all visible children
        function selectAllVisibleChildren(folderElement, select) {
            const childrenContainer = folderElement.querySelector('.exported-releases-tree-children');
            if (!childrenContainer) return;
            
            const childCheckboxes = childrenContainer.querySelectorAll('input[type="checkbox"][data-leaf="true"]');
            
            childCheckboxes.forEach(childCheckbox => {
                const filepath = childCheckbox.value;
                
                if (select) {
                    childCheckbox.checked = true;
                    if (!selectedReleases.includes(filepath)) {
                        selectedReleases.push(filepath);
                    }
                } else {
                    childCheckbox.checked = false;
                    const index = selectedReleases.indexOf(filepath);
                    if (index !== -1) {
                        selectedReleases.splice(index, 1);
                    }
                }
            });
        }

        // Update UI elements based on current selection
        function updateSelectionUI() {
            const count = selectedReleases.length;
            document.getElementById('selectedCount').textContent = `${count} Selected`;
            document.getElementById('downloadBtn').disabled = count === 0;

            // Update project checkboxes based on their children
            updateProjectCheckboxes();
        }

        // Update project checkboxes based on selected children (with indeterminate state)
        function updateProjectCheckboxes() {
            for (const projectName in filteredReleases) {
                const projectCheckbox = document.querySelector(`input[type="checkbox"][value="${projectName}"][data-leaf="false"]`);
                if (!projectCheckbox) continue;

                const projectReleases = filteredReleases[projectName];
                const projectFilePaths = Object.values(projectReleases).map(r => r.full_file_path);
                const selectedFromProject = projectFilePaths.filter(path => selectedReleases.includes(path));
                
                if (selectedFromProject.length === 0) {
                    projectCheckbox.checked = false;
                    projectCheckbox.indeterminate = false;
                } else if (selectedFromProject.length === projectFilePaths.length) {
                    projectCheckbox.checked = true;
                    projectCheckbox.indeterminate = false;
                } else {
                    projectCheckbox.checked = false;
                    projectCheckbox.indeterminate = true;
                }
            }
        }

        // Restore selections from persistent array after re-rendering
        function restoreSelectionsFromPersistent() {
            selectedReleases.forEach(filepath => {
                const checkbox = document.querySelector(`input[value="${CSS.escape(filepath)}"][data-leaf="true"]`);
                if (checkbox) {
                    checkbox.checked = true;
                }
            });
        }

        // Download selected releases
        async function downloadSelectedReleases() {
            if (selectedReleases.length === 0) {
                showMessageExportedRelease('Please select at least one release to download', 'error');
                return;
            }

            const downloadBtn = document.getElementById('downloadBtn');
            const originalText = downloadBtn.textContent;
            let downloadCount = 0;
            let errorCount = 0;

            try {
                downloadBtn.textContent = 'Downloading...';
                downloadBtn.disabled = true;

                showMessageExportedRelease(`Starting download of ${selectedReleases.length} file(s)...`, 'info');

                for (const filepath of selectedReleases) {
                    try {
                        // This will work both on Windows or Unix servers
                        let filename = filepath.split(/[\/\\]/).pop();
                        
                        await downloadSingleFile(filepath, filename);
                        downloadCount++;
                        
                        // Update progress
                        downloadBtn.textContent = `${downloadCount}/${selectedReleases.length}`;
                        
                        // Small delay between downloads to prevent overwhelming the server
                        await new Promise(resolve => setTimeout(resolve, 100));
                        
                    } catch (error) {
                        console.error(`Failed to download ${filepath}:`, error);
                        errorCount++;
                    }
                }

                // Show completion message
                if (errorCount === 0) {
                    showMessageExportedRelease(`Successfully downloaded ${downloadCount} file(s)`, 'success');
                } else {
                    showMessageExportedRelease(`Downloaded ${downloadCount} file(s), ${errorCount} failed`, 'error');
                }

            } catch (error) {
                showMessageExportedRelease('Download failed: ' + error.message, 'error');
                console.error('Download error:', error);
            } finally {
                downloadBtn.textContent = originalText;
                downloadBtn.disabled = selectedReleases.length === 0;
            }
        }

        // Download a single file
        async function downloadSingleFile(filepath, filename) {
            const download_req = { filepath: filepath }
            PackageManagerAPI.downloadRelease(download_req,'noCache')
                .then(function(content) {
                    const blob = new Blob([content], { type: 'application/xml' });
                    const url = URL.createObjectURL(blob);
                    
                    const a = document.createElement('a');
                    a.style.display = 'none';
                    a.href = url;
                    a.download = filename;
                    
                    document.body.appendChild(a);
                    a.click();
                    document.body.removeChild(a);
                    
                    URL.revokeObjectURL(url);
                })
                .catch(function(err) {
                    showMessageExportedRelease('Error while downloading exported releases: ' + err.message, 'error');
                    console.error('Error:', err.message);
                });        
        }

        // Search/filter functionality with selection preservation
        function filterExportedReleases() {
            const searchTerm = document.getElementById('searchInput').value.toLowerCase().trim();
            
            if (!searchTerm) {
                // Make a copy of the allReleases object
                filteredReleases = {};
                for (const key in allReleases) {
                    if (allReleases.hasOwnProperty(key)) {
                        filteredReleases[key] = allReleases[key];
                    }
                }
            } else {
                filteredReleases = {};
                
                for (const projectName in allReleases) {
                    const matchingReleases = {};
                    
                    // Check if project name matches
                    const projectMatches = projectName.toLowerCase().includes(searchTerm);
                    
                    for (const releaseName in allReleases[projectName]) {
                        const release = allReleases[projectName][releaseName];
                        const releaseMatches = releaseName.toLowerCase().includes(searchTerm) ||
                                             release.name.toLowerCase().includes(searchTerm);
                        
                        if (projectMatches || releaseMatches) {
                            matchingReleases[releaseName] = release;
                        }
                    }
                    
                    if (Object.keys(matchingReleases).length > 0) {
                        filteredReleases[projectName] = matchingReleases;
                    }
                }
            }
            
            renderExportedReleases(filteredReleases);
        }

        // Expand all project folders
        function expandAllReleases() {
            document.querySelectorAll('.exported-releases-tree-item.folder').forEach(item => {
                item.classList.add('expanded');
            });
        }

        // Collapse all project folders
        function collapseAllReleases() {
            document.querySelectorAll('.exported-releases-tree-item.folder').forEach(item => {
                item.classList.remove('expanded');
            });
        }

        // Clear all selections
        function clearReleaseSelection() {
            selectedReleases = []; // Clear persistent array
            document.querySelectorAll('input[type="checkbox"]').forEach(cb => {
                cb.checked = false;
                cb.indeterminate = false;
            });
            updateSelectionUI();
        }

        // Utility functions
        function formatFileSize(bytes) {
            if (bytes === 0) return '0 B';
            const k = 1024;
            const sizes = ['B', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
        }

        function formatDate(dateString) {
            const date = new Date(dateString);
            return date.toLocaleString();
        }

        function showMessageExportedRelease(text, type) {
            const container = document.getElementById('exported-releases-messageContainer');
            
            // Clear existing messages
            container.innerHTML = '';
            
            if (text) {
                const messageDiv = document.createElement('div');
                messageDiv.className = `exported-releases-message ${type}`;
                messageDiv.textContent = text;
                container.appendChild(messageDiv);
                
                // Auto-hide success messages
                if (type === 'success') {
                    setTimeout(() => {
                        if (container.contains(messageDiv)) {
                            container.removeChild(messageDiv);
                        }
                    }, 5000);
                }
            }
        }
    </script>>
    Return sc
}

}
