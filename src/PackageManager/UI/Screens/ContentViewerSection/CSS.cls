Class PackageManager.UI.Screens.ContentViewerSection.CSS Extends PackageManager.UI.Screens.Abstract
{

/*
    CSS STYLES
*/
/// Wrapper for content viewer section css styles
ClassMethod RenderStyles() As %Status
{
    Set sc = $$$OK
    Do ..CreateProject()
    Do ..ProjectTable()
    Do ..NewProjectModal()
    Do ..Msg()
    Do ..ContentTreeViewer()
    Do ..AddClassesModal()
    Return sc
}

/*
    SCREENS AND MODALS CSS
*/
ClassMethod CreateProject() As %Status
{
    Set sc = $$$OK
    &html<<style>
        .create-project-controls {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .create-project-controls button {
            padding: 10px 18px;
            font-weight: 600;
            border: 1px solid #e0e4e8;
            border-radius: 15px;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.03em;
            min-width: 150px;
            margin-right: 10px;
            background-color: #fefefe;
            transition: background-color 0.25s ease, box-shadow 0.25s ease;
        }

        .create-project-controls button:hover {
            background-color: #3498db;
            box-shadow: 0 2px 5px #3498db;
            color: white;
        }
    </style>>

    Return sc
}

ClassMethod ProjectTable() As %Status
{
    Set sc = $$$OK
    &html<<style>
        .project-table-controls {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #e0e4e8;
        }

        .project-table-controls button {
            padding: 10px 18px;
            font-weight: 600;
            border: 1px solid #e0e4e8;
            border-radius: 15px;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.03em;
            min-width: 150px;
            margin-right: 10px;
            background-color: #fefefe;
            transition: background-color 0.25s ease, box-shadow 0.25s ease;
            cursor: pointer;
        }

        .project-table-controls button:hover {
            transform: translateY(-1px);
            background-color: #3498db;
            box-shadow: 0 2px 5px #3498db;
            color: white;
        }

        /* container styles */
        .project-container {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            overflow: hidden;
            margin-bottom: 20px;
            margin-top: 10px;
        }

        .project-header {
            background: linear-gradient(135deg, #3c97ffff, #0d6bd7ff);
            color: white;
            padding: 16px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .project-title {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 16px;
            font-weight: 600;
        }

        .project-title .icon {
            font-size: 18px;
        }

        .header-controls {
            display: flex;
            gap: 8px;
        }

        .header-controls button {
            padding: 8px 16px;
            background-color: #fefefe;
            color: #2c3e50;
            border: 1px solid #e0e4e8;
            border-radius: 15px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.03em;
            transition: all 0.25s ease;
            white-space: nowrap;
        }
        
        .header-controls button:hover {
            transform: translateY(-1px);
            background: linear-gradient(135deg, #3e5f81ff 0%, #34495e 100%);
            color: white;
            border-color: #2c3e50;
            box-shadow: 0 2px 5px rgba(44, 62, 80, 0.3);
        }

        .header-controls button:active {
            transform: translateY(-1px) scale(1.01);
            box-shadow: 0 4px 15px rgba(44, 62, 80, 0.2);
        }

        .header-controls button:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(44, 62, 80, 0.1),
                        0 4px 15px rgba(44, 62, 80, 0.2);
        }

        .header-controls input {
            width: 100%;
            padding: 8px 10px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            background-color: #fefefe;
            box-sizing: border-box;
        }

        .header-controls input:focus {
            outline: none;
            border-color: #4a90e2;
            box-shadow: 0 0 0 3px rgba(74, 144, 226, 0.1);
        }

        .project-content {
            padding: 20px;
        }

        .project-table-wrapper {
            overflow-x: auto;
            border: 1px solid #e0e4e8;
            border-radius: 6px;
            margin-bottom: 20px;
        }

        .project-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
        }

        .project-table th {
            background: #f8f9fa;
            padding: 12px 16px;
            text-align: left;
            font-weight: 600;
            color: #333;
            border-bottom: 1px solid #e0e4e8;
        }

        .project-table td {
            padding: 12px 16px;
            border-bottom: 1px solid #e0e4e8;
        }

        .project-table tr:last-child td {
            border-bottom: none;
        }

        .project-table tr:hover {
            background-color: #f8f9fa;
        }

        .message {
            padding: 12px;
            border-radius: 6px;
            display: none;
        }

        .message.success {
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
        }

        .message.error {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
        }

        .message.info {
            background-color: #cce7ff;
            border: 1px solid #99d3ff;
            color: #004085;
        }
    </style>>

    Return sc
}

ClassMethod NewProjectModal() As %Status
{
    Set sc = $$$OK
    &html<<style>
        /* Special styling for New Project button */
        .new-project-btn {
            background: #81f99dff !important;
            border-color: #81f99dff !important;
            font-weight: 600 !important;
        }

        .new-project-btn:hover {
            background: #58df76ff !important;
            border-color: #58df76ff !important;
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(40, 167, 69, 0.3);
        }

        .plus-icon {
            font-size: 16px;
            font-weight: bold;
            margin-right: 4px;
        }

        /* Modal Styles */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            animation: fadeIn 0.3s ease;
        }

        .modal-overlay.show {
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .modal-container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            width: 90%;
            max-width: 500px;
            max-height: 90vh;
            overflow-y: auto;
            animation: slideIn 0.3s ease;
        }

        .modal-header {
            background: linear-gradient(135deg, #28a745, #20c997);
            color: white;
            padding: 20px;
            border-radius: 12px 12px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-header h3 {
            margin: 0;
            font-size: 18px;
            font-weight: 600;
        }

        .modal-close {
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

        .modal-close:hover {
            background: rgba(255, 255, 255, 0.2);
        }

        .modal-content {
            padding: 30px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
            color: #333;
        }

        .form-group input,
        .form-group textarea,
        .form-group select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            transition: border-color 0.2s ease;
            box-sizing: border-box;
        }

        .form-group input:focus,
        .form-group textarea:focus,
        .form-group select:focus {
            outline: none;
            border-color: #28a745;
            box-shadow: 0 0 0 3px rgba(40, 167, 69, 0.1);
        }

        .form-help {
            display: block;
            margin-top: 4px;
            font-size: 12px;
            color: #666;
        }

        .modal-actions {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }

        .btn-primary,
        .btn-secondary {
            padding: 12px 24px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            border: none;
        }

        .btn-primary {
            background: #31b14cff;
            color: white;
        }

        .btn-primary:hover {
            background: #218838;
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(40, 167, 69, 0.3);
        }

        .btn-secondary {
            background: #6c757d;
            color: white;
        }

        .btn-secondary:hover {
            background: #5a6268;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideIn {
            from { transform: translateY(-50px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .header-controls {
                flex-direction: column;
                gap: 8px;
                align-items: stretch;
            }
            
            .header-controls input,
            .header-controls button {
                width: 100%;
            }
            
            .modal-container {
                width: 95%;
                margin: 10px;
            }
            
            .modal-content {
                padding: 20px;
            }
        }
    </style>>

    Return sc
}

ClassMethod Msg() As %Status
{
    Set sc = $$$OK
    &html<<style>
            #msg {
            margin-top: 10px;
            font-weight: bold;
            max-width: 600px;
            word-wrap: break-word;
            padding: 10px 12px;
            border-radius: 5px;
            background-color: #fefefe;
        }

        #msg .success {
            color: #2ecc71;
            background-color: #eafaf1;
            border: 1px solid #2ecc71;
        }

        #msg .error {
            color: #e74c3c;
            background-color: #fdecea;
            border: 1px solid #e74c3c;
        }
    </style>>

    Return sc
}

ClassMethod ContentTreeViewer() As %Status
{
    Set sc = $$$OK
    &html<<style>
        .container {
            width: 100%;
            max-width: none;
            margin: 0;
            background-color: #ffffff;
            border-radius: 6px;
            overflow: hidden;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            margin-top: 20px;
        }
        
        .selection-info {
            padding: 12px 15px;
            background-color: #e8f8fbff;
            border-bottom: 1px solid #e0e4e8;
            font-size: 14px;
            color: #2c3e50;
        }
        
        .selected-count {
            font-weight: bold;
            color: #3498db;
        }
        
        .tree-wrapper {
            background-color: #ffffff;
        }
        
        .tree-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 15px;
            border-bottom: 1px solid #e0e4e8;
            background: linear-gradient(135deg, #3c97ffff, #0d6bd7ff);
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .tree-header h3 {
            margin: 0;
            color: white;
            font-size: 16px;
            font-weight: 600;
            min-width: 0;
            flex-shrink: 1;
        }
        
        .tree-controls {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        
        .tree-controls button {
            padding: 8px 16px;
            background-color: #fefefe;
            color: #2c3e50;
            border: 1px solid #e0e4e8;
            border-radius: 15px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.03em;
            transition: all 0.25s ease;
            white-space: nowrap;
        }
        
        .tree-controls button:hover {
            transform: translateY(-1px);
            background: linear-gradient(135deg, #3e5f81ff 0%, #34495e 100%);
            color: white;
            border-color: #2c3e50;
            box-shadow: 0 2px 5px rgba(44, 62, 80, 0.3);
        }
        
        .tree-controls button:active {
            transform: translateY(-1px) scale(1.01);
            box-shadow: 0 4px 15px rgba(44, 62, 80, 0.2);
        }

        .tree-controls button:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(44, 62, 80, 0.1),
                        0 4px 15px rgba(44, 62, 80, 0.2);
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .tree-header {
                flex-direction: column;
                align-items: stretch;
                text-align: center;
            }
            
            .tree-controls {
                justify-content: center;
            }
            
            .tree-controls button {
                flex: 1;
                min-width: 120px;
            }
        }
        
        @media (max-width: 480px) {
            .container {
                margin-top: 15px;
                border-radius: 4px;
            }
            
            .selection-info {
                padding: 10px 12px;
                font-size: 13px;
            }
            
            .tree-header {
                padding: 10px 12px;
            }
            
            .tree-header h3 {
                font-size: 14px;
            }
            
            .tree-controls {
                flex-direction: column;
                gap: 6px;
            }
            
            .tree-controls button {
                width: 100%;
                margin: 0;
                padding: 10px 16px;
                font-size: 14px;
            }
        }
        
        .tree-container {
            max-height: 600px;
            overflow-y: auto;
            padding: 0;
            background-color: #ffffff;
        }
        
        .tree-list {
            list-style: none;
            margin: 0;
            padding: 0;
        }
        
        .tree-item {
            list-style: none;
            margin: 0;
            padding: 0;
        }
        
        .tree-item-content {
            display: flex;
            align-items: center;
            padding: 4px 8px;
            cursor: pointer;
            min-height: 22px;
            border-bottom: 1px solid #f0f5fa;
            transition: background-color 0.2s ease;
        }
        
        .tree-item-content:hover {
            background-color: #f0f5fa;
        }
        
        .tree-toggle {
            width: 16px;
            height: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 4px;
            font-size: 12px;
            transition: transform 0.15s ease;
            color: #2c3e50;
        }
        
        .tree-checkbox {
            margin-right: 6px;
            margin-left: 0px;
        }
        
        .tree-icon {
            margin-right: 6px;
            font-size: 16px;
            vertical-align: middle;
            /*font-family: 'Material Icons';  /* Optional, but clarifies intention */
        }
        
        .tree-label {
            flex: 1;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            font-size: 14px;
            color: #2c3e50;
        }
        
        .tree-type {
            font-size: 11px;
            color: #555;
            margin-left: 0px;
            background-color: #e0e4e8;
            padding: 2px 6px;
            border-radius: 3px;
            font-weight: 500;
        }
        
        .tree-children {
            margin-left: 20px;
            display: none;
            list-style: none;
            padding: 2px 0 0 0;
        }
        
        .tree-item.expanded .tree-children {
            display: block;
        }
        
        /* Ensure nested collapsed items stay hidden */
        .tree-item:not(.expanded) .tree-children {
            display: none !important;
        }
        
        .tree-item.expanded .tree-toggle {
            transform: rotate(90deg);
        }
        
        /* Reset rotation for nested non-expanded items */
        .tree-item:not(.expanded) .tree-toggle {
            transform: rotate(0deg);
        }
        
        .search-container {
            padding: 10px 15px;
            border-bottom: 1px solid #3c3c3c;
        }
        
        .search-input {
            width: 100%;
            padding: 8px 10px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            background-color: #fbfffeff;
            box-sizing: border-box;
        }

        .search-input:focus {
            outline: none;
            border-color: #0e639c;
        }

        .edit-input {
            width: auto; /* Let size attribute control width */
            min-width: 400px; /* Fallback minimum width */
            padding: 8px 10px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            background-color: #fbfffeff;
            box-sizing: border-box;
        }

        .edit-input:focus {
            outline: none;
            border-color: #0e639c;
        }    
    </style>>
    Return sc
}

/// CSS for Add Classes Modal 
ClassMethod AddClassesModal() As %Status
{
    Set sc = $$$OK
    &html<<style>
        /* Add Classes Modal Overlay Styles */
        .add-classes-modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.7);
            z-index: 1000;
            display: none;
            backdrop-filter: blur(4px);
            animation: fadeIn 0.3s ease;
        }

        .add-classes-modal-container {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 90%;
            max-width: 1200px;
            height: 85%;
            max-height: 800px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        /* Add Classes Modal Header Styles */
        .add-classes-modal-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 10px;
            border-radius: 12px 12px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .add-classes-modal-title {
            font-size: 24px;
            font-weight: 600;
            margin: 0;
            color: #ffffffff
        }

        .add-classes-project-name {
            font-size: 18px;
            opacity: 0.9;
            margin-top: 5px;
        }

        .add-classes-close-btn {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            font-size: 24px;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.3s ease;
        }

        .add-classes-close-btn:hover {
            background: rgba(255, 255, 255, 0.3);
        }

        /* Add Classes Control Panel Styles */
        .add-classes-control-panel {
            background: #f8fafc;
            padding: 20px;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: nowrap;
            overflow-x: auto; /* Add horizontal scroll if needed */
        }

        .add-classes-control-group {
            display: flex;
            align-items: center;
            gap: 8px;
            white-space: nowrap; /* Prevent text wrapping */
            flex-shrink: 0; /* Prevent shrinking */
        }

        .add-classes-control-group label {
            font-weight: 500;
            color: #374151;
            font-size: 14px;
        }

        .add-classes-type-selector {
            padding: 6px 10px;
            border: 2px solid #d1d5db;
            border-radius: 8px;
            background: white;
            font-size: 13px;
            transition: border-color 0.3s ease;
            min-width: 120px; 
        }

        .add-classes-type-selector:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .add-classes-search-input {
            padding: 6px 10px;
            border: 2px solid #d1d5db;
            border-radius: 8px;
            background: white;
            font-size: 13px;
            min-width: 150px;
            transition: border-color 0.3s ease;
        }

        .add-classes-search-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .add-classes-btn {
            padding: 6px 12px;
            border: none;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 4px;
            white-space: nowrap;
        }

        .add-classes-btn-primary {
            background: #667eea;
            color: white;
        }

        .add-classes-btn-primary:hover {
            transform: translateY(-1px);
            background: #5a6fd8;
        }

        .add-classes-btn-secondary {
            background: #e5e7eb;
            color: #374151;
        }

        .add-classes-btn-secondary:hover {
            background: #d1d5db;
        }

        .add-classes-btn-success {
            background: #10b981;
            color: white;
        }

        .add-classes-btn-success:hover {
            background: #059669;
            transform: translateY(-1px);
        }

        /* Add Classes Tree Content Styles */
        .add-classes-tree-content {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            background: white;
        }

        .add-classes-loading-message {
            text-align: center;
            color: #6b7280;
            font-style: italic;
            padding: 40px;
        }

        .add-classes-error-message {
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #dc2626;
            padding: 15px;
            border-radius: 8px;
            margin: 20px;
        }

        /* Add Classes Tree Styles */
        .add-classes-tree-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .add-classes-tree-item {
            margin: 0;
            padding: 0;
        }

        .add-classes-tree-item-content {
            display: flex;
            align-items: center;
            padding: 6px 8px;
            margin: 2px 0;
            border-radius: 6px;
            cursor: pointer;
            transition: background-color 0.2s ease;
        }

        .add-classes-tree-item-content:hover {
            background-color: #f3f4f6;
        }

        .add-classes-tree-toggle {
            width: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            color: #6b7280;
            cursor: pointer;
            transition: transform 0.15s ease;
        }

        .add-classes-tree-item.expanded .add-classes-tree-toggle {
            transform: rotate(90deg);
        }

        .add-classes-tree-checkbox {
            margin: 0 8px;
        }

        .add-classes-tree-icon {
            margin-right: 8px;
            font-size: 16px;
        }

        .add-classes-tree-label {
            flex: 1;
            font-weight: 500;
            font-size: 14px;
            color: #374151;
        }

        .add-classes-tree-type {
            background: #e5e7eb;
            color: #6b7280;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
            text-transform: uppercase;
        }

        .add-classes-tree-children {
            list-style: none;
            padding-left: 20px;
            margin: 0;
            display: none;
        }

        .add-classes-tree-item.expanded .add-classes-tree-children {
            display: block;
        }

        .add-classes-tree-item.file .add-classes-tree-toggle {
            visibility: hidden;
        }

        /* Reset rotation for nested non-expanded items */
        .add-classes-tree-item:not(.expanded) .add-classes-tree-toggle {
            transform: rotate(0deg);
        }

        /* Add Classes Modal Footer Styles */
        .add-classes-modal-footer {
            background: #f8fafc;
            padding: 20px;
            border-top: 1px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .add-classes-selection-info {
            color: #6b7280;
            font-weight: 500;
        }

        .add-classes-footer-actions {
            display: flex;
            gap: 12px;
        }

        @media (max-width: 1200px) {
            .add-classes-control-panel {
                flex-wrap: wrap;
            }
        }

        /* Add Classes Modal Responsive Design */
        @media (max-width: 768px) {
            .add-classes-modal-container {
                width: 95%;
                height: 90%;
            }

            .add-classes-control-panel {
                flex-direction: column;
                align-items: stretch;
                gap: 15px;
            }

            .add-classes-control-group {
                justify-content: space-between;
                flex-wrap: wrap;
            }

            .add-classes-search-input {
                min-width: auto;
                flex: 1;
            }
        }

        /* ADDITION: Fix toggle arrow rotation for expanded items */
        .add-classes-tree-item.expanded .add-classes-tree-toggle {
            transform: rotate(90deg);
        }

        /* ADDITION: Ensure nested collapsed items stay hidden */
        .add-classes-tree-item:not(.expanded) .add-classes-tree-children {
            display: none !important;
        }

        /* ADDITION: Reset rotation for nested non-expanded items */
        .add-classes-tree-item:not(.expanded) .add-classes-tree-toggle {
            transform: rotate(0deg);
        }
    </style>>
    Return sc
}

}
