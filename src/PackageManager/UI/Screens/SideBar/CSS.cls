Class PackageManager.UI.Screens.SideBar.CSS Extends PackageManager.UI.Screens.Abstract
{

ClassMethod SideBarCSS() As %Status
{
    Set sc = $$$OK
    &html<<style>
        .sidebar {
            width: 260px;
            background: #1e2a38;
            color: #ecf0f1;
            display: flex;
            flex-direction: column;
            border-right: 1px solid #ccc;
            transition: width 0.3s ease;
            overflow-x: hidden;
            position: relative; /* Added for version positioning */
        }

        .sidebar.collapsed {
            width: 60px;
        }

        .sidebar.collapsed h3 span.label {
            display: none;
        }

        .sidebar.collapsed .sidebar-header .label {
            display: none;
        }

        /* Hide version text when collapsed, show only icon */
        .sidebar.collapsed .version-text {
            display: none;
        }

        .sidebar.collapsed .sidebar-version {
            padding: 8px 5px;
        }

        .sidebar.collapsed .version-icon {
            display: inline-block;
        }

        /* Hide user info when collapsed */
        .sidebar.collapsed .user-info {
            display: none;
        }

        .sidebar-header {
            padding: 20px;
            font-size: 1.3em;
            font-weight: 600;
            background-color: #162029;
            border-bottom: 1px solid #2d3c4d;
            letter-spacing: 0.5px;
            text-align: center;
            cursor: pointer;
            user-select: none;
        }

        .sidebar h3 {
            font-size: 0.95em;
            margin: 0;
            padding: 14px 20px;
            cursor: pointer;
            border-left: 4px solid transparent;
            display: flex;
            align-items: center;
            gap: 10px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            transition: all 0.2s ease-in-out;
        }

        .sidebar h3:hover {
            background-color: #2f3e4e;
            border-left: 4px solid #3498db;
        }

        .sidebar.collapsed h3 span.label {
            display: none;
        }

        /* Bottom info section - groups user info and version together */
        .bottom-info {
            margin-top: auto;
            border-top: 1px solid #2d3c4d;
            background-color: rgba(22, 32, 41, 0.6);
        }

        /* User information styling */
        .user-info {
            padding: 8px 12px;
            display: flex;
            gap: 8px;
            align-items: center;
            border-bottom: 1px solid rgba(45, 60, 77, 0.5);
        }

        .currentNamespace,
        .currentUser {
            flex: 1;
            font-size: 10px;
            color: rgba(236, 240, 241, 0.7);
            padding: 4px 6px;
            background-color: rgba(52, 152, 219, 0.1);
            border-radius: 3px;
            font-weight: 300;
            letter-spacing: 0.2px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            transition: all 0.3s ease;
            text-align: center;
            min-width: 0; /* Allows flex items to shrink */
        }

        .currentNamespace:hover,
        .currentUser:hover {
            background-color: rgba(52, 152, 219, 0.2);
            color: rgba(236, 240, 241, 0.9);
        }

        /* Version indicator styling - now part of bottom info */
        .sidebar-version {
            text-align: center;
            padding: 8px 12px;
            transition: all 0.3s ease;
        }

        .version-text {
            font-size: 11px;
            color: rgba(236, 240, 241, 0.5); /* Matches your sidebar text color with opacity */
            font-weight: 300;
            letter-spacing: 0.5px;
            transition: opacity 0.3s ease;
        }

        /* Version icon for collapsed state */
        .version-icon {
            display: none;
            font-size: 12px;
            color: rgba(236, 240, 241, 0.4);
        }

        /* Hover effect for version area */
        .sidebar-version:hover .version-text {
            color: rgba(236, 240, 241, 0.8);
        }

        .sidebar-version:hover .version-icon {
            color: rgba(236, 240, 241, 0.7);
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .sidebar-version {
                font-size: 10px;
                padding: 6px 8px;
            }
            
            .currentNamespace,
            .currentUser {
                font-size: 10px;
            }
        }
    </style>>
    Return sc
}

}
