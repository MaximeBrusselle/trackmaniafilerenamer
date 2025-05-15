param(
    [Parameter(Mandatory=$true)]
    [string]$Directory,
    
    [Parameter(Mandatory=$false)]
    [string]$OutDirectory,
    
    [Parameter(Mandatory=$false)]
    [switch]$ShowDetails,
    
    [Parameter(Mandatory=$false)]
    [switch]$NoProgressBar
)

function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Text,
        
        [Parameter(Mandatory=$false)]
        [string]$ForegroundColor = "White"
    )
    
    Write-Host $Text -ForegroundColor $ForegroundColor
}

function Show-ProgressBar {
    param(
        [Parameter(Mandatory=$true)]
        [int]$PercentComplete,
        
        [Parameter(Mandatory=$true)]
        [int]$Width
    )
    
    $filled = [math]::Floor($Width * $PercentComplete / 100)
    $remaining = $Width - $filled
    
    $progressBar = "[" + ("#" * $filled) + (" " * $remaining) + "]"
    Write-Host "`r$progressBar $PercentComplete% " -NoNewline
}

Write-ColorOutput "=========================================================" "Cyan"
Write-ColorOutput "                TRACKMANIA REPLAY RENAMER                " "Cyan"
Write-ColorOutput "=========================================================" "Cyan"

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

if (-not (Test-Path -LiteralPath $Directory)) {
    Write-ColorOutput "ERROR: Directory $Directory does not exist." "Red"
    exit 1
}

if (-not [string]::IsNullOrWhiteSpace($OutDirectory) -and -not (Test-Path -LiteralPath $OutDirectory)) {
    try {
        New-Item -ItemType Directory -Force -Path $OutDirectory | Out-Null
        Write-ColorOutput "Output directory created: $OutDirectory" "Green"
    } catch {
        Write-ColorOutput "ERROR: Failed to create output directory: $OutDirectory" "Red"
        Write-ColorOutput "Error: $_" "Red"
        exit 1
    }
}

Write-ColorOutput "Searching for replay files..." "Yellow"
$files = @(Get-ChildItem -LiteralPath $Directory -Filter "*.Replay.gbx" -File)
$totalFiles = $files.Count

if ($totalFiles -eq 0) {
    Write-ColorOutput "No replay files found in $Directory" "Yellow"
    exit 0
}

Write-ColorOutput "$totalFiles replay files found" "Blue"

$processed = 0
$success = 0
$failed = 0
$progressWidth = 50
$progressInterval = [math]::Max(1, [math]::Min(10, [math]::Floor($totalFiles / 20)))
$operationText = if ($OutDirectory) { "Copying and renaming" } else { "Renaming" }

$fileInfo = @()

Write-ColorOutput "$operationText files in progress..." "Yellow"
if (-not $NoProgressBar) {
    Show-ProgressBar -PercentComplete 0 -Width $progressWidth
}

foreach ($file in $files) {
    $baseName = $file.Name -replace '\.Replay\.gbx$', ''
    $originalName = $baseName
    
    $newName = $baseName -replace ' ', '_'
    $newName = $newName -replace '\$[ghijkmnopqrstuvwxyzGHIJKMNOPQRSTUVWXYZ]', ''
    $newName = $newName -replace '\$[lL]\[.*?\]', ''
    $newName = $newName -replace '\$l', ''
    $newName = $newName -replace '\$[0-9a-zA-Z_]{3}', ''
    $newName = $newName -replace '\$\$', '$'
    $newName = $newName -replace '_{2,}', '_'
    $newName = $newName -replace '^_|_$', ''
    
    if ([string]::IsNullOrWhiteSpace($newName)) {
        $newName = "unnamed_replay"
    }
    
    try {
        $index = 1
        $basePath = if ($OutDirectory) { $OutDirectory } else { $Directory }
        $operation = if ($OutDirectory) { "Copy-Item" } else { "Move-Item" }

        $destinationPath = Join-Path $basePath "$newName.Replay.gbx"
        $finalName = "$newName.Replay.gbx"
        
        while (Test-Path -LiteralPath $destinationPath) {
            $finalName = "$newName`_$index.Replay.gbx"
            $destinationPath = Join-Path $basePath $finalName
            $index++
        }

        & $operation -LiteralPath $file.FullName -Destination $destinationPath -ErrorAction Stop
        
        $fileInfo += [PSCustomObject]@{
            OriginalName = "$originalName.Replay.gbx"
            NewName = $finalName
            Status = "OK"
        }
        
        $success++
        
        if ($ShowDetails) {
            Write-ColorOutput "  + $($file.Name) -> $finalName" "Gray"
        }
    } catch {
        $failed++
        
        $fileInfo += [PSCustomObject]@{
            OriginalName = "$originalName.Replay.gbx"
            NewName = "$newName.Replay.gbx"
            Status = "FAILED"
        }
        
        Write-ColorOutput "  ERROR: Failed to process: $($file.Name)" "Red"
        Write-ColorOutput "  Error: $_" "Red"
    }
    
    $processed++
    if (-not $NoProgressBar -and ($processed % $progressInterval -eq 0 -or $processed -eq $totalFiles)) {
        $percentage = [math]::Floor(($processed * 100) / $totalFiles)
        Show-ProgressBar -PercentComplete $percentage -Width $progressWidth
    }
}

$stopwatch.Stop()
$elapsedTime = $stopwatch.Elapsed
$formattedTime = "{0:mm\:ss\.fff}" -f $elapsedTime

Write-Host ""

Write-ColorOutput "=========================================================" "Cyan"
Write-ColorOutput "                        SUMMARY                          " "Cyan"
Write-ColorOutput "=========================================================" "Cyan"
Write-ColorOutput "Processing completed in $formattedTime" "Green"
Write-ColorOutput "Statistics:" "Blue"
Write-ColorOutput "   * Files processed: $totalFiles" "White"
Write-ColorOutput "   * Successful: $success" "Green"

if ($failed -gt 0) {
    Write-ColorOutput "   * Failed: $failed" "Red"
}

if ($OutDirectory) {
    Write-ColorOutput "Renamed files copied from '$Directory' to '$OutDirectory'" "Yellow"
} else {
    Write-ColorOutput "Files renamed in '$Directory'" "Yellow"
}

if ($fileInfo.Count -gt 0) {
    $exportOption = Read-Host "Do you want to export the list of processed files? (Y/N)"
    if ($exportOption -eq "Y" -or $exportOption -eq "y") {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $csvPath = Join-Path $basePath "rename_log_$timestamp.csv"
        $fileInfo | Export-Csv -Path $csvPath -NoTypeInformation -Delimiter ";" -Encoding UTF8
        Write-ColorOutput "List exported to $csvPath" "Green"
    }
}