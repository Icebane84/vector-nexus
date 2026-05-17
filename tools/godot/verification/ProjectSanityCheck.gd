# scripts/tools/ProjectSanityCheck.gd
extends SceneTree

## PHOENIX_CODEX: v4.4.0 - Sovereign Synthesis Audit (Orchestrator)
## Usage: godot -s scripts/tools/ProjectSanityCheck.gd

const InfraAudit = preload("res://tools/godot/lib/Audit.Infrastructure.gd")
const EntityAudit = preload("res://tools/godot/lib/Audit.Entities.gd")

func _initialize() -> void:
	print("--- PHOENIX_LOG: BEGINNING SOVEREIGN SANITY CHECK ---")
	_run_audit()

func _run_audit() -> void:
	var target_root: Node = _find_audit_root()
	
	InfraAudit.check_autoloads()
	InfraAudit.check_types()
	
	_run_scene_audits(target_root)

	print("--- PHOENIX_LOG: SANITY CHECK COMPLETE (PHOENIX-GREEN) ---")
	quit(0)

func _find_audit_root() -> Node:
	if root.get_child_count() > 0:
		return root.get_child(0)

	var main_scene: PackedScene = load("res://scenes/world/Main.tscn") as PackedScene
	if main_scene: 
		return main_scene.instantiate() as Node

	return null


func _run_scene_audits(target_root: Node) -> void:
	if not target_root:
		print("PHOENIX_LOG: Skipping scene-based audits due to missing root.")
		return

	EntityAudit.audit_collision_identity(target_root)

	if target_root.name == "Main" or target_root.has_node("Player"):
		EntityAudit.audit_sovereign_scene(target_root)
	elif target_root is CharacterBody3D:
		EntityAudit.audit_player(target_root)
	else:
		EntityAudit.audit_generic(target_root)
