from flask import Flask, request, jsonify
import winrm
import logging
import json
import os
from dotenv import load_dotenv
from asgiref.wsgi import WsgiToAsgi

# Load environment variables
load_dotenv()

app = Flask(__name__)
asgi_app = WsgiToAsgi(app)

# -----------------------------------------------------------------------------
# Logging
# -----------------------------------------------------------------------------
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("winrm-gateway")

# -----------------------------------------------------------------------------
# WinRM Configuration (loaded from .env)
# -----------------------------------------------------------------------------
WINRM_CONFIG = {
    "server": os.getenv("WINRM_SERVER"),
    "username": os.getenv("WINRM_USERNAME"),
    "password": os.getenv("WINRM_PASSWORD"),
    "port": int(os.getenv("WINRM_PORT", 5986)),
}

WINRM_ENDPOINT = (
    f"https://{WINRM_CONFIG['server']}:{WINRM_CONFIG['port']}/wsman"
)

# -----------------------------------------------------------------------------
# Utility: Create WinRM session
# -----------------------------------------------------------------------------
def create_session():
    return winrm.Session(
        WINRM_ENDPOINT,
        auth=(WINRM_CONFIG["username"], WINRM_CONFIG["password"]),
        server_cert_validation="ignore",
    )

# -----------------------------------------------------------------------------
# Utility: Execute PowerShell safely
# -----------------------------------------------------------------------------
def run_ps(script: str, timeout: int = 60):
    session = create_session()
    result = session.run_ps(script)

    stdout = result.std_out.decode("utf-8", errors="ignore").strip()
    stderr = result.std_err.decode("utf-8", errors="ignore").strip()

    return {
        "status": result.status_code,
        "stdout": stdout,
        "stderr": stderr,
        "success": result.status_code == 0,
    }

# -----------------------------------------------------------------------------
# Health
# -----------------------------------------------------------------------------
@app.route("/health", methods=["GET"])
def health():
    return jsonify(
        {
            "status": "running",
            "target": WINRM_CONFIG["server"],
            "port": WINRM_CONFIG["port"],
        }
    )

# -----------------------------------------------------------------------------
# Test WinRM
# -----------------------------------------------------------------------------
@app.route("/test", methods=["GET"])
def test():
    try:
        session = create_session()
        result = session.run_cmd("whoami")
        return jsonify(
            {
                "success": True,
                "output": result.std_out.decode("utf-8").strip(),
            }
        )
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

# -----------------------------------------------------------------------------
# Execute Raw PowerShell (used by n8n)
# -----------------------------------------------------------------------------
@app.route("/execute", methods=["POST"])
def execute():
    try:
        data = request.json
        if not data or "script" not in data:
            return jsonify({"error": "script required"}), 400

        script = data["script"]  # DO NOT STRIP NEWLINES

        logger.info("Executing PowerShell script")
        result = run_ps(script)

        return jsonify(result)

    except Exception as e:
        logger.exception("Execution failure")
        return jsonify(
            {
                "success": False,
                "status": -1,
                "stdout": "",
                "stderr": str(e),
            }
        ), 500

# -----------------------------------------------------------------------------
# Excel Read (Session-Attached, STA-Safe)
# -----------------------------------------------------------------------------
@app.route("/excel/read", methods=["POST"])
def excel_read():
    try:
        data = request.json
        if not data or "file_path" not in data:
            return jsonify({"error": "file_path required"}), 400

        file_path = data["file_path"]

        ps_script = rf"""
$ExcelFile = "{file_path}"

if (-not (Test-Path $ExcelFile)) {{
    Write-Error "File not found: $ExcelFile"
    exit 2
}}

$excel = $null
$workbook = $null
$worksheet = $null

try {{
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false

    $workbook = $excel.Workbooks.Open($ExcelFile)
    $worksheet = $workbook.Worksheets.Item(1)

    $used = $worksheet.UsedRange
    $rows = $used.Rows.Count
    $cols = $used.Columns.Count

    $out = @()
    for ($r = 1; $r -le $rows; $r++) {{
        $row = @()
        for ($c = 1; $c -le $cols; $c++) {{
            $row += $worksheet.Cells.Item($r, $c).Text
        }}
        $out += ,$row
    }}

    $out | ConvertTo-Json -Depth 10 -Compress
}}
catch {{
    Write-Error $_.Exception.Message
    exit 3
}}
finally {{
    if ($workbook) {{ $workbook.Close($false) }}
    if ($excel) {{ $excel.Quit() }}

    if ($worksheet) {{ [Runtime.InteropServices.Marshal]::ReleaseComObject($worksheet) | Out-Null }}
    if ($workbook) {{ [Runtime.InteropServices.Marshal]::ReleaseComObject($workbook) | Out-Null }}
    if ($excel) {{ [Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null }}

    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}}
"""

        result = run_ps(ps_script, timeout=90)

        if not result["success"]:
            return jsonify(result), 500

        try:
            parsed = json.loads(result["stdout"])
            return jsonify({"success": True, "rows": len(parsed), "data": parsed})
        except Exception:
            return jsonify(
                {
                    "success": True,
                    "raw": result["stdout"],
                    "note": "Output not valid JSON",
                }
            )

    except Exception as e:
        logger.exception("Excel read failure")
        return jsonify({"success": False, "error": str(e)}), 500

