Class PackageManager.UI.Screens.ExportTaskSection.CSS Extends PackageManager.UI.Screens.Abstract
{

/*
    CSS STYLES
*/
ClassMethod RenderStyles() As %Status
{
    Set sc = $$$OK
    Do ..TaskFileSelectorModalStyles()
    Do ..CreateTaskModalStyles()

    &html<<style>
        .header {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            padding: 24px;
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header h1 {
            font-size: 28px;
            font-weight: 700;
            color: #1e293b;
        }

        .header p {
            color: #64748b;
            margin-top: 4px;
        }

        .table-container {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            overflow: auto;
            max-height: 600px;
        }

        .table-header {
            padding: 20px 24px;
            border-bottom: 1px solid #e2e8f0;
        }

        .table-header h2 {
            font-size: 20px;
            font-weight: 600;
            color: #1e293b;
        }

        .styled-table {
            width: 100%;
            min-width: 1000px;
            border-collapse: collapse;
        }

        .styled-table th,
        .styled-table td {
            padding: 12px 24px;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
            white-space: nowrap;
        }

        .styled-table tr:hover {
            background: #f8fafc;
        }

        .status-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
        }

        .status-active {
            background: #dcfce7;
            color: #166534;
        }

        .status-suspended {
            background: #fffcbaff;
            color: #736e09ff;
        }

        .status-running {
            background: #a7b1f2ff;
            color: rgba(7, 54, 148, 1);
        }

        .status-error {
            background: #fecaca;
            color: #991b1b;
        }

        .priority-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
        }

        .priority-high { background: #fee2e2; color: #991b1b; }
        .priority-normal { background: #dbeafe; color: #1e40af; }
        .priority-low { background: #f1f5f9; color: #475569; }

        .task-info-panel {
            position: fixed;
            top: 0;
            right: -400px;
            width: 400px;
            height: 100vh;
            background: white;
            box-shadow: -2px 0 10px rgba(0,0,0,0.1);
            transition: right 0.3s ease;
            z-index: 1002;
            overflow-y: auto;
        }

        .task-info-panel.open {
            right: 0;
        }

        .info-panel-header {
            padding: 20px;
            border-bottom: 1px solid #e2e8f0;
            background: #f8fafc;
            position: sticky;
            top: 0;
            z-index: 1;
        }

        .info-panel-content {
            padding: 20px;
        }

        .info-section {
            margin-bottom: 24px;
        }

        .info-section h4 {
            font-size: 14px;
            font-weight: 600;
            color: #374151;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 8px;
        }

        .info-item {
            margin-bottom: 12px;
        }

        .info-label {
            font-size: 12px;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .info-value {
            font-size: 14px;
            color: #1f2937;
            font-weight: 500;
            margin-top: 2px;
        }

        .error-details {
            background: #fef2f2;
            border: 1px solid #fecaca;
            border-radius: 6px;
            padding: 12px;
            font-family: monospace;
            font-size: 12px;
            color: #991b1b;
            white-space: pre-wrap;
        }

        .project-item-with-action {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .add-project-item {
            border: 2px dashed #d1d5db;
            background: transparent;
            color: #6b7280;
            cursor: pointer;
            transition: all 0.2s;
        }

        .add-project-item:hover {
            border-color: #3b82f6;
            color: #3b82f6;
            background: #f0f9ff;
        }

        .project-list {
            list-style: none;
            padding: 0;
        }

        .project-item {
            padding: 8px 12px;
            background: #f8fafc;
            border-radius: 6px;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
    </style>>
    Return sc
}

/*
    Modals CSS STYLES
*/
/// Styles for the task create modal which let the create a new export task
ClassMethod CreateTaskModalStyles() As %Status
{
    &html<<style>
        .create-task-modal-overlay {
            display: none;
            position: fixed;
            z-index: 1000;
            top: 0; 
            left: 0; 
            right: 0; 
            bottom: 0;
            background-color: rgba(0, 0, 0, 0.5);
            justify-content: center;
            align-items: center;
        }

        @keyframes CreateTaskFadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes CreateTaskSlideIn {
            from { transform: translateY(-50px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        .create-task-modal-container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            width: 90%;
            max-width: 700px;
            max-height: 90vh;
            overflow-y: auto;
            animation: CreateTaskFadeIn 0.3s ease, CreateTaskSlideIn 0.3s ease;
            /* Remove any positioning that might interfere */
            position: relative;
        }
        
        .create-task-modal-header {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .create-task-modal-header h3 {
            margin: 0;
            font-size: 18px;
            font-weight: 600;
        }

        .create-task-close {
            background: none;
            border: none;
            color: white;
            font-size: 24px;
            cursor: pointer;
            padding: 0;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.2s ease;
        }

        .create-task-close:hover {
            background: rgba(255, 255, 255, 0.2);
        }

        .create-task-modal-content {
            padding: 30px;
        }

        .create-task-form-row {
            display: flex;
            gap: 20px;
            align-items: flex-start;
            flex-wrap: wrap;
        }

        .create-task-form-group {
            margin-bottom: 20px;
            flex: 1;
            min-width: 200px;
        }

        .create-task-form-label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
            color: #333;
        }

        .create-task-form-input,
        .create-task-form-select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            transition: border-color 0.2s ease;
            box-sizing: border-box;
        }

        .create-task-form-input:focus,
        .create-task-form-select:focus {
            outline: none;
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
        }

        .create-task-form-grid-2 {
            display: grid;
            gap: 12px;
        }

        .create-task-week-row {
            display: flex;
            gap: 10px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .create-task-day-checkbox, .edit-task-day-checkbox{
            display: inline-flex; 
            align-items: center;
            margin: 4px 8px 4px 0;
            padding: 6px 10px;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            background-color: #f9fafb;
            font-size: 14px;
            cursor: pointer;
            user-select: none;
            transition: background-color 0.2s, border-color 0.2s;
        }

        .create-task-day-checkbox:hover,
        .edit-task-day-checkbox:hover {
            background-color: #f3f4f6;
            border-color: #9ca3af;
        }

        .create-task-day-checkbox input[type="checkbox"],
        .edit-task-day-checkbox input[type="checkbox"] {
            margin-right: 6px;
            cursor: pointer;
        }

        .create-task-email-section h4 {
            font-size: 14px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 12px;
        }

        .create-task-email-input-group {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .create-task-email-list {
            margin-top: 8px;
        }

        .create-task-modal-actions {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }

        /* Purge Section Styles */
        .purge-section {
            margin-bottom: 30px;
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 8px;
            border: 1px solid #e9ecef;
        }

        .purge-section h4 {
            font-size: 16px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .create-task-purge-checkbox {
            display: flex;
            align-items: center;
            font-weight: 600;
            color: #333;
            cursor: pointer;
            user-select: none;
            margin-bottom: 8px;
        }

        .create-task-purge-checkbox input[type="checkbox"] {
            margin-right: 8px;
            cursor: pointer;
            width: 16px;
            height: 16px;
        }

        .create-task-purge-warning {
            display: flex;
            align-items: flex-start;
            gap: 8px;
            padding: 12px;
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 6px;
            margin-top: 16px;
        }
        
        .warning-icon {
            flex-shrink: 0;
            font-size: 16px;
        }

        .warning-text {
            font-size: 13px;
            color: #856404;
            line-height: 1.4;
        }

        /* Schedule Section Styles */
        .schedule-section {
            margin-bottom: 30px;
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 8px;
            border: 1px solid #e9ecef;
        }

        .schedule-section h4 {
            font-size: 16px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        @keyframes CreateTask {
            from { transform: translateY(-50px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        @media (max-width: 768px) {
            .create-task-form-row {
                flex-direction: column;
            }

            .create-task-modal-container {
                width: 95%;
                margin: 10px;
            }

            .create-task-modal-content {
                padding: 20px;
            }

            .purge-section {
                padding: 16px;
            }
            
            .create-task-purge-warning {
                padding: 10px;
            }
            
            .warning-text {
                font-size: 12px;
            }
        }
    </style>>
    Quit $$$OK
}

/// Styles for the task file/project selector modal which let the user associate the projects with an export task
ClassMethod TaskFileSelectorModalStyles() As %Status
{
    Set sc = $$$OK
    &html<<style>
            .task-file-selector-modal {
                display: none;
                position: fixed;
                z-index: 1000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0, 0, 0, 0.5);
                animation: taskFileSelectorFadeIn 0.3s ease;
            }

            .task-file-selector-modal.show {
                display: flex;
                justify-content: center;
                align-items: center;
            }

            @keyframes taskFileSelectorFadeIn {
                from { opacity: 0; }
                to { opacity: 1; }
            }

            .task-file-selector-modal-content {
                background-color: #ffffff;
                margin: 2% auto;
                border-radius: 12px;
                width: 90%;
                max-width: 1200px;
                max-height: 90vh;
                box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
                display: flex;
                flex-direction: column;
                overflow-y: auto;
            }

            .task-file-selector-modal-header {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 24px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .task-file-selector-modal-title {
                font-size: 1.5rem;
                font-weight: 600;
                margin: 0;
            }

            .task-file-selector-task-name {
                font-size: 0.9rem;
                opacity: 0.9;
                margin-top: 4px;
            }

            .task-file-selector-close {
                font-size: 28px;
                font-weight: bold;
                cursor: pointer;
                background: none;
                border: none;
                color: white;
                opacity: 0.8;
                transition: opacity 0.2s;
                padding: 0;
                width: 32px;
                height: 32px;
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 6px;
            }

            .task-file-selector-close:hover {
                opacity: 1;
                background-color: rgba(255, 255, 255, 0.1);
            }

            .task-file-selector-modal-body {
                flex: 1;
                display: flex;
                gap: 2px;
                background-color: #f8fafc;
                min-height: 0;
            }

            .task-file-selector-panel {
                flex: 1;
                background: white;
                display: flex;
                flex-direction: column;
                position: relative;
            }

            .task-file-selector-panel-header {
                padding: 20px;
                border-bottom: 2px solid #e2e8f0;
                background: white;
            }

            .task-file-selector-panel-title {
                font-size: 1.1rem;
                font-weight: 600;
                color: #1a202c;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .task-file-selector-panel-subtitle {
                font-size: 0.875rem;
                color: #64748b;
                margin-top: 4px;
            }

            .task-file-selector-panel-icon {
                font-size: 1.2rem;
            }

            .task-file-selector-associated-panel .task-file-selector-panel-header {
                background: linear-gradient(135deg, #e0f2fe 0%, #f0f9ff 100%);
                border-bottom-color: #0ea5e9;
            }

            .task-file-selector-associated-panel .task-file-selector-panel-title {
                color: #0c4a6e;
            }

            .task-file-selector-available-panel .task-file-selector-panel-header {
                background: linear-gradient(135deg, #f0fdf4 0%, #f7fee7 100%);
                border-bottom-color: #22c55e;
            }

            .task-file-selector-available-panel .task-file-selector-panel-title {
                color: #15803d;
            }

            .task-file-selector-panel-body {
                flex: 1;
                overflow-y: auto;
                padding: 16px;
            }

            .task-file-selector-file-list {
                display: flex;
                flex-direction: column;
                gap: 8px;
            }

            .task-file-selector-file-item {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 12px 16px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                background: white;
                transition: all 0.2s ease;
                cursor: pointer;
                position: relative;
            }

            .task-file-selector-file-item:hover {
                border-color: #cbd5e1;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
                transform: translateY(-1px);
            }

            .task-file-selector-file-item.selected {
                background: linear-gradient(135deg, #dbeafe 0%, #eff6ff 100%);
                border-color: #3b82f6;
                box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1);
            }

            .task-file-selector-file-info {
                flex: 1;
                display: flex;
                flex-direction: column;
            }

            .task-file-selector-file-name {
                font-weight: 600;
                color: #1a202c;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .task-file-selector-file-description {
                font-size: 0.875rem;
                color: #64748b;
                margin-top: 2px;
            }

            .task-file-selector-file-meta {
                font-size: 0.8rem;
                color: #94a3b8;
                margin-top: 4px;
            }

            .task-file-selector-file-actions {
                display: flex;
                gap: 8px;
                align-items: center;
            }

            .task-file-selector-btn {
                padding: 6px 12px;
                border: none;
                border-radius: 6px;
                font-size: 0.875rem;
                font-weight: 500;
                cursor: pointer;
                transition: all 0.2s ease;
                display: flex;
                align-items: center;
                gap: 4px;
            }

            .task-file-selector-btn-remove {
                background-color: #fee2e2;
                color: #dc2626;
                border: 1px solid #fecaca;
            }

            .task-file-selector-btn-remove:hover {
                background-color: #fecaca;
                border-color: #f87171;
            }

            .task-file-selector-btn-add {
                background-color: #dcfce7;
                color: #16a34a;
                border: 1px solid #bbf7d0;
            }

            .task-file-selector-btn-add:hover {
                background-color: #bbf7d0;
                border-color: #86efac;
            }

            .task-file-selector-empty-state {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                height: 200px;
                color: #64748b;
                text-align: center;
                padding: 40px;
            }

            .task-file-selector-empty-icon {
                font-size: 3rem;
                margin-bottom: 16px;
                opacity: 0.5;
            }

            .task-file-selector-search-box {
                margin-bottom: 16px;
            }

            .task-file-selector-search-input {
                width: 100%;
                padding: 10px 16px;
                border: 1px solid #d1d5db;
                border-radius: 8px;
                font-size: 0.9rem;
                transition: border-color 0.2s;
            }

            .task-file-selector-search-input:focus {
                outline: none;
                border-color: #3b82f6;
                box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
            }

            .task-file-selector-counter {
                background: #f1f5f9;
                color: #475569;
                padding: 2px 8px;
                border-radius: 12px;
                font-size: 0.8rem;
                font-weight: 500;
            }

            .task-file-selector-status-badge {
                padding: 2px 8px;
                border-radius: 12px;
                font-size: 0.75rem;
                font-weight: 500;
            }

            .task-file-selector-status-associated {
                background: #dbeafe;
                color: #1d4ed8;
            }

            .task-file-selector-modal-footer {
                padding: 20px 24px;
                border-top: 1px solid #e2e8f0;
                background: white;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .task-file-selector-btn-primary {
                background: #3b82f6;
                color: white;
                padding: 10px 24px;
                border: none;
                border-radius: 8px;
                font-weight: 500;
                cursor: pointer;
                transition: background-color 0.2s;
            }

            .task-file-selector-btn-primary:hover {
                background: #2563eb;
            }

            .task-file-selector-btn-secondary {
                background: #f8fafc;
                color: #64748b;
                padding: 10px 24px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                font-weight: 500;
                cursor: pointer;
                transition: all 0.2s;
            }

            .task-file-selector-btn-secondary:hover {
                background: #f1f5f9;
                border-color: #cbd5e1;
            }

            @media (max-width: 768px) {
                .task-file-selector-modal-content {
                    width: 95%;
                    height: 90vh;
                    margin: 5% auto;
                }

                .task-file-selector-modal-body {
                    flex-direction: column;
                }

                .task-file-selector-associated-panel {
                    order: 0;
                }

                .task-file-selector-available-panel {
                    order: 2;
                }
            }
        </style>>
    Return sc
}

}
