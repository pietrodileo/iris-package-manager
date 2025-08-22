Class PackageManager.UI.Screens.ExportTaskSection.JavaScript Extends PackageManager.UI.Screens.Abstract
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

    // Modals JavaScript
    Do ..AddProjectModalJavaScript()
    Do ..CreateTaskModalJavaScript()
    Do ..EditTaskModalJavaScript()
    Do ..TaskTableActionsJavaScript()
    Do ..TaskTableJavaScript()
    
    &html<<script type="text/javascript">                       
        // Utility function to escape HTML
        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
        
        // Close modals when clicking outside
        window.onclick = function(event) {
            const modals = document.querySelectorAll('.modal');
            modals.forEach(modal => {
                if (event.target === modal) {
                    modal.style.display = 'none';
                }
            });
        }
    </script>>
    Return sc
}

/// Render JavaScript code for the task table
/// 
/// This method generates the necessary JavaScript code for the task table,
/// including loading tasks from the API, rendering the table, and handling
/// user interactions.
/// 
/// # Returns
/// * `sc`: Status code indicating success
/// 
/// # Notes
/// This method is responsible for rendering the JavaScript code that is used
/// to interact with the task table UI component.
/// 
/// # Functions
/// * `loadExportTasks`: Loads tasks from the API and renders the table.
/// * `renderTasksTable`: Renders the task table based on the loaded tasks.
ClassMethod TaskTableJavaScript() As %Status
{
    Set sc = $$$OK
    &html<<script type="text/javascript">
        // Global variables
        let currentTasks = [];
            
        // Load tasks from API
        async function loadExportTasks() {
            try {
                //console.log('Making API call to fetch tasks from database...');
                const container = document.getElementById('taskTableContainer');
                const taskCountElement = document.getElementById('taskCount');
                
                // Show loading state
                container.innerHTML = '<div class="loading">Loading tasks from database...</div>';
                
                // Make API call to get tasks from database
                const response = await fetch("/csp/user/rest/packagemanager/task/existing", { method: "GET" });
                if (!response.ok) {
                    throw new Error('Failed to fetch tasks');
                }
                const tasks = await response.json();
                currentTasks = tasks.tasks;
                renderTasksTable(currentTasks);
                
                // Update task count in header
                if (taskCountElement) {
                    taskCountElement.textContent = `🗃️ Existing Tasks: ${currentTasks.length}`;
                }
                
            } catch (error) {
                const container = document.getElementById('taskTableContainer');
                container.innerHTML = `
                    <div class="loading">
                        <p>❌ Error loading tasks from database</p>
                        <p style="font-size: 14px; color: #64748b; margin-top: 8px;">${error.message}</p>
                        <button class="btn-primary" onclick="loadExportTasks()" style="margin-top: 12px;">
                            🔄 Retry
                        </button>
                    </div>
                `;
            }
        }
        
        // Render tasks table
        function renderTasksTable(tasks) {
            const container = document.getElementById('taskTableContainer');
            
            if (!tasks || tasks.length === 0) {
                container.innerHTML = `
                    <div class="loading">
                        <p>📋 No tasks found in database</p>
                        <p style="font-size: 14px; color: #64748b; margin-top: 8px;">
                            Create your first task to get started
                        </p>
                        <button class="btn-primary" onclick="openCreateTaskModal()" style="margin-top: 12px;">
                            ➕ Create New Task
                        </button>
                    </div>
                `;
                return;
            }
            
            //console.log(`Rendering ${tasks.length} tasks from database`);
            
            let html = `
                <table class="styled-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Description</th>
                            <th>Namespace</th>
                            <th>Priority</th>
                            <th>Status</th>
                            <th>Projects</th>
                            <th>Last Started</th>
                            <th>Last Finished</th>
                            <th>Execution Time (s)</th>
                            <th>Last Execution Status</th>
                            <th>Next Run</th>
                            <th>Start Date</th>
                            <th>End Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
            `;
            
            tasks.forEach(task => {
                const statusClass = task.Suspended ? 'status-suspended' : 'status-active';
                const statusText = task.Suspended ? 'Suspended' : 'Active';
                let priorityClass = '';
                if (task.Priority == 1) {
                    priorityClass += 'Low';
                } else if (task.Priority == 0) {
                    priorityClass += 'Normal';
                } else if (task.Priority == 2) {
                    priorityClass += 'High';
                }
                
                // Data di ultima esecuzione
                const displayStarted = task.DisplayStarted?.replace(' ', 'T') ? new Date(task.DisplayStarted.replace(' ', 'T')) : '-';
                const displayFinished = task.DisplayFinished?.replace(' ', 'T') ? new Date(task.DisplayFinished.replace(' ', 'T')) : '-';
                const DisplayStartDate = task.DisplayStartDate? new Date(task.DisplayStartDate) : '-';
                const DisplayEndDate = task.DisplayEndDate === "None" ? '-' : new Date(task.DisplayEndDate);

                // Stato ultima esecuzione
                const displayStatus = task.DisplayStarted ? (task.DisplayStatus || '') : '-';

                // Calcola tempo di esecuzione in secondi solo se entrambe le date sono valide
                let execution_time_seconds = '';
                if (displayStarted instanceof Date && !isNaN(displayStarted) &&
                    displayFinished instanceof Date && !isNaN(displayFinished)) {
                    
                    const diffInMs = displayFinished - displayStarted;
                    execution_time_seconds = diffInMs / 1000;
                }

                // Data di prossima esecuzione
                let nextScheduled = null;
                if (task.DisplayDayNextScheduled && task.TimeNextScheduled) {
                    nextScheduled = new Date(`${task.DisplayDayNextScheduled}T${task.TimeNextScheduled}`);
                }

                // Get projects associated with the current task
                let projects = task.Projects
                // Set the icon for tasks associated with projects
                let projectsIcon = "🗂️";
                let projectsIconTitle = "View Projects";
                if (projects.length === 0) {
                    // Task without any associated project
                    projectsIcon = "📁";
                    projectsIconTitle = "Associate projects to this task";
                }

                html += `
                    <tr>
                        <td>${escapeHtml(task.ID || '')}</td>
                        <td><strong>${escapeHtml(task.Name || '')}</strong></td>
                        <td>${escapeHtml(task.Description || '-')}</td>
                        <td>${escapeHtml(task.NameSpace || '')}</td>
                        <td><span class="priority-badge priority-${priorityClass}">${priorityClass}</span></td>
                        <td><span class="status-badge ${statusClass}">${statusText}</span></td>
                        <td>
                            <button type="button" class="btn-icon" 
                                data-task-name="${escapeHtml(task.Name)}"
                                data-task-id="${task.ID}"
                                data-task-projects="${escapeHtml(btoa(unescape(encodeURIComponent(JSON.stringify(task.Projects)))))}" 
                                onclick="showProjects(this)"
                                title="${projectsIconTitle}">
                                ${projectsIcon}
                            </button>
                        </td>
                        <td>${displayStarted ? displayStarted.toLocaleString() : 'Never'}</td>
                        <td>${displayFinished ? displayFinished.toLocaleString() : '-'}</td>
                        <td>${execution_time_seconds !== '' ? `${execution_time_seconds} sec` : '-'}</td>                        
                        <td>${displayStatus !== '' ? `${displayStatus}` : '-'}</td>
                        <td>${nextScheduled ? nextScheduled.toLocaleString() : '-'}</td>
                        <td>${DisplayStartDate 
                            ? DisplayStartDate.toLocaleDateString('it-IT', { day: '2-digit', month: '2-digit', year: 'numeric' }) 
                        : '-'}</td>
                        <td>${DisplayEndDate === "-"
                            ? '-' : DisplayEndDate.toLocaleDateString('it-IT', { day: '2-digit', month: '2-digit', year: 'numeric' }) }</td>
                        <td>
                            <div class="actions">
                                <button type="button" class="btn-icon" onclick="editTask('${escapeHtml(task.ID)}')" title="Edit Task">
                                    ✏️
                                </button>
                                <button type="button" class="btn-icon" onclick="runTask('${escapeHtml(task.ID)}')" title="Run Task">
                                    ▶️
                                </button>
                                <button type="button" class="btn-icon" onclick="deleteTask('${escapeHtml(task.ID)}')" title="Delete Task">
                                    🗑️
                                </button>
                            </div>
                        </td>
                    </tr>
                `;
            });
            
            html += '</tbody></table>';
            container.innerHTML = html;
        }
        </script>>
    Return sc
}

