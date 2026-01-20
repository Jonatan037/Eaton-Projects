<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ZMMRDataImport.aspx.cs" Inherits="ZMMRDataImport" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>ZMMR Scrap Data Import</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #1a1a2e;
            color: #eee;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .container-main {
            max-width: 1000px;
            margin: 30px auto;
            padding: 20px;
        }
        .card {
            background: linear-gradient(135deg, #16213e 0%, #1a1a2e 100%);
            border: 1px solid #0f3460;
            border-radius: 15px;
            margin-bottom: 20px;
        }
        .card-header {
            background: linear-gradient(90deg, #0f3460 0%, #16213e 100%);
            border-bottom: 1px solid #0f3460;
            border-radius: 15px 15px 0 0 !important;
            padding: 15px 20px;
        }
        .card-header h5 {
            margin: 0;
            color: #00d4ff;
        }
        .btn-primary {
            background: linear-gradient(135deg, #0f3460 0%, #16213e 100%);
            border: 1px solid #00d4ff;
            color: #00d4ff;
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, #16213e 0%, #0f3460 100%);
            border-color: #00d4ff;
            color: #fff;
        }
        .btn-success {
            background: linear-gradient(135deg, #00a86b 0%, #007a4d 100%);
            border: none;
        }
        .alert-info {
            background-color: rgba(0, 212, 255, 0.1);
            border-color: #00d4ff;
            color: #00d4ff;
        }
        .alert-success {
            background-color: rgba(0, 168, 107, 0.1);
            border-color: #00a86b;
            color: #00a86b;
        }
        .alert-danger {
            background-color: rgba(220, 53, 69, 0.1);
            border-color: #dc3545;
            color: #ff6b6b;
        }
        .table {
            color: #eee;
        }
        .table thead th {
            background-color: #0f3460;
            color: #00d4ff;
            border-color: #16213e;
        }
        .table tbody td {
            border-color: #16213e;
        }
        .form-control, .form-select {
            background-color: #16213e;
            border: 1px solid #0f3460;
            color: #eee;
        }
        .form-control:focus, .form-select:focus {
            background-color: #1a1a2e;
            border-color: #00d4ff;
            color: #eee;
            box-shadow: 0 0 0 0.2rem rgba(0, 212, 255, 0.25);
        }
        .preview-container {
            max-height: 400px;
            overflow-y: auto;
        }
        .stats-box {
            background: rgba(0, 212, 255, 0.1);
            border: 1px solid #0f3460;
            border-radius: 10px;
            padding: 15px;
            text-align: center;
        }
        .stats-box h3 {
            color: #00d4ff;
            margin: 0;
        }
        .stats-box p {
            margin: 5px 0 0 0;
            color: #aaa;
        }
        .back-link {
            color: #00d4ff;
            text-decoration: none;
        }
        .back-link:hover {
            color: #fff;
        }
        .file-drop-zone {
            border: 2px dashed #0f3460;
            border-radius: 10px;
            padding: 40px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .file-drop-zone:hover, .file-drop-zone.dragover {
            border-color: #00d4ff;
            background: rgba(0, 212, 255, 0.05);
        }
        .file-drop-zone i {
            font-size: 48px;
            color: #0f3460;
            margin-bottom: 15px;
        }
        .file-drop-zone:hover i, .file-drop-zone.dragover i {
            color: #00d4ff;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-main">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2><i class="fas fa-database me-2"></i>ZMMR Scrap Data Import</h2>
                <a href="ScrapDashboard.aspx" class="back-link">
                    <i class="fas fa-chart-line me-1"></i>View Dashboard
                </a>
            </div>

            <!-- Import Status Summary -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="stats-box">
                        <h3><asp:Label ID="lblTotalRecords" runat="server" Text="0" /></h3>
                        <p>Total Records</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stats-box">
                        <h3><asp:Label ID="lblLastImportDate" runat="server" Text="-" /></h3>
                        <p>Last Import</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stats-box">
                        <h3><asp:Label ID="lblDateRange" runat="server" Text="-" /></h3>
                        <p>Date Range</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stats-box">
                        <h3><asp:Label ID="lblFilesImported" runat="server" Text="0" /></h3>
                        <p>Files Imported</p>
                    </div>
                </div>
            </div>

            <!-- File Upload Card -->
            <div class="card">
                <div class="card-header">
                    <h5><i class="fas fa-upload me-2"></i>Upload CSV File</h5>
                </div>
                <div class="card-body">
                    <asp:Panel ID="pnlUpload" runat="server">
                        <div class="file-drop-zone" id="dropZone" onclick="document.getElementById('<%= fileUpload.ClientID %>').click();">
                            <i class="fas fa-cloud-upload-alt"></i>
                            <p class="mb-2">Drag and drop your CSV file here, or click to browse</p>
                            <small class="text-muted">Accepts .csv files from Power BI export</small>
                        </div>
                        <asp:FileUpload ID="fileUpload" runat="server" CssClass="d-none" accept=".csv" />
                        <div id="fileInfo" class="mt-3 d-none">
                            <div class="alert alert-info">
                                <i class="fas fa-file-csv me-2"></i>
                                <span id="fileName"></span>
                                <span class="float-end" id="fileSize"></span>
                            </div>
                        </div>
                        <div class="mt-3">
                            <asp:Button ID="btnPreview" runat="server" Text="Preview Data" 
                                CssClass="btn btn-primary me-2" OnClick="btnPreview_Click" />
                            <asp:Button ID="btnImport" runat="server" Text="Import to Database" 
                                CssClass="btn btn-success" OnClick="btnImport_Click" Visible="false" />
                        </div>
                    </asp:Panel>

                    <!-- Results Panel -->
                    <asp:Panel ID="pnlResults" runat="server" Visible="false">
                        <asp:Panel ID="pnlSuccess" runat="server" CssClass="alert alert-success" Visible="false">
                            <i class="fas fa-check-circle me-2"></i>
                            <strong>Import Successful!</strong><br />
                            <asp:Label ID="lblSuccessMessage" runat="server" />
                        </asp:Panel>
                        <asp:Panel ID="pnlError" runat="server" CssClass="alert alert-danger" Visible="false">
                            <i class="fas fa-exclamation-circle me-2"></i>
                            <strong>Import Error</strong><br />
                            <asp:Label ID="lblErrorMessage" runat="server" />
                        </asp:Panel>
                        <asp:Button ID="btnReset" runat="server" Text="Import Another File" 
                            CssClass="btn btn-primary mt-2" OnClick="btnReset_Click" />
                    </asp:Panel>
                </div>
            </div>

            <!-- Preview Card -->
            <asp:Panel ID="pnlPreview" runat="server" Visible="false">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5><i class="fas fa-table me-2"></i>Data Preview</h5>
                        <span class="badge bg-info">
                            <asp:Label ID="lblPreviewCount" runat="server" Text="0" /> rows
                        </span>
                    </div>
                    <div class="card-body">
                        <div class="preview-container">
                            <asp:GridView ID="gvPreview" runat="server" CssClass="table table-sm table-hover"
                                AutoGenerateColumns="false" GridLines="None">
                                <Columns>
                                    <asp:BoundField DataField="PostingDate" HeaderText="Date" DataFormatString="{0:MM/dd/yyyy}" />
                                    <asp:BoundField DataField="CostCenterCode" HeaderText="Cost Center" />
                                    <asp:BoundField DataField="MaterialNumber" HeaderText="Material #" />
                                    <asp:BoundField DataField="MaterialDescription" HeaderText="Description" />
                                    <asp:BoundField DataField="MovementType" HeaderText="Type" />
                                    <asp:BoundField DataField="Quantity" HeaderText="Qty" />
                                    <asp:BoundField DataField="Amount" HeaderText="Amount" DataFormatString="{0:C2}" />
                                    <asp:BoundField DataField="ReasonDescription" HeaderText="Reason" />
                                </Columns>
                            </asp:GridView>
                        </div>
                        <div class="mt-3 d-flex gap-2">
                            <asp:Button ID="btnConfirmImport" runat="server" Text="Confirm Import" 
                                CssClass="btn btn-success" OnClick="btnConfirmImport_Click" />
                            <asp:Button ID="btnCancelPreview" runat="server" Text="Cancel" 
                                CssClass="btn btn-secondary" OnClick="btnReset_Click" />
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <!-- Recent Imports Card -->
            <div class="card">
                <div class="card-header">
                    <h5><i class="fas fa-history me-2"></i>Recent Imports</h5>
                </div>
                <div class="card-body">
                    <asp:GridView ID="gvImportLog" runat="server" CssClass="table table-sm table-hover"
                        AutoGenerateColumns="false" GridLines="None" EmptyDataText="No imports yet.">
                        <Columns>
                            <asp:BoundField DataField="ImportDate" HeaderText="Date" DataFormatString="{0:MM/dd/yyyy HH:mm}" />
                            <asp:BoundField DataField="FileName" HeaderText="File Name" />
                            <asp:BoundField DataField="RecordsImported" HeaderText="Imported" />
                            <asp:BoundField DataField="RecordsSkipped" HeaderText="Skipped" />
                            <asp:BoundField DataField="Status" HeaderText="Status" />
                            <asp:BoundField DataField="ImportedBy" HeaderText="By" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </form>

    <script>
        // File drop zone functionality
        const dropZone = document.getElementById('dropZone');
        const fileInput = document.getElementById('<%= fileUpload.ClientID %>');
        const fileInfo = document.getElementById('fileInfo');
        const fileName = document.getElementById('fileName');
        const fileSize = document.getElementById('fileSize');

        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            dropZone.addEventListener(eventName, preventDefaults, false);
        });

        function preventDefaults(e) {
            e.preventDefault();
            e.stopPropagation();
        }

        ['dragenter', 'dragover'].forEach(eventName => {
            dropZone.addEventListener(eventName, () => dropZone.classList.add('dragover'), false);
        });

        ['dragleave', 'drop'].forEach(eventName => {
            dropZone.addEventListener(eventName, () => dropZone.classList.remove('dragover'), false);
        });

        dropZone.addEventListener('drop', handleDrop, false);

        function handleDrop(e) {
            const dt = e.dataTransfer;
            const files = dt.files;
            if (files.length > 0) {
                // Can't directly set FileUpload control, user must click
                alert('Please click the drop zone and select your file.');
            }
        }

        fileInput.addEventListener('change', function() {
            if (this.files.length > 0) {
                const file = this.files[0];
                fileName.textContent = file.name;
                fileSize.textContent = formatBytes(file.size);
                fileInfo.classList.remove('d-none');
            }
        });

        function formatBytes(bytes) {
            if (bytes === 0) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
        }
    </script>
</body>
</html>
