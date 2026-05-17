"""
[GVRN] [FABRIC] [SYSTEM]
Artifact ID:   FABRIC.System.VFXPool
Description:   Object-pool for visual effects. Listens to vfx_requested on
               GameEvents and spawns/recycles effect nodes from a pool.
Version:       1.0 [STUB – Prototype Safe]
Relationships: GOVERNED_BY(Director), LISTENS(GameEvents.vfx_requested)
Status:        [PROTOTYPE]

[Wisdom Scar / Why this exists]:
  Player.execute_shadow_attack() emits GameEvents.instance.vfx_requested("shadow_ghost", pos).
  Without this autoload present, Godot throws a 'File not found' parse error on any
  scene that holds a reference to this script, preventing the project from loading.
  This stub satisfies the reference while the full pooling system is designed later.
"""

extends Node
class_name VFXPool

# PHOENIX-GVRN: Pool registry — effect_name → PackedScene
var _pool: Dictionary = {}

func _ready() -> void:
	if GameEvents.instance:
		GameEvents.instance.vfx_requested.connect(_on_vfx_requested)

# --- Public API ---

func register_effect(effect_name: String, scene: PackedScene) -> void:
	_pool[effect_name] = scene

# --- Internal ---

func _on_vfx_requested(effect_name: String, world_position: Vector3) -> void:
	if not _pool.has(effect_name):
		# [Prototype]: No scene registered yet – print a dev notice and bail gracefully.
		print("[VFXPool] DEV: No scene registered for '%s'. Skipping." % effect_name)
		return

	var instance: Node3D = _pool[effect_name].instantiate()
	get_tree().current_scene.add_child(instance)
	instance.global_position = world_position
