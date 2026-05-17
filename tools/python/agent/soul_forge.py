import argparse
import os
import re

# PHOENIX: SOUL FORGE (v1.0)
# Scaffolding and Refactoring tool for Sovereign Components


def refactor_backing_field(file_path, variable_name):
    """Converts a variable into a property with a backing field (SKILL-001)."""
    if not os.path.exists(file_path):
        print(f"Error: File {file_path} not found.")
        return

    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    new_lines = []
    found = False
    for line in lines:
        # Match '@export var name: type' or 'var name' at class level (no indent)
        match = re.match(
            rf"^(@export(?:_range|_enum|_flags)?\s+)?var\s+{variable_name}(\s*:\s*[\w\.]+)?(\s*=.*)?$",
            line.strip("\n"),
        )
        if match and not found:
            export_prefix = match.group(1).strip() + " " if match.group(1) else ""
            var_type = match.group(2) if match.group(2) else ""
            default_val = match.group(3) if match.group(3) else ""

            # Create private backing field and public property
            new_lines.append(f"var _{variable_name}{var_type}{default_val}\n")
            new_lines.append(f"{export_prefix}var {variable_name}{var_type}:\n")
            new_lines.append(f"\tget: return _{variable_name}\n")
            new_lines.append("\tset(v):\n")
            new_lines.append(f"\t\t_{variable_name} = v\n")
            found = True
        else:
            new_lines.append(line)

    if found:
        with open(file_path, "w", encoding="utf-8") as f:
            f.writelines(new_lines)
        print(
            f"--- PHOENIX_LOG: SANCTIFIED {variable_name} in {file_path} (SKILL-001 applied) ---"
        )
    else:
        print(f"Could not find variable '{variable_name}' in {file_path}")


def refactor_named_callback(file_path, line_number):
    """Converts an anonymous lambda in a .connect() call to a named method (SKILL-005)."""
    if not os.path.exists(file_path):
        print(f"Error: File {file_path} not found.")
        return

    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    if line_number > len(lines):
        print(f"Error: Line {line_number} exceeds file length.")
        return

    line = lines[line_number - 1]
    # Match signal.connect(func(...) or signal.connect(func(args): body)
    # Pattern: func(args): [optional space] body
    match = re.search(r"func\((.*?)\):\s*(.*)(?=\))", line)
    if not match:
        print(f"Could not parse lambda at {file_path}:{line_number}")
        return

    args = match.group(1)
    body = match.group(2).strip()
    lambda_full_text = match.group(0)

    # Extract signal name from the line (text before .connect)
    signal_match = re.search(r"(\w+)\.connect", line)
    signal_name = signal_match.group(1) if signal_match else "signal"

    method_name = f"_on_{signal_name}_triggered"

    # 1. Replace the exact lambda text
    lines[line_number - 1] = line.replace(lambda_full_text, method_name)

    # 2. Append the new method at the end of the file
    lines.append("\n")
    lines.append(f"func {method_name}({args}):\n")
    lines.append(f"\t{body}\n")

    with open(file_path, "w", encoding="utf-8") as f:
        f.writelines(lines)

    print(
        f"--- PHOENIX_LOG: DECOUPLED lambda at {file_path}:{line_number} -> {method_name} (SKILL-005 applied) ---"
    )


def scaffold_state(name):
    """Creates a new Player State following SKILL-008."""
    template = f"""extends State
# {name}State.gd (SKILL-008 Phoenix-Pure)

var _timer: float = 0.0
var _buffer: bool = False

func enter(_msg: Dictionary = {{}}) -> void:
    _timer = 0.5 # Default duration
    _buffer = false

func physics_update(delta: float) -> void:
    _timer -= delta
    
    if Input.is_action_just_pressed(&"attack"):
        _buffer = true
        
    if _timer <= 0:
        if _buffer:
            # Handle combo/loop logic here
            _timer = 0.5
            _buffer = false
        else:
            transitioned.emit(ID.IDLE)
"""
    file_path = f"scripts/entities/player/states/COMM.Avatar.State.{name}.gd"
    if os.path.exists(file_path):
        print(f"Error: State {name} already exists.")
        return

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(template)
    print(
        f"--- PHOENIX_LOG: FORGED STATE {name} at {file_path} (SKILL-008 applied) ---"
    )


