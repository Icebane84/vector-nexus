# scripts/tools/lib/Audit.Entities.gd
extends RefCounted

## PHOENIX: Entity and Scene Auditor

static func audit_collision_identity(root_node: Node) -> void:
	print("PHOENIX_LOG: Auditing Collision Identity...")
	var layers: String = ProjectSettings.get_setting("layer_names/3d_physics/layer_1") as String
	if layers != "Environment":
		print("  [!] LAYER MISMATCH: Layer 1 should be 'Environment'.")
	
	var player: Node = root_node.find_child("Player", true, false)
	if player and not player.is_in_group("player"):
		print("  [!] MISSING GROUP: Player not in 'player' group.")

static func audit_player(p: Node) -> void:
	print("PHOENIX_LOG: Auditing Player Entity...")
	_check_component(p, "HealthComponent")
	_check_component(p, "StaminaComponent")
	_check_component(p, "PoiseComponent")

static func audit_sovereign_scene(m: Node) -> void:
	print("PHOENIX_LOG: Auditing World Substrate...")
	var player: Node = m.find_child("Player", true, false)
	if player:
		audit_player(player)


static func audit_generic(n: Node) -> void:
	for child in n.get_children():
		if child is CharacterBody3D: audit_player(child)
		audit_generic(child)

static func _check_component(parent: Node, component: String) -> void:
	if not parent.has_node(component):
		print("  [!] MISSING COMPONENT: ", component)
