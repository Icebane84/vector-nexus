# [GVRN]
# CollisionAudit.gd (v28.1)
# Purpose: Verify Physics Layers and Scene Hierarchy.
extends SceneTree

# RUN: godot --headless -s scripts/tools/CollisionAudit.gd

func _init() -> void:
	print("\n--- [PHOENIX AUDIT: Physics Feedback Loop] ---")
	
	var player_scene: PackedScene = load("res://scenes/entities/Player.tscn") as PackedScene
	if not player_scene:
		print("❌ Error: Player scene not found.")
		quit(1)
		return

	var player: CharacterBody3D = player_scene.instantiate() as CharacterBody3D
	var camera_root: Node3D = player.get_node("CameraRoot") as Node3D
	var spring_arm: SpringArm3D = camera_root.get_node("SpringArm3D") as SpringArm3D

	print("Checking Player Logic...")
	if player is CharacterBody3D:
		print("✅ Player is CharacterBody3D.")
	else:
		print("❌ Player is NOT CharacterBody3D.")

	print("\nAuditing Physics Layers...")
	
	# Current State Audit
	var p_layer: int = player.collision_layer
	var s_mask: int = spring_arm.collision_mask
	
	print("Player Collision Layer: ", p_layer)
	print("SpringArm Collision Mask: ", s_mask)


	if (p_layer & s_mask) != 0:
		print("\n🔴 CRITICAL: PHYSICAL OVERLAP DETECTED.")
		print("The SpringArm3D is masking for the same layer as the Player.")
		print("Result: The camera probe will physically 'hit' the player mesh, causing jitter.")
	else:
		print("\n🟢 Physics Layers are decoupled.")

	print("\nVerifying Hierarchy...")
	if camera_root.top_level:
		print("✅ CameraRoot is set to top_level.")
	else:
		print("⚠️ Warning: CameraRoot is not top_level. Transform jitter likely.")

	print("\nAudit Complete. Recommendation: Configure Player to Layer 2 and SpringArm to Mask Layer 1 only.")
	quit(0)
