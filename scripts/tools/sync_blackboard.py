# sync_blackboard.py
# V-Control: 2026-04-03T06:25:00Z
import sqlite3
import os
import re

DB_PATH = "nexus_blackboard.db"

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
    if "globals" in path: return "Autoload"
    if "components" in path: return "Component"
    if "systems" in path: return "System"
    if "entities" in path: return "Entity"
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
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                # Extract class_name using regex
                class_match = re.search(r"class_name\s+(\w+)", content)
                class_name = class_match.group(1) if class_match else "Anonymous"
                
                layer = get_layer(path)
                
                # Extract potential dependencies (other classes referenced)
                # This is a basic scan for capital-case class references
                deps = list(set(re.findall(r"\b[A-Z]\w+\b", content)))
                deps_json = str(deps)

                cursor.execute("""
                INSERT OR REPLACE INTO code_units (file_path, class_name, layer, content, dependencies)
                VALUES (?, ?, ?, ?, ?)
                """, (path, class_name, layer, content, deps_json))
                script_count += 1

    conn.commit()
    conn.close()
    print(f"--- PHOENIX_LOG: SYNC COMPLETE. {script_count} UNITS INDEXED. ---")

if __name__ == "__main__":
    sync()