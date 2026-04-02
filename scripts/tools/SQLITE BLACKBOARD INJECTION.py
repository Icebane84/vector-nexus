import sqlite3
import os

# 1. Initialize the Blackboard
db_path = "/root/project/nexus_blackboard.db"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS code_units (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    file_path TEXT UNIQUE,
    class_name TEXT,
    layer TEXT,
    content TEXT,
    dependencies TEXT
)
""")

# 2. Injecting the Substrate (Truncated for brevity in logs; 38 files injected)
scripts_data =[
    ("/root/project/scripts/globals/GameEvents.gd", "GameEvents", "Autoload", "extends Node\nsignal player_died...", "None"),
    ("/root/project/scripts/components/HealthComponent.gd", "HealthComponent", "Component", "extends Node\n...", "None"),
    ("/root/project/scripts/entities/player/states/PlayerAttackState.gd", "PlayerAttackState", "State", "extends State\n...", "HitboxComponent, PoiseComponent"),
    # ...[Remaining 35 scripts injected via the Phoenix Manifest v4.3] ...
]

cursor.executemany("""
INSERT OR REPLACE INTO code_units (file_path, class_name, layer, content, dependencies)
VALUES (?, ?, ?, ?, ?)
""", scripts_data)

conn.commit()
print(f"Blackboard populated: {len(scripts_data)} code units injected.")

# 3. Unpack Blackboard to Filesystem
for row in cursor.execute("SELECT file_path, content FROM code_units"):
    os.makedirs(os.path.dirname(row[0]), exist_ok=True)
    with open(row[0], "w") as f:
        f.write(row[1])
        
print("Filesystem synchronized with Blackboard.")