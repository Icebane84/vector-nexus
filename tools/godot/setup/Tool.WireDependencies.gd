# [GVRN]
# Artifact ID: Tool.WireDependencies
# Description: Automatically connects exported dependencies in the currently open scene.
@tool
extends EditorScript

const Wiring = preload("res://tools/godot/lib/Wiring.Library.gd")

func _run() -> void:
	var root: Node = EditorInterface.get_edited_scene_root()
	if not root:
		print("PHOENIX_LOG: No scene open in the editor.")
		return
		
	if root is Player:
		_wire_player(root)
	elif root is EnemyBase:
		_wire_enemy(root)
	elif root is RigidBody3D and root.has_node("InteractableComponent"):
		_wire_loot_drop(root)
	elif root.name == "HUD" or root is CanvasLayer:
		_wire_hud(root)

func _wire_player(player: Player) -> void:
	Wiring.wire_player_core(player)
	Wiring.wire_player_combat(player)
	Wiring.wire_player_animation(player)
	print("PHOENIX_LOG: Wired Player.")

func _wire_enemy(enemy: EnemyBase) -> void:
	Wiring.wire_enemy_base(enemy)
	var chase: Node = enemy.get_node_or_null("StateMachine/AIChaseState")
	if chase and enemy.has_node("RayCast3D"):
		chase.set("los_ray", enemy.get_node("RayCast3D"))
	print("PHOENIX_LOG: Wired Enemy.")

func _wire_hud(hud: CanvasLayer) -> void:
	var pause: Node = hud.find_child("PauseMenu", true, false)
	if pause:
		Wiring.wire_hud_menu(pause, {"resume_button": "ResumeButton", "quit_button": "QuitButton"})
	var main: Node = hud.find_child("MainMenu", true, false)
	if main:
		Wiring.wire_hud_menu(main, {"start_button": "StartButton", "quit_button": "QuitButton"})

func _wire_loot_drop(loot: Node) -> void:
	loot.set("interactable_component", loot.get_node_or_null("InteractableComponent"))
