import os

# 1. Define ExtResource mappings based on our Blackboard
ext_resources = {
    "Player": "res://scripts/entities/player/Player.gd",
    "PlayerCamera": "res://scripts/entities/player/PlayerCamera.gd",
    "HealthComponent": "res://scripts/components/HealthComponent.gd",
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
    "AIAttackState": "res://scripts/entities/enemies/states/AIAttackState.gd"
}

def generate_ext_resources_block(keys):
    block = ""
    for idx, key in enumerate(keys, start=1):
        block += f'[ext_resource type="Script" path="{ext_resources[key]}" id="{idx}_{key}"]\n'
    return block

# 2. Construct Player.tscn
player_keys =["Player", "PlayerCamera", "HealthComponent", "PoiseComponent", 
               "HitboxComponent", "HurtboxComponent", "StateMachine", 
               "PlayerIdleState", "PlayerMoveState", "PlayerAttackState", 
               "PlayerDodgeState", "PlayerParryState"]

player_tscn = f"""[gd_scene load_steps={len(player_keys)+2} format=3]

{generate_ext_resources_block(player_keys)}[sub_resource type="CapsuleShape3D" id="CapsuleShape3D_player"]

[node name="Player" type="CharacterBody3D"]
script = ExtResource("1_Player")
state_machine = NodePath("StateMachine")
camera = NodePath("CameraPivot")
visuals = NodePath("Visuals")[node name="Collision" type="CollisionShape3D" parent="."]
unique_name_in_owner = true
shape = SubResource("CapsuleShape3D_player")

[node name="Visuals" type="Node3D" parent="."][node name="AnimationPlayer" type="AnimationPlayer" parent="Visuals"][node name="CameraPivot" type="SpringArm3D" parent="."]
script = ExtResource("2_PlayerCamera")[node name="Camera3D" type="Camera3D" parent="CameraPivot"][node name="HealthComponent" type="Node" parent="."]
script = ExtResource("3_HealthComponent")[node name="PoiseComponent" type="Node" parent="."]
script = ExtResource("4_PoiseComponent")[node name="HurtboxComponent" type="Area3D" parent="."]
script = ExtResource("6_HurtboxComponent")
team_id = 0[node name="CollisionShape3D" type="CollisionShape3D" parent="HurtboxComponent"]
shape = SubResource("CapsuleShape3D_player")[node name="HitboxComponent" type="Area3D" parent="."]
script = ExtResource("5_HitboxComponent")
team_id = 0

[node name="StateMachine" type="Node" parent="."]
script = ExtResource("7_StateMachine")
initial_state = NodePath("PlayerIdleState")[node name="PlayerIdleState" type="Node" parent="StateMachine"]
script = ExtResource("8_PlayerIdleState")[node name="PlayerMoveState" type="Node" parent="StateMachine"]
script = ExtResource("9_PlayerMoveState")

[node name="PlayerAttackState" type="Node" parent="StateMachine"]
script = ExtResource("10_PlayerAttackState")[node name="PlayerDodgeState" type="Node" parent="StateMachine"]
script = ExtResource("11_PlayerDodgeState")[node name="PlayerParryState" type="Node" parent="StateMachine"]
script = ExtResource("12_PlayerParryState")
"""

# 3. Construct EnemyBase.tscn
enemy_keys =["EnemyBase", "HealthComponent", "NavigationComponent", "HurtboxComponent", "StateMachine", "AIChaseState", "AIAttackState"]

enemy_tscn = f"""[gd_scene load_steps={len(enemy_keys)+2} format=3]

{generate_ext_resources_block(enemy_keys)}[sub_resource type="CapsuleShape3D" id="CapsuleShape3D_enemy"][node name="EnemyBase" type="CharacterBody3D"]
script = ExtResource("1_EnemyBase")
state_machine = NodePath("StateMachine")
nav_comp = NodePath("NavigationComponent")[node name="Collision" type="CollisionShape3D" parent="."]
shape = SubResource("CapsuleShape3D_enemy")[node name="Visuals" type="Node3D" parent="."][node name="AnimationPlayer" type="AnimationPlayer" parent="Visuals"]

[node name="HealthComponent" type="Node" parent="."]
script = ExtResource("2_HealthComponent")

[node name="NavigationComponent" type="Node" parent="."]
script = ExtResource("3_NavigationComponent")[node name="NavigationAgent3D" type="NavigationAgent3D" parent="NavigationComponent"][node name="HurtboxComponent" type="Area3D" parent="."]
script = ExtResource("4_HurtboxComponent")
team_id = 1

[node name="CollisionShape3D" type="CollisionShape3D" parent="HurtboxComponent"]
shape = SubResource("CapsuleShape3D_enemy")[node name="StateMachine" type="Node" parent="."]
script = ExtResource("5_StateMachine")
initial_state = NodePath("AIChaseState")

[node name="AIChaseState" type="Node" parent="StateMachine"]
script = ExtResource("6_AIChaseState")[node name="AIAttackState" type="Node" parent="StateMachine"]
script = ExtResource("7_AIAttackState")
"""

# 4. Write to Filesystem
os.makedirs("/root/project/scenes/entities/", exist_ok=True)

with open("/root/project/scenes/entities/Player.tscn", "w") as f:
    f.write(player_tscn)
    
with open("/root/project/scenes/entities/EnemyBase.tscn", "w") as f:
    f.write(enemy_tscn)

print("TSCN Scene Topologies successfully generated.")