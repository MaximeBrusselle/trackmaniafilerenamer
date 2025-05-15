param(
    [Parameter(Mandatory=$true)]
    [string]$Directory,
    
    [Parameter(Mandatory=$false)]
    [string]$OutDirectory
)


# Check if input directory exists
if (-not (Test-Path -LiteralPath $Directory)) {
    Write-Error "The directory $Directory does not exist."
    exit 1
}

# Create output directory if it doesn't exist
if (-not [string]::IsNullOrWhiteSpace($OutDirectory) -and -not (Test-Path -LiteralPath $OutDirectory)) {
    New-Item -ItemType Directory -Force -Path $OutDirectory | Out-Null
}

# Get all replay files
$files = Get-ChildItem -LiteralPath $Directory -Filter "*.Replay.gbx"
$totalFiles = $files.Count
$processed = 0
$progressInterval = [math]::Max(1, [math]::Floor($totalFiles / 10))

foreach ($file in $files) {
    $baseName = $file.Name -replace '\.Replay\.gbx$', ''
    
    $newName = $baseName -replace ' ', '_'
    
    $newName = $newName -replace '\$[ghijkmnopqrstuvwxyzGHIJKMNOPQRSTUVWXYZ]', ''
    $newName = $newName -replace '\$[lL]\[.*?\]', ''
    $newName = $newName -replace '\$l', ''
    $newName = $newName -replace '\$[0-9a-zA-Z_]{3}', ''
    $newName = $newName -replace '\$\$', '$'
    $newName = $newName -replace '_{2,}', '_'
    
    if ([string]::IsNullOrWhiteSpace($newName)) {
        $newName = "unnamed_replay"
    }
    
    # Show progress
    $processed++
    if ($totalFiles -gt 10 -and $processed % $progressInterval -eq 0) {
        $percentage = [math]::Floor(($processed * 100) / $totalFiles)
        Write-Host "Processed $percentage% of files."
    }
    
    # Handle file operations with error handling
    try {
        $index = 1
        $basePath = if ($OutDirectory) { $OutDirectory } else { $Directory }
        $operation = if ($OutDirectory) { "Copy-Item" } else { "Move-Item" }

        $destinationPath = Join-Path $basePath "$newName.Replay.gbx"
        while (Test-Path -LiteralPath $destinationPath) {
            $destinationPath = Join-Path $basePath "$newName`_$index.Replay.gbx"
            $index++
        }

        & $operation -LiteralPath $file.FullName -Destination $destinationPath -ErrorAction Stop
    } catch {
        Write-Warning "Failed to process file: $($file.Name)"
        Write-Warning "Error: $_"
        continue
    }
}

# Print success message
if ($OutDirectory) {
    Write-Host "Successfully renamed all files from $Directory and saved them to $OutDirectory"
} else {
    Write-Host "Successfully renamed all files from $Directory"
} 