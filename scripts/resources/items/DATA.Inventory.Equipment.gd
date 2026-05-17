# [GVRN]
# Artifact ID: DATA.Inventory.Equipment
# Description: Data container for equippable items.
# Author: Architect

extends ItemData
class_name EquipmentData

@export var slot: T.EquipmentSlot
var _damage_modifier: float = 1.0
@export var damage_modifier: float:
	get: return _damage_modifier
	set(v):
		_damage_modifier = v
@export var visual_mesh: PackedScene
