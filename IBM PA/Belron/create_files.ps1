# Define the path to the text file containing the list of file names

# DISABLING THIS LINE TO AVOID ERRORS
# $fileListPath = "list.txt"

# Define the subfolders
# $subFolders = @("Original", "New")
$subFolders = @("Original")

# Ensure the subfolders exist
foreach ($folder in $subFolders) {
    if (-not (Test-Path -Path $folder)) {
        New-Item -Path $folder -ItemType Directory
    }
}

# Read all lines from the text file
$fileNames = Get-Content -Path $fileListPath

# Loop through each file name and create an empty file in both subfolders
foreach ($fileName in $fileNames) {
    foreach ($folder in $subFolders) {
        $filePath = Join-Path -Path $folder -ChildPath $fileName
        New-Item -Path $filePath -ItemType File -Force
    }
}