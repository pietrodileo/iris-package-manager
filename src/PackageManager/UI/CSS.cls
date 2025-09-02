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

        /* Icon base styles */
        .icon {
            display: inline-block;
            font-style: normal;
            font-variant: normal;
            text-rendering: auto;
            line-height: 1;
        }

        /* Specific icon classes */
        .icon-save:before { content: "\1f4be"; }        /* floppy disk */
        .icon-cancel:before { content: "\274c"; }       /* cross mark */
        .icon-edit:before { content: "\270D"; }         /* pencil */
        .icon-delete:before { content: "\1F6AE"; }      /* wastebasket */
        .icon-settings:before { content: "\1F4D1"; }     /* whitepaper */
        .icon-tools:before { content: "\1f527"; }       /* wrench */
        .icon-success:before { content: "\2713"; }      /* check mark */
        .icon-warning:before { content: "\26a0"; }      /* warning sign */
        .icon-home:before { content: "\1f3e0"; }        /* house */
        .icon-user:before { content: "\1f464"; }        /* bust in silhouette */
        .icon-search:before { content: "\1f50d"; }      /* left-pointing magnifying glass */
        .icon-refresh:before { content: "\21bb"; }      /* clockwise open circle arrow */
        .icon-download:before { content: "\2B07"; }     /* downwards arrow */
        .icon-upload:before { content: "\2191"; }       /* upwards arrow */
        .icon-multiplication:before { content: "\00D7"; }         /* multiplication sign */
        .icon-plus:before { content: "\002b"; }         /* plus sign */
        .icon-minus:before { content: "\2212"; }        /* minus sign */
        .icon-left:before { content: "\2190"; }         /* leftwards arrow */
        .icon-right:before { content: "\2192"; }        /* rightwards arrow */
        .icon-up:before { content: "\2191"; }           /* upwards arrow */
        .icon-down:before { content: "\2193"; }         /* downwards arrow */
        .icon-package:before { content: "\1f4e6"; }     /* package */
        .icon-info:before { content: "\2139"; }         /* information source */
        .icon-document:before { content: "\1f4c4"; }    /* page facing up */
        .icon-cls:before { content: "\1f4d8"; }          /* blue book */
        .icon-mac:before { content: "\1f4dc"; }          /* scroll */
        .icon-inc:before { content: "\1f4dd"; }          /* memo */
        .icon-csp:before { content: "\1f9e9"; }          /* puzzle piece */
        .icon-css:before { content: "\1f3a8"; }          /* artist palette */
        .icon-js:before { content: "\1f4bb"; }           /* personal computer */
        .icon-json:before { content: "\1f9fe"; }         /* receipt */
        .icon-png:before { content: "\1f5bc"; }          /* framed picture */
        .icon-html:before { content: "\1f310"; }         /* globe with meridians */
        .icon-ico:before { content: "\1f5bc"; }          /* framed picture */
        .icon-jpg:before { content: "\1f5bc"; }          /* framed picture */
        .icon-folder:before { content: "\1f4c1"; }       /* file folder */
        .icon-folder-open:before { content: "\1f4c2"; }  /* open file folder */
        .icon-books:before { content: "\1f4da"; }        /* books */
        .icon-outbox:before { content: "\1f4e4"; }       /* outbox tray */
        .icon-info-circle:before { content: "\24d8"; }   /* circled information */
        .icon-question:before { content: "\2753"; }      /* question mark ornament */
        .icon-exclamation:before { content: "\2757"; }   /* exclamation mark symbol */
        .icon-lightbulb:before { content: "\1f4a1"; }    /* light bulb */
        .icon-speech:before { content: "\1f4ac"; }       /* speech balloon */
        .icon-thought:before { content: "\1f4ad"; }      /* thought balloon */
        .icon-wireless:before { content: "\1f6dc"; }     /* wireless */
        .icon-dividers:before { content: "\1F5C2"; }     /* CARD INDEX DIVIDERS */
        .icon-new:before { content: "\1F195"; }          /* SQUARED NEW */
        .icon-refresh:before { content: "\1F504"; }      /* REFRESH */
        .icon-open-book:before { content: "\1F4D6"; }    /* open book */
        .icon-plus:before { content: "\2795"; }          /* PLUS SIGN */
        .icon-calendar:before { content: "\1F4C5"; }     /* CALENDAR */
        .icon-email:before { content: "\1F4E7"; }        /* EMAIL */
        .icon-pause:before { content: "\23F8"; }        /* Pause Button */
        .icon-barchart:before { content: "\1F4CA"; }    /* Bar Chart */
        .icon-bag:before { content: "\1F4BC"; }    /* BRIEFCASE / BAG */
        .icon-clipboard:before { content: "\1F4CB"; }   /* Clipboard */
        .icon-run:before {                              /* RUN BUTTON */
            content: "\25B6"; 
            background-color: #1c73ffff; /* Sets the background color to blue */
            padding: 3px 6px; /* Adds space around the icon */
            border-radius: 4px; /* Rounds the corners for a softer look */
            color: white; /* Makes the arrow white for contrast against the blue background */
            font-size: 0.65em;
        }
        .icon-right-arrow:before { content: "\25B6"; }        /* ARROW TOGGLE */
        .icon-hourglass:before { content: "\23F3"; }        /* hourglass with sand */
        .icon-select-all:before { content: "\290B"; }        /* Downwards Triple arrow  */
    </style>>

    // Specific CSS for the Sidebar
    Do ##class(PackageManager.UI.Screens.SideBar.CSS).SideBarCSS()

    Return sc
}

}