/*
    Modals JAVASCRIPT
*/
ClassMethod CreateTaskModalJavaScript() As %Status
{
    Set sc = $$$OK
    &html<<script type="text/javascript">

        // Show create task modal        
        function openCreateTaskModal() {
            const modal = document.getElementById('createTaskModal');
            modal.style.display = 'flex';  // Force flex display
            // Reset form
            document.getElementById('createTaskForm').reset();
            initializeCreateTaskForm();
        }

        // Close create task modal
        function closeCreateTaskModal() {
            const modal = document.getElementById('createTaskModal');
            modal.style.display = 'none';  // Hide it
        }        
        
        // Handle schedule type changes
        function handleScheduleTypeChange(modal = 'create') {
            let schedule_type_id = 'schedule_type'; // For create modal
            let daily_options_id = 'daily_options';
            let weekly_options_id = 'weekly_options';
            let monthly_options_id = 'monthly_options';
            if (modal === 'edit') {
                schedule_type_id = 'edit-schedule_type'; // for edit modal
                daily_options_id = 'edit-daily_options';
                weekly_options_id = 'edit-weekly_options';
                monthly_options_id = 'edit-monthly_options';
            }
            const scheduleType = document.getElementById(schedule_type_id).value;
            
            // Hide all schedule-specific sections
            document.getElementById(daily_options_id).classList.add('hidden');
            document.getElementById(weekly_options_id).classList.add('hidden');
            document.getElementById(monthly_options_id).classList.add('hidden');
            //document.getElementById('after_task_options').classList.add('hidden');
            
            // Show relevant section based on selection
            switch(scheduleType) {
                case 'daily':
                    document.getElementById(daily_options_id).classList.remove('hidden');
                    break;
                case 'weekly':
                    document.getElementById(weekly_options_id).classList.remove('hidden');
                    break;
                case 'monthly':
                    document.getElementById(monthly_options_id).classList.remove('hidden');
                    break;
                //case 'monthly_by_day':
                //    document.getElementById('monthly_options').classList.remove('hidden');
                //    break;
                //case 'after_task':
                //    document.getElementById('after_task_options').classList.remove('hidden');
                //    break;
            }
        }
        
        // Handle frequency type changes (once vs multiple times)
        function handleFrequencyTypeChange(modal = 'create') {
            let freq_type_id = 'frequency_type'; // For create modal
            if (modal === 'edit') {
                freq_type_id = 'edit-frequency_type'; // for edit modal
            }
            const frequencyType = document.getElementById(freq_type_id).value;
            //const multipleTimesOptions = document.getElementById('multiple_times_options');
            
            //if (frequencyType === 'multiple') {
            //    multipleTimesOptions.classList.remove('hidden');
            //} else {
            //    multipleTimesOptions.classList.add('hidden');
            //}
        }
        
        // Email management functions
        let emailNotifications = {
            completion: [],
            error: [],
            expiration: []
        };
        
        function addEmail(type) {
            const inputId = `${type}_email_input`;
            const email = document.getElementById(inputId).value.trim();
            
            // Basic email validation
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!email || !emailRegex.test(email)) {
                alert('Please enter a valid email address');
                return;
            }
            
            // Check if email already exists
            if (emailNotifications[type].includes(email)) {
                alert('Email address already added');
                return;
            }
            
            // Add email to list
            emailNotifications[type].push(email);
            document.getElementById(inputId).value = '';
            updateEmailDisplay(type);
        }
        
        function removeEmail(type, email) {
            const index = emailNotifications[type].indexOf(email);
            if (index > -1) {
                emailNotifications[type].splice(index, 1);
                updateEmailDisplay(type);
            }
        }
        
        function updateEmailDisplay(type) {
            const container = document.getElementById(`${type}_email_list`);
            container.innerHTML = emailNotifications[type].map(email => 
                `<span class="email-tag">
                    ${escapeHtml(email)}
                    <span class="remove-email" onclick="removeEmail('${type}', '${email}')">&times;</span>
                </span>`
            ).join('');
        }

        // Initialize form
        function initializeCreateTaskForm() {
            // Reset email lists
            emailNotifications = { completion: [] };
            updateEmailDisplay('completion');
            
            // Set current time
            const now = new Date();
            const hours = String(now.getHours()).padStart(2, '0');
            const minutes = String(now.getMinutes()).padStart(2, '0');
            document.getElementById('run_once_time').value = `${hours}:${minutes}`;

            // Set current date
            const today = new Date();
            const yyyy = today.getFullYear();
            const mm = String(today.getMonth() + 1).padStart(2, '0');
            const dd = String(today.getDate()).padStart(2, '0');
            document.getElementById('start_date').value = `${yyyy}-${mm}-${dd}`;

            // Set default values
            document.getElementById('schedule_type').value = 'daily';
            document.getElementById('frequency_type').value = 'once';
            
            // Handle initial state
            handleScheduleTypeChange();
            handleFrequencyTypeChange();
        }

        // Submit new task
        async function submitNewTask() {
            try {
                // Collect basic task data
                const taskName = document.getElementById('task_name').value.trim();
                const taskDesc = document.getElementById('task_desc').value.trim();
            
                // Validate required fields
                if (!taskName) {
                    alert('Task name is required');
                    return;
                }
                
                // Check that the first character is not a number
                const firstChar = taskName.trim().charAt(0);
                if (/^[0-9]$/.test(firstChar)) {
                    alert('Task name cannot start with a number');
                    return;
                }

                let schedule_type = document.getElementById('schedule_type').value.trim();
                let id_to_verify = '';
                let max_value = 0;
                if (schedule_type === 'daily') {
                    id_to_verify = 'every_n_days';
                    max_value = 7
                } else if (schedule_type === 'weekly') {
                    id_to_verify = 'every_n_weeks';
                    max_value = 5
                } else if (schedule_type === 'monthly') {
                    id_to_verify = 'day_of_month';
                    max_value = 31
                } else if (schedule_type === 'once') {
                    // continue
                } else {
                    alert('Please choose a valid schedule type');
                    return; 
                }
                if (id_to_verify) {
                    if (document.getElementById(id_to_verify).value.trim() > max_value) {
                        alert('Invalid value for ' + id_to_verify + '. Max value is ' + max_value);
                        return;
                    }
                }

                // Collect schedule data
                const scheduleType = document.getElementById('schedule_type').value;
                let startDate = document.getElementById('start_date').value;
                if (!startDate) {
                    const today = new Date();
                    const yyyy = today.getFullYear();
                    const mm = String(today.getMonth() + 1).padStart(2, '0');
                    const dd = String(today.getDate()).padStart(2, '0');
                    startDate = `${yyyy}-${mm}-${dd}`; // Format: YYYY-MM-DD
                }

                const endDate = document.getElementById('end_date').value;
                const frequencyType = document.getElementById('frequency_type').value;
                const priority_type = document.getElementById('priority_type').value;

                let scheduleData = {
                    type: scheduleType,
                    startDate: startDate,
                    endDate: endDate,
                    frequencyType: frequencyType,
                    priority: priority_type
                };
                
                // Add schedule-specific data
                switch(scheduleType) {
                    case 'daily':
                        scheduleData.everyNDays = parseInt(document.getElementById('every_n_days').value) || 1;
                        break;
                    case 'weekly':
                        scheduleData.everyNWeeks = parseInt(document.getElementById('every_n_weeks').value) || 1;
                        const output = Array.from(document.querySelectorAll('.create-task-day-checkbox input:checked'))
                            .map(cb => Number(cb.value))         // convert to numbers
                            .sort((a, b) => a - b)               // numeric sort
                            .join('');                           // join with no separator
                        scheduleData.daysOfWeek = output;
                        break;
                    case 'monthly':
                        scheduleData.everyNMonths = parseInt(document.getElementById('every_n_months').value) || 1;
                        scheduleData.dayOfMonth = parseInt(document.getElementById('day_of_month').value) || 1;
                        break;
                    //case 'monthly_by_day':
                    //    scheduleData.everyNMonths = parseInt(document.getElementById('every_n_months').value) || 1;
                    //   scheduleData.dayOfMonth = parseInt(document.getElementById('day_of_month').value) || 1;
                    //    break;
                    //case 'after_task':
                    //    scheduleData.dependentTask = document.getElementById('dependent_task').value;
                    //    break;
                }
                
                // Add frequency data
                if (frequencyType === 'once') {
                    scheduleData.runTime = document.getElementById('run_once_time').value;
                } else {
                    scheduleData.intervalType = document.getElementById('interval_type').value;
                    scheduleData.intervalValue = parseInt(document.getElementById('interval_value').value) || 1;
                    scheduleData.firstRunTime = document.getElementById('first_run_time').value;
                    scheduleData.lastRunTime = document.getElementById('last_run_time').value;
                }
                
                // Prepare form data for API
                const formData = {
                    task_name: taskName,
                    task_desc: taskDesc,
                    schedule: scheduleData,
                    email_notifications: emailNotifications
                };
                
                console.log('Submitting task data:', formData);

                const response = await fetch('/csp/user/rest/packagemanager/task/create', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(formData)
                });
                
                if (response.ok) {
                    alert('Task created successfully!');
                    closeCreateTaskModal();
                    loadExportTasks();
                } else {
                    const error = await response.text();
                    const now = new Date();
                    const formatted_date_time = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
                    alert(`${formatted_date_time} - Error creating task: ${response.status} ${response.statusText} - ${error}.`);
                }
            } catch (error) {
                const now = new Date();
                const formatted_date_time = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
                alert(`${formatted_date_time} - Error creating task: ${error.message}.`);
            }
        }

        </script>>
    Return sc
}

