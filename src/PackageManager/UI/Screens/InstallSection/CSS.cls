Class PackageManager.UI.Screens.InstallSection.CSS Extends PackageManager.UI.Screens.Abstract
{

/*
    CSS STYLES
*/
ClassMethod RenderStyles() As %Status
{
    Set sc = $$$OK

    &html<<style>

        .api-mgr-reset * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        /* Project Container Styles - matching existing design */
        .api-mgr-project-container {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            overflow: hidden;
            margin-bottom: 20px;
            margin-top: 10px;
            max-width: 1000px;
            margin-left: 0;  /* Changed from auto to 0 */
            margin-right: auto;
        }

        .api-mgr-project-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 15px;
            background: linear-gradient(135deg, #3c97ffff, #0d6bd7ff);
            color: white;
            flex-wrap: wrap;
            gap: 10px;
        }

        .api-mgr-project-header h3 {
            margin: 0;
            font-size: 16px;
            font-weight: 600;
            min-width: 0;
            flex-shrink: 1;
        }

        .api-mgr-project-title {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 18px;
            font-weight: 600;
        }

        .api-mgr-project-title .api-mgr-icon {
            font-size: 20px;
        }

        .api-mgr-project-content {
            padding: 10px;
        }

        /* Section Styling */
        .api-mgr-section {
            margin-bottom: 30px;
        }

        .api-mgr-status-box {
            overflow-x: auto;
            border: 1px solid #e0e4e8;
            border-radius: 8px;
            margin-bottom: 20px;
            margin-top: 20px;
            background: white;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            /* Remove any horizontal margins */
            margin-left: 0;
            margin-right: 0;
        }

        .api-mgr-status-content {
            padding: 24px 28px;
        }

        .api-mgr-status-box--success {
            border-left: 4px solid #28a745;
            background: linear-gradient(135deg, #f8fff9 0%, #f0fff1 100%);
        }

        .api-mgr-status-box--error {
            border-left: 4px solid #dc3545;
            background: linear-gradient(135deg, #fff8f8 0%, #ffeaea 100%);
        }

        .api-mgr-status-box--warning {
            border-left: 4px solid #ffc107;
            background: linear-gradient(135deg, #fffbf0 0%, #fff8e1 100%);
        }

        .api-mgr-status-text {
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 16px;
            color: #2c3e50;
            line-height: 1.4;
            display: flex;
            align-items: center;
        }

        .api-mgr-status-details {
            font-size: 14px;
            color: #5a6c7d;
            line-height: 1.6;
            margin-bottom: 8px;
            margin-top: 8px;
            padding-left: 18px; /* Align with status indicator */
        }

        /* Button Styles - matching existing project buttons */
        .api-mgr-btn {
            padding: 10px 18px;
            font-weight: 600;
            border: 1px solid #e0e4e8;
            border-radius: 15px;
            font-size: 12px;
            letter-spacing: 0.03em;
            min-width: 120px;
            margin-right: 10px;
            margin-bottom: 10px;
            background-color: #fefefe;
            transition: all 0.25s ease;
            cursor: pointer;
            color: #2c3e50;
        }

        .api-mgr-btn:hover {
            transform: translateY(-1px);
            background-color: #3498db;
            box-shadow: 0 2px 5px #3498db;
            color: white;
        }

        .api-mgr-btn--success {
            background-color: #28a745;
            color: white;
            border-color: #28a745;
        }

        .api-mgr-btn--success:hover {
            background-color: #218838;
            box-shadow: 0 2px 5px rgba(40, 167, 69, 0.3);
        }

        .api-mgr-btn--danger {
            background-color: #dc3545;
            color: white;
            border-color: #dc3545;
        }

        .api-mgr-btn--danger:hover {
            background-color: #c82333;
            box-shadow: 0 2px 5px rgba(220, 53, 69, 0.3);
        }

        .api-mgr-btn:disabled {
            background-color: #6c757d;
            color: white;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .api-mgr-btn:disabled:hover {
            background-color: #6c757d;
            transform: none;
            box-shadow: none;
        }

        .api-mgr-btn--refresh {
            background: linear-gradient(135deg, #3e5f81ff 0%, #34495e 100%);
            color: white;
            border-color: #2c3e50;
        }

        .api-mgr-btn--refresh:hover {
            box-shadow: 0 2px 5px rgba(44, 62, 80, 0.3);
        }

        /* Loading Spinner */
        .api-mgr-loading-spinner {
            display: inline-block;
            width: 16px;
            height: 16px;
            border: 2px solid #f3f3f3;
            border-top: 2px solid #3498db;
            border-radius: 50%;
            animation: api-mgr-spin 1s linear infinite;
            margin-right: 8px;
        }

        @keyframes api-mgr-spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .api-mgr-container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
        }
    
        /* Message Styles - matching existing project messages */
        .api-mgr-message {
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 15px;
            display: none;
        }

        .api-mgr-message--success {
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
        }

        .api-mgr-message--error {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
        }

        .api-mgr-message--info {
            background-color: #cce7ff;
            border: 1px solid #99d3ff;
            color: #004085;
        }

        /* Details List Styles */
        .api-mgr-details-list {
            list-style: none;
            padding: 0;
            margin: 8px 0 0 0;
        }

        .api-mgr-details-list__item {
            padding: 6px 0;
            border-bottom: 1px solid #f0f0f0;
            font-size: 13px;
            display: flex;
            align-items: center;
        }

        .api-mgr-details-list__item:last-child {
            border-bottom: none;
        }

        /* Status Indicators - Enhanced */
        .api-mgr-status-indicator {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            margin-right: 12px;
            margin-left: 6;
            flex-shrink: 0;
            box-shadow: 0 0 0 2px rgba(255, 255, 255, 0.8);
        }

        .api-mgr-status-indicator--green {
            background: linear-gradient(135deg, #28a745, #20c997);
            box-shadow: 0 0 0 2px rgba(40, 167, 69, 0.2);
        }

        .api-mgr-status-indicator--red {
            background: linear-gradient(135deg, #dc3545, #e74c3c);
            box-shadow: 0 0 0 2px rgba(220, 53, 69, 0.2);
        }

        .api-mgr-status-indicator--yellow {
            background: linear-gradient(135deg, #ffc107, #f39c12);
            box-shadow: 0 0 0 2px rgba(255, 193, 7, 0.2);
        }

        /* Controls Area - Enhanced spacing */
        .api-mgr-controls {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 24px;
            padding-top: 20px;
            border-top: 1px solid #e8ecef;
        }

        /* Page Header */
        .api-mgr-page-header {
            text-align: center;
            margin-bottom: 30px;
            color: #2c3e50;
        }

        .api-mgr-page-title {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .api-mgr-page-subtitle {
            font-size: 14px;
            color: #7f8c8d;
        }

        /* Enhanced status details styling */
        .api-mgr-status-details strong {
            color: #2c3e50;
            font-weight: 600;
        }

        .api-mgr-status-details br + * {
            margin-top: 4px;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .api-mgr-project-header {
                flex-direction: column;
                gap: 5px;
                text-align: center;
            }
            
            .api-mgr-controls {
                flex-direction: column;
                margin-top: 20px;
                padding-top: 16px;
            }
            
            .api-mgr-btn {
                width: 100%;
                min-width: auto;
            }
            
            .api-mgr-status-content {
                padding: 20px;
            }
            
            .api-mgr-status-text {
                font-size: 15px;
            }
            
            .api-mgr-status-details {
                font-size: 13px;
                padding-left: 16px;
            }
        }

    </style>>
    Return sc
}

}
