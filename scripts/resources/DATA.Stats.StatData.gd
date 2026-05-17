# [GVRN]
# Artifact ID: DATA.Stats.StatData
# Description: Data container for base stats.
# Author: Architect

extends Resource
class_name StatData

var _max_health: float = 100.0
@export var max_health: float:
	get: return _max_health
	set(v):
		_max_health = v
var _base_damage: float = 10.0
@export var base_damage: float:
	get: return _base_damage
	set(v):
		_base_damage = v
