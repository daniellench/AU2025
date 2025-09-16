# PowerShell Batch Layer Standards Checker
# Advanced batch processing with progress tracking and detailed reporting

param(
    [Parameter(Mandatory=$false)]
    [string]$InputFolder,
    
    [Parameter(Mandatory=$false)]
    [string]$AcCoreConsolePath = "C:\Program Files\Autodesk\AutoCAD 2024\AcCoreConsole.exe",
    
    [Parameter(Mandatory=$false)]
    [switch]$Recursive,
    
    [Parameter(Mandatory=$false)]
    [switch]$CreateBackups,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputReport
)

# Script configuration
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$LispFile = Join-Path $ScriptPath "layer_standards_checker.lsp"
$TempScriptFile = Join-Path $ScriptPath "temp_process.scr"
$LogFile = Join-Path $ScriptPath "BatchProcessing_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Color codes for console output
$Colors = @{
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "Cyan"
    Header = "Magenta"
}

function Write-ColorLog {
    param($Message, $Color = "White", $LogLevel = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$LogLevel] $Message"
    
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $logMessage
}

function Test-Prerequisites {
    Write-ColorLog "Checking prerequisites..." -Color $Colors.Info
    
    # Check AcCoreConsole.exe
    if (-not (Test-Path $AcCoreConsolePath)) {
        Write-ColorLog "ERROR: AcCoreConsole.exe not found at: $AcCoreConsolePath" -Color $Colors.Error -LogLevel "ERROR"
        
        # Try to find AutoCAD installation
        $autocadPaths = @(
            "C:\Program Files\Autodesk\AutoCAD 2025\AcCoreConsole.exe",
            "C:\Program Files\Autodesk\AutoCAD 2024\AcCoreConsole.exe",
            "C:\Program Files\Autodesk\AutoCAD 2023\AcCoreConsole.exe",
            "C:\Program Files\Autodesk\AutoCAD 2022\AcCoreConsole.exe"
        )
        
        foreach ($path in $autocadPaths) {
            if (Test-Path $path) {
                $AcCoreConsolePath = $path
                Write-ColorLog "Found AutoCAD at: $path" -Color $Colors.Success
                break
            }
        }
        
        if (-not (Test-Path $AcCoreConsolePath)) {
            return $false
        }
    }
    
    # Check LISP file
    if (-not (Test-Path $LispFile)) {
        Write-ColorLog "ERROR: LISP file not found: $LispFile" -Color $Colors.Error -LogLevel "ERROR"
        return $false
    }
    
    Write-ColorLog "Prerequisites OK" -Color $Colors.Success
    return $true
}

function Get-DwgFiles {
    param($FolderPath, $Recursive)
    
    if ($Recursive) {
        return Get-ChildItem -Path $FolderPath -Filter "*.dwg" -Recurse -File
    } else {
        return Get-ChildItem -Path $FolderPath -Filter "*.dwg" -File
    }
}

function Create-ProcessScript {
    param($DwgPath)
    
    $scriptContent = @"
(load "$($LispFile.Replace('\', '/'))")
(c:LayerStandardsCheck)
QSAVE
QUIT
"@
    
    Set-Content -Path $TempScriptFile -Value $scriptContent
}