# -----------------------------------------------------------------------------
# Excel: Just Open
# -----------------------------------------------------------------------------
@app.route("/excel/open", methods=["POST"])
def excel_open():
    try:
        data = request.json or {}
        file_path = data.get("file_path", "").strip()

        # Create unique task name and paths
        import uuid
        task_id = str(uuid.uuid4())[:8]
        task_name = f"Excel-Open-{task_id}"
        
        base_path = r"C:\Windows\Temp\excel-task"
        script_path = f"{base_path}\\excel_script_{task_id}.ps1"
        output_path = f"{base_path}\\output_{task_id}.json"
        
        # Create the PowerShell script that will run in the interactive session
        if file_path:
            excel_script = f"""
$ErrorActionPreference = 'Stop'
try {{
    $result = @{{ success = $false; message = ""; error = "" }}
    
    $ExcelFile = "{file_path}"
    if (-not (Test-Path $ExcelFile)) {{
        $result.error = "File not found: $ExcelFile"
        $result | ConvertTo-Json | Set-Content -Path "{output_path}" -Encoding UTF8
        exit 1
    }}
    
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $true
    $excel.DisplayAlerts = $false
    
    $workbook = $excel.Workbooks.Open($ExcelFile)
    
    $result.success = $true
    $result.message = "Excel opened with file: $($workbook.Name)"
    $result.file = $ExcelFile
    
    $result | ConvertTo-Json | Set-Content -Path "{output_path}" -Encoding UTF8
    exit 0
}}
catch {{
    $result = @{{ success = $false; message = ""; error = $_.Exception.Message }}
    $result | ConvertTo-Json | Set-Content -Path "{output_path}" -Encoding UTF8
    exit 1
}}
"""
        else:
            excel_script = f"""
$ErrorActionPreference = 'Stop'
try {{
    $result = @{{ success = $false; message = ""; error = ""; file = "" }}
    
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $true
    $excel.DisplayAlerts = $false
    
    $workbook = $excel.Workbooks.Add()
    $worksheet = $workbook.Worksheets.Item(1)
    
    # Add headers
    $worksheet.Cells.Item(1, 1) = "Name"
    $worksheet.Cells.Item(1, 2) = "Email"
    $worksheet.Cells.Item(1, 3) = "Department"
    $worksheet.Cells.Item(1, 4) = "Salary"
    
    # Format headers
    $headerRange = $worksheet.Range("A1", "D1")
    $headerRange.Font.Bold = $true
    $headerRange.Interior.ColorIndex = 15
    
    # Add data
    $worksheet.Cells.Item(2, 1) = "John Doe"
    $worksheet.Cells.Item(2, 2) = "john.doe@example.com"
    $worksheet.Cells.Item(2, 3) = "Engineering"
    $worksheet.Cells.Item(2, 4) = 75000
    
    $worksheet.Cells.Item(3, 1) = "Jane Smith"
    $worksheet.Cells.Item(3, 2) = "jane.smith@example.com"
    $worksheet.Cells.Item(3, 3) = "Marketing"
    $worksheet.Cells.Item(3, 4) = 65000
    
    $worksheet.Cells.Item(4, 1) = "Bob Johnson"
    $worksheet.Cells.Item(4, 2) = "bob.johnson@example.com"
    $worksheet.Cells.Item(4, 3) = "Sales"
    $worksheet.Cells.Item(4, 4) = 70000
    
    $worksheet.Columns.AutoFit() | Out-Null
    
    # Save file
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $downloadsPath = [Environment]::GetFolderPath("UserProfile") + "\\Downloads"
    $filePath = "$downloadsPath\\SampleData_$timestamp.xlsx"
    
    $workbook.SaveAs($filePath, 51)
    
    $result.success = $true
    $result.message = "Excel file created and saved"
    $result.file = $filePath
    
    $result | ConvertTo-Json | Set-Content -Path "{output_path}" -Encoding UTF8
    exit 0
}}
catch {{
    $result = @{{ success = $false; message = ""; error = $_.Exception.Message; file = "" }}
    $result | ConvertTo-Json | Set-Content -Path "{output_path}" -Encoding UTF8
    exit 1
}}
"""
        
        # Upload the script to the remote machine
        ps_upload = f"""
$ErrorActionPreference = 'Stop'
$basePath = '{base_path}'
New-Item -ItemType Directory -Force -Path $basePath | Out-Null
@'
{excel_script}
'@ | Set-Content -Path '{script_path}' -Encoding UTF8
if (Test-Path '{output_path}') {{ Remove-Item -Force '{output_path}' }}
"""
        
        result = run_ps(ps_upload)
        if not result["success"]:
            return jsonify({{"error": "Failed to upload script", "details": result}}), 500
        
        # Create and run scheduled task in interactive session
        # Note: Using current WinRM credentials as run-as user
        ps_task = f"""
$ErrorActionPreference = 'Stop'
$taskName = '{task_name}'
$scriptPath = '{script_path}'

# Get current user
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Delete old task if exists
try {{ schtasks /Delete /TN $taskName /F 2>&1 | Out-Null }} catch {{}}

# Create task - /IT makes it run in interactive session
$action = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -NoProfile -ExecutionPolicy Bypass -File $scriptPath"

schtasks /Create /F /TN $taskName /SC ONCE /ST 00:00 /RL HIGHEST /RU $currentUser /IT /TR $action | Out-Null

# Run task immediately
schtasks /Run /TN $taskName | Out-Null

Write-Output "Task created and started: $taskName"
"""
        
        result = run_ps(ps_task)
        if not result["success"]:
            return jsonify({{"error": "Failed to create task", "details": result}}), 500
        
        # Wait for output file (max 30 seconds)
        import time
        max_wait = 30
        start_time = time.time()
        
        while time.time() - start_time < max_wait:
            ps_check = f"""
if (Test-Path '{output_path}') {{
    Get-Content '{output_path}' -Raw -Encoding UTF8
}}
"""
            check_result = run_ps(ps_check)
            if check_result["success"] and check_result["stdout"].strip():
                # Clean up task
                ps_cleanup = f"try {{ schtasks /Delete /TN '{task_name}' /F 2>&1 | Out-Null }} catch {{}}"
                run_ps(ps_cleanup)
                
                # Parse JSON output
                try:
                    output_data = json.loads(check_result["stdout"])
                    return jsonify(output_data)
                except:
                    return jsonify({{"success": True, "raw_output": check_result["stdout"]}})
            
            time.sleep(0.5)
        
        # Timeout - cleanup and return error
        ps_cleanup = f"try {{ schtasks /Delete /TN '{task_name}' /F 2>&1 | Out-Null }} catch {{}}"
        run_ps(ps_cleanup)
        
        return jsonify({{"success": False, "error": "Timeout waiting for Excel to complete"}}), 500

    except Exception as e:
        logger.exception("Excel open failure")
        return jsonify({"success": False, "error": str(e)}), 500

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
if __name__ == "__main__":
    import uvicorn
    print("=" * 60)
    print("WinRM Automation Gateway (Excel / UI)")
    print("=" * 60)
    print(f"Target: {WINRM_CONFIG['server']}:{WINRM_CONFIG['port']}")
    print("Endpoints:")
    print("  GET  /health")
    print("  GET  /test")
    print("  POST /execute")
    print("  POST /excel/read")
    print("=" * 60)
    
    uvicorn.run(
        "improved_winrm_server:asgi_app",
        host="0.0.0.0",
        port=5001,
        reload=True,
        log_level="debug"
    )