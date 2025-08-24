/// This class provides the main and generic CSS classes for the Package Manager UI. 
Class PackageManager.UI.CSS Extends PackageManager.UI.Screens.Abstract
{

/// Overall generic styles for the package manager projecty 
ClassMethod Styles() As %Status
{
    Set sc = $$$OK

    &html<<style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            height: 100vh;
            overflow: hidden;
            background-color: #f4f6f8;
        }

        .main-content {
            flex-grow: 1;
            flex-shrink: 1; /* Allow shrinking when needed */
            min-width: 0; /* Important: allows flex item to shrink below content size */
            width: 0; /* Forces flexbox to calculate width based on available space */
            padding: 40px;
            overflow-y: auto;
            overflow-x: hidden; /* Prevents horizontal overflow */
            background-color: #ffffff;
        }

        .main-content h1 {
            font-size: 2em;
            color: #2c3e50;
            margin-bottom: 10px;
        }

        .main-content h2 {
            font-size: 1.5em;
            color: #34495e;
            border-bottom: 2px solid #e0e4e8;
            padding-bottom: 6px;
            margin-top: 30px;
        }

        .main-content p {
            font-size: 1em;
            color: #555;
            line-height: 1.6em;
            margin-top: 12px;
        }

        .hidden {
            display: none;
        }

        .message {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 12px 16px;
            border-radius: 6px;
            color: white;
            font-weight: 500;
            z-index: 1001;
            transform: translateX(100%);
            transition: transform 0.3s ease;
        }

        .message.show {
            transform: translateX(0);
        }

        .message.success {
            background: #10b981;
        }

        .message.error {
            background: #ef4444;
        }

        .loading {
            text-align: center;
            padding: 40px;
            color: #64748b;
        }

        .actions {
            display: flex;
            gap: 8px;
        }    

        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-primary {
            background: #3b82f6;
            color: white;
        }

        .btn-primary:hover {
            background: #2563eb;
        }

        .btn-secondary {
            background: #e2e8f0;
            color: #475569;
        }

        .btn-secondary:hover {
            background: #cbd5e1;
        }

        .btn-danger {
            background: #ef4444;
            color: white;
        }

        .btn-danger:hover {
            background: #dc2626;
        }

        .btn-small {
            padding: 4px 8px;
            font-size: 12px;
        }

        .btn-icon {
            width: 32px;
            height: 32px;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            background: none;
            border: none;
            outline: none;
            font-size: 18px;
        }

        .btn-icon:hover {
            transform: translateY(-1px) scale(1.2) rotate(360deg);
        }

        .btn-icon:focus {
            outline: none;
        }

        .sidebar-icon {
            width: 32px;
            height: 32px;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            background: none;
            border: none;
            outline: none;
            font-size: 18px;
        }

        .sidebar-icon:hover {
            transform: translateY(-1px) scale(1.2) rotate(720deg);
            transition: transform 0.8s cubic-bezier(0.68, -0.55, 0.265, 1.55);
        }
        
        @keyframes spin {
            from { transform: translateY(-1px) scale(1.2) rotate(0deg); }
            to { transform: translateY(-1px) scale(1.2) rotate(360deg); }
        }

        .sidebar-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .sidebar-header-icon {
            width: 32px;
            height: 32px;
            padding: 0;
            background: none;
            border: none;
            outline: none;
            font-size: 24px;
        }

        .sidebar-header-icon:hover {
            transform: translateY(-1px) scale(1.4);
            animation: spin 0.7s linear infinite;
        }
    </style>>

    // Specific CSS for the Sidebar
    Do ##class(PackageManager.UI.Screens.SideBar.CSS).SideBarCSS()

    Return sc
}

}
