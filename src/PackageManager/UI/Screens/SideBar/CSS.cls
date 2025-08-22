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
    </style>>
    Return sc
}

}
