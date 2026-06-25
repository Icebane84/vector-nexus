# [GVRN]
# Artifact ID: DATA.Inventory.ConsumableItem
# Description: Data container for consumable items like potions and firebombs.

extends ItemData
class_name ConsumableItem

enum ConsumableType { HEAL, DAMAGE }

var _consumable_type: ConsumableType = ConsumableType.HEAL
@export var consumable_type: ConsumableType:
	get: return _consumable_type
	set(v): _consumable_type = v

var _potency: float = 40.0
@export var potency: float:
	get: return _potency
	set(v): _potency = maxf(0.0, v)

var _count: int = 5
@export var count: int:
	get: return _count
	set(v): _count = max(0, v)

var _max_count: int = 5
@export var max_count: int:
	get: return _max_count
	set(v): _max_count = max(1, v)

var _physical_instance: PackedScene
@export var physical_instance: PackedScene:
	get: return _physical_instance
	set(v): _physical_instance = v