ClassMethod TaskTableActionsJavaScript() As %Status
{
    Set sc = $$$OK
    &html<<script type="text/javascript">

        // Delete task
        async function deleteTask(taskId) {
            const task = currentTasks.find(t => t.ID === taskId.toString());
            if (!task) {
                alert('Task not found');
                return;
            }
            if (!confirm(`Are you sure you want to delete the task '${taskId}-${task.Name}'?`)) {
                return;
            }
            
            try {
                const response = await fetch(`/csp/user/rest/packagemanager/task/delete/${encodeURIComponent(taskId)}`, {
                    method: 'DELETE'
                });
                
                if (response.ok) {
                    loadExportTasks();
                    alert('Task deleted successfully!');
                } else {
                    const error = await response.text();
                    alert(`Error deleting task: ${error}`);
                }
                
            } catch (error) {
                //console.error('Error deleting task:', error);
                alert('Error deleting task');
            }
        }
        
        // Run task
        async function runTask(taskId) {
            const task = currentTasks.find(t => t.ID === taskId.toString());
            if (!task) {
                alert('Task not found');
                return;
            }
            if (!confirm(`Do you really want to run the task '${taskId}-${task.Name}' now?`)) {
                return;
            }
            
            try {
                const response = await fetch(`/csp/user/rest/packagemanager/task/run/${encodeURIComponent(taskId)}`, {
                    method: 'GET'
                });
                
                if (response.ok) {
                    loadExportTasks();
                    alert('Task run was scheduled successfully!');
                } else {
                    const error = await response.text();
                    alert(`Error while attempting to run the task: ${error}`);
                }
                
            } catch (error) {
                alert('Error while attempting to run the task');
            }
        }


        </script>>
    Return sc
}

