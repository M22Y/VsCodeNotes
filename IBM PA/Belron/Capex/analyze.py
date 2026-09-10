from pathlib import Path
import re
import subprocess
import sys
import argparse


def analyze_tm1_rules(file_path: Path):
    text = file_path.read_text(encoding="utf-8", errors="ignore")
    lines = text.splitlines()
    file_name = file_path.stem
    metadata = {}

    rules = []

    for i, line in enumerate(lines, start=1):
        if re.match(r"^\s*#", line):
            continue

        # detect feeders or DB references
        feeders = '=>' in line
        db_matches = list(re.finditer(r"DB\(\s*[\'\"]([^\'\"]+)[\'\"]", line))
        sources = [Path(m.group(1)).stem for m in db_matches]

        # try to find a target cube or rule left-hand side like [CubeName ...] = ...;
        target_match = re.search(r"\[\s*([^\]]+?)\s*\]\s*=", line)
        targets = [target_match.group(1).strip()] if target_match else []

        has_actual = bool(re.search(r"\bActual\b", line, re.IGNORECASE))

        # capture attributes when 55_Capex_Items referenced
        if any('55_Capex_Items' in (m.group(1) or '') for m in db_matches):
            args = re.findall(r"[\'\"]([^\'\"]+)[\'\"]", line)
            try:
                idx = args.index('55_Capex_Items')
            except ValueError:
                idx = -1
            if idx >= 0 and idx + 1 < len(args):
                metadata.setdefault('55_Capex_Items_attrs', set()).add(args[idx + 1])

        if feeders or db_matches or targets:
            rules.append({
                'file': file_name,
                'line_no': i,
                'text': line.strip(),
                'sources': sources,
                'targets': targets,
                'feeders': feeders,
                'has_actual': has_actual,
            })

    return rules, metadata