function Process-DwgFile {
    param($DwgFile, $Index, $Total)
    
    $fileName = $DwgFile.Name
    $filePath = $DwgFile.FullName
    
    Write-Progress -Activity "Processing AutoCAD Files" -Status "Processing: $fileName" -PercentComplete (($Index / $Total) * 100)
    Write-ColorLog "[$Index/$Total] Processing: $fileName" -Color $Colors.Info
    
    # Create backup if requested
    if ($CreateBackups) {
        $backupPath = $filePath -replace '\.dwg$', '_backup.dwg'
        Copy-Item -Path $filePath -Destination $backupPath -Force
        Write-ColorLog "  Backup created: $backupPath" -Color $Colors.Info
    }
    
    # Create script file
    Create-ProcessScript -DwgPath $filePath
    
    # Process file with AcCoreConsole
    try {
        $startTime = Get-Date
        $processArgs = @("/i", "`"$filePath`"", "/s", "`"$TempScriptFile`"")
        
        $processInfo = Start-Process -FilePath $AcCoreConsolePath -ArgumentList $processArgs -Wait -PassThru -WindowStyle Hidden
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds
        
        if ($processInfo.ExitCode -eq 0) {
            Write-ColorLog "  SUCCESS (${duration}s)" -Color $Colors.Success
            return @{ Success = $true; Duration = $duration; Error = $null }
        } else {
            Write-ColorLog "  ERROR (Exit Code: $($processInfo.ExitCode))" -Color $Colors.Error -LogLevel "ERROR"
            return @{ Success = $false; Duration = $duration; Error = "Exit Code: $($processInfo.ExitCode)" }
        }
    }
    catch {
        Write-ColorLog "  EXCEPTION: $($_.Exception.Message)" -Color $Colors.Error -LogLevel "ERROR"
        return @{ Success = $false; Duration = 0; Error = $_.Exception.Message }
    }
}

function Generate-Report {
    param($Results, $StartTime, $EndTime)
    
    $totalFiles = $Results.Count
    $successfulFiles = ($Results | Where-Object { $_.Success }).Count
    $failedFiles = $totalFiles - $successfulFiles
    $totalDuration = [math]::Round(($EndTime - $StartTime).TotalMinutes, 2)
    $avgDuration = if ($totalFiles -gt 0) { [math]::Round(($Results | Measure-Object Duration -Average).Average, 2) } else { 0 }
    
    $reportContent = @"
LAYER STANDARDS BATCH PROCESSING REPORT
=======================================
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Total Processing Time: $totalDuration minutes
AutoCAD Version: $AcCoreConsolePath

SUMMARY
-------
Total Files Processed: $totalFiles
Successful: $successfulFiles
Failed: $failedFiles
Success Rate: $([math]::Round(($successfulFiles / $totalFiles) * 100, 1))%
Average Processing Time: $avgDuration seconds per file

DETAILED RESULTS
----------------
"@
    
    foreach ($result in $Results) {
        $status = if ($result.Success) { "SUCCESS" } else { "FAILED" }
        $reportContent += "`n$($result.FileName): $status ($($result.Duration)s)"
        if (-not $result.Success) {
            $reportContent += " - Error: $($result.Error)"
        }
    }
    
    if ($OutputReport) {
        Set-Content -Path $OutputReport -Value $reportContent
        Write-ColorLog "Report saved to: $OutputReport" -Color $Colors.Info
    }
    
    return $reportContent
}

# Main execution
try {
    Write-ColorLog "Layer Standards Batch Processor Starting..." -Color $Colors.Header
    Write-ColorLog "Log file: $LogFile" -Color $Colors.Info
    
    # Get input folder
    if (-not $InputFolder) {
        $InputFolder = Read-Host "Enter folder path containing DWG files"
    }
    
    if (-not (Test-Path $InputFolder)) {
        Write-ColorLog "ERROR: Folder not found: $InputFolder" -Color $Colors.Error -LogLevel "ERROR"
        exit 1
    }
    
    # Check prerequisites
    if (-not (Test-Prerequisites)) {
        exit 1
    }
    
    # Get DWG files
    $dwgFiles = Get-DwgFiles -FolderPath $InputFolder -Recursive:$Recursive
    
    if ($dwgFiles.Count -eq 0) {
        Write-ColorLog "No DWG files found in: $InputFolder" -Color $Colors.Warning -LogLevel "WARNING"
        exit 0
    }
    
    Write-ColorLog "Found $($dwgFiles.Count) DWG files" -Color $Colors.Info
    Write-ColorLog "Recursive search: $Recursive" -Color $Colors.Info
    Write-ColorLog "Create backups: $CreateBackups" -Color $Colors.Info
    
    # Confirm processing
    $confirm = Read-Host "Proceed with processing? (Y/N)"
    if ($confirm -notmatch '^[Yy]') {
        Write-ColorLog "Processing cancelled by user" -Color $Colors.Warning
        exit 0
    }
    
    # Process files
    $startTime = Get-Date
    $results = @()
    
    for ($i = 0; $i -lt $dwgFiles.Count; $i++) {
        $result = Process-DwgFile -DwgFile $dwgFiles[$i] -Index ($i + 1) -Total $dwgFiles.Count
        $result["FileName"] = $dwgFiles[$i].Name
        $results += $result
    }
    
    $endTime = Get-Date
    
    # Clean up
    if (Test-Path $TempScriptFile) {
        Remove-Item $TempScriptFile -Force
    }
    
    Write-Progress -Activity "Processing AutoCAD Files" -Completed
    
    # Generate and display report
    $report = Generate-Report -Results $results -StartTime $startTime -EndTime $endTime
    Write-ColorLog "`n$report" -Color $Colors.Info
    
    Write-ColorLog "Processing completed successfully!" -Color $Colors.Success
}
catch {
    Write-ColorLog "FATAL ERROR: $($_.Exception.Message)" -Color $Colors.Error -LogLevel "FATAL"
    exit 1
}
finally {
    # Clean up temp files
    if (Test-Path $TempScriptFile) {
        Remove-Item $TempScriptFile -Force
    }
}