# Step 1: Extract Dependencies
$logFile = "cube_dependency.log"
$dotFile = "cube_dependencies.dot"
$jpegFile = "cube_dependencies.jpg"
$graphvizBinPath = "C:\tools\graphviz\bin"

$allowedCubes = @(
    "08_SalesCOS_B2B_WH_by_Customer","08_SalesCOS_Assump_by_Customer_Insur","09_SalesCOS_by_Customer", "111_SalesCOS_ADAS", "10_SalesCOS", "11_SalesCOS_NonPrime", "12_Sales&Marketing",
    "13_Internal_Transfer", "20_OtherGL", "30_Manning_by_Employee", "32_Manning_Assump",
    "33_Manning_Time_Available", "34_Manning_Time_Needed", "35_Manning_Output_FTE",
    "56_Capex_Dep", "57_Capex_Dep_Items", "60_DailySales_Stats_Std", "60_DailySales_Stats_Std_Vanfax",
    "67_DailySales_Stats_Std", "68_DailySales_GL_Std", "70_Split_Bud_WSB", "85_ETL_Stats",
    "85a_ETL_Stats", "86_ETL_GL", "86a_ETL_GL", "94_Holiday", "97_Daily_Sales_Actual_Flags"
)

$dependencies = @()

Get-Content $logFile | ForEach-Object {
    if ($_ -match "Adding cube dependency: Cube '(.+?)' depends on cube '(.+?)'") {
        $dependentCube = $matches[1]
        $dependencyCube = $matches[2]
        if ($allowedCubes -contains $dependentCube -and $allowedCubes -contains $dependencyCube) {
            $dependencies += [PSCustomObject]@{
                DependentCube = $dependentCube
                DependencyCube = $dependencyCube
            }
        }
    }
}

# Step 2: Generate DOT File
$dotContent = "digraph CubeDependencies {`n"
$dependencies | ForEach-Object {
    $dotContent += "    `"$($_.DependentCube)`" -> `"$($_.DependencyCube)`";`n"
}
$dotContent += "}`n"

Set-Content -Path $dotFile -Value $dotContent

# Step 3: Generate JPEG Image
Start-Process -FilePath "$graphvizBinPath\dot.exe" -ArgumentList "-Tjpg", $dotFile, "-o", $jpegFile -NoNewWindow -Wait