def scaffold_component(name, type="Node"):
    """Creates a new Sovereign Component (SOVEREIGN-001)."""
    template = f"""extends {type}
# {name}Component.gd (Sovereign Component v1.0)

@export var _director: Node # Dependency Injection

func _ready() -> void:
    if not _director:
        printerr("[{name}] Orphaned Component! Director not injected.")

func execute() -> void:
    pass
"""
    file_path = f"scripts/components/FABRIC.Comp.{name}.gd"
    if os.path.exists(file_path):
        print(f"Error: Component {name} already exists.")
        return

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(template)
    print(
        f"--- PHOENIX_LOG: FORGED COMPONENT {name} at {file_path} (SOVEREIGN-001 applied) ---"
    )


def auto_standardize(directory="scripts/"):
    """Applies Phoenix Class formatting standards to all files in the directory."""
    print(f"--- PHOENIX_LOG: INITIATING AUTO-STANDARDIZATION in {directory} ---")
    count = 0
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".gd"):
                path = os.path.join(root, file)
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()
                
                modified = False
                # 1. Purge Tabs
                if "\t" in content:
                    content = content.replace("\t", "    ")
                    modified = True
                
                # 2. Add return types for simple functions
                if "func _ready()" in content and "-> void" not in content:
                    content = content.replace("func _ready()", "func _ready() -> void")
                    modified = True
                
                if "func _physics_process(delta)" in content and "-> void" not in content:
                    content = content.replace("func _physics_process(delta)", "func _physics_process(delta: float) -> void")
                    modified = True
                
                if modified:
                    with open(path, "w", encoding="utf-8") as f:
                        f.write(content)
                    print(f"--- PHOENIX_LOG: SANCTIFIED {path} ---")
                    count += 1
    print(f"--- PHOENIX_LOG: COMPLETED. {count} files standardized. ---")


def main():
    parser = argparse.ArgumentParser(description="PHOENIX: Soul Forge Scaffolding Tool")
    subparsers = parser.add_subparsers(dest="command")

    # Command: backing-field
    bf_parser = subparsers.add_parser(
        "backing-field", help="Convert variable to property+backing field"
    )
    bf_parser.add_argument("file", help="Path to the GDScript file")
    bf_parser.add_argument("var", help="Variable name to refactor")

    # Command: named-callback
    nc_parser = subparsers.add_parser(
        "named-callback", help="Convert lambda to named method"
    )
    nc_parser.add_argument("file", help="Path to the GDScript file")
    nc_parser.add_argument("line", type=int, help="Line number of the connect() call")

    # Command: scaffold-state
    ss_parser = subparsers.add_parser(
        "scaffold-state", help="Create a new player state"
    )
    ss_parser.add_argument("name", help="Name of the state (e.g. Attack)")

    # Command: scaffold-component
    sc_parser = subparsers.add_parser(
        "scaffold-component", help="Create a new Sovereign Component"
    )
    sc_parser.add_argument("name", help="Name of the component (e.g. Health)")
    sc_parser.add_argument("--type", default="Node", help="Base type of the component")

    # Command: auto-standardize
    as_parser = subparsers.add_parser(
        "auto-standardize", help="Applies Phoenix Class formatting standards"
    )
    as_parser.add_argument("--dir", default="scripts/", help="Directory to process")

    args = parser.parse_args()

    if args.command == "backing-field":
        refactor_backing_field(args.file, args.var)
    elif args.command == "named-callback":
        refactor_named_callback(args.file, args.line)
    elif args.command == "scaffold-state":
        scaffold_state(args.name)
    elif args.command == "scaffold-component":
        scaffold_component(args.name, args.type)
    elif args.command == "auto-standardize":
        auto_standardize(args.dir)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