ClassMethod EditTaskModalJavaScript() As %Status
{
    Set sc = $$$OK
    &html<<script type="text/javascript">

        // Store original task data for restore functionality
        let originalTaskData = null;
        let currentEditingTaskId = null;

        // Edit task
        function editTask(taskId) {
            const task = currentTasks.find(t => t.ID === taskId);
            if (!task) {
                alert('Task not found');
                return;
            }
            openEditTaskModal(task);                  
        }
        
        // Call API to get task information and show edit task modal        
        async function openEditTaskModal(task) {
            const modal = document.getElementById('renderEditTaskModal');
            if (!modal) {
                console.error('Edit modal not found in DOM');
                return;
            }

            // Store the task ID we're editing
            currentEditingTaskId = task.ID;

            modal.style.display = 'flex';  // Force flex display

            // Call API 
            const response = await fetch('/csp/user/rest/packagemanager/task/' + encodeURIComponent(task.ID), {
                method: 'GET',
            });
            
            if (response.ok) {
                const taskData = await response.json();

                // Store original data for restore functionality
                originalTaskData = JSON.parse(JSON.stringify(taskData)); // Deep copy
                
                // Reset form first
                document.getElementById('EditTaskForm').reset();
                
                // Populate the form with the retrieved task data
                populateFormWithTaskData(taskData);
            } else {
                const response_status = await response.status + '-' + await response.statusText;
                const error = await response.text();
                alert(`It was impossible to retrieve task information. ${response_status}. ${error}`);
            }
        }

        // Close edit task modal and clear stored data
        function closeEditTaskModal() {
            // Use the correct modal ID from your HTML
            const modal = document.getElementById('renderEditTaskModal');
            if (modal) {
                modal.style.display = 'none';  // Hide it
            }
            
            // Clear stored data
            originalTaskData = null;
            currentEditingTaskId = null;
        }
        
        // Restore original task data
        function restoreOriginalData() {
            if (!originalTaskData) {
                console.warn('No original data to restore');
                return;
            }
            
            if (confirm('Are you sure you want to restore the original task settings? All current changes will be lost.')) {
                populateFormWithTaskData(originalTaskData);
            }
        }

        // Email management functions
        let emailNotificationsEdit = {
            completion: [],
            error: [],
            expiration: []
        };
        
        // Populate form with existing task data
        function populateFormWithTaskData(taskData) {
            console.log('Populating form with task data:', taskData);
            try {
                // Add a small delay to ensure DOM elements are ready
                setTimeout(() => {
                    // Basic task information
                    const taskNameElement = document.getElementById('edit-task_name');
                    const taskDescElement = document.getElementById('edit-task_desc');
                    
                    if (taskNameElement) {
                        taskNameElement.value = taskData.Name || '';
                        console.log('Set task name to:', taskData.Name);
                    } else {
                        console.error('edit-task_name element not found');
                    }
                    
                    if (taskDescElement) {
                        taskDescElement.value = taskData.Description || '';
                        console.log('Set task description to:', taskData.Description);
                    } else {
                        console.error('edit-task_desc element not found');
                    }
                    
                    // Read-only status fields (if they exist)
                    const statusElement = document.getElementById('edit-task_status');
                    if (statusElement) {
                        statusElement.value = taskData.DisplayStatus || 'Unknown';
                    }
                    
                    const lastRunElement = document.getElementById('edit-last_run');
                    if (lastRunElement) {
                        lastRunElement.value = taskData.DisplayFinished || 'Never';
                    }
                    
                    const nextScheduledElement = document.getElementById('edit-next_scheduled');
                    if (nextScheduledElement) {
                        const nextTime = taskData.TimeNextScheduled !== "00:00:00" ? taskData.TimeNextScheduled : 'Not scheduled';
                        nextScheduledElement.value = nextTime;
                    }
                    
                    const taskClassElement = document.getElementById('edit-task_class');
                    if (taskClassElement) {
                        taskClassElement.value = taskData.TaskClass || '';
                    }
                    
                    // Task suspended status
                    const suspendedElement = document.getElementById('edit-task_suspended');
                    if (suspendedElement) {
                        suspendedElement.value = taskData.Suspended ? '1' : '0';
                    }
                    
                    // Dates
                    if (taskData.StartDate) {
                        const startDateElement = document.getElementById('edit-start_date');
                        if (startDateElement) {
                            // Ensure date is in YYYY-MM-DD format
                            const startDate = new Date(taskData.StartDate);
                            if (!isNaN(startDate.getTime())) {
                                startDateElement.value = startDate.toISOString().split('T')[0];
                            }
                        }
                    }

                    if (taskData.EndDate) {
                        const endDateElement = document.getElementById('edit-end_date');
                        if (endDateElement) {
                            const endDate = new Date(taskData.EndDate);
                            if (!isNaN(endDate.getTime())) {
                                endDateElement.value = endDate.toISOString().split('T')[0];
                            }
                        }
                    }
                    
                    // Priority
                    const priorityElement = document.getElementById('edit-priority_type');
                    if (priorityElement) {
                        priorityElement.value = taskData.Priority || '0';
                    }
                    
                    // Schedule type based on TimePeriod
                    let scheduleType = 'daily'; // default
                    switch(parseInt(taskData.TimePeriod)) {
                        case 0:
                            scheduleType = 'daily';
                            break;
                        case 1:
                            scheduleType = 'weekly';
                            break;
                        case 2:
                            scheduleType = 'monthly';
                            break;
                        case 5:
                            scheduleType = 'once';
                            break;
                        default:
                            scheduleType = 'daily';
                    }
                    
                    const scheduleTypeElement = document.getElementById('edit-schedule_type');
                    if (scheduleTypeElement) {
                        scheduleTypeElement.value = scheduleType;
                        console.log('Set schedule type to:', scheduleType);

                        const event = new Event('change', { bubbles: true });
                        scheduleTypeElement.dispatchEvent(event);
                    }
                                        
                    // Set schedule-specific values (with another small delay to ensure options are shown)
                    setTimeout(() => {
                        switch(scheduleType) {
                            case 'daily':
                                const everyDaysElement = document.getElementById('edit-every_n_days');
                                if (everyDaysElement) {
                                    everyDaysElement.value = taskData.TimePeriodEvery || 1;
                                }
                                break;
                            case 'weekly':
                                const everyWeeksElement = document.getElementById('edit-every_n_weeks');
                                if (everyWeeksElement) {
                                    everyWeeksElement.value = taskData.TimePeriodEvery || 1;
                                }
                                
                                // Handle days of week from TimePeriodDay
                                // TimePeriodDay format: Sunday=1, Monday=2, ..., Saturday=7
                                // String like "23456" means Monday through Friday
                                if (taskData.TimePeriodDay) {
                                    console.log('Processing TimePeriodDay:', taskData.TimePeriodDay);
                                    
                                    // Reset all checkboxes first
                                    document.querySelectorAll('.edit-task-day-checkbox input').forEach(cb => cb.checked = false);
                                    
                                    // Check the selected days
                                    const daysString = taskData.TimePeriodDay.toString();
                                    for (let i = 0; i < daysString.length; i++) {
                                        const dayValue = daysString.charAt(i);
                                        const checkbox = document.querySelector(`.edit-task-day-checkbox input[value="${dayValue}"]`);
                                        if (checkbox) {
                                            checkbox.checked = true;
                                            console.log('Checked day:', dayValue);
                                        } else {
                                            console.warn('Checkbox not found for day value:', dayValue);
                                        }
                                    }
                                }
                                break;
                            case 'monthly':
                                const everyMonthsElement = document.getElementById('edit-every_n_months');
                                if (everyMonthsElement) {
                                    everyMonthsElement.value = taskData.TimePeriodEvery || 1;
                                }
                                
                                // For monthly, if TimePeriodDay is set, use it, otherwise extract from StartDate
                                let dayOfMonth = 1;
                                if (taskData.TimePeriodDay && taskData.TimePeriodDay !== '') {
                                    dayOfMonth = parseInt(taskData.TimePeriodDay) || 1;
                                } else if (taskData.StartDate) {
                                    dayOfMonth = new Date(taskData.StartDate).getDate();
                                }
                                
                                const dayOfMonthElement = document.getElementById('edit-day_of_month');
                                if (dayOfMonthElement) {
                                    dayOfMonthElement.value = dayOfMonth;
                                }
                                break;
                        }
                    }, 100); // Small delay to ensure schedule options are visible
                    
                    // Trigger change event
                    if (typeof handleScheduleTypeChange === 'function') {
                        handleScheduleTypeChange('edit');
                    }

                    // Time settings
                    if (taskData.DailyStartTime) {
                        // Convert from HH:MM:SS to HH:MM format
                        const timeParts = taskData.DailyStartTime.split(':');
                        if (timeParts.length >= 2) {
                            const runTimeElement = document.getElementById('edit-run_once_time');
                            if (runTimeElement) {
                                const hours = timeParts[0].padStart(2, '0');
                                const minutes = timeParts[1].padStart(2, '0');
                                runTimeElement.value = `${hours}:${minutes}`;
                            }
                        }
                    }
                    
                    // Frequency type (for now, default to 'once' as that seems to be the main use case)
                    const frequencyElement = document.getElementById('edit-frequency_type');
                    if (frequencyElement) {
                        frequencyElement.value = 'once';

                        // Trigger change event
                        if (typeof handleFrequencyTypeChange === 'function') {
                            handleFrequencyTypeChange('edit');
                        }
                    }
                                        
                    console.log('Task data populated successfully');
                    
                }, 50); // Small delay to ensure form elements are rendered
                
            } catch (error) {
                console.error('Error populating form with task data:', error);
                alert('Error loading task data into form. Please try again.');
            }
        }

        // Submit new task
        async function submitEditTask() {
            try {
                if (!currentEditingTaskId) {
                    alert('No task selected for editing');
                    return;
                }

                // Collect basic task data
                const taskName = document.getElementById('edit-task_name').value.trim();
                const taskDesc = document.getElementById('edit-task_desc').value.trim();
                const taskSuspended = document.getElementById('edit-task_suspended').value;

                // Validate required fields
                if (!taskName) {
                    alert('Task name is required');
                    return;
                }
                
                // Check that the first character is not a number
                const firstChar = taskName.trim().charAt(0);
                if (/^[0-9]$/.test(firstChar)) {
                    alert('Task name cannot start with a number');
                    return;
                }

                let schedule_type = document.getElementById('edit-schedule_type').value.trim();
                let id_to_verify = '';
                let max_value = 0;
                if (schedule_type === 'daily') {
                    id_to_verify = 'edit-every_n_days';
                    max_value = 7
                } else if (schedule_type === 'weekly') {
                    id_to_verify = 'edit-every_n_weeks';
                    max_value = 5
                } else if (schedule_type === 'monthly') {
                    id_to_verify = 'edit-day_of_month';
                    max_value = 31
                } else if (schedule_type === 'once') {
                    // continue
                } else {
                    alert('Please choose a valid schedule type');
                    return; 
                }
                if (id_to_verify) {
                    if (document.getElementById(id_to_verify).value.trim() > max_value) {
                        alert('Invalid value for ' + id_to_verify + '. Max value is ' + max_value);
                        return;
                    }
                }

                // Collect schedule data
                const scheduleType = document.getElementById('edit-schedule_type').value;
                let startDate = document.getElementById('edit-start_date').value;
                if (startDate === originalTaskData.StartDate) {
                    startDate = ''; // do not pass the start date if it wasn't modified to avoid errors (task schedule won't allow to set past dates as starting date)
                }
                /*if (!startDate) {
                    const today = new Date();
                    const yyyy = today.getFullYear();
                    const mm = String(today.getMonth() + 1).padStart(2, '0');
                    const dd = String(today.getDate()).padStart(2, '0');
                    startDate = `${yyyy}-${mm}-${dd}`; // Format: YYYY-MM-DD
                }*/

                const endDate = document.getElementById('edit-end_date').value;
                const frequencyType = document.getElementById('edit-frequency_type').value;
                const priority_type = document.getElementById('edit-priority_type').value;

                let scheduleData = {
                    type: scheduleType,
                    startDate: startDate,
                    endDate: endDate,
                    frequencyType: frequencyType,
                    priority: priority_type
                };
                
                // Add schedule-specific data
                switch(scheduleType) {
                    case 'daily':
                        scheduleData.everyNDays = parseInt(document.getElementById('edit-every_n_days').value) || 1;
                        break;
                    case 'weekly':
                        scheduleData.everyNWeeks = parseInt(document.getElementById('edit-every_n_weeks').value) || 1;
                        const output = Array.from(document.querySelectorAll('.edit-task-day-checkbox input:checked'))
                            .map(cb => Number(cb.value))         // convert to numbers
                            .sort((a, b) => a - b)               // numeric sort
                            .join('');                           // join with no separator
                        scheduleData.daysOfWeek = output;
                        break;
                    case 'monthly':
                        scheduleData.everyNMonths = parseInt(document.getElementById('edit-every_n_months').value) || 1;
                        scheduleData.dayOfMonth = parseInt(document.getElementById('edit-day_of_month').value) || 1;
                        break;
                    //case 'monthly_by_day':
                    //    scheduleData.everyNMonths = parseInt(document.getElementById('every_n_months').value) || 1;
                    //   scheduleData.dayOfMonth = parseInt(document.getElementById('day_of_month').value) || 1;
                    //    break;
                    //case 'after_task':
                    //    scheduleData.dependentTask = document.getElementById('dependent_task').value;
                    //    break;
                }
                
                // Add frequency data
                if (frequencyType === 'once') {
                    scheduleData.runTime = document.getElementById('edit-run_once_time').value;
                } else {
                    scheduleData.intervalType = document.getElementById('edit-interval_type').value;
                    scheduleData.intervalValue = parseInt(document.getElementById('edit-interval_value').value) || 1;
                    scheduleData.firstRunTime = document.getElementById('edit-first_run_time').value;
                    scheduleData.lastRunTime = document.getElementById('edit-last_run_time').value;
                }
                
                // Prepare form data for API
                const formData = {
                    task_id: currentEditingTaskId,  
                    task_name: taskName,
                    task_desc: taskDesc,
                    task_suspended: taskSuspended,
                    schedule: scheduleData,
                    email_notifications: emailNotificationsEdit
                };
                
                //console.log('Submitting task data:', formData);

                const response = await fetch('/csp/user/rest/packagemanager/task/update/' + encodeURIComponent(currentEditingTaskId), {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(formData)
                });
                
                if (response.ok) {
                    alert('Task updated successfully!');
                    closeEditTaskModal();
                    loadExportTasks(); // Refresh the task list
                } else {
                    const error = await response.text();
                    alert(`Error updating task: ${error}`);
                }
                
            } catch (error) {
                console.error('Error updating task:', error.message);
                alert(`Error updating task: ${error}`);
            }
        }

        </script>>
    Return sc
}

