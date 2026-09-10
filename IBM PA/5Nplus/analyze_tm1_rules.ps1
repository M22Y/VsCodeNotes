# Define the folder path
$folderPath = Join-Path -Path $PSScriptRoot -ChildPath "Rules"
$outputFilePath = "DataFlow.txt"
$dotFilePath = "./DataFlow.dot"
$imageFilePath = "DataFlow.jpg"
$graphvizPath = "C:\tools\Graphviz\bin\dot.exe"

# Get all files in the folder
$files = Get-ChildItem -Path $folderPath -Filter *.rux

# Function to extract and analyze TM1 rules for Rolling_Fct_Adj
function Analyze-TM1Rules {
    param (
        [string]$filePath
    )

    $rules = Get-Content -Path $filePath
    $dataFlow = @()
    $dotEdges = New-Object System.Collections.Generic.HashSet[string]
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)

    foreach ($line in $rules) {
        if ($line -match "^\s*SKIPCHECK\s*$") {
            $dataFlow += "SKIPCHECK found in $filePath"
        } elseif ($line -match "^\s*FEEDERS\s*$") {
            $dataFlow += "FEEDERS found in $filePath"
        } elseif ($line -match "^\s*#") {
            # Skip comments
            continue
        } elseif ($line -match "^\s*\[.*Rolling_Fct_Adj.*\]\s*=\s*.*;") {
            $dataFlow += "Calculation Rule for Rolling_Fct_Adj: $line"
            if ($line -match "DB\(") {
                $sourceFile = $line -replace '.*DB\(\s*["'']([^"'']+)["''].*', '$1'
                $sourceFile = [System.IO.Path]::GetFileNameWithoutExtension($sourceFile)
                $dotEdges.Add("`"$sourceFile`" -> `"$fileName`";")
            }
        }
    }

    return [PSCustomObject]@{
        DataFlow = $dataFlow
        DotEdges = $dotEdges
    }
}

# Analyze each file and collect data flow information for Rolling_Fct_Adj
$dataFlows = @()
$dotEdges = New-Object System.Collections.Generic.HashSet[string]
foreach ($file in $files) {
    $result = Analyze-TM1Rules -filePath $file.FullName
    $dataFlows += "File: $($file.Name)"
    $dataFlows += "===================="
    $dataFlows += $result.DataFlow
    $dataFlows += ""
    $dotEdges.UnionWith($result.DotEdges)
}

# Write the data flow summary to a text file
$dataFlows | Out-File -FilePath $outputFilePath -Encoding UTF8

# Generate DOT file for Graphviz without BOM
$dotContent = @"
digraph TM1_DataFlow {
    node [shape=box];
    $($dotEdges -join "`n")
}
"@
[System.IO.File]::WriteAllText($dotFilePath, $dotContent)

# Generate JPEG image using Graphviz
Start-Process -FilePath $graphvizPath -ArgumentList "-Tjpg", $dotFilePath, "-o", $imageFilePath -NoNewWindow -Wait

# Output a message indicating the results have been written
Write-Output "Data flow summary for Rolling_Fct_Adj has been written to $outputFilePath"
Write-Output "Data flow diagram for Rolling_Fct_Adj has been generated as $imageFilePath"