def main():
    parser = argparse.ArgumentParser(description="Analyze TM1 .rux files for Rolling_Fct_Adj dataflow")
    parser.add_argument("--folder", "-f", help="Folder to scan for .rux files. Defaults to script dir/New or script dir.")
    parser.add_argument("--graphviz", "-g", default=r"C:\\tools\\Graphviz\\bin\\dot.exe", help="Path to Graphviz dot executable")
    parser.add_argument("--output", "-o", default="DataFlow.txt", help="Output text file")
    parser.add_argument("--dot", default="DataFlow.dot", help="Output DOT file")
    parser.add_argument("--image", "-i", default="DataFlow.jpg", help="Output image file")
    args = parser.parse_args()

    script_dir = Path(__file__).parent.resolve()
    if args.folder:
        folder = Path(args.folder).expanduser().resolve()
    else:
        cand = script_dir / "New"
        folder = cand if cand.exists() and cand.is_dir() else script_dir

    # include all .rux files recursively in the folder (includes files like 86_ETL_GL.rux)
    rux_files = sorted(folder.rglob("*.rux"))
    if not rux_files:
        print(f"No .rux files found in {folder}")
        sys.exit(0)

    all_data = []
    all_edges = set()

    metadata_all = {}
    all_rules = []
    for f in rux_files:
        rules, metadata = analyze_tm1_rules(f)
        all_rules.extend(rules)
        # produce a compact textual section per file
        all_data.append(f"File: {f.name}")
        all_data.append("====================")
        if not rules:
            all_data.append("(no matches)")
        else:
            for r in rules:
                all_data.append(f"L{r['line_no']}: {r['text']}")
                if r['sources']:
                    all_data.append(f"  sources: {', '.join(r['sources'])}")
                if r['targets']:
                    all_data.append(f"  targets: {', '.join(r['targets'])}")
                if r['feeders']:
                    all_data.append("  method: FEEDERS")
                all_data.append("")
        # merge metadata
        for k, v in metadata.items():
            metadata_all.setdefault(k, set()).update(v)

    # append metadata information to the text output
    if metadata_all:
        all_data.append("Metadata summary:")
        for k, vals in metadata_all.items():
            all_data.append(f"{k}:")
            for v in sorted(vals):
                all_data.append(f"  - {v}")
            all_data.append("")

    Path(args.output).write_text("\n".join(all_data), encoding="utf-8")

    # Build graphs for Non-Actual and Actual
    def build_graph(rules_list, dot_path, image_path):
        nodes = {}
        edges = []
        # nodes: name -> type ('cube'|'rule')
        def normalize_target_name(t, file_cube):
            # if target looks like an element set or contains braces/commas/!' or quotes,
            # treat it as elements of the file's cube and aggregate to the cube name
            if re.search(r"[\{\},!\s'\"]", t):
                return file_cube
            return t
        for r in rules_list:
            rule_id = f"rule_{r['file']}_{r['line_no']}"
            nodes[rule_id] = 'rule'
            # add source cube nodes
            for s in r['sources']:
                nodes[s] = 'cube'
                edges.append((s, rule_id, 'DB'))
            # feeders: if feeders present and no DB sources, create a generic source node as the file cube
            if r['feeders'] and not r['sources']:
                src = r['file']
                nodes[src] = 'cube'
                edges.append((src, rule_id, 'FEEDERS'))
            # add targets (normalize element-set targets to the file's cube to avoid
            # stretching every account/element into separate nodes)
            for t in r['targets']:
                norm_t = normalize_target_name(t, r['file'])
                nodes[norm_t] = 'cube'
                edges.append((rule_id, norm_t, 'ASSIGN'))

        dot_lines = ["digraph DataFlow {", "    rankdir=LR;", "    node [fontname=Arial];"]
        # emit cube nodes
        for n, typ in nodes.items():
            if typ == 'cube':
                dot_lines.append(f'    "{n}" [shape=box, style=filled, fillcolor=lightblue];')
        # emit rule nodes
        for n, typ in nodes.items():
            if typ == 'rule':
                label = n.replace('rule_', 'rule:')
                dot_lines.append(f'    "{n}" [shape=oval, style=filled, fillcolor=lightgoldenrod, label="{label}"];')

        # emit edges with labels
        for a, b, lbl in edges:
            dot_lines.append(f'    "{a}" -> "{b}" [label="{lbl}"];')

        dot_lines.append("}")
        Path(dot_path).write_text("\n".join(dot_lines), encoding="utf-8")
        try:
            subprocess.run([args.graphviz, "-Tjpg", dot_path, "-o", image_path], check=True)
            return True
        except Exception:
            return False

    non_actual_rules = [r for r in all_rules if not r['has_actual']]
    actual_rules = [r for r in all_rules if r['has_actual']]

    # primary dot for non-actual (default)
    non_actual_dot = args.dot.replace('.dot', '_nonActual.dot')
    non_actual_img = args.image.replace('.jpg', '_nonActual.jpg')
    ok1 = build_graph(non_actual_rules, non_actual_dot, non_actual_img)

    # actual dot
    actual_dot = args.dot.replace('.dot', '_Actual.dot')
    actual_img = args.image.replace('.jpg', '_Actual.jpg')
    ok2 = build_graph(actual_rules, actual_dot, actual_img)

    # also write a combined DOT that includes both sets for reference
    combined_dot = args.dot
    combined_img = args.image
    ok3 = build_graph(all_rules, combined_dot, combined_img)

    Path(args.output).write_text("\n".join(all_data), encoding="utf-8")

    print(f"Data flow summary written to {args.output}")
    if ok3:
        print(f"Combined diagram generated as {combined_img}")
    else:
        print(f"Combined DOT written to {combined_dot} (Graphviz unavailable or failed)")
    if ok1:
        print(f"Non-Actual diagram generated as {non_actual_img}")
    else:
        print(f"Non-Actual DOT written to {non_actual_dot} (Graphviz unavailable or failed)")
    if ok2:
        print(f"Actual diagram generated as {actual_img}")
    else:
        print(f"Actual DOT written to {actual_dot} (Graphviz unavailable or failed)")


if __name__ == "__main__":
    main()
