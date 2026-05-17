import os

# 1. Path Resolution: Use OS-agnostic pathing
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if "_" in PROJECT_ROOT:
    PROJECT_ROOT = os.path.abspath(os.path.join(os.getcwd(), "..", ".."))

# Standardized Resource Paths
ext_resources = {
    "Player": "res://scripts/entities/player/Player.gd",
    "PlayerCamera": "res://scripts/entities/player/PlayerCamera.gd",
    "HealthComponent": "res://scripts/components/HealthComponent.gd",
    "StaminaComponent": "res://scripts/components/StaminaComponent.gd",
    "PoiseComponent": "res://scripts/components/PoiseComponent.gd",
    "HitboxComponent": "res://scripts/components/HitboxComponent.gd",
    "HurtboxComponent": "res://scripts/components/HurtboxComponent.gd",
    "StateMachine": "res://scripts/components/state_machine/StateMachine.gd",
    "PlayerIdleState": "res://scripts/entities/player/states/PlayerIdleState.gd",
    "PlayerMoveState": "res://scripts/entities/player/states/PlayerMoveState.gd",
    "PlayerAttackState": "res://scripts/entities/player/states/PlayerAttackState.gd",
    "PlayerDodgeState": "res://scripts/entities/player/states/PlayerDodgeState.gd",
    "PlayerParryState": "res://scripts/entities/player/states/PlayerParryState.gd",
    "EnemyBase": "res://scripts/entities/enemies/EnemyBase.gd",
    "NavigationComponent": "res://scripts/components/NavigationComponent.gd",
    "AIChaseState": "res://scripts/entities/enemies/states/AIChaseState.gd",
    "AIAttackState": "res://scripts/entities/enemies/states/AIAttackState.gd",
}


def generate_ext_resources_block(keys):
    block = ""
    for idx, key in enumerate(keys, start=1):
        block += f'[ext_resource type="Script" path="{ext_resources[key]}" id="{idx}_{key}"]\n'
    return block


# 2. Construct Player.tscn
player_keys = [
    "Player",
    "PlayerCamera",
    "HealthComponent",
    "StaminaComponent",
    "PoiseComponent",
    "HitboxComponent",
    "HurtboxComponent",
    "StateMachine",
    "PlayerIdleState",
    "PlayerMoveState",
    "PlayerAttackState",
    "PlayerDodgeState",
    "PlayerParryState",
]

player_tscn = f"""[gd_scene load_steps={len(player_keys) + 2} format=3]

{generate_ext_resources_block(player_keys)}
[sub_resource type="CapsuleShape3D" id="CapsuleShape3D_player"]

[node name="Player" type="CharacterBody3D" groups=["player"]]
script = ExtResource("1_Player")
state_machine = NodePath("StateMachine")
camera = NodePath("CameraPivot/PlayerCamera")
visuals = NodePath("Visuals")

[node name="Collision" type="CollisionShape3D" parent="."]
unique_name_in_owner = true
shape = SubResource("CapsuleShape3D_player")

[node name="Visuals" type="Node3D" parent="."]

[node name="PlayerVisuals" type="Node3D" parent="Visuals"]

[node name="AnimationPlayer" type="AnimationPlayer" parent="Visuals/PlayerVisuals"]

[node name="CameraPivot" type="Node3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.5, 0)

[node name="PlayerCamera" type="SpringArm3D" parent="CameraPivot"]
script = ExtResource("2_PlayerCamera")
spring_length = 4.0

[node name="Camera3D" type="Camera3D" parent="CameraPivot/PlayerCamera"]

[node name="HealthComponent" type="Node" parent="."]
script = ExtResource("3_HealthComponent")

[node name="StaminaComponent" type="Node" parent="."]
script = ExtResource("4_StaminaComponent")

[node name="PoiseComponent" type="Node" parent="."]
script = ExtResource("5_PoiseComponent")

[node name="HurtboxComponent" type="Area3D" parent="."]
script = ExtResource("7_HurtboxComponent")
team_id = 0

[node name="CollisionShape3D" type="CollisionShape3D" parent="HurtboxComponent"]
shape = SubResource("CapsuleShape3D_player")

[node name="HitboxComponent" type="Area3D" parent="."]
script = ExtResource("6_HitboxComponent")
team_id = 0

[node name="StateMachine" type="Node" parent="."]
script = ExtResource("8_StateMachine")
initial_state = NodePath("Idle")

[node name="Idle" type="Node" parent="StateMachine"]
script = ExtResource("9_PlayerIdleState")

[node name="Move" type="Node" parent="StateMachine"]
script = ExtResource("10_PlayerMoveState")

[node name="Attack" type="Node" parent="StateMachine"]
script = ExtResource("11_PlayerAttackState")

[node name="Dodge" type="Node" parent="StateMachine"]
script = ExtResource("12_PlayerDodgeState")

[node name="Parry" type="Node" parent="StateMachine"]
script = ExtResource("13_PlayerParryState")
"""

