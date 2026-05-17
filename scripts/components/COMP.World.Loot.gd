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
	# In a full game, you'd spawn a "Pickup" scene here
	print("Phoenix Loot: Dropped ", data.display_name)
