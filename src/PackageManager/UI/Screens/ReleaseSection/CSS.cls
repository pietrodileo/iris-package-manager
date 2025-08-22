Class PackageManager.UI.Screens.ReleaseSection.CSS Extends PackageManager.UI.Screens.Abstract
{

/*
    CSS STYLES
*/
ClassMethod RenderStyles() As %Status
{
    Set sc = $$$OK

    &html<<style>
        .exported-releases-container {
            width: 100%;
            max-width: none;
            margin: 0;
            background-color: #ffffff;
            border-radius: 6px;
            overflow: hidden;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            margin-top: 20px;
        }
        
        .exported-releases-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 15px;
            background: linear-gradient(135deg, #3c97ffff, #0d6bd7ff);
            color: white;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .exported-releases-header h3 {
            margin: 0;
            font-size: 16px;
            font-weight: 600;
            min-width: 0;
            flex-shrink: 1;
        }
        
        .exported-releases-controls {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        
        .exported-releases-controls button {
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
        
        .exported-releases-controls button:hover {
            transform: translateY(-1px);
            background: linear-gradient(135deg, #3e5f81ff 0%, #34495e 100%);
            color: white;
            border-color: #2c3e50;
            box-shadow: 0 2px 5px rgba(44, 62, 80, 0.3);
        }
        
        .exported-releases-controls button:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }
        
        .exported-releases-controls button:disabled:hover {
            transform: none;
            background-color: #fefefe;
            color: #2c3e50;
        }
        
        .exported-releases-selection-info {
            padding: 12px 15px;
            background-color: #e8f8fbff;
            border-bottom: 1px solid #e0e4e8;
            font-size: 14px;
            color: #2c3e50;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .exported-releases-selected-count {
            font-weight: bold;
            color: #3498db;
        }
        
        .exported-releases-search-container {
            padding: 10px 15px;
            border-bottom: 1px solid #e0e4e8;
            background-color: #f8f9fa;
        }
        
        .exported-releases-search-input {
            width: 100%;
            padding: 8px 10px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            background-color: #fbfffeff;
            box-sizing: border-box;
        }
        
        .exported-releases-search-input:focus {
            outline: none;
            border-color: #0e639c;
        }
        
        .exported-releases-tree-container {
            max-height: 600px;
            overflow-y: auto;
            padding: 0;
            background-color: #ffffff;
        }
        
        .exported-releases-tree-list {
            list-style: none;
            margin: 0;
            padding: 0;
        }
        
        .exported-releases-tree-item {
            list-style: none;
            margin: 0;
            padding: 0;
        }
        
        .exported-releases-tree-item-content {
            display: flex;
            align-items: center;
            padding: 8px 15px;
            cursor: pointer;
            min-height: 32px;
            border-bottom: 1px solid #f0f5fa;
            transition: background-color 0.2s ease;
        }
        
        .exported-releases-tree-item-content:hover {
            background-color: #f8f9fa;
        }
        
        .exported-releases-tree-toggle {
            width: 16px;
            height: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 8px;
            font-size: 12px;
            transition: transform 0.15s ease;
            color: #2c3e50;
        }
        
        .exported-releases-tree-checkbox {
            margin-right: 10px;
            margin-left: 0px;
        }
        
        .exported-releases-tree-icon {
            margin-right: 8px;
            font-size: 16px;
            vertical-align: middle;
        }
        
        .exported-releases-tree-label {
            flex: 1;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            font-size: 14px;
            color: #2c3e50;
            margin-right: 10px;
        }
        
        .exported-releases-file-info {
            display: flex;
            gap: 15px;
            font-size: 12px;
            color: #666;
            margin-left: auto;
        }
        
        .exported-releases-file-date {
            white-space: nowrap;
        }
        
        .exported-releases-file-size {
            white-space: nowrap;
            font-weight: 500;
        }
        
        .exported-releases-tree-children {
            margin-left: 24px;
            display: none;
            list-style: none;
            padding: 0;
        }
        
        .exported-releases-tree-item.expanded .exported-releases-tree-children {
            display: block;
        }
        
        .exported-releases-tree-item.expanded .exported-releases-tree-toggle {
            transform: rotate(90deg);
        }
        
        .exported-releases-loading {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        
        .exported-releases-message {
            padding: 15px;
            margin: 15px;
            border-radius: 6px;
            font-weight: 500;
        }
        
        .exported-releases-message.success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .exported-releases-message.error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        /* Responsive design */
        @media (max-width: 768px) {
            .exported-releases-header {
                flex-direction: column;
                align-items: stretch;
                text-align: center;
            }
            
            .exported-releases-controls {
                justify-content: center;
            }
            
            .exported-releases-controls button {
                flex: 1;
                min-width: 120px;
            }
            
            .exported-releases-file-info {
                flex-direction: column;
                gap: 5px;
            }
        }
        
        @media (max-width: 480px) {
            .exported-releases-container {
                margin-top: 15px;
                border-radius: 4px;
            }
            
            .exported-releases-header {
                padding: 10px 12px;
            }
            
            .exported-releases-header h3 {
                font-size: 14px;
            }
            
            .exported-releases-controls {
                flex-direction: column;
                gap: 6px;
            }
            
            .exported-releases-controls button {
                width: 100%;
                margin: 0;
                padding: 10px 16px;
                font-size: 14px;
            }
            
            .exported-releases-tree-item-content {
                padding: 6px 12px;
                flex-wrap: wrap;
            }
            
            .exported-releases-file-info {
                width: 100%;
                justify-content: space-between;
                margin-left: 0;
                margin-top: 5px;
            }
        }
    </style>>
    Return sc
}

}
