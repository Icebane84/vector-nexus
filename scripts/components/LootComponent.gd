extends Node
class_name LootComponent
@export var xp_value: int = 25
@export var loot_table: Array[ItemData] = []
@export_range(0, 1) var drop_chance: float = 0.5
func spawn_loot() -> void:
	# 1. Award XP via Global Event Bus
	GameEvents.enemy_killed.emit(&"orc", xp_value) 
	# 2. Physical Drop Logic
	if randf() <= drop_chance and loot_table.size() > 0:
		var item = loot_table.pick_random()
		_drop_physical_item(item)
func _drop_physical_item(data: ItemData) -> void:
	# In a full game, you'd spawn a "Pickup" scene here
	print("Phoenix Loot: Dropped ", data.display_name)