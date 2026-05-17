# tscn_analyzer.py
# V-Control: 2026-05-09T01:55:00Z
import os
import re

SCENE_DIR = "scenes"
OUTPUT_FILE = "context_export.txt"


def parse_tscn(file_path):
    nodes = []
    signals = []
    ext_resources = {}

    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Parse external resources (scripts, sub-scenes)
    ext_res_matches = re.finditer(
        r'\[ext_resource type="(.*?)" uid="(.*?)" path="(.*?)" id="(.*?)"\]', content
    )
    for m in ext_res_matches:
        ext_resources[m.group(4)] = {"type": m.group(1), "path": m.group(3)}

    # Parse nodes
    node_matches = re.finditer(
        r'\[node name="(.*?)"(?: type="(.*?)")?(?: parent="(.*?)")?(?: groups=\[(.*?)\])?\](?:.*?script = ExtResource\("(.*?)"\))?',
        content,
        re.DOTALL,
    )
    for m in node_matches:
        name = m.group(1)
        node_type = m.group(2) or "Unknown"
        parent = m.group(3) or "."
        groups = m.group(4) or ""
        script_id = m.group(5)

        script_path = (
            ext_resources.get(script_id, {}).get("path", "") if script_id else ""
        )

        nodes.append(
            {
                "name": name,
                "type": node_type,
                "parent": parent,
                "groups": groups,
                "script": script_path,
            }
        )

    # Parse signals
    signal_matches = re.finditer(
        r'\[connection signal="(.*?)" from="(.*?)" to="(.*?)" method="(.*?)"\]', content
    )
    for m in signal_matches:
        signals.append(f"{m.group(2)}.{m.group(1)} -> {m.group(3)}.{m.group(4)}")

    return nodes, signals


def build_tree(nodes):
    tree = {}
    for node in nodes:
        parent = node["parent"]
        if parent not in tree:
            tree[parent] = []
        tree[parent].append(node)

    def render_node(name, indent=0):
        lines = []
        node_info = next((n for n in nodes if n["name"] == name), None)
        if node_info:
            script_tag = (
                f" [Script: {node_info['script']}]" if node_info["script"] else ""
            )
            group_tag = (
                f" (Groups: {node_info['groups']})" if node_info["groups"] else ""
            )
            lines.append(
                "  " * indent + f"┕ {name} ({node_info['type']}){script_tag}{group_tag}"
            )

        # Handle the root case where parent is "."
        if name == ".":
            # Filter nodes with no parent or parent="."
            root_nodes = [n for n in nodes if n["parent"] == "."]
            for rn in root_nodes:
                lines.extend(render_node(rn["name"], indent))
        else:
            # Godot 4 parent paths are relative to the scene root or absolute paths like "Root/Child"
            # For simplicity, we just look for children whose parent is the current node name
            for child in [n for n in nodes if n["parent"] == name]:
                lines.extend(render_node(child["name"], indent + 1))
        return lines

    # Find the root (usually the node with parent=".")
    root_node = next((n for n in nodes if n["parent"] == "."), None)
    if not root_node:
        return ["No root found"]

    return render_node(root_node["name"])


def run_analysis():
    print("--- PHOENIX_LOG: INITIATING VISUAL CORTEX SCAN ---")
    all_scene_data = []

    for root, dirs, files in os.walk(SCENE_DIR):
        for file in files:
            if file.endswith(".tscn"):
                path = os.path.join(root, file)
                print(f"Analyzing: {path}")
                nodes, signals = parse_tscn(path)
                tree_lines = build_tree(nodes)

                scene_block = [f"\n--- SCENE: {path} ---"]
                scene_block.extend(tree_lines)
                if signals:
                    scene_block.append("\n  [Signals]")
                    for sig in signals:
                        scene_block.append(f"    {sig}")

                all_scene_data.append("\n".join(scene_block))

    # Append to context_export.txt or create if missing
    with open(OUTPUT_FILE, "a", encoding="utf-8") as f:
        f.write("\n\n--- VISUAL CORTEX: SCENE HIERARCHIES ---\n")
        f.write("\n".join(all_scene_data))

    print(f"--- PHOENIX_LOG: SCAN COMPLETE. UPDATED {OUTPUT_FILE} ---")


if __name__ == "__main__":
    run_analysis()