ClassMethod AddProjectModalJavaScript() As %Status
{
    Set sc = $$$OK
    &html<<script type="text/javascript">
        let taskFileSelectorAllProjects = [];
        let taskFileSelectorOriginalProjects = [];

        async function showProjects(buttonElement) {
            const taskName = buttonElement.getAttribute('data-task-name');
            const taskID = parseInt(buttonElement.getAttribute('data-task-id'));
            const taskProjectsJson = atob(unescape(buttonElement.getAttribute('data-task-projects')));

            let taskProjects = [];
            try {
                taskProjects = taskProjectsJson ? JSON.parse(taskProjectsJson) : [];
            } catch (e) {
                console.error('Error parsing projects JSON:', e);
                taskProjects = [];
            }

            if (taskProjects.length === 0) {
                console.log("No projects for this task");
            }

            // You may fetch real task data here if needed.
            taskFileSelectorData = {
                ID: taskID,
                Name: taskName,
                Description: `Projects for task: ${taskName}`,
                Projects: taskProjects
            };
            
            taskFileSelectorOriginalProjects = JSON.parse(JSON.stringify(taskProjects)); // deep clone

            taskFileSelectorOpenModal();
        }

        let taskFileSelectorSelected = {
            associated: new Set(),
            available: new Set()
        };

        function taskFileSelectorOpenModal() {
            const modal = document.getElementById("taskFileSelectorModal");
            document.getElementById("taskFileSelectorTaskName").textContent = taskFileSelectorData.Description;
            taskFileSelectorLoadAllProjects();
            modal.classList.add("show");
            taskFileSelectorUpdateTransferButtons();
        }

        function taskFileSelectorCloseModal() {
            const modal = document.getElementById("taskFileSelectorModal");
            taskFileSelectorSelected.associated.clear();
            taskFileSelectorSelected.available.clear();
            modal.classList.remove("show");
        }

        function taskFileSelectorRestoreChanges() {
            taskFileSelectorData.Projects = JSON.parse(JSON.stringify(taskFileSelectorOriginalProjects));
            taskFileSelectorPopulateFiles();
            taskFileSelectorSelected.associated.clear();
            taskFileSelectorSelected.available.clear();
            taskFileSelectorUpdateTransferButtons();
            
        }

        async function taskFileSelectorLoadAllProjects() {
            const btn = document.getElementById("taskFileSelectorLoadProjectsBtn");
            const originalText = btn.innerHTML;

            btn.innerHTML = "⏳ Loading...";
            btn.disabled = true;

            document.getElementById("taskFileSelectorAvailableFiles").innerHTML = `<div class="empty-state"><div class="empty-icon">⏳</div><div>Loading projects...</div></div>`;

            setTimeout(async () => {

                try {
                    const res = await fetch("/csp/user/rest/packagemanager/projects", { method: "GET" });
                    if (!res.ok) {
                        alert("Failed to load projects");
                        return;
                    }
                    taskFileSelectorAllProjects = await res.json();
                } catch (err) {
                    alert("Error loading projects: " + err.message);
                }

                taskFileSelectorPopulateFiles();

                btn.innerHTML = "✓ Refreshed";
                btn.innerHTML = originalText;
                btn.disabled = false;
            }, 200);
        }

        function taskFileSelectorPopulateFiles() {
            const associatedIds = taskFileSelectorData.Projects.map(p => p.ProjectId || p.name);
            const associatedProjects = taskFileSelectorAllProjects.filter(p => 
                associatedIds.includes(p.ProjectId || p.name || p.id)
            );
            const availableProjects = taskFileSelectorAllProjects.filter(p => 
                !associatedIds.includes(p.ProjectId || p.name || p.id)
            );
            taskFileSelectorRenderFileList("taskFileSelectorAssociatedFiles", associatedProjects, "associated");
            taskFileSelectorRenderFileList("taskFileSelectorAvailableFiles", availableProjects, "available");
            taskFileSelectorUpdateCounters();
        }

        function taskFileSelectorRenderFileList(containerId, projects, type) {
            const container = document.getElementById(containerId);

            if (projects.length === 0) {
                container.innerHTML = `<div class="empty-state">
                    <div class="empty-icon">${type === "associated" ? "📁" : "🗂️"}</div>
                    <div>No ${type} projects</div>
                </div>`;
            }

            container.innerHTML = projects.map(project => {
                const projectId = project.ProjectId || project.name || project.id;
                const projectName = project.name || project.ProjectId || project.id;
                const projectDescription = project.description || project.Description || '';
                const lastModified = project.last_modified || project.lastModified || project.LastModified || new Date().toISOString();

                return `
                    <div class="task-file-selector-file-item" data-name="${projectId}" onclick="taskFileSelectorToggleSelection('${type}', '${projectId}')">
                        <div class="task-file-selector-file-info">
                            <div class="task-file-selector-file-name">
                                📄 ${projectName} ${type === "associated" ? '<span class="status-badge status-associated">Associated</span>' : ''}
                            </div>
                            ${projectDescription ? `<div class="task-file-selector-file-description">${projectDescription}</div>` : ''}
                            <div class="task-file-selector-file-meta">Last modified: ${new Date(lastModified).toLocaleString()}</div>
                        </div>
                        <div class="task-file-selector-file-actions">
                            ${type === "associated"
                                ? `<button class="task-file-selector-btn-remove" onclick="event.stopPropagation(); taskFileSelectorQuickRemove('${projectId}')">✖ Remove</button>`
                                : `<button class="task-file-selector-btn-add" onclick="event.stopPropagation(); taskFileSelectorQuickAdd('${projectId}')">✓ Add</button>`
                            }
                        </div>
                    </div>
                `;
            }).join("");
        }

        function taskFileSelectorToggleSelection(type, name) {
            const item = document.querySelector(`#taskFileSelector${type.charAt(0).toUpperCase() + type.slice(1)}Files .task-file-selector-file-item[data-name='${name}']`);
            const set = taskFileSelectorSelected[type];
            if (!item) {
                console.error(`Item not found: ${name} in ${type}`);
                return;
            }
            if (set.has(name)) {
                set.delete(name);
                item.classList.remove("selected");
            } else {
                set.add(name);
                item.classList.add("selected");
            }

            taskFileSelectorUpdateTransferButtons();
            
        }

        function taskFileSelectorQuickAdd(projectId) {
            if (!taskFileSelectorData.Projects.find(p => (p.ProjectId || p.name) === projectId)) {
                taskFileSelectorData.Projects.push({ ProjectId: projectId });
                taskFileSelectorPopulateFiles();
                
            }
        }

        function taskFileSelectorQuickRemove(projectId) {
            taskFileSelectorData.Projects = taskFileSelectorData.Projects.filter(p => 
                (p.ProjectId || p.name) !== projectId
            );
            taskFileSelectorPopulateFiles();
            
        }

        function taskFileSelectorUpdateTransferButtons() {
            const addBtn = document.getElementById("taskFileSelectorAddBtn");
            const removeBtn = document.getElementById("taskFileSelectorRemoveBtn");

            if (addBtn) {
                addBtn.disabled = taskFileSelectorSelected.available.size === 0;
            }
            if (removeBtn) {
                removeBtn.disabled = taskFileSelectorSelected.associated.size === 0;
            }            
        }

        function taskFileSelectorUpdateCounters() {
            document.getElementById("taskFileSelectorAssociatedCounter").textContent = taskFileSelectorData.Projects.length;
            document.getElementById("taskFileSelectorAvailableCounter").textContent = taskFileSelectorAllProjects.length - taskFileSelectorData.Projects.length;
        }

        function taskFileSelectorFilterFiles(type, searchTerm) {
            const container = document.getElementById(`taskFileSelector${type.charAt(0).toUpperCase() + type.slice(1)}Files`);
            const items = container.querySelectorAll(".task-file-selector-file-item");
            const search = searchTerm.toLowerCase();

            items.forEach(item => {
                const name = item.querySelector(".task-file-selector-file-name").textContent.toLowerCase();
                const descEl = item.querySelector(".task-file-selector-file-description");
                const desc = descEl ? descEl.textContent.toLowerCase() : "";

                item.style.display = name.includes(search) || desc.includes(search) ? "flex" : "none";
            });
        }

        function taskFileSelectorSaveChanges() {
            const originalIds = taskFileSelectorOriginalProjects.map(p => p.ProjectId || p.name);
            const currentIds = taskFileSelectorData.Projects.map(p => p.ProjectId || p.name);

            const removedProjects = originalIds.filter(id => !currentIds.includes(id));
            const addedProjects = currentIds.filter(id => !originalIds.includes(id));

            console.log("Removed:", removedProjects);
            console.log("Added:", addedProjects);

            fetch("/csp/user/rest/packagemanager/task/updateclasses/" + encodeURIComponent(taskFileSelectorData.ID), {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    taskID: taskFileSelectorData.ID,
                    removed: removedProjects,
                    added: addedProjects
                })
            })
            .then(res => {
                if (!res.ok) throw new Error("Failed to update task projects");
                return res.text();
            })
            .then(responseText => {
                alert(`Changes saved successfully!\nAdded: ${addedProjects.length} projects\nRemoved: ${removedProjects.length} projects`);
                // Refresh the task list to show updated data
                if (typeof loadExportTasks === 'function') {
                    loadExportTasks();
                }
                taskFileSelectorCloseModal();
            })
            .catch(err => {
                alert("Error saving changes: " + err.message);
            });
        }

        window.addEventListener("click", e => {
            const modal = document.getElementById("taskFileSelectorModal");
            if (e.target === modal) taskFileSelectorCloseModal();
        });

    </script>>
    Return sc
}

}
