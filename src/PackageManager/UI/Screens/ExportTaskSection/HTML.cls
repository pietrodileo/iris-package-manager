Class PackageManager.UI.Screens.ExportTaskSection.HTML Extends PackageManager.UI.Screens.Abstract
{

/*
    HTML Rendering
*/
ClassMethod renderExportTask() As %Status
{
    Set sc = $$$OK
    // CSS
    Do ##class(PackageManager.UI.Screens.ExportTaskSection.CSS).RenderStyles()
    // JS 
    Do ##class(PackageManager.UI.Screens.ExportTaskSection.JavaScript).RenderJavaScript()
    // HTML Modals
    Do ##class(PackageManager.UI.Screens.ExportTaskSection.HTML).renderCreateTaskModal()
    Do ##class(PackageManager.UI.Screens.ExportTaskSection.HTML).renderAddProjectModal()
    Do ##class(PackageManager.UI.Screens.ExportTaskSection.HTML).renderEditTaskModal()
    
    &html<<script language='javascript'>
        function renderExportTask() {
            return `
                <h2>📤 #($$$ExportProjectTaskSectionTitle)#</h2>
                <p>Manage system tasks and schedules.</p>
                <div class="project-container">
                    <div class="project-header">
                        <div class='project-title'>
                           <h3 id="taskCount">🗂️ Active Tasks</h3>
                        </div>
                        <div class='header-controls'>
                            <button class='new-project-btn' onclick='openCreateTaskModal()'><span class='plus-icon'>+</span> Create New Task</button>
                        </div>
                    </div>

                    <div class="project-content">
                        <div class='project-table-wrapper'>
                            <table class='project-table' id="taskTableContainer">
                                <tbody id='projectTableBody'>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Modal to show projects related to the current task -->
                    ${renderAddProjectModal()}

                    <!-- Modal to create a new task -->
                    ${renderCreateTaskModal()}

                    <!-- Modal to edit a task -->
                    ${renderEditTaskModal()}

                </div>
            `;
        }
    </script>>
    Return sc
}

/*
    Modals Rendering
*/
ClassMethod renderCreateTaskModal() As %Status
{
    Set sc = $$$OK
    &html<<script language='javascript'>
        function renderCreateTaskModal() {
            return `
                <!-- OVERLAY -->
                <div id="createTaskModal" class="create-task-modal-overlay">

                    <!-- CONTAINER CENTRATO -->
                    <div class="create-task-modal-container">

                        <!-- HEADER + FORM -->
                        <div class="create-task-modal-header">
                            <h3>🗃️ Create New Task</h3>
                            <button type="button" class="create-task-close" onclick="closeCreateTaskModal()">×</button>
                        </div>
                        <div class="create-task-modal-content">
                            <form id="createTaskForm">
                                <!-- Basic Information -->
                                <div class="create-task-form-row">
                                    <div class="create-task-form-group">
                                        <label class="create-task-form-label">Task Name *</label>
                                        <input type="text" id="task_name" class="create-task-form-input" placeholder="Enter task name" maxlength="50" required>
                                    </div>
                                    <div class="create-task-form-group">
                                        <label class="create-task-form-label">Description</label>
                                        <input type="text" id="task_desc" class="create-task-form-input" placeholder="Enter task description">
                                    </div>
                                </div>

                                <!-- Schedule Section -->
                                <div class="schedule-section">
                                    <h4>📅 Schedule Configuration</h4>
                                    <div class="create-task-form-group">
                                        <label class="create-task-form-label">How often do you want the Task Manager to execute this task?</label>
                                        <select id="schedule_type" class="create-task-form-select" onchange="handleScheduleTypeChange()">
                                            <option value="" disabled selected>Choose...</option>
                                            <option value="once">Only Once</option>
                                            <option value="daily">Daily</option>
                                            <option value="weekly">Weekly</option>
                                            <option value="monthly">Monthly</option>
                                        </select>
                                    </div>
                                    
                                    <!-- Daily Options -->
                                    <div id="daily_options" class="hidden">
                                        <div class="create-task-form-group">
                                            <label class="create-task-form-label">Every</label>
                                            <div class="create-task-form-grid-2">
                                                <input type="number" id="every_n_days" class="create-task-form-input" value="1" min="1" max="7">
                                                <span style="align-self: center;">day(s)</span>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Weekly Options -->
                                    <div id="weekly_options" class="hidden">
                                        <div class="create-task-form-group">
                                            <label class="create-task-form-label">Every</label>
                                            <div class="create-task-form-grid-2">
                                                <input type="number" id="every_n_weeks" class="create-task-form-input" value="1" min="1" max="5">
                                                <span style="align-self: center;">week(s)</span>
                                            </div>
                                        </div>
                                        <div class="create-task-form-group">
                                            <label class="create-task-form-label">Days of the week:</label>
                                            <div class="create-task-week-row">
                                                <label class="create-task-day-checkbox"><input type="checkbox" value="2"> Monday</label>
                                                <label class="create-task-day-checkbox"><input type="checkbox" value="3"> Tuesday</label>
                                                <label class="create-task-day-checkbox"><input type="checkbox" value="4"> Wednesday</label>
                                                <label class="create-task-day-checkbox"><input type="checkbox" value="5"> Thursday</label>
                                                <label class="create-task-day-checkbox"><input type="checkbox" value="6"> Friday</label>
                                                <label class="create-task-day-checkbox"><input type="checkbox" value="7"> Saturday</label>
                                                <label class="create-task-day-checkbox"><input type="checkbox" value="1"> Sunday</label>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Monthly Options -->
                                    <div id="monthly_options" class="hidden">
                                        <div class="create-task-form-group">
                                            <label class="create-task-form-label">Every</label>
                                            <div class="create-task-form-grid-2">
                                                <input type="number" id="every_n_months" class="create-task-form-input" value="1" min="1" max="12">
                                                <span style="align-self: center;">month(s)</span>
                                            </div>
                                        </div>
                                        <div class="create-task-form-group">
                                            <label for="day_of_month" class="create-task-form-label">On day of month:</label>
                                            <input type="number" id="day_of_month" class="create-task-form-input" value="1" min="1" max="31">
                                        </div>
                                    </div>
                                </div>

                                <!-- Date Range -->
                                <div class="create-task-form-row">
                                    <div class="create-task-form-group">
                                        <label class="create-task-form-label">Start Date</label>
                                        <input type="date" id="start_date" class="create-task-form-input">
                                    </div>
                                    <div class="create-task-form-group">
                                        <label class="create-task-form-label">End Date (optional)</label>
                                        <input type="date" id="end_date" class="create-task-form-input">
                                        <small style="color: #666; font-size: 12px;">Leave empty for tasks that never expire</small>
                                    </div>
                                </div>

                                <!-- Frequency -->
                                <div class="create-task-form-row">
                                    <div class="create-task-form-group">
                                        <label class="create-task-form-label">Execution frequency:</label>
                                        <select id="frequency_type" class="create-task-form-select" onchange="handleFrequencyTypeChange()">
                                            <option value="once">Run once at this time</option>
                                        </select>
                                    </div>
                                    <div id="single_run_options">
                                        <div class="create-task-form-group">
                                            <label class="create-task-form-label">Run time:</label>
                                            <input type="time" id="run_once_time" class="create-task-form-input" value="01:00">
                                        </div>
                                    </div>
                                    <div class="create-task-form-group">
                                        <label class="create-task-form-label">Priority</label>
                                        <select id="priority_type" class="create-task-form-select">
                                            <option value="1">Low</option>
                                            <option value="0">Normal</option>
                                            <option value="2">High</option>
                                        </select>
                                    </div>
                                </div>

                                <!-- Email Notifications Section -->
                                <div class="create-task-email-section">
                                    <h4>📧 Email Notifications (Available Soon...)</h4>
                                    <div class="create-task-form-group">
                                        <label class="create-task-form-label">Completion Notifications:</label>
                                        <div class="create-task-email-input-group">
                                            <input type="email" id="completion_email_input" class="create-task-form-input" placeholder="Enter email address" disabled>
                                            <button type="button" class="btn btn-secondary" onclick="addEmail('completion')">Add</button>
                                        </div>
                                        <div id="completion_email_list" class="create-task-email-list"></div>
                                    </div>
                                </div>

                                <!-- Buttons -->
                                <div style="text-align: right; padding-top: 16px; border-top: 1px solid #e2e8f0; margin-top: 16px;">
                                    <button type="button" class="btn btn-secondary" onclick="closeCreateTaskModal()" style="margin-right: 8px;">Cancel</button>
                                    <button type="button" class="btn btn-primary" onclick="submitNewTask()">Create Task</button>
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

ClassMethod renderEditTaskModal() As %Status
{
    Set sc = $$$OK
    &html<<script language='javascript'>
        function renderEditTaskModal() {
            return `
                <!-- OVERLAY -->
                <div id="renderEditTaskModal" class="create-task-modal-overlay">

                    <!-- CONTAINER CENTRATO -->
                    <div class="create-task-modal-container">

                        <!-- HEADER + FORM -->
                        <div class="create-task-modal-header">
                            <h3>🗃️ Edit Task</h3>
                            <button type="button" class="create-task-close" onclick="closeEditTaskModal()">×</button>
                        </div>
                        <div class="create-task-modal-content">
                            <form id="EditTaskForm">
                                <!-- Task Status Info (Read-only) -->
                                <div class="task-status-section" style="background: #f8f9fa; padding: 12px; border-radius: 6px; margin-bottom: 16px;">
                                    <h4>📊 Current Task Status</h4>
                                    <div class="create-task-form-row">
                                        <div class="create-task-form-group">
                                            <label class="create-task-form-label">Status</label>
                                            <input type="text" id="edit-task_status" class="create-task-form-input" readonly style="background: #f1f1f1;">
                                        </div>
                                        <div class="create-task-form-group">
                                            <label class="create-task-form-label">Last Run</label>
                                            <input type="text" id="edit-last_run" class="create-task-form-input" readonly style="background: #f1f1f1;">
                                        </div>
                                    </div>
                                    <div class="create-task-form-row">
                                        <div class="create-task-form-group">
                                            <label class="create-task-form-label">Next Scheduled</label>
                                            <input type="text" id="edit-next_scheduled" class="create-task-form-input" readonly style="background: #f1f1f1;">
                                        </div>
                                        <div class="create-task-form-group">
                                            <label class="create-task-form-label">Task Class</label>
                                            <input type="text" id="edit-task_class" class="create-task-form-input" readonly style="background: #f1f1f1;">
                                        </div>
                                    </div>
                                </div>

                                <!-- Basic Information -->
                                <div class="create-task-form-row">
                                    <div class="create-task-form-group">
                                        <label class="create-task-form-label">Task Name *</label>
                                        <input type="text" id="edit-task_name" class="create-task-form-input" placeholder="Enter task name" maxlength="50" required>
                                    </div>
                                    <div class="create-task-form-group">
                                        <label class="create-task-form-label">Description</label>
                                        <input type="text" id="edit-task_desc" class="create-task-form-input" placeholder="Enter task description">
                                    </div>
                                </div>

                                <!-- Schedule Section -->
                                <div class="schedule-section">
                                    <h4>📅 Schedule Configuration</h4>
                                    <div class="create-task-form-group">
                                        <label class="create-task-form-label">How often do you want the Task Manager to execute this task?</label>
                                        <select id="edit-schedule_type" class="create-task-form-select" onchange="handleScheduleTypeChange('edit')">
                                            <option value="" disabled>Choose...</option>
                                            <option value="once">Only Once</option>
                                            <option value="daily">Daily</option>
                                            <option value="weekly">Weekly</option>
                                            <option value="monthly">Monthly</option>
                                        </select>
                                    </div>
                                    
                                    <!-- Daily Options -->
                                    <div id="edit-daily_options" class="hidden">
                                        <div class="create-task-form-group">
                                            <label class="create-task-form-label">Every</label>
                                            <div class="create-task-form-grid-2">
                                                <input type="number" id="edit-every_n_days" class="create-task-form-input" value="1" min="1" max="7">
                                                <span style="align-self: center;">day(s)</span>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Weekly Options -->
                                    <div id="edit-weekly_options" class="hidden">
                                        <div class="create-task-form-group">
                                            <label class="create-task-form-label">Every</label>
                                            <div class="create-task-form-grid-2">
                                                <input type="number" id="edit-every_n_weeks" class="create-task-form-input" value="1" min="1" max="5">
                                                <span style="align-self: center;">week(s)</span>
                                            </div>
                                        </div>
                                        <div class="create-task-form-group">
                                            <label class="create-task-form-label">Days of the week:</label>
                                            <div class="create-task-week-row">
                                                <label class="edit-task-day-checkbox"><input type="checkbox" value="2"> Monday</label>
                                                <label class="edit-task-day-checkbox"><input type="checkbox" value="3"> Tuesday</label>
                                                <label class="edit-task-day-checkbox"><input type="checkbox" value="4"> Wednesday</label>
                                                <label class="edit-task-day-checkbox"><input type="checkbox" value="5"> Thursday</label>
                                                <label class="edit-task-day-checkbox"><input type="checkbox" value="6"> Friday</label>
                                                <label class="edit-task-day-checkbox"><input type="checkbox" value="7"> Saturday</label>
                                                <label class="edit-task-day-checkbox"><input type="checkbox" value="1"> Sunday</label>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Monthly Options -->
                                    <div id="edit-monthly_options" class="hidden">
                                        <div class="create-task-form-group">
                                            <label class="create-task-form-label">Every</label>
                                            <div class="create-task-form-grid-2">
                                                <input type="number" id="edit-every_n_months" class="create-task-form-input" value="1" min="1" max="12">
                                                <span style="align-self: center;">month(s)</span>
                                            </div>
                                        </div>
                                        <div class="create-task-form-group">
                                            <label for="day_of_month" class="create-task-form-label">On day of month:</label>
                                            <input type="number" id="edit-day_of_month" class="create-task-form-input" value="1" min="1" max="31">
                                        </div>
                                    </div>
                                </div>

                                <!-- Date Range -->
                                <div class="create-task-form-row">
                                    <div class="create-task-form-group">
                                        <label class="create-task-form-label">Start Date</label>
                                        <input type="date" id="edit-start_date" class="create-task-form-input">
                                    </div>
                                    <div class="create-task-form-group">
                                        <label class="create-task-form-label">End Date (optional)</label>
                                        <input type="date" id="edit-end_date" class="create-task-form-input">
                                        <small style="color: #666; font-size: 12px;">Leave empty for tasks that never expire</small>
                                    </div>
                                </div>

                                <!-- Frequency -->
                                <div class="create-task-form-row">
                                    <div class="create-task-form-group">
                                        <label class="create-task-form-label">Execution frequency:</label>
                                        <select id="edit-frequency_type" class="create-task-form-select" onchange="handleFrequencyTypeChange()">
                                            <option value="once">Run once at this time</option>
                                        </select>
                                    </div>
                                    <div id="single_run_options">
                                        <div class="create-task-form-group">
                                            <label class="create-task-form-label">Run time:</label>
                                            <input type="time" id="edit-run_once_time" class="create-task-form-input" value="01:00">
                                            <small style="color: #666; font-size: 12px;">Empty, if the next schedule is not set.</small>
                                        </div>
                                    </div>
                                    <div class="create-task-form-group">
                                        <label class="create-task-form-label">Priority</label>
                                        <select id="edit-priority_type" class="create-task-form-select">
                                            <option value="1">Low</option>
                                            <option value="0">Normal</option>
                                            <option value="2">High</option>
                                        </select>
                                    </div>
                                </div>

                                <!-- Task Control Section -->
                                <div class="task-control-section" style="background: #fff7ed; padding: 12px; border-radius: 6px; margin: 16px 0; border-left: 4px solid #f59e0b;">
                                    <h4>🎛️ Task Control</h4>
                                    <div class="create-task-form-row">
                                        <div class="create-task-form-group">
                                            <label class="create-task-form-label">Task Status</label>
                                            <select id="edit-task_suspended" class="create-task-form-select">
                                                <option value="0">Active</option>
                                                <option value="1">Suspended</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>

                                <!-- Email Notifications Section -->
                                <div class="create-task-email-section">
                                    <h4>📧 Email Notifications (Available Soon...)</h4>
                                    <div class="create-task-form-group">
                                        <label class="create-task-form-label">Completion Notifications:</label>
                                        <div class="create-task-email-input-group">
                                            <input type="email" id="edit-completion_email_input" class="create-task-form-input" placeholder="Enter email address" disabled>
                                            <button type="button" class="btn btn-secondary" onclick="addEmail('completion')">Add</button>
                                        </div>
                                        <div id="completion_email_list" class="create-task-email-list"></div>
                                    </div>
                                </div>

                                <!-- Buttons -->
                                <div style="text-align: right; padding-top: 16px; border-top: 1px solid #e2e8f0; margin-top: 16px; display: flex; justify-content: space-between; align-items: center;">
                                    <button type="button" class="btn btn-warning" onclick="restoreOriginalData()" style="background: #f59e0b; color: white;">🔄 Restore Original</button>
                                    <div>
                                        <button type="button" class="btn btn-secondary" onclick="closeEditTaskModal()" style="margin-right: 8px;">Cancel</button>
                                        <button type="button" class="btn btn-primary" onclick="submitEditTask()">Update Task</button>
                                    </div>
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

ClassMethod renderAddProjectModal() As %Status
{
    Set sc = $$$OK
    &html<<script language='javascript'>
        function renderAddProjectModal() {
            return `
            <!-- Modal -->
            <div id="taskFileSelectorModal" class="task-file-selector-modal">
                <div class="task-file-selector-modal-content">
                    <div class="task-file-selector-modal-header">
                        <div>
                            <h2 class="task-file-selector-modal-title">Manage Project Files</h2>
                            <div class="task-file-selector-task-name"><strong id="taskFileSelectorTaskName">Export projects utility task</strong></div>
                        </div>
                        <button class="task-file-selector-close" onclick="taskFileSelectorCloseModal()">&times;</button>
                    </div>

                    <div class="task-file-selector-modal-body">
                        <!-- Associated Files Panel -->
                        <div class="task-file-selector-panel task-file-selector-associated-panel">
                            <div class="task-file-selector-panel-header">
                                <div class="task-file-selector-panel-title">
                                    <span class="task-file-selector-panel-icon">📁</span>
                                    Associated Projects
                                    <span class="task-file-selector-counter" id="taskFileSelectorAssociatedCounter">0</span>
                                </div>
                                <div class="task-file-selector-panel-subtitle">Projects currently linked to this task</div>
                            </div>
                            <div class="task-file-selector-panel-body">
                                <div class="task-file-selector-search-box">
                                    <input type="text" class="task-file-selector-search-input" placeholder="Search associated projects..."
                                        oninput="taskFileSelectorFilterFiles('associated', this.value)">
                                </div>
                                <div class="task-file-selector-file-list" id="taskFileSelectorAssociatedFiles">
                                    <!-- Associated files will be populated here -->
                                </div>
                            </div>
                        </div>

                        <!-- Available Files Panel -->
                        <div class="task-file-selector-panel task-file-selector-available-panel">
                            <div class="task-file-selector-panel-header">
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
                                    <div>
                                        <div class="task-file-selector-panel-title">
                                            <span class="task-file-selector-panel-icon">🗂️</span>
                                            Available Projects
                                            <span class="task-file-selector-counter" id="taskFileSelectorAvailableCounter">0</span>
                                        </div>
                                        <div class="task-file-selector-panel-subtitle">All projects in the filesystem</div>
                                    </div>
                                    <button class="btn" onclick="taskFileSelectorLoadAllProjects()"
                                        style="background: #22c55e; color: white; font-size: 0.875rem; padding: 8px 16px; border-radius: 6px; font-weight: 500; transition: all 0.2s ease;"
                                        id="taskFileSelectorLoadProjectsBtn"
                                        onmouseover="this.style.background='#16a34a'"
                                        onmouseout="this.style.background='#22c55e'">
                                        🔄 Refresh Projects
                                    </button>
                                </div>
                            </div>
                            <div class="task-file-selector-panel-body">
                                <div class="task-file-selector-search-box">
                                    <input type="text" class="task-file-selector-search-input" placeholder="Search available projects..."
                                        oninput="taskFileSelectorFilterFiles('available', this.value)">
                                </div>
                                <div class="task-file-selector-file-list" id="taskFileSelectorAvailableFiles">
                                    <!-- Available files will be populated here -->
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="task-file-selector-modal-footer">
                        <div>
                        </div>
                        <div style="display: flex; gap: 12px;">
                            <button class="btn-secondary" onclick="taskFileSelectorRestoreChanges()" style="background: #f59e0b; color: white;">🔄 Restore Original</button>
                            <button class="btn-secondary" onclick="taskFileSelectorCloseModal()">Cancel</button>
                            <button class="btn-primary" onclick="taskFileSelectorSaveChanges()">Save Changes</button>
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
