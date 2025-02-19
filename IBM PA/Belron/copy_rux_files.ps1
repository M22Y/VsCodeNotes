# Define the source and destination folders
$sourceFolder = "Original"
$destinationFolder = "New"
$oldFolder = Join-Path -Path $destinationFolder -ChildPath "old"

# Ensure the destination and old folders exist
if (-not (Test-Path -Path $destinationFolder)) {
    New-Item -Path $destinationFolder -ItemType Directory
}
if (-not (Test-Path -Path $oldFolder)) {
    New-Item -Path $oldFolder -ItemType Directory
}

# Get all files with the .rux extension from the source folder
$ruxFiles = Get-ChildItem -Path $sourceFolder -Filter *.rux

# Copy each .rux file to the destination folder
foreach ($file in $ruxFiles) {
    $destinationFile = Join-Path -Path $destinationFolder -ChildPath $file.Name
    if (Test-Path -Path $destinationFile) {
        Move-Item -Path $destinationFile -Destination $oldFolder -Force
    }
    Copy-Item -Path $file.FullName -Destination $destinationFolder -Force
}