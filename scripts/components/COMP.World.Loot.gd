# [GVRN]
# Artifact ID: COMP.World.Loot
# Description: Handles XP awarding and physical item spawning on death.
# Author: Architect

extends Node

class_name LootComponent

signal loot_collected(xp_value: int)

var _xp_value: int = 25
@export var xp_value: int:
	get: return _xp_value
	set(v):
		_xp_value = v
@export var loot_table: Array[ItemData] = []
@export_range(0, 1) var drop_chance: float = 0.5

func spawn_loot() -> void:
	# Emit local signal for loot collection
	loot_collected.emit(xp_value)
	# 2. Physical Drop Logic
	if randf() <= drop_chance and loot_table.size() > 0:
		var item: ItemData = loot_table.pick_random()
		_drop_physical_item(item)

func _drop_physical_item(data: ItemData) -> void:
	var loot_drop_scene = load("res://scenes/ui/LootDrop.tscn")
	if not loot_drop_scene:
		print("PHOENIX_LOG: ERROR - LootDrop.tscn not found.")
		return
	var inst = loot_drop_scene.instantiate() as RigidBody3D
	if inst:
		inst.item_data = data
		var parent = get_parent()
		if parent is Node3D:
			inst.global_position = parent.global_position + Vector3.UP * 0.5
			if parent.get_parent():
				parent.get_parent().add_child(inst)
			else:
				get_tree().current_scene.add_child(inst)

			# Apply physical pop-out impulse (upward and outward random force)
			var force_direction = Vector3(
				randf_range(-1.5, 1.5),
				randf_range(4.0, 6.0),
				randf_range(-1.5, 1.5)
			)
			inst.apply_central_impulse(force_direction)

			# Play spawn audio
			var spawn_sfx = load("res://audio/SoundFX/special/Spawn01.wav") as AudioStream
			if spawn_sfx:
				GameEvents.instance.spatial_sound_requested.emit(spawn_sfx, inst.global_position, 0.0, 0.1)
		else:
			get_tree().current_scene.add_child(inst)
		print("PHOENIX_LOG: Spawned physical loot drop: ", data.display_name)
