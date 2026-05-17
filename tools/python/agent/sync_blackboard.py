# sync_blackboard.py
# V-Control: 2026-04-03T06:25:00Z
import os
import re
import sqlite3
import sys

DB_PATH = "nexus_blackboard.db"
DOCS_ROOT = os.path.join(".agent", "godot-docs-master", "godot-docs-master", "classes")

CORE_CLASSES = [
    "Node",
    "Node3D",
    "CharacterBody3D",
    "RigidBody3D",
    "StaticBody3D",
    "Area3D",
    "Camera3D",
    "RayCast3D",
    "Timer",
    "AnimationPlayer",
    "NavigationAgent3D",
    "Marker3D",
    "MeshInstance3D",
    "CollisionShape3D",
    "Input",
    "Resource",
    "SceneTree",
    "OS",
    "Engine",
    "ProjectSettings",
]


def initialize_blackboard():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS code_units (
        file_path TEXT PRIMARY KEY,
        class_name TEXT,
        layer TEXT,
        content TEXT,
        dependencies TEXT,
        verification_status TEXT DEFAULT 'PENDING'
    )
    """)
    conn.commit()
    return conn


def get_layer(path):
    if "globals" in path:
        return "Autoload"
    if "components" in path:
        return "Component"
    if "systems" in path:
        return "System"
    if "entities" in path:
        return "Entity"
    if path.endswith(".md"):
        return "KnowledgeBase"
    if "godot-docs-master" in path:
        return "EngineAPI"
    return "Other"


def sync():
    print("--- PHOENIX_LOG: SYNCING BLACKBOARD SUBSTRATE ---")
    conn = initialize_blackboard()
    cursor = conn.cursor()

    script_count = 0
    # Scan scripts directory based on Phoenix repository structure
    for root, dirs, files in os.walk("scripts"):
        for file in files:
            if file.endswith(".gd"):
                path = os.path.join(root, file)
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()

                # Extract class_name using regex
                class_match = re.search(r"class_name\s+(\w+)", content)
                class_name = class_match.group(1) if class_match else "Anonymous"

                layer = get_layer(path)

                # Extract potential dependencies (other classes referenced)
                # This is a basic scan for capital-case class references
                deps = list(set(re.findall(r"\b[A-Z]\w+\b", content)))
                deps_json = str(deps)

                cursor.execute(
                    """
                INSERT OR REPLACE INTO code_units (file_path, class_name, layer, content, dependencies)
                VALUES (?, ?, ?, ?, ?)
                """,
                    (path, class_name, layer, content, deps_json),
                )
                script_count += 1

    # Scan Obsidian vault for Markdown files
    for root, dirs, files in os.walk(".agent"):
        # Defensively exclude hidden directories (like .obsidian) from the walk
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        for file in files:
            if file.endswith(".md"):
                path = os.path.join(root, file)
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()

                # Extract file name without extension to act as the unit name
                class_name = os.path.splitext(file)[0]
                layer = get_layer(path)

                # Extract Obsidian wikilinks [[Like This]] as dependencies
                deps = list(set(re.findall(r"\[\[(.*?)\]\]", content)))
                deps_json = str(deps)

                cursor.execute(
                    """
                INSERT OR REPLACE INTO code_units (file_path, class_name, layer, content, dependencies)
                VALUES (?, ?, ?, ?, ?)
                """,
                    (path, class_name, layer, content, deps_json),
                )
                script_count += 1

    # Scan Godot Engine API Documentation
    if os.path.exists(DOCS_ROOT):
        print("--- PHOENIX_LOG: INDEXING ENGINE API (CORE CLASSES) ---")
        for cls in CORE_CLASSES:
            filename = f"class_{cls.lower()}.rst"
            path = os.path.join(DOCS_ROOT, filename)
            if os.path.exists(path):
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()

                layer = "EngineAPI"
                # For engine classes, dependencies are often other engine classes mentioned in the text
                deps = list(set(re.findall(r":ref:`class_(.*?)`", content)))
                deps_json = str(deps)

                cursor.execute(
                    """
                INSERT OR REPLACE INTO code_units (file_path, class_name, layer, content, dependencies)
                VALUES (?, ?, ?, ?, ?)
                """,
                    (path, cls, layer, content, deps_json),
                )
                script_count += 1
            else:
                # Try with underscores for camelCase names if they exist in Godot docs
                # Godot docs usually use lowercase with underscores for filenames
                pass

    conn.commit()
    conn.close()
    print(f"--- PHOENIX_LOG: SYNC COMPLETE. {script_count} UNITS INDEXED. ---")


def get_scripts_depending_on(component_name):
    """Retrieves a list of files that depend on a specific class or component."""
    if not os.path.exists(DB_PATH):
        print("Database not found. Please run a sync first.")
        return []

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute(
        """
        SELECT file_path, class_name, layer 
        FROM code_units 
        WHERE dependencies LIKE ?
    """,
        (f"%'{component_name}'%",),
    )
    results = cursor.fetchall()
    conn.close()

    if not results:
        print(f"No scripts found depending on: {component_name}")
        return []

    print(f"\n--- Scripts depending on {component_name} ---")
    for row in results:
        print(f" - {row[0]} (Class: {row[1]}, Layer: {row[2]})")
    return results


def get_autoloads():
    """Retrieves a list of all Autoloads (globals) in the database."""
    if not os.path.exists(DB_PATH):
        print("Database not found. Please run a sync first.")
        return []

    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("""
        SELECT file_path, class_name 
        FROM code_units 
        WHERE layer = 'Autoload'
    """)
    results = cursor.fetchall()
    conn.close()

    if not results:
        print("No Autoloads found in the database.")
        return []

    print("\n--- Autoloads (Globals) ---")
    for row in results:
        print(f" - {row[0]} (Class: {row[1]})")
    return results


if __name__ == "__main__":
    if len(sys.argv) > 1:
        if sys.argv[1] == "--query" and len(sys.argv) > 2:
            get_scripts_depending_on(sys.argv[2])
        elif sys.argv[1] == "--autoloads":
            get_autoloads()
        else:
            sync()
    else:
        sync()
