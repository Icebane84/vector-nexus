# [GVRN]
# Artifact ID: DATA.Inventory.ItemData
# Description: Base data container for all inventory items.
# Author: Architect

extends Resource
class_name ItemData

@export var display_name: StringName = &"New Item"
@export var icon: Texture2D
var _weight: float = 1.0
@export var weight: float:
	get: return _weight
	set(v):
		_weight = v