# 3. Construct EnemyBase.tscn
enemy_keys = [
    "EnemyBase",
    "HealthComponent",
    "NavigationComponent",
    "HurtboxComponent",
    "StateMachine",
    "AIChaseState",
    "AIAttackState",
]

enemy_tscn = f"""[gd_scene load_steps={len(enemy_keys) + 2} format=3]

{generate_ext_resources_block(enemy_keys)}
[sub_resource type="CapsuleShape3D" id="CapsuleShape3D_enemy"]

[node name="EnemyBase" type="CharacterBody3D" groups=["enemy"]]
script = ExtResource("1_EnemyBase")
state_machine = NodePath("StateMachine")
nav_comp = NodePath("NavigationComponent")

[node name="Collision" type="CollisionShape3D" parent="."]
shape = SubResource("CapsuleShape3D_enemy")

[node name="Visuals" type="Node3D" parent="."]

[node name="AnimationPlayer" type="AnimationPlayer" parent="Visuals"]

[node name="HealthComponent" type="Node" parent="."]
script = ExtResource("2_HealthComponent")

[node name="NavigationComponent" type="Node" parent="."]
script = ExtResource("3_NavigationComponent")

[node name="NavigationAgent3D" type="NavigationAgent3D" parent="NavigationComponent"]

[node name="HurtboxComponent" type="Area3D" parent="."]
script = ExtResource("4_HurtboxComponent")
team_id = 1

[node name="CollisionShape3D" type="CollisionShape3D" parent="HurtboxComponent"]
shape = SubResource("CapsuleShape3D_enemy")

[node name="StateMachine" type="Node" parent="."]
script = ExtResource("5_StateMachine")
initial_state = NodePath("AIChaseState")

[node name="AIChaseState" type="Node" parent="StateMachine"]
script = ExtResource("6_AIChaseState")

[node name="AIAttackState" type="Node" parent="StateMachine"]
script = ExtResource("7_AIAttackState")
"""

# 4. Construct Main.tscn
main_tscn = """[gd_scene load_steps=3 format=3]

[ext_resource type="PackedScene" path="res://scenes/entities/Player.tscn" id="1_player"]
[ext_resource type="PackedScene" path="res://scenes/entities/EnemyBase.tscn" id="2_enemy"]

[node name="Main" type="Node3D"]

[node name="WorldEnvironment" type="WorldEnvironment" parent="."]

[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 0.707107, 0.707107, 0, -0.707107, 0.707107, 0, 10, 0)

[node name="Environment" type="Node3D" parent="."]

[node name="Floor" type="CSGBox3D" parent="Environment"]
use_collision = true
size = Vector3(50, 1, 50)

[node name="Player" parent="." instance=ExtResource("1_player")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.5, 0)

[node name="EnemyBase" parent="." instance=ExtResource("2_enemy")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 5, 1.5, 5)
"""

# 5. Write to Filesystem
OUTPUT_DIR = os.path.join(os.getcwd(), "scenes", "entities")
WORLD_DIR = os.path.join(os.getcwd(), "scenes", "world")
os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(WORLD_DIR, exist_ok=True)

with open(os.path.join(OUTPUT_DIR, "Player.tscn"), "w") as f:
    f.write(player_tscn)

with open(os.path.join(OUTPUT_DIR, "EnemyBase.tscn"), "w") as f:
    f.write(enemy_tscn)

with open(os.path.join(WORLD_DIR, "Main.tscn"), "w") as f:
    f.write(main_tscn)

print(f"TSCN Scene Topologies successfully generated in: {OUTPUT_DIR} and {WORLD_DIR}")
