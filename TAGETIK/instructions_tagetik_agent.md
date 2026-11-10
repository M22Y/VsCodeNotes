# Copilot Instructions for VsCodeNotes

## Repository Overview
This is a financial analytics and data consolidation workspace containing code, configurations, and documentation for:
- **IBM Planning Analytics (PA/TM1)**: Budgeting and forecasting for Belron (car glass repair)
- **CCH TAGETIK**: Financial consolidation platform with SQL-based data integration
- Scripts and queries for ETL, data transformation, and analytical reporting

## Critical Architecture Patterns

### 1. IBM PA Belron Environment
**Location**: `IBM PA/Belron/`

- **RUX Files** (.rux): TM1 rules files defining calculations for cubes
  - `20_OtherGL.rux`: Core General Ledger cube with rolling forecast adjustments
  - `56.rux`, `57.rux`: Referenced source cubes for Capex and other GL items
  - Key pattern: Rules contain `SKIPCHECK;`, `FEEDSTRINGS;` sections and `FEEDERS` for data flow tracking
  - Scenario structure: Actual, Budget_Final, Budget, Rolling_Forecast, Forecast, Forecast_Final, Rolling_Fct_Adj

- **PROC Files** (.proc): TM1 process templates for data transformation
  - `Trsf_All_version_to_Rolling_Fct_Adj(Bud Cubes)_Loop.proc`: Version transformation workflow
  - Use these as templates; they contain loop logic for cube operations

- **PowerShell Automation** (.ps1):
  - `analyze_tm1_rules.ps1`: Parses RUX files to extract data flow and generate Graphviz diagrams
  - `dependencies.ps1`: Maps cube dependencies
  - Pattern: Parse SKIPCHECK, FEEDERS, and DB() references to understand data lineage

### 2. TAGETIK SQL Integration
**Location**: `TAGETIK/` with subdirectories: HRN/, LaCaisse/, PCC/, QSL/

- **Data Flow**: Sources (JDE, DataHub, Excel) → SQL transformations → TAGETIK module import
- **Key Concepts**:
  - **Vue 1.1**: Cumulative balances (P&L, balance sheet) + volumes
  - **Vue 1.2**: Monthly statistics (volumes, CPL by business unit, department, product)
  - **Vue 2**: Intercompany data
  - **Vue 3**: Detailed transactions
  - Dimensions are dynamically generated from: Scenario, Period, Entity, Account, Product, Department/Customer Type

- **SQL Patterns** (see QSL/, PCC/ subdirectories):
  - Common CTEs: PERIOD_FILTER, resource hierarchies (ED_RESOURCE_GERARCHIA_FLAT)
  - Filtering logic: Scenario codes containing 'BDG' (Budget) or 'FCT' (Forecast)
  - Origin validation: TEXT_ORIGIN checks for data source (e.g., 'AW004_INPUT_DE050')
  - Reconciliation: IFERROR patterns for balance validation

- **TGKML Formulas**: Custom TAGETIK expressions for period/scenario lookup
  - Pattern: `A:=IF($PERIOD.code=="03","03",...)` for period-based logic
  - Uses code() function for quarter extraction, select() for dimension filtering

## Key File Examples

| File | Purpose | Key Pattern |
|------|---------|------------|
| [20_OtherGL.rux](IBM%20PA/Belron/20_OtherGL.rux#L23) | GL cube rules | STET (Statement Rules), Rolling_Fct_Adj calculation baseline |
| [analyze_tm1_rules.ps1](IBM%20PA/Belron/analyze_tm1_rules.ps1#L25) | RUX analysis | Extract DB() refs and FEEDERS to map data flow |
| [QSL/SM050.sql](TAGETIK/QSL/SM050.sql) | Stevedoring cost allocations | CASE logic, IFERROR, COUNTIF validation |
| [HRN/BRD Flux de données.md](TAGETIK/HRN/BRD%20Flux%20de%20données.md) | Data architecture | Vue definitions and dimension mapping |

## Common Workflows

### Understanding Data Lineage
1. For TM1/PA: Parse .rux files → look for `DB()` function calls and FEEDERS sections
2. For TAGETIK: Trace SQL from table names (raccolta_prospetto_controllo, ED_RESOURCE_GERARCHIA_FLAT) backwards through CTEs
3. Use PowerShell scripts to auto-generate dependency diagrams

### Scenario Naming Conventions
- Budgets: contain "BDG" or "Budget" in code
- Forecasts: contain "FCT", "Forecast", "Rolling_Forecast"
- Example: `Budget_Final`, `Rolling_Fct_Adj`, `Forecast_Final`

### Version Management
- Multiple "Original - Dev" and "Original - Prod" folders track different deployment states
- "NEW" file prefixes indicate unreleased changes
- Date stamps in filenames (e.g., 20250308) track versions by deployment date

## Development Conventions

- **Comments**: Historical notes embedded in files (see RUX headers for change logs with dates and names)
- **Naming**: French and English mixed (Flux = Flow, Prospetto = Report View)
- **File Organization**: Group related artifacts (e.g., all QSL queries for one subject matter area together)
- **Graphviz Outputs**: .dot files used to visualize data dependencies as .jpg diagrams

## Integration Points

- **External Systems**: JDE (financial data), DataHub (consolidated source), HANA (reporting)
- **Manual Entry**: TAGETIK forms accept manual intercompany declarations and supplementary GL entries
- **Validation Logic**: Frequent use of COUNTIF and reconciliation checks (sums must match, resources must exist)

---

## When Analyzing New Code
1. Check for scenario/period/entity filtering patterns (ubiquitous in TAGETIK SQL)
2. Look for SKIPCHECK in RUX (indicates no validation on calculations)
3. Trace DB() references in RUX rules to find cube dependencies
4. For SQL, identify if using Vue 1.1 (cumulative) vs 1.2 (monthly) logic
5. Check file naming: "Rolling_Fct_Adj" is a critical aggregated scenario combining months 2-12 with month 1 baseline
