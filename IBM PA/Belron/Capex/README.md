Analyze TM1 rules and generate a dataflow diagram

Usage

- Ensure Python 3.14 is installed at `C:\tools\Python` (or adjust PATH)
- The script analyses rules for Rolling_Fct_Adj, Budget and Forecast-related patterns and extracts relationships between TM1 cubes based on `DB()` references.
- Install nothing else is required (uses only stdlib)

Run from the `Capex` folder:

```powershell
C:\tools\Python\python.exe analyze.py
```

Optional arguments:
- `-f, --folder` : folder to scan for `.rux` files (defaults to `./New` if present, otherwise script dir)
- `-g, --graphviz`: path to `dot.exe` (default `C:\tools\Graphviz\bin\dot.exe`)
- `-o, --output`: output text file (default `DataFlow.txt`)
- `--dot`: output DOT file (default `DataFlow.dot`)
- `-i, --image`: output image file (default `DataFlow.jpg`)

Example with explicit Graphviz:

```powershell
C:\tools\Python\python.exe analyze.py -f . -g "C:\tools\Graphviz\bin\dot.exe"
```

If Graphviz is not available the script will still write the DOT file.
