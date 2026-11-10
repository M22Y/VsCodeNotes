# VsCodeNotes Project Instructions

This workspace contains IBM Planning Analytics (TM1) and CCH TAGETIK financial analytics assets, including SQL, rules, processes, and documentation.

Treat these workspace instructions as required for every task. Before answering or editing, identify and follow the relevant section; do not skip applicable guidance.

## TAGETIK

- **Before any TAGETIK answer or change, consult the knowledge base**: [TAGETIK/Knowledge base/](../TAGETIK/Knowledge%20base/). Search the relevant manuals, data-model references, API documentation, and examples before relying on assumptions.
- Apply knowledge-base guidance to the actual workspace files and patterns. When sources disagree or do not cover a case, inspect nearby TAGETIK examples and clearly state uncertainty.
- Preserve existing SQL dialect, Tagetik placeholders/formulas, dimension codes, and naming conventions. Validate query syntax against the target Tagetik tool where possible; SQL functions can vary by query context.
- TAGETIK files are grouped by client or subject under `TAGETIK/`; keep changes within the relevant area.

## IBM Planning Analytics

- TM1 rules use `.rux` files and processes use `.proc` files. Follow nearby files for syntax and conventions.
- When tracing calculations or dependencies, inspect `DB()` references, `SKIPCHECK`, `FEEDERS`, and related cube rules. Do not infer behavior from one directive alone.
- Keep changes scoped to the relevant environment and preserve historical comments unless they are being updated as part of the task.

## General

- Read relevant files and examples before changing them; make focused changes and preserve existing behavior.
- Use the repository’s established naming and formatting, including its French/English terminology.
- Run the smallest relevant validation available and report anything that could not be verified